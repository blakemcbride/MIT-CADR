;;; -*- Mode:Lisp; Readtable:CL; Package:SITE-DATA-EDIT; Base:10; Patch-File:T -*-
;;; Patch file for Site Data Editor version 8.4
;;; Reason:
;;;  The Site Editor doesn't allow you to assign addresses that are not on known
;;;  networks.  Unfortunately, it wasn't taking subnet masks into account.
;;;  Ditto when checking whether a network number was in use when defining
;;;  new networks.
;;; Written 19-Nov-87 15:18:33 by pld at site Gigamos Cambridge
;;; while running on Jack Flanders from band 2
;;; with Experimental System 123.115, Experimental Local-File 73.2, Experimental FILE-Server 22.1, Experimental Unix-Interface 11.0, Experimental Tape 18.0, Experimental KERMIT 34.0, Experimental ZMail 71.0, Experimental Lambda-Diag 15.0, Experimental Site Data Editor 8.0, microcode 1754, SDU Boot Tape 3.12, SDU ROM 8.



; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#41 at 19-Nov-87 15:18:39
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "

(defun check-shared-addresses (addressing-domain address)
  (unless (valid-address-for-addressing-domain-p addressing-domain address)
    (format *query-io* "~A is not a valid address for the ~A addressing domain.~%"
	    (net::unparse-address address addressing-domain) addressing-domain)
    (abort-edit))
  (let* ((current-host (send *edit-pane* :object))
	 (other-hosts (remq current-host (multiple-value-list (get-host-from-address (list addressing-domain address))))))
    (when other-hosts
      (complain "~A already has address of ~A."
		(car other-hosts)
		(net::unparse-address address addressing-domain))
      (abort-edit)))
  (unless (find-network-by-address address addressing-domain)
    (complain "~A address ~A is on network ~A, which is unknown"
	      addressing-domain
	      (net::unparse-address address addressing-domain)
	      (net::unparse-address (funcall (get addressing-domain 'network-number-from-address #'identity) address)
				    addressing-domain))
    (abort-edit)))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#41 at 19-Nov-87 15:26:03
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "

(defun find-network-by-address (address domain)
  (let ((func (get domain 'network-number-from-address #'identity)))
    (dolist (x (all-class-objects :network))
      (dolist (network-spec (send x :spec))
	(and (eq domain (first network-spec))
	     (if (third network-spec)
		 (= (logand (third network-spec) address) (second network-spec))
	       (= (funcall func address) (funcall func (second network-spec))))
	     (return-from find-network-by-address x))))))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#41 at 19-Nov-87 15:42:34
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "

(defmethod (network-spec :case :edit network-spec-network-number) ()
  (let ((new (funcall (let ((-addressing-domain- addressing-domain))	; grumble....
			#'(lambda (string) (net:parse-address string -addressing-domain-)))
		      (query-read-line "Network Number: "))))
    (unless (valid-network-for-addressing-domain-p addressing-domain new)
      (format *query-io* "~A is not a valid network for the ~A addressing domain.~%"
	      (net::unparse-address new addressing-domain) addressing-domain)
      (abort-edit))
    (let ((network (find-network-by-address new addressing-domain)))
      (when network
	(format *query-io* "~A already has ~A network number ~A.~%"
		(send network :name)
		addressing-domain
		(net::unparse-address new addressing-domain))
	(abort-edit)))
    (setq network-number new)))

))
