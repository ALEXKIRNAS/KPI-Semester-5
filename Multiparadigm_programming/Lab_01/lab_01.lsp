;gnu clisp 2.49

(setq LIST_1 '(T Y D E F (NL KM LM) JK))
(setq LIST_2 '(+ 2 3))
(setq LIST_3 '(* (+ 6 8) (- 70 8)))

(print (LIST (CAR LIST_1) (CAR LIST_2) (CAR LIST_3)))

(DEFUN CONCAT_LISTS
       (L1 L2 L3) 
       (list (NTH 6 L1) (NTH 2 L2) (NTH 2 L3))
)
(print (CONCAT_LISTS LIST_1 LIST_2 LIST_3))


(DEFUN SIGN_CHAR
       (NUMBER)
       (COND ((= (SIGNUM NUMBER) -1) '-)
             (T '+)
        )
)

(DEFUN DESCRIBE_NUMBER 
       (NUMBER)
       (LIST (SIGN_CHAR NUMBER) (ABS NUMBER) (ROUND NUMBER))
)
(print (DESCRIBE_NUMBER 10.36))
(print (DESCRIBE_NUMBER -11.56))
