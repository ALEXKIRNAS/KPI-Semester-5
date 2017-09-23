(defun string-right (s n)
  (subseq s (- (length s) n)))
 
(defun drop-suffix (s v &aux (m (length s)) (n (length (car v))))
  (cond ((null v) s)
        ((string= (string-right s n) (car v)) (subseq s 0 (- m n)))
        ((drop-suffix s (cdr v)))))
 
(defun drop-suffixes (w v &aux (v> (sort v #'string>)))
  (mapcar #'(lambda (s) (drop-suffix s v>)) w))

  
(print (drop-suffixes '("kiamoto") '("moto" "iamoto")))