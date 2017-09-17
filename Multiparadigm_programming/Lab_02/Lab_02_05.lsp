;TASK #5
(DEFUN rotate
      (l n)
      (APPEND (NTHCDR n l) (butlast l (- (LENGTH l) n)))
)


(DEFUN rotate_all 
    (lst n cum_sum)
    (COND ((NULL lst) (LIST cum_sum))
          ((NULL (NTH n (CAR lst))) nil)
          (T (APPEND (rotate_all (CDR lst) 0 (APPEND cum_sum (LIST (rotate (CAR lst) n)))) 
                     (rotate_all lst (+ n 1) cum_sum)))
     )
)


(DEFUN rotate_all_wrapper 
        (lst)
        (rotate_all lst 0 nil)
)


(print (rotate_all_wrapper '((a b) (c d))))