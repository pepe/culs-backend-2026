(defn read-input [prompt]
  (print prompt)
  (string/trim (file/read stdin :line)))

(defn read-number [prompt]
  (var n nil)
  (while (nil? n)
    (def text (read-input prompt))
    (set n (scan-number text))
    (when (nil? n)
      (print "Please enter a valid number.")))
  n)

(defn calc [op a b]
  (if (= op "+")
    (+ a b)
    (if (= op "-")
      (- a b)
      (if (= op "*")
        (* a b)
        (if (= op "/")
          (if (= b 0)
            "Error: cannot divide by zero"
            (/ a b))
          "Error: unknown operator")))))

(def op (read-input "Enter operator (+, -, *, /): "))
(def a (read-number "Enter first number: "))
(def b (read-number "Enter second number: "))

(print "Result: " (calc op a b))