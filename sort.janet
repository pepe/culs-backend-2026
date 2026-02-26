# -------------------------------
# ARRAY SORTING PROGRAM IN JANET
# -------------------------------

(def numbers @[5 2 9 1 7 3 8 4])

(print "Original Array:")
(print numbers)

# Create copies
(def asc (array))
(each n numbers (array/push asc n))

(def desc (array))
(each n numbers (array/push desc n))

# Ascending
(print "\nAscending Order:")
(sort asc)

(each n asc
  (print n))

# Descending
(print "\nDescending Order:")
(sort desc (fn [a b] (> a b)))

(each n desc
  (print n))
