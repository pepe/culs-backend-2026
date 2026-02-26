(def charset "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*")

# 1. We renamed the argument to 'pass-len' so it doesn't break the built-in 'length' function!
(defn generate-password [pass-len]
  (def rng (math/rng (os/time)))
  (def pass-chars @[])
  
  (for i 0 pass-len
    # 2. Now (length charset) correctly returns 70. 
    # We subtract 1 because Janet starts counting at 0!
    (def random-index (math/rng-int rng (- (length charset) 1)))
    (array/push pass-chars (charset random-index)))
    
  (string/from-bytes ;pass-chars))

(defn main [& args]
  (print "=== Random Password Generator ===")
  (print "How long should the password be? (e.g., 12): ")
  (def input (file/read stdin :line))
  
  (if-let [len (scan-number (string/trim input))]
    (do
      (def password (generate-password len))
      (print "\nYour new password is: " password))
    (print "\nError: Please enter a valid number next time!")))