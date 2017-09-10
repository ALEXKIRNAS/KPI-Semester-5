;gnu clisp 2.49

(setq LIST_1 '(T Y D E F (NL KM LM) JK))
(setq LIST_2 '(+ 2 3))
(setq LIST_3 '(* (+ 6 8) (- 70 8)))

(DEFUN CONCAT_LISTS
       (L1 L2 L3) 
       (list (NTH 6 L1) (NTH 2 L2) (NTH 2 L3))
)
(print (CONCAT_LISTS LIST_1 LIST_2 LIST_3))

