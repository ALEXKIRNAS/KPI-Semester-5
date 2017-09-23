; -------------------------------------------------
; Task 1 

(defun fact (n)
  (cond ((equal n 0) 1)
        (t ((lambda (x y)(* x y))
            n (fact (- n 1))
           )
         )
  )
)

(print (fact 5))

; -------------------------------------------------
; Task 2

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

; -------------------------------------------------
; Task 3

(defun task (lst) 
        (let ((res nil))    
            (dolist (i lst (reverse res))      
            (if (atom i) (push i res) (push (task (reverse i)) res)))
        )
)

(print (task '(1 ((2 3) 4) 5 6)))

; -------------------------------------------------
; Task 4 

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

(print (my_eval 'NILL))

; -------------------------------------------------
; Task 5

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

; -------------------------------------------------
; Task 6

(defun substitute-word (replace_to pattern str)
      (format nil "~{~pattern~^ ~}"
              (substitute
               (read-from-string replace_to)
               (read-from-string pattern)
               (read-from-string
                (concatenate 'string "(" str ")")))
      )
)

(print (substitute "aa" "bb" "aa bb aa cc"))

; -------------------------------------------------
; Task 7

(setq vowels '(а е ё и о у ы э ю я))

(defun splitStr (src pat /)
    (setq wordlist (list))
    (setq len (strlen pat))
    (setq cnt 0)
    (setq letter cnt)
    (while (setq cnt (vl-string-search pat src letter))
        (setq word (substr src (1+ letter) (- cnt letter)))
        (setq letter (+ cnt len))
        (setq wordlist (append wordlist (list word)))
    )
    (setq wordlist (append wordlist (list (substr src (1+ letter)))))
)
 
(defun is_vowels(chr lst_vowels)
  (member chr lst_vowels))
 
(defun ins (s)
      (cond ((is_vowels s vowels) (pack (list s '-)))
            (t s)
       )
)
 
(defun divide_word (word)
    (cond
      ((null word) nil)
      (cons (ins (car word)) (divide_word (cdr word)))
     )
)
 
(defun syllables (txt)
      (mapcar #'(lambda (s) (pack (divide_word (unpack s)))) txt)
)
 
(defun divide_string (txt)
     (mapcar #'(lambda (s) (syllables s)) (splitStr txt))
)

(print '("При" "ве" "т" "ми" "р"))

; -------------------------------------------------
; Task 8

; (deli 'kontti) -> ((#\K #\O) (#\N #\T #\T #\I))
(defun deli (word)
    (deli-slovo nil
    (coerce (string word) 'list)))

(defun deli-slovo (begin end)
    (cond
    ((null end) (list begin end))
    ((sogl? (first end))
    (deli-slovo
    (v-end begin (first end))
    (rest end)))
    ((dolgaya-nach? end)
    (list (append begin
    (list (first end)
    (second end)))
    (cddr end)))
    (t (list (v-end begin (first end))
    (rest end)))))

(defun v-end (spisok element)
    (append spisok (list element)))

(defun glasnaya? (letter)
    (member letter *glas*))
    (setq *glas* '(#\A #\E #\I #\O #\U #\Y #\a #\o));
    (defun sogl? (letter)
    (not (glasnaya? letter)))

(defun dolgaya-nach? (word)
    (and (glasnaya? (first word))
    (eql (first word)
    (second word))))

(defun perevedi-slovo(word key)
    (let ((chastislova (deli word))
    (chastikey (deli key)))
    (dolgota-glasnoi (first chastislova)
    (second chastislova)
    (first chastikey)
    (second chastikey))))

(defun dolgota-glasnoi (begin1 end1 begin2 end2)
    (cond
    ((dolgaya-kon? begin1)
    (cond
    ((dolgaya-kon? begin2)
    (pom-chasti begin1 end1 begin2 end2))
    (t (pom-chasti (ukoroti begin1) end1
    (udlinni begin2) end2))))
    ((dolgaya-kon? begin2)
    (pom-chasti
    (udlinni begin1) end2
    (ukoroti begin2) end2))
    (t (pom-chasti begin1 end1 begin2 end2))))

(defun dolgaya-kon? (word)
    (dolgaya-nach? (reverse word)))

(defun ukoroti (slog)
    (if (not (rest slog))
    nil
    (cons (first slog)
    (ukoroti (rest slog)))))

(defun udlinni (slog)
    (if (null (rest slog))
    (cons (first slog) slog)
    (cons (first slog)
    (udlinni (rest slog)))))

(defun pom-chasti
    (begin1 end1 begin2 end2)
    (list (sozv begin1 end1)
    (sozv begin2 end2)))

(defun sozv (begin end)
    (cond (;(perednee begin);
    (soedeni begin (vpered end)))
    (t (soedeni begin (nazad end)))))


(defun vpered (word)
    (sublis
    '((#\U . #\Y) (#\A . #\a) (#\O . #\o))
    word))

(defun nazad (word)
    (sublis
    '((#\Y . #\U) (#\a . #\A) (#\o . #\O))
    word))
    (defun soedeni(begin end)
    (intern (coerce (append begin end)
    'string)))
    
(print (perevedi-slovo 'frog 'kontti))

; -------------------------------------------------
; Task 9

(defun string-right (s n)
  (subseq s (- (length s) n)))
 
(defun drop-suffix (s v &aux (m (length s)) (n (length (car v))))
  (cond ((null v) s)
        ((string= (string-right s n) (car v)) (subseq s 0 (- m n)))
        ((drop-suffix s (cdr v)))))
 
(defun drop-suffixes (w v &aux (v> (sort v #'string>)))
  (mapcar #'(lambda (s) (drop-suffix s v>)) w))

  
(print (drop-suffixes '("kiamoto") '("moto" "iamoto")))
