(DEFUN SIGN_CHAR
       (NUMBER)
       (if (= (SIGNUM NUMBER) -1) 
           '- 
           '+
        )
)

(DEFUN DESCRIBE_NUMBER 
       (NUMBER)
       (LIST (SIGN_CHAR NUMBER) (ABS NUMBER) (ROUND NUMBER))
)
(print (DESCRIBE_NUMBER 10.36))
(print (DESCRIBE_NUMBER -11.56))
