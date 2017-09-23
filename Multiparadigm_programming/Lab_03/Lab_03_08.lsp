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
