;;; -*- Mode:Lisp; Readtable:ZL; Package:USER; Base:8; Patch-File:T -*-
;;; Patch file for System version 301.2
;;; Reason:
;;;  SI:MAP-TO-NEW-CDR-CODE: New function from System 130.
;;; Written 27-Nov-24 14:21:26 by ams,
;;; while running on Lisp Machine One from band 4
;;; with Experimental System 301.0, Experimental ZWEI 129.0, microcode 323.



; From file OZ: /sys/sys/qfasl.lisp at 27-Nov-24 14:21:33
#8R SYSTEM-INTERNALS#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SYSTEM-INTERNALS")))
  (COMPILER::PATCH-SOURCE-FILE "OZ: //sys//sys//qfasl"

(defun map-to-new-cdr-code (x)
  ;; This is, conveniently, a no-op if you run it in a system with the old values.
  (symbol-value (nth (logand x 3) '(cdr-normal cdr-error cdr-nil cdr-next))))

))
