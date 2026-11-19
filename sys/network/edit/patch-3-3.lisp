;;; -*- Mode:Lisp; Readtable:CL; Package:SITE-DATA-EDIT; Base:10; Patch-File:T -*-
;;; Patch file for Site Data Editor version 3.3
;;; Reason:
;;;  If an attribute doesn't refer to any object, just return NIL for
;;;   :VALUE-AS-SITE-ATTRIBUTE.
;;; Written 3-Apr-86 14:33:04 by mrc at site LMI Cambridge
;;; while running on Natasha Nogoodnik from band 3
;;; with Experimental System 110.162, Experimental Lambda-Diag 7.3, Experimental Local-File 68.5, Experimental FILE-Server 18.2, Experimental Unix-Interface 9.1, Experimental ZMail 65.11, Experimental Object Lisp 3.1, Experimental Tape 6.30, Experimental Site Data Editor 3.2, Experimental Tiger 24.0, Experimental KERMIT 31.2, Experimental Window-Maker 1.0, Experimental Gateway 4.5, Experimental TCP-Kernel 39.5, Experimental TCP-User 62.6, Experimental TCP-Server 45.5, Experimental MEDIUM-RESOLUTION-COLOR 3.1, Experimental MICRO-COMPILATION-TOOLS 3.2, microcode 1408, SDU ROM 102, Alpha III(3/25 mrc) printing.



; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#27 at 3-Apr-86 14:33:07
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "

(defmethod (object-reference :value-as-site-attribute) ()
  (and value ; can be NIL, if not referring to any object
       (send value :name)))

))
