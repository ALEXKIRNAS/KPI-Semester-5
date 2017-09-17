;gnu clisp 2.49

;TASK #1
(DEFUN RECURSIVE_REVERSE
       (LIST_TO_REVERSE)
       (COND ((NULL LIST_TO_REVERSE) '())
             ((ATOM LIST_TO_REVERSE) (LIST LIST_TO_REVERSE))
             ((ATOM (CAR LIST_TO_REVERSE)) (APPEND (RECURSIVE_REVERSE (CDR LIST_TO_REVERSE)) (RECURSIVE_REVERSE (CAR LIST_TO_REVERSE)))) 
             (T (APPEND (RECURSIVE_REVERSE (CDR LIST_TO_REVERSE)) (LIST (RECURSIVE_REVERSE (CAR LIST_TO_REVERSE)))))
        )
)

(DEFUN REVERSE_ONLY_LISTS 
       (LST)
       (COND ((NULL LST) '())
             ((ATOM LST) (LIST LST))
             ((ATOM (CAR LST)) (APPEND (REVERSE_ONLY_LISTS (CAR LST)) (REVERSE_ONLY_LISTS (CDR LST))))
             (T (APPEND (LIST (RECURSIVE_REVERSE (CAR LST))) (REVERSE_ONLY_LISTS (CDR LST))))
       )
)

(print (REVERSE_ONLY_LISTS '(1 ((2 3) 4) 5 6)))


;TASK #2
(DEFUN insertion (lst x)
   (COND ((NULL lst) (LIST x))
         ((> (CAR lst) x) (CONS x lst))
         (t (CONS (CAR lst) (insertion (CDR lst) x)))))

(DEFUN isort (x &optional (s nil))
   (COND ((NULL x) s)
         (t (isort (CDR x) (insertion s (CAR x))))))

(DEFUN shell (lst gap finalLIST)
 (COND ((NULL lst) finalLIST)
 (T (COND ((> gap (LENGTH lst)) (APPEND finalLIST (isort lst)))

  (T (APPEND finalLIST (isort (subseq lst 0 gap)) (shell (subseq lst gap (LENGTH lst)) gap finalLIST)))))
 ))

(DEFUN shellSort (lst gaps) 
 (COND ((NULL (CDR gaps)) (shell lst (CAR gaps) '()))
  (T (shellSort (shell lst (CAR gaps) '()) (CDR gaps)))))

(DEFUN SedgewickGaps (len finalLIST) 
 '(1 8 23 77 281 1073 4193 16577 65921 262913 1050113 4197377 16783361 
   67121153 268460033 1073790977 4295065601 17180065793 68719869953 274878693377 
   1099513200641 4398049656833 17592192335873 70368756760577)
)

(DEFUN sortWithShellAndSedgewick (lst) 
 (shellSort lst (SedgewickGaps (LENGTH lst) '(1)))
 )

(print (sortWithShellAndSedgewick '(7 6 5 4 3 1 2 0)))


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