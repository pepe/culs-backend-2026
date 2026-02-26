(math/seedrandom (os/time))

(def secret (+ 1 (math/floor (* 100 (math/random)))))

(print "I have picked a number between 1 and 100.")
(print "Can you guess it?")

(var running true)

(while running 
  (print "Enter your guess: ")

  (def input (string/trim (getline)))
  (def guess (scan-number input))

  (cond
    (nil? guess)      (print "Please enter a real number!")
    (< guess secret)  (print "Higher! ⬆️")
    (> guess secret)  (print "Lower! ⬇️")
    (= guess secret)  (do
                        (print "CORRECT! You won! 🎉")
                        (set running false)))) 