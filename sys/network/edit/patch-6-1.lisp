;;; -*- Mode:Lisp; Readtable:CL; Package:SITE-DATA-EDIT; Base:10; Patch-File:T -*-
;;; Patch file for Site Data Editor version 6.1
;;; Reason:
;;;  Put Internet network numbers and subnet masks into site file as dotted decimal
;;;  strings -- easier for humans to understand.  Properly accept such from file.
;;; Written 6-Oct-87 12:15:27 by pld at site LMI Cambridge
;;; while running on Jack Flanders from band 2
;;; with Experimental System 123.28, Experimental Local-File 73.0, Experimental FILE-Server 22.0, Experimental Unix-Interface 11.0, Experimental Tape 18.0, Experimental KERMIT 34.0, Experimental ZMail 71.0, Experimental Lambda-Diag 15.0, Experimental Site Data Editor 6.0, microcode 1754, SDU Boot Tape 3.12, SDU ROM 8.



; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#38 at 6-Oct-87 12:15:32
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defmethod (network-spec :set-value) (list)
  (let ((domain (first list))
	(number (second list))
	(mask (third list)))
    (when (eq domain :internet)
      (setq number (ip:parse-internet-address number))
      (setq mask (ip:parse-internet-address mask)))
    (setf `(,addressing-domain ,network-number ,subnet-mask) (list domain number mask))))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#38 at 6-Oct-87 12:15:36
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defmethod (network-spec :value) ()
  (if (eq addressing-domain :internet)
      (if subnet-mask
	  (list :internet
		(net::unparse-address network-number :internet)
		(net::unparse-address subnet-mask :internet))
	(list :internet (net::unparse-address network-number :internet)))
    (list addressing-domain network-number)))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#38 at 6-Oct-87 12:15:43
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defmethod (network :case :update-property network-spec) (newval oldval)
  (if oldval
      (setf (car (member (car oldval) network-specs :test #'eq :key #'car)) newval)
    (push newval network-specs)))

))
