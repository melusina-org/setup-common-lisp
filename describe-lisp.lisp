;;;; describe-lisp.lisp — Setup Common Lisp

;;;; Melusina Actions (https://github.com/melusina-org/setup-common-lisp)
;;;; This file is part of Melusina Actions.
;;;;
;;;; Copyright © 2023 Michaël Le Barbier
;;;; All rights reserved.

;;;; This file must be used under the terms of the MIT License.
;;;; This source file is licensed as described in the file LICENSE, which
;;;; you should have received as part of this distribution. The terms
;;;; are also available at https://opensource.org/licenses/MIT

(require '#:asdf)
(require '#:uiop)

(defpackage #:org.melusina.lisp-action/describe-lisp
  (:use #:common-lisp)
  (:export #:entrypoint))

(in-package #:org.melusina.lisp-action/describe-lisp)

(defparameter *init-filename*
  '((allegro . ".clinit.cl")
    (abcl . ".abclrc")
    (ccl .
     #+windows
     "ccl-init.lisp"
     #-windows
     ".ccl-init.lisp")
    (clasp . ".clasprc")
    (clisp . ".clisprc.lisp")
    (ecl . ".eclrc")
    (mkcl . ".mkclrc")
    (lispworks . ".lispworks")
    (sbcl . ".sbclrc")
    (cmucl . ".cmucl-init.lisp")
    (scl . ".scl-init.lisp")))

(defun normalized-lisp-implementation-type ()
  (let ((exceptions
	  '(("armed bear common lisp" . "abcl"))))
    (flet ((exceptions (implementation-type)
	     (or
	      (cdr (assoc implementation-type exceptions :test #'string=))
	      implementation-type)))
      (exceptions
       (string-downcase (lisp-implementation-type))))))

(defun init-filename ()
  (let ((init-filename
	  (cdr
	   (assoc (normalized-lisp-implementation-type) *init-filename*
		  :test #'string-equal))))
    (unless init-filename
      (error "Cannot determine the INIT-FILENAME for ~
              implementation type ~A."
	     (normalized-lisp-implementation-type)))
    (merge-pathnames
     init-filename
     (user-homedir-pathname))))

(defun write-detail (&key name key value)
  "Write detail NAME with VALUE.
Additionally, when running on GitHub Actions, the key is written
to job output."
  (format t "~&~A: ~A~%" name value)
  (when (uiop:getenv "GITHUB_OUTPUT")
    (with-open-file (output (uiop:getenv "GITHUB_OUTPUT")
			    :direction :output
			    :if-exists :append :if-does-not-exist :create)
      (format output "~&~A=~A~%" key value))))

(defun write-implementation-details ()
  "Write details about the current Common Lisp Implementation."
  (write-detail
   :name "Lisp Implementation Type"
   :key "lisp-implementation-type"
   :value (normalized-lisp-implementation-type))
  (write-detail
   :name "Lisp Implementation Version"
   :key "lisp-implementation-version"
   :value (lisp-implementation-version))
  (write-detail
   :name "Lisp Implementation Init Filename"
   :key "lisp-implementation-init-filename"
   :value (init-filename)))

(defun entrypoint ()
  (handler-case (write-implementation-details)
    (error (c)
      (format *trace-output* "~&Failure: ~A~&" c)
      (uiop:quit 1))))

(progn (entrypoint))

;;;; End of file `describe-lisp.lisp'
