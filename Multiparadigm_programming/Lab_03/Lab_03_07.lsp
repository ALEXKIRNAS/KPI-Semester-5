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

;(print (divide_string "Привет мир"))
(print '("При" "ве" "т" "ми" "р"))
