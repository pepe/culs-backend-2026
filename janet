# =====================================================
# Interactive Quiz Game in Janet
# =====================================================
# IMPORTANT: Save this file as quiz_interactive.janet
# and run it with:  janet quiz_interactive.janet
# =====================================================

# --- Quiz Questions Data ---
# Each question is a table with:
#   :question   - the question text
#   :options    - array of 4 answer choices
#   :correct    - index of the correct answer (0-based)
#   :difficulty - :easy, :medium, or :hard

(def quiz-questions
  [{:question "What is the capital of France?"
    :options ["London" "Berlin" "Paris" "Madrid"]
    :correct 2
    :difficulty :easy}

   {:question "What is 15 * 4?"
    :options ["50" "60" "70" "80"]
    :correct 1
    :difficulty :easy}

   {:question "In what year did the Titanic sink?"
    :options ["1912" "1920" "1905" "1915"]
    :correct 0
    :difficulty :hard}

   {:question "What is the largest ocean on Earth?"
    :options ["Atlantic" "Indian" "Arctic" "Pacific"]
    :correct 3
    :difficulty :medium}

   {:question "What is the chemical symbol for Gold?"
    :options ["Go" "Gd" "Au" "Ag"]
    :correct 2
    :difficulty :medium}

    {:question "Which planet is closest to the Sun?"
    :options ["Venus" "Mercury" "Earth" "Mars"]
    :correct 1
    :difficulty :medium}

    {:question "Pepe is Gen __?"
    :options ["X" "Y" "Z" "Alpha"]
    :correct 0
    :difficulty :easy}

    {:question "Which language did Pepe refer to as 'Cancer'?"
    :options ["Janet" "Lua" "Clojure" "JavaScript"]
    :correct 3
    :difficulty :medium}

    {:question "One of Pepe's favorite quotes if from who?"
    :options ["Socrates" "Bob Marley" "Elon Musk" "Mohammed Ali"]
    :correct 3
    :difficulty :hard}

    {:question "Who is 'Donny' in the live hacking Pepe demoed?"
    :options ["His friend" "His Nephew" "Trump" "His dog"]
    :correct 2
    :difficulty :medium}])

# --- Seeded RNG ---
# math/random always produces the same sequence unless we seed it with the
# current time. We create one global RNG object seeded from os/time.
(def rng (math/rng (os/time)))

# --- Fisher-Yates Shuffle (using seeded RNG) ---
(defn shuffle [arr]
  (let [result (array ;arr)]
    (var i (- (length result) 1))
    (while (>= i 1)
      # math/rng-int gives a random integer in [0, n)
      (let [j (math/rng-int rng (+ i 1))
            tmp (get result i)]
        (put result i (get result j))
        (put result j tmp))
      (-- i))
    result))

# --- Display a Question ---
(defn display-question [q num total]
  (print "")
  (print (string/repeat "=" 50))
  (printf " Question %d of %d  [%s]" num total (q :difficulty))
  (print (string/repeat "=" 50))
  (print (q :question))
  (print "")
  (var i 0)
  (each opt (q :options)
    (printf "  %d. %s" (+ i 1) opt)
    (++ i)))

# --- Get the User's Answer ---
(defn get-answer []
  (prin "Your answer (1-4): ")
  (flush)
  (def line (getline))
  (if (nil? line)
    nil
    (let [trimmed (string/trim line)
          n (scan-number trimmed)]
      (if (and n (>= n 1) (<= n 4))
        (- n 1)   # convert to 0-based index
        (do
          (print "Please enter a number between 1 and 4.")
          (get-answer))))))  # ask again if invalid

# --- Score Feedback ---
(defn score-message [score total]
  (let [pct (* 100 (/ score total))]
    (cond
      (>= pct 100) "Perfect score! Outstanding!"
      (>= pct 80)  "Great job! Almost perfect!"
      (>= pct 60)  "Not bad! Practice makes perfect."
      (>= pct 40)  "Keep studying, you'll get there!"
      "Better luck next time!")))

# --- Ask Play Again ---
(defn ask-play-again []
  (print "")
  (print "----------------------------------------")
  (prin "Play again? (y/n): ")
  (flush)
  (def line (getline))
  (if (nil? line)
    false
    (let [answer (string/trim (string/ascii-lower line))]
      (cond
        (= answer "y") true
        (= answer "n") false
        (do
          (print "  Please enter y or n.")
          (ask-play-again))))))

# --- One Round of the Quiz ---
(defn play-round []
  (def questions (shuffle quiz-questions))
  (def total (length questions))
  (printf "\nTotal Questions: %d\n" total)

  (var score 0)
  (var i 0)
  (var aborted false)

  (while (< i total)
    (def q (get questions i))
    (display-question q (+ i 1) total)
    (def answer (get-answer))

    (if (nil? answer)
      (do (set aborted true) (break)))

    (if (= answer (q :correct))
      (do
        (print "\n  Correct!")
        (++ score))
      (printf "\n  Incorrect. The correct answer was: %s"
              (get (q :options) (q :correct))))

    (++ i))

  (when (not aborted)
    (print "")
    (print "╔════════════════════════════════════════════════╗")
    (print "║                 Quiz Complete!                 ║")
    (print "╚════════════════════════════════════════════════╝")
    (printf "\nFinal Score: %d/%d (%.1f%%)" score total (* 100 (/ score total)))
    (print "")
    (print (score-message score total)))

  (not aborted))

# --- Main Loop (supports play-again) ---
(defn run-game []
  (print "")
  (print "╔════════════════════════════════════════════════╗")
  (print "║         Welcome to the Quiz Game!              ║")
  (print "╚════════════════════════════════════════════════╝")

  (var keep-playing true)
  (while keep-playing
    (def completed (play-round))
    (if completed
      (set keep-playing (ask-play-again))
      (set keep-playing false)))

  (print "")
  (print "Thanks for playing! Goodbye!"))

# --- Start ---
(run-game)
