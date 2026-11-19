;;; -*- Mode:Lisp; Readtable:CL; Package:SITE-DATA-EDIT; Base:10; Patch-File:T -*-
;;; Patch file for Site Data Editor version 5.3
;;; Reason:
;;;  Change criteria for valid Internet Network Numbers and Subnet Masks
;;; Written 7-Aug-87 15:25:16 by pld at site LMI Cambridge
;;; while running on Azathoth from band 4
;;; with Experimental System 122.10, Experimental Local-File 73.0, Experimental FILE-Server 22.0, Experimental Unix-Interface 11.0, Experimental Tape 17.1, Experimental Tiger 26.0, Experimental KERMIT 33.1, Experimental ZMail 71.0, Experimental Lambda-Diag 15.0, Experimental Site Data Editor 5.2, microcode 1754, SDU Boot Tape 3.12, SDU ROM 102, the old ones.



; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#36 at 7-Aug-87 15:25:34
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defun (:property :internet valid-network-p) (x)
  (and x
       (not (minusp x))
       (or (and (= (ldb (byte 1 31) x) 0)	;Class A
		(not (zerop (ldb (byte 8 24) x))))
	   (= (ldb (byte 2 30) x) 2)		;Class B
	   (= (ldb (byte 3 29) x) 6))))		;Class C

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#36 at 7-Aug-87 15:25:42
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defun (:property :internet valid-subnet-mask-p) (network-number subnet-mask)
  (or (null subnet-mask)			;Not having a subnet mask is allowed
      (and (zerop (logandc2 network-number subnet-mask))	;But if have one, must cover all network bits
	   (cond ((= (ldb (byte 1 31) network-number) 0)	;...Including all of Class A
		  (= (ldb (byte 8 24) subnet-mask) #xff))
		 ((= (ldb (byte 2 30) network-number) 2)	; or Class B
		  (= (ldb (byte 16 16) subnet-mask) #xffff))
		 ((= (ldb (byte 3 29) network-number) 6)	; or Class C network number
		  (= (ldb (byte 24 8) subnet-mask) #xffffff))))))

))
