#MIA SHAKIL
#HOSSAIN MD SHAMIM
#MD ABDULLAH AL AMIN SHUVO

(defn main [&]
  (let [secret (+ (math/rng-int (math/rng (os/cryptorand 8)) 100) 1)
        max-attempts 7]

    (var attempts 0) # 'var' defines a mutable variable
    (var won false)

    (while (and (< attempts max-attempts) (not won))
      (prin (string "Attempt " (+ attempts 1) "/" max-attempts " > "))

      (let [input (string/trim (file/read stdin :line))
            guess (scan-number input)]

        (cond
          (nil? guess)
          (print "That's not a number! (This attempt didn't count)")

          (= guess secret)
          (do
            (print "\e[32mCorrect!\e[0m")
            (set won true))

          (do # The 'else' case
            (++ attempts) # Only increment if it was a valid number
            (if (> guess secret)
              (print "Too high!")
              (print "Too low!"))))))

    (if (not won)
      (print "\e[31mGame Over! The number was " secret ".\e[0m"))))