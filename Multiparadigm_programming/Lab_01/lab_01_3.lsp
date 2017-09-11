(DEFUN SIGN_CHAR
       (NUMBER)
       (COND ((= (SIGNUM NUMBER) -1) '-)
             (T '+)
        )
)

(print (DESCRIBE_NUMBER 10.36))
(print (DESCRIBE_NUMBER -11.56))
