(defun my_eval (loc_form &optional (loc_links nil))
     (cond
        ((atom loc_form)
            (cond
                ((eq loc_form 't1) 't1)
                ((eq loc_form 'nil) 'nil1)
                ((numberp loc_form) loc_form)
                ((car (assoc loc_form loc_links)))
                (t (format t
                    "~%In atom absent local link: ~S"
                    loc_form))
        ((atom (car loc_form))
            (cond
                ((eq (car loc_form) 'quote1)
                    (cadr loc_form))
                ((eq (car loc_form) 'cond1)
                    (eval-cond (cdr loc_form) loc_links))
                ((get (car loc_form) 'fn)
                    (my_apply (get (car loc_form) 'fn)
                        (eval-list (cdr loc_form)
                                loc_links)
                        loc_links))
                    (t (my_apply (car loc_form)
                        (eval-list (cdr loc_form)
                                loc_links)
                        loc_links))))
        (t (my_apply (car loc_form)
                (eval-list (cdr loc_form) loc_links)
                loc_links)))))
)
                
(defun eval-cond (branches context)
	(cond
		((null branches) 'nil1)
		((not (eq (my_eval (caar branches) context)
					'nil1))
			(my_eval (cadar branches) context))
		(t (eval-cond (cdr branches) context)))
)

(defun unite (w v)
  (cond ((null w)  v)
    ((member (car w) v) (union (cdr w) v))
    ((cons (car w) (union (cdr w) v))))
)

(defun my_apply (func arg loc_links)
	(cond ((atom func)
		(cond
			((eq func 'car1)
				(cond ((eq (car arg) 'nil1)
						'nil1)
						(t (caar arg))))
			((eq func 'cdr1)
				(cond ((eq (car arg) 'nil1)
						'nil1)
						((null (cdar arg))
						'nil1)
						(t (cdar arg))))
			((eq func 'cons1)
				(cond ((eq (cadr arg)
							'nil1)
						(list (car arg)))
						(t (cons (car arg)
							(cadr arg)))))
			((eq func 'atom1)
				(cond ((atom (car arg))
								't1)
						(t 'nil1)))
			((eq func 'equal1)
				(cond ((equal (car arg)
							(cadr arg))
						't1)
						(t 'nil1)))
				(t (format t "~%Unkown function:
								~S" func))))
			((eq (car func) 'lambda1)
				(my_eval (caddr func)
					(create-links (cadr func)
						arg loc_links)))
                        
            ((eq (car func) 'unite)
                (unite (caddr func)))
                
			(t (format t
					"~%It's not lambda call: ~S"
					func)))
)

(defun create-links
		(loc_forms params env)
	(cond
		((null loc_forms) env)
		(t (acons (car loc_forms)
					(car params)
					(create-links (cdr loc_forms)
								(cdr params)
								env))))
)

(defun eval-list (params loc_links)
	(cond
		((null params) nill)
		(t (cons
				(my_eval (car params) loc_links)
				(eval-list (cdr params)
								loc_links))))
)



(print (unite '(3 5 7) '(3 5 8)))
