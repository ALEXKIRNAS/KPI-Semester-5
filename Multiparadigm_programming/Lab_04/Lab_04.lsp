(defun make-ts (production type naming)
(list :production production :type type :naming naming))

;��������� �����
(defvar *db* nil)

;��������� ������ � ���� �����
(defun add-record (ts) (push ts *db*))

;�������� ���� ���� ������ � ���� ���������� ����
(defun dump-db ()
(dolist (ts *db*)
(format t "~{~a:~10t~a~%~}~%" ts)))

;������ ����� �������� � ���� �����
(defun select (selector-fn)
(remove-if-not selector-fn *db*))

;������ ��� ��������� �������
(defun type-selector (type)
(lambda (ts) (equal (getf ts :type) type)))

;������ ����� ������, ��� ������� �� ������ ��� ���. �������, �� ���������� � ����������, �������� � where
(defun where (&key production type naming)
(lambda (ts)
(and
(if production (equal (getf ts :production) production) t)
(if type (equal (getf ts :type) type) t)
(if naming (equal (getf ts :naming) naming) t))))

;��������� �� ������������ ����������-������ ��� ������� ������ ��������
(defun update (selector-fn &key production type naming (ripped nil ripped-p))
(setf *db*
(mapcar
(lambda (row)
(when (funcall selector-fn row)
(if production (setf (getf row :production) production))
(if type (setf (getf row :type) type))
(if naming (setf (getf row :naming) naming)))
row) *db*)))

;��������� ����� �� ���� �����
(defun delete-rows (selector-fn)
(setf *db* (remove-if selector-fn *db*)))

;����� �� ������� ���������
(defun make-comparison-expr (field value)
(list 'equal (list 'getf 'ts field) value))
