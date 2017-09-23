(defun deriv (e) 
    (cond ((null e) 0) 
          ((equal e 'x) 1)
          ((atom e) 0)
          ((null (cdr e)) (deriv (car e)))
          ((null (cddr e)); monadic operator +, -, or function id
          (cond ((equal (car e) '+ ) (deriv (cadr e))) ;+
          ((equal (car e) '- ) (list '- (deriv (cadr e))));-
          (t (derfun (car e) (cadr e))) ) ) ; function
          (t (derexpr (car e) (cadr e) (caddr e))) 
    )
)

(defun derexpr (arg1 op arg2 )
    (cond ((equal op '+ ) (deradd arg1 arg2 ))
          ((equal op '- ) (dersub arg1 arg2 ))
          ((equal op '* ) (dermult arg1 arg2))
          ((equal op '/ ) (derdiv arg1 arg2))
          ((equal op '^ ) (derpower arg1 arg2))
          (t (print 'error)) 
    )
)

(defun derfun (fun arg)
    (cond ((equal 'SIN fun) (list (list 'COS arg) '* (deriv arg) ))
          ((equal 'COS fun) (list (list '- (list 'SIN arg)) '*
          (deriv arg) ))
          ((equal 'EXP fun) (list (list 'EXP (list arg)) '*
          (deriv arg) ))
          ((equal 'LOG fun) (list (deriv arg) '/ arg ))
          (t (print 'illegal_function)) 
    )
)

(defun deradd (arg1 arg2)
    (list (deriv arg1) '+ (deriv arg2))
)

(defun dersub (arg1 arg2)
    (list (deriv arg1) '- (deriv arg2))
)

(defun derdiv (arg1 arg2)
    (list (list (list (deriv arg1) '* arg2)
     '- (list arg1 '* (deriv arg2) ))
     '/ (list arg2 '^ '2)
    )
)

(defun dermult (arg1 arg2)
    (list (list (deriv arg1) '* arg2)
     '+ (list arg1 '* (deriv arg2)) 
    )
)

(defun derpower (arg1 arg2)
    (list (list arg1 '^ arg2)
     '* (dermult arg2 (list 'LOG(list arg1)))
    )
)

(print(deriv '(x + 3)))
