;gnu clisp 2.49

(defun task06 (a b c d)
       (cond
            ((and (and (null b) (null c)) (null d)) ; flatten list of unique numbers
                 (cond 
                      ((null a) '())
                      ((atom a) (list a))
                      ((atom (car a)) (cond
                                         ((funcall  ; member function equivalent 
                                              (lambda (F A B) 
                                                (funcall F A B F)
                                              )
                                              (lambda (A B F)
                                                (cond 
                                                  ((null B) nil)
                                                  (T 
                                                    (cond
                                                      ((equal A (car B)) T)
                                                      (T (funcall F A (cdr B) F))
                                                    )
                                                  )
                                                )
                                              )
                                           (car a) (task06 (cdr a) nil nil nil)) (task06 (cdr a) nil nil nil))
                                         (T (append (list (car a)) (task06 (cdr a) nil nil nil)))
                                       )
                       )
                      (T (task06 (append (task06 (car a) nil nil nil) (cdr a)) nil nil nil))
                  )
             )
            ((and (null c) (null d)) ; union
                (task06 (append (task06 a nil nil nil) (task06 b nil nil nil)) nil nil nil)
             )
           ((and (null b) (null c)) ; difference
                (cond
                   ((null a) '())
                   ((atom (car a)) 
                        (cond
                            ((funcall  ; member function equivalent 
                                              (lambda (F A B) 
                                                (funcall F A B F)
                                              )
                                              (lambda (A B F)
                                                (cond 
                                                  ((null B) nil)
                                                  (T 
                                                    (cond
                                                      ((equal A (car B)) T)
                                                      (T (funcall F A (cdr B) F))
                                                    )
                                                  )
                                                )
                                              )
                               (car (task06 a nil nil nil)) (task06 d nil nil nil)) (task06 (cdr (task06 a nil nil nil)) nil nil d))
                            (T (append (list (car (task06 a nil nil nil))) (task06 (cdr (task06 a nil nil nil)) nil nil d)))
                         )
                    )
                   (T (task06 (task06 a nil nil nil) nil nil d))
                )
           )
           (T (task06 (task06 a b nil nil) nil nil (task06 c d nil nil)))
       )
)

(print (task06 '(1 1 3 2 5) '(4 6) '(7 8 9) '(3 4 5)))
