(defn rand-int [n]
  (math/floor (* (math/random) n)))

(defn roll [sides]
  (+ 1 (rand-int sides)))

(defn clamp [x lo hi]
  (if (< x lo) lo (if (> x hi) hi x)))

(defn run-once [seed]
  # Optional: try to seed if supported; ignore if not.
  (try (math/seedrandom seed) ([err] nil))

  (var hp 20)
  (var gold 0)
  (var room 1)

  (print "=== Dungeon Dice (Simulation) ===")
  (print "Auto-plays 10 rooms (no keyboard input needed).")
  (print "")

  (while (and (> hp 0) (<= room 10))
    (var monster-hp (+ 6 (rand-int (+ 6 (math/floor (/ room 2))))))
    (var monster-dmg (+ 2 (rand-int (+ 3 (math/floor (/ room 3))))))

    (print "--- Room " room " ---")
    (print "Monster: hp=" monster-hp " bite=" monster-dmg)

    (while (and (> hp 0) (> monster-hp 0))
      # You attack
      (var you-hit (+ (roll 6) (min 3 (math/floor (/ room 3)))))
      (set monster-hp (- monster-hp you-hit))
      (print "You hit for " you-hit " -> monster hp=" (max 0 monster-hp))

      (when (> monster-hp 0)
        # Monster attacks back
        (var back (clamp (+ 1 (rand-int (+ 1 monster-dmg))) 1 99))
        (set hp (- hp back))
        (print "Monster hits for " back " -> your hp=" (max 0 hp))))

    (when (> hp 0)
      (var reward (+ 2 (rand-int (+ 4 (math/floor (/ room 2))))))
      (set gold (+ gold reward))

      # Auto-heal rule: if low hp and have gold, spend gold to heal
      (when (and (< hp 12) (>= gold 3))
        (set gold (- gold 3))
        (var heal (+ 4 (rand-int 5)))
        (set hp (min 30 (+ hp heal)))
        (print "Auto-heal +" heal " (cost 3 gold) -> hp=" hp " gold=" gold))

      (print "Room cleared! +" reward " gold. Now gold=" gold)
      (print "")
      (set room (+ room 1))))

  (var rooms-cleared (max 0 (- room 1)))
  (var score (+ (* rooms-cleared 10) gold))

  (print "=== Result ===")
  (print "Rooms cleared: " rooms-cleared "/10")
  (print "HP left: " (max 0 hp))
  (print "Gold: " gold)
  (print "Score: " score)

  score)

(defn main [& args]
  (print "Running 5 simulations...")
  (print "")

  (var best 0)
  (var best-run 1)

  (for i 1 6
    (print "Simulation #" i)
    (var sc (run-once (* i 12345)))
    (print "")
    (when (> sc best)
      (set best sc)
      (set best-run i)))

  (print "=== Best ===")
  (print "Best run: #" best-run)
  (print "Best score: " best))

(main)