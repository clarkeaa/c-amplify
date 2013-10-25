(in-package #:common-lisp-user)
(defpackage #:testrunner
  (:use :common-lisp :compiler)  
  (:export main)
  (:import-from se.defmacro.c-amplify 
                defsystem
                update))
(in-package #:testrunner)

(defparameter *all-tests* nil)

(defmacro assert-equal (x y)
  `(when (not (equal ,x ,y))
     (error (format nil "expected:~a but saw:~a~%" ,x ,y))))

(defmacro deftest ((name output) &body body)
  (let ((exec-path (gensym))
        (ss (gensym))
        (symbol (intern name)))
    `(progn 
       (defun ,symbol ()
         (format t ,(format nil "running \"~a\":" name))
         (let ((,exec-path ,(format nil "./tests/~a" name)))
           (compiler:c-system-gen-binary 
            ,(format nil "./tests/~a.csys" name) 
            :out-path ,exec-path)
           (let ((,output (with-output-to-string (,ss)
                            (external-program:run ,exec-path nil 
                                                  :output ,ss))))
             ,@body)))
       
       (eval-when (:load-toplevel) 
         (pushnew #',symbol *all-tests*)))))


(deftest ("test-add" output)
  (assert-equal "11" output))

(defun main ()   
  (let ((pass-count 0) 
        (count 0))
    (dolist (test *all-tests*)
      (let (pass)
        (handler-case 
            (progn
              (incf count)
              (funcall test)
              (setf pass t)
              (incf pass-count))        
          (error (e) (format t "failed~%~a" e)))
        (when pass (format t "pass~%"))))
    (format t "passed ~a of ~a~%" pass-count count)))
