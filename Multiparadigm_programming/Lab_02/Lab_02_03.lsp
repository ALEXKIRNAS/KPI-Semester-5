;TASK #3
(DEFUN LIST< (a b)
  (COND
    ((or (NULL a)(NULL b)) NIL)
    (( < a (CAR b)) (LIST< a (CDR b)))
    (t(CONS (CAR b) (LIST< a (CDR b))))))

(DEFUN LIST>= (a b)
  (COND
    ((or (NULL a)(NULL b)) NIL)
    (( >= a (CAR b)) (LIST>= a (CDR b)))
    (T (CONS (CAR b) (LIST>= a (CDR b))))))


(DEFUN qsort (L)
  (COND
    ((NULL L) nil)
    (T (APPEND
        (qsort (LIST< (CAR L) (CDR L)))
        (CONS (CAR L) nil) 
        (qsort (LIST>= (CAR L) (CDR L)))))))

(print (qsort '(1 5 3 8 2)))
