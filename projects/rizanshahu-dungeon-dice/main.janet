(import json)

(defn rand-int [n]
  "Return an integer in [0, n)."
  (math/floor (* (math/random) n)))

(defn clamp [x lo hi]
  (if (< x lo) lo (if (> x hi) hi x)))

(defn prompt [s]
  (print s)
  (flush)
  (or (read-line) ""))

(def score-file "scores.json")

(defn read-scores []
  (try
    (let [data (slurp score-file)]
      (let [obj (json/decode data)]
        (if (table? obj) obj {})))
    ([err] {})))

(defn write-scores [scores]
  (spit score-file (json/encode scores)))

(defn best-score [scores]
  (get scores "best" 0))

(defn maybe-update-best! [scores newscore]
  (let [best (best-score scores)]
    (if (> newscore best)
      (do
        (put scores "best" newscore)
        (write-scores scores)
        true)
      false)))

(defn roll-dice [count sides]
  (var total 0)
  (for i 0 count
    (set total (+ total (+ 1 (rand-int sides)))))
  total)

(defn show-help []
  (print "")
  (print "Commands:")
  (print "  a  attack (deal damage, take some back)")
  (print "  h  heal   (spend gold to restore HP)")
  (print "  r  run    (escape, small penalty)")
  (print "  q  quit")
  (print "  ?  help")
  (print ""))

(defn main []
  (print "=== Dungeon Dice (Janet) ===")
  (print "Survive rooms, earn gold, chase a high score.")
  (print "")

  (def scores (read-scores))
  (print "Current best score: " (best-score scores))
  (show-help)

  (var hp 20)
  (var gold 0)
  (var room 1)
  (var alive true)

  (while alive
    (print "")
    (print "--- Room " room " ---")
    (def monster-hp (+ 6 (rand-int (+ 6 (math/floor (/ room 2))))))
    (def monster-dmg (+ 2 (rand-int (+ 3 (math/floor (/ room 3))))))
    (print "A monster appears! (hp=" monster-hp ", bite=" monster-dmg ")")

    (while (and alive (> monster-hp 0))
      (print "")
      (print "You: hp=" hp "  gold=" gold "  room=" room)
      (print "Monster: hp=" monster-hp)
      (def cmd (string/lower (string/trim (prompt "Choose [a/h/r/q/?]: "))))

      (cond
        (= cmd "?") (show-help)

        (= cmd "q")
        (do
          (print "You leave the dungeon.")
          (set alive false))

        (= cmd "r")
        (do
          (def penalty (clamp (rand-int 3) 0 2))
          (set gold (max 0 (- gold penalty)))
          (print "You run away! Lost " penalty " gold.")
          (set monster-hp 0))

        (= cmd "h")
        (do
          (if (>= gold 3)
            (do
              (set gold (- gold 3))
              (def heal (+ 4 (rand-int 5)))
              (set hp (min 30 (+ hp heal)))
              (print "You heal +" heal " HP (cost 3 gold). Now hp=" hp))
            (print "Not enough gold (need 3).")))

        (= cmd "a")
        (do
          (def you-hit (roll-dice 1 (+ 6 (min 4 (math/floor (/ room 4))))))
          (set monster-hp (- monster-hp you-hit))
          (print "You strike for " you-hit " damage!")

          (when (> monster-hp 0)
            (def back (clamp (+ (rand-int (+ 1 monster-dmg)) 1) 1 99))
            (set hp (- hp back))
            (print "Monster hits back for " back "!")
            (when (<= hp 0)
              (print "You fall...")
              (set alive false))))

        (true
          (print "Unknown command. Type ? for help."))))

    (when alive
      (when (<= hp 0)
        (set alive false))

      (when alive
        (def reward (+ 2 (rand-int (+ 4 (math/floor (/ room 2))))))
        (set gold (+ gold reward))
        (print "")
        (print "Room cleared! You find " reward " gold.")
        (set room (+ room 1))

        ;; small regen every room
        (when (< hp 30)
          (set hp (+ hp 1))
          (print "You catch your breath (+1 hp)."))))

  ;; score = rooms cleared * 10 + gold
  (def score (+ (* (max 0 (- room 1)) 10) gold))
  (print "")
  (print "Final score: " score)

  (if (maybe-update-best! scores score)
    (print "NEW BEST! Saved to " score-file)
    (print "Best remains: " (best-score (read-scores))))

  (print "Thanks for playing!"))

(main)