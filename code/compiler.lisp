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
  (let ((system (car (load-csys-file in-path))))
    (when (not (null out-path))
      (setf (c-system-output-file system) (pathname out-path)))
    (update-system system)
    (c-system-output-file system)))

(defun c-system-gen-binary (in-path &key (out-path nil))
  (let* ((source (c-system-gen-source in-path))
         (args (list source)))
    (when (not (null out-path))
      (setf args (cons "-o" (cons out-path args))))
    (external-program:run *CC* args 
                          :output *standard-output*
                          :error *standard-output*)))

(defun main ()
  (unix-options:with-cli-options () 
    (gen-c-source unix-options:&parameters out-path) 
    (cond (gen-c-source
           (c-system-gen-source (car unix-options:free) 
                                :out-path out-path))
          (t
           (c-system-gen-binary (car unix-options:free)
                                :out-path out-path)))))

(in-package #:common-lisp-user)

(shadowing-import 'se.defmacro.c-amplify::defsystem *package*)
(shadowing-import 'se.defmacro.c-amplify::update *package*)

(defun build ()
  (sb-ext:save-lisp-and-die "compiler" 
                            :toplevel #'compiler:main
                            :executable t))
