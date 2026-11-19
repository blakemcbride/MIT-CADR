;;; -*- Mode:Lisp; Readtable:T; Package:USER; Base:8; Patch-File:T -*-
;;; Patch file for System version 301.4
;;; Reason:
;;;  SET-FILL-POINTER: New function from System 130.
;;; Written 10-Dec-24 11:41:47 by ams,
;;; while running on Lisp Machine One from band 3
;;; with Experimental System 301.3, Experimental ZWEI 129.0, microcode 323, Dist.



; From file OZ: /sys/sys/qrand.lisp at 10-Dec-24 11:41:47
#8R SYSTEM-INTERNALS#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SYSTEM-INTERNALS")))
  (COMPILER::PATCH-SOURCE-FILE "OZ: //sys//sys//qrand"

(defun set-fill-pointer (array value)
  (cond ((not (arrayp array))
	 (ferror "Argument ~S must be an array" array))
	((not (array-has-leader-p array))
	 (ferror "Array ~S has no fill-pointer" array))
	((not (fixnump value))
	 (ferror "New fill-pointer must be a fixnum"))
	((or (minusp value) (> value (array-length array)))
	 (ferror "New fill pointer ~A out of range for array ~A" value array))
	(t
	 (setf (array-leader array 0) value))))

))
