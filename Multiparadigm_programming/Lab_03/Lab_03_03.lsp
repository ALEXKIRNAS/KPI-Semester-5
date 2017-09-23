(defun task (lst) 
        (let ((res nil))    
            (dolist (i lst (reverse res))      
            (if (atom i) (push i res) (push (task (reverse i)) res)))
        )
)

(print (task '(1 ((2 3) 4) 5 6)))
