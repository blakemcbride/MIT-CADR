;;; -*- Mode:Lisp; Readtable:ZL; Package:USER; Base:8; Patch-File:T -*-
;;; Patch file for System version 301.7
;;; Reason:
;;;  GETHASH: Add SETF versions.
;;; Written 13-Dec-24 10:37:33 by ams,
;;; while running on Lisp Machine One from band 6
;;; with Experimental System 301.6, Experimental ZWEI 129.0, microcode 323, A.



; From file OZ: /sys/sys2/hashfl.lisp at 13-Dec-24 10:37:33
#8R SYSTEM-INTERNALS#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SYSTEM-INTERNALS")))
  (COMPILER::PATCH-SOURCE-FILE "OZ: //sys//sys2//hashfl"

(defsetf zl:gethash (object hash-table &optional (default nil defaultp)) (value)
  (let ((tem (if defaultp `(prog1 ,hash-table ,default) hash-table)))
    `(sethash ,object ,tem ,value)))

(defun cli:gethash (key hash-table &optional default-value)
  "Read the values associated with KEY in HASH-TABLE.
Returns:
 1) The primary value associated with KEY (DEFAULT-VALUE if KEY is not found),
 2) a flag which is T if KEY was found"
  (declare (values value key-found-flag))
  (multiple-value-bind (value key-found-flag)
      (send hash-table :get-hash key default-value)
    (values value key-found-flag)))

(defsetf cli:gethash (object hash-table &optional (default nil defaultp)) (value)
  (let ((tem (if defaultp `(prog1 ,hash-table ,default) hash-table)))
    `(sethash ,object ,tem ,value)))

))
