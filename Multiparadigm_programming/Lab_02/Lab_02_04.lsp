;TASK #4
(DEFUN merge_LISTs 
    (LIST1 LIST2)
    (COND ((NULL LIST1) LIST2)
          ((NULL LIST2) LIST1)
          ((> (CAR LIST1) (CAR LIST2)) (CONS (CAR LIST2) (merge_LISTs LIST1 (CDR LIST2))))
          (T (CONS (CAR LIST1) (merge_LISTs (CDR LIST1) LIST2)))
     )
)
 
(print (merge_LISTs '(1 2 3) '(1 2 3 4 5)))
