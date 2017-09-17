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
