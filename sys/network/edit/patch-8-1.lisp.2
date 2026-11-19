;;; -*- Mode:Lisp; Readtable:CL; Package:SITE-DATA-EDIT; Base:10; Patch-File:T -*-
;;; Patch file for Site Data Editor version 8.1
;;; Reason:
;;;  Site Editor converts network numbers and subnet masks to integers when read from
;;;  site files, and back to human-readable form when writing to site files.
;;;  Always stored as numbers when in memory for easy comparisons.
;;; Written 19-Nov-87 12:30:49 by pld at site Gigamos Cambridge
;;; while running on Jack Flanders from band 2
;;; with Experimental System 123.115, Experimental Local-File 73.2, Experimental FILE-Server 22.1, Experimental Unix-Interface 11.0, Experimental Tape 18.0, Experimental KERMIT 34.0, Experimental ZMail 71.0, Experimental Lambda-Diag 15.0, Experimental Site Data Editor 8.0, microcode 1754, SDU Boot Tape 3.12, SDU ROM 8.



; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#39 at 19-Nov-87 12:31:07
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defmethod (network-spec :value) ()
  (if subnet-mask
      (list addressing-domain
	    (net::unparse-address network-number addressing-domain)
	    (net::unparse-address subnet-mask addressing-domain))
    (list addressing-domain (net::unparse-address network-number addressing-domain))))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#39 at 19-Nov-87 12:31:12
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defmethod (network :after :init) (&rest ignore)
  (dolist (x network-specs)
    (when (and (second x) (not (numberp (second x))))
      (setf (second x) (net:parse-address (second x) (first x))))
    (when (and (third x) (not (numberp (third x))))
      (setf (third x) (net:parse-address (third x) (first x))))))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#39 at 19-Nov-87 12:31:20
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defmethod (network :dump-to-site-info) ()
  (push	(list (cons name nicknames)
	      (do* ((list (send self :spec) (cdr list))
		    (spec (car list) (car list))
		    (domain (first spec) (first spec))
		    (result nil))
		   ((null spec)
		    (nreverse result))
		(push (append (ncons domain)
			      (when (second spec)
				(ncons (human-readable-network-address (second spec) domain)))
			      (when (third spec)
				(ncons (human-readable-network-address (third spec) domain))))
		      result)))
	(get-site-wide-option :network-names)))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#39 at 19-Nov-87 12:31:21
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defun human-readable-network-address (address domain)
  (case domain
    (:chaos address)
    (:internet (net:unparse-address address domain))))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#40 at 19-Nov-87 15:09:31
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "

(defmethod (network :case :update-property network-spec) (newval oldval)
  (when (and (second newval) (not (numberp (second newval))))
    (setf (second newval) (net:parse-address (second newval) (first newval))))
  (when (and (third newval) (not (numberp (third newval))))
    (setf (third newval) (net:parse-address (third newval) (first newval))))
  (if oldval
      (setf (car (member (car oldval) network-specs :test #'eq :key #'car)) newval)
    (push newval network-specs)))

))
