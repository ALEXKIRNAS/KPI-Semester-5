(defun make-ts (production type naming)
(list :production production :type type :naming naming))

;глобальна змінна
(defvar *db* nil)

;додавання запису в базу даних
(defun add-record (ts) (push ts *db*))

;виводить зміст бази данних в більш читабельній формі
(defun dump-db ()
(dolist (ts *db*)
(format t "~{~a:~10t~a~%~}~%" ts)))

;вибирає деяке значення з бази даних
(defun select (selector-fn)
(remove-if-not selector-fn *db*))

;вибирає тип телевізійної системи
(defun type-selector (type)
(lambda (ts) (equal (getf ts :type) type)))

;генерує вираз вибору, яке повертає всі записи про тел. системи, які співпадають зі значеннями, заданими в where
(defun where (&key production type naming)
(lambda (ts)
(and
(if production (equal (getf ts :production) production) t)
(if type (equal (getf ts :type) type) t)
(if naming (equal (getf ts :naming) naming) t))))

;оновлення та використання аргументов-ключів для задання нового значення
(defun update (selector-fn &key production type naming (ripped nil ripped-p))
(setf *db*
(mapcar
(lambda (row)
(when (funcall selector-fn row)
(if production (setf (getf row :production) production))
(if type (setf (getf row :type) type))
(if naming (setf (getf row :naming) naming)))
row) *db*)))

;видалення рядків із бази даних
(defun delete-rows (selector-fn)
(setf *db* (remove-if selector-fn *db*)))

;пошук за заданим значенням
(defun make-comparison-expr (field value)
(list 'equal (list 'getf 'ts field) value))
