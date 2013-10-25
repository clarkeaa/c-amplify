(in-package #:common-lisp-user)
(defpackage #:compiler
  (:use :common-lisp)  
  (:import-from se.defmacro.c-amplify 
                load-csys-file
                c-system-output-file
                update-system
                defsystem
                update)
  (:export main
           c-system-gen-source))
(in-package #:compiler)

(defparameter *CC* "clang")

(defun c-system-gen-source (in-path &key (out-path nil))
  (format t "inpath:~a~%" in-path)
  (let ((system (car (load-csys-file in-path))))
    (when (not (null out-path))
      (setf (c-system-output-file system) (pathname out-path)))
    (update-system system)))

(defun main ()
  (unix-options:with-cli-options () 
    (unix-options:&parameters out-path) 
    (format t "~a ~a~%" out-path unix-options:free)
    (c-system-gen-source (car unix-options:free) 
                         :out-path out-path)))

(in-package #:common-lisp-user)

(import 'se.defmacro.c-amplify::defsystem *package*)
(import 'se.defmacro.c-amplify::update *package*)

(defun build ()
  (sb-ext:save-lisp-and-die "compiler" 
                            :toplevel #'compiler:main
                            :executable t))
