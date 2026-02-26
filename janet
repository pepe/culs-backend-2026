#!/usr/bin/env janet
# Interactive Quiz Game in Janet
# A fun, educational quiz application demonstrating Janet's core features

# Define quiz questions as an array of maps
(def quiz-questions
  [
    {
      :question "What is the capital of France?"
      :options ["London" "Berlin" "Paris" "Madrid"]
      :correct 2
      :difficulty :easy
    }
    {
      :question "What is 15 * 4?"
      :options ["50" "60" "70" "80"]
      :correct 1
      :difficulty :easy
    }
    {
      :question "Which planet is closest to the Sun?"
      :options ["Venus" "Mercury" "Earth" "Mars"]
      :correct 1
      :difficulty :medium
    }
    {
      :question "What is the chemical symbol for Gold?"
      :options ["Go" "Gd" "Au" "Ag"]
      :correct 2
      :difficulty :medium
    }
    {
      :question "In what year did the Titanic sink?"
      :options ["1912" "1920" "1905" "1915"]
      :correct 0
      :difficulty :hard
    }
    {
      :question "What is the largest ocean on Earth?"
      :options ["Atlantic" "Indian" "Arctic" "Pacific"]
      :correct 3
      :difficulty :medium
    }
    {
      :question "Pepe is Gen _?"
      :options ["X" "Y" "Z" "Alpha"]
      :correct 1
      :difficulty :hard
    }
    {
      :question "What language did Pepe refer to as 'Cancer'?"
      :options ["Janet" "Python" "JavaScript" "Clojure"]
      :correct 3
      :difficulty :medium
    }
  ])

# Shuffle an array using Fisher-Yates algorithm
(defn shuffle
  [arr]
  (let [result (array ;arr)]
    (var i (- (length result) 1))
    (while (>= i 0)
      (let [j (math/floor (* (math/random) (+ i 1)))
            temp (get result i)]
        (set (result i) (get result j))
        (set (result j) temp))
      (set i (- i 1)))
    result))

# Display a single question
(defn display-question
  [question-map question-number total-questions]
  (print "\n" "=" 50)
  (printf "Question %d of %d [%s difficulty]\n" 
          question-number total-questions 
          (question-map :difficulty))
  (print "=" 50)
  (print (question-map :question))
  (print "")
  
  # Display options
  (var i 0)
  (while (< i (length (question-map :options)))
    (printf "%d. %s\n" (+ i 1) (get (question-map :options) i))
    (set i (+ i 1))))

# Check if answer is correct and provide feedback
(defn check-answer
  [user-answer correct-answer question-map]
  (let [is-correct (= user-answer correct-answer)
        correct-option (get (question-map :options) correct-answer)]
    (if is-correct
      (do
        (print "✓ Correct!")
        1)
      (do
        (printf "✗ Incorrect. The correct answer is: %s\n" correct-option)
        0))))

# Simulate a quiz with predefined answers
(defn simulate-quiz
  []
  (let [questions quiz-questions
        shuffled (shuffle questions)
        total (length shuffled)
        # Predefined answers for demonstration
        answers [2 1 1 2 0 3]]
    
    (var score 0)
    
    (print "\n")
    (print "╔════════════════════════════════════════════════╗")
    (print "║         Welcome to the Quiz Game! 🎓           ║")
    (print "╚════════════════════════════════════════════════╝")
    (printf "\nTotal Questions: %d\n" total)
    
    (var i 0)
    (while (< i total)
      (let [question (get shuffled i)
            user-answer (get answers i)
            correct-answer (question :correct)
            points (check-answer user-answer correct-answer question)]
        (display-question question (+ i 1) total)
        (printf "\nYour answer: %d\n" (+ user-answer 1))
        (set score (+ score points)))
      (set i (+ i 1)))
    
    # Display final results
    (print "\n")
    (print "╔════════════════════════════════════════════════╗")
    (print "║              Quiz Complete! 🎉                 ║")
    (print "╚════════════════════════════════════════════════╝")
    (printf "\nFinal Score: %d/%d (%.1f%%)\n" 
            score total 
            (* 100 (/ score total)))
    
    # Performance feedback
    (let [percentage (* 100 (/ score total))]
      (cond
        (>= percentage 90) (print "Outstanding! You're a quiz master! 🌟")
        (>= percentage 80) (print "Great job! You know your stuff! 👏")
        (>= percentage 70) (print "Good effort! Keep learning! 📚")
        (>= percentage 60) (print "Not bad! Practice makes perfect! 💪")
        (print "Keep studying! You'll do better next time! 🚀")))
    
    (print "")))

# Run the quiz game
(simulate-quiz)
