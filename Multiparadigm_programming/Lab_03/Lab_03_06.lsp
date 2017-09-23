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
