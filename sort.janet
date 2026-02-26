# -------------------------------
# ARRAY SORTING PROGRAM IN JANET
# -------------------------------

# Create an array
(def numbers @[5 2 9 1 7 3 8 4])

(print "Original Array:")
(print numbers)

# -------------------------------
# Ascending Order
# -------------------------------
(print "\nAscending Order:")

(sort numbers)

(for i 0 (- (length numbers) 1)
  (print (get numbers i)))

# -------------------------------
# Descending Order
# -------------------------------
(print "\nDescending Order:")

(sort numbers (fn [a b] (> a b)))

(for i 0 (- (length numbers) 1)
  (print (get numbers i)))
