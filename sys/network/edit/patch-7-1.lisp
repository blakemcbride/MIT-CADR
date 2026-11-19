;;; -*- Mode:Lisp; Readtable:CL; Package:SITE-DATA-EDIT; Base:10; Patch-File:T -*-
;;; Patch file for Site Data Editor version 7.1
;;; Reason:
;;;  cosmetic error - meant to print current translation of sys:site;
;;;  instead of NIL.
;;; Written 5-Nov-87 16:56:19 by keith (Keith Corbett) at site LMI
;;; while running on Opus from band 1
;;; with Experimental System 123.90, Experimental Local-File 73.0, Experimental FILE-Server 22.0, Experimental Unix-Interface 11.0, Experimental Tape 18.0, Experimental KERMIT 34.0, Experimental ZMail 71.0, Experimental Lambda-Diag 15.0, Experimental Tiger 27.0, Experimental Site Data Editor 7.0, microcode 1754, SDU Boot Tape 3.14, SDU ROM 8, site/patches/tiger.



; From modified file OPUS: L.NETWORK.EDIT; MAIN.LISP#35 at 5-Nov-87 16:56:41
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; MAIN  "


(defun get-sys-host-smart(&optional (stream terminal-io))
  (let((msg-ok "***")
       (msg-ng "???"))
    (case 
      (tv:menu-choose '(local remote)
		      "Is the SYS HOST the LOCAL machine or a REMOTE host?"
		      (list :window stream))
      (NIL (values nil :abort))
      (LOCAL (list "LM" nil nil 
		   (send
		     (fs:translated-pathname
		       (let((default "LM:RELEASE-4.CUSTOMER-SITE;"))
			 (prompt-and-read
			   `(:pathname :defaults ,default)
			   "~%Specify the directory containing site files (~a is default): "
			   default)))
		     :string-for-directory)))
      (REMOTE
       (let(sys-site-translation sys-host-option sys-host
	    sys-host-name sys-type sys-directory
	    which-addr sys-chaos sys-internet)
	 (declare(special sys-host-name sys-type sys-directory
			  which-addr sys-chaos sys-internet))
	 (flet ((valid-host(host)
			   (multiple-value-bind(result error-p)
			       (catch-error (si:parse-host host))
			     (if error-p
				 (format stream "~%~a ~s is not a valid host"))
			     (return-from valid-host
			       (and (not error-p) result)))))
	   ;;Get defaults for current sys host
	   (Or
	     (And (setq sys-site-translation (catch-error (fs:translated-pathname "sys:site;")))
		  (let((ok (and (pathnamep sys-site-translation)
				(setq sys-host (valid-host (pathname-host sys-site-translation)))
				(setq sys-host-name (send sys-host :name))
				(setq sys-type (send sys-host :system-type)))))
		    (format stream "~%~a Current SYS:SITE; translates to ~s"
			    (if ok msg-ok msg-ng)
			    sys-site-translation)
		    (If (not ok)
			(format stream "~& ...which is not a valid host/pathname")
		      sys-host-name)))
	     (format stream "~%~a No translation for SYS: SITE;" msg-ng)
	     (If (setq sys-host-option (si:get-site-option :sys-host))
		 (typecase sys-host-option
		   (string (setq sys-host-name sys-host-option)
			   (setq sys-host (valid-host sys-host-name)))
		   (si:host (setq sys-host-name (send sys-host-option :name))
			    (setq sys-host sys-host-option)))
	       (format stream "~%~a No value for site option :SYS-HOST" msg-ng)))
	   ;;If we got a remote host, set other defaults
	   (cond
	     (sys-host
	      (setq sys-directory (send sys-site-translation :directory))
	      (if (stringp sys-directory) (setq sys-directory (ncons sys-directory)))
	      (setq sys-chaos (send sys-host :chaos-address))
	      (setq sys-internet (car (send sys-host :unparsed-network-addresses :internet)))
	      (setq which-addr (if sys-chaos :chaos :internet)))
	     ;;Got nothing, set defaults
	     (t (setq sys-host-name "LAMA")
		(setq sys-type :lispm)
		(setq sys-directory '("RELEASE-4" "CUSTOMER-SITE"))
		(setq sys-chaos #o3430)))
	   ;;Pop up menu for entering remote host info
	   (let((*print-base* #o10)
		(*read-base* #o10))
	     (tv:choose-variable-values
	       '((sys-host-name
		   "Sys Host Name           " :string)
		 (sys-type
		   "System Host Type        " :sexp
		   :documentation "Click left to enter system type keyword (use :LISPM if in doubt.)")
		 (sys-directory
		   "Site Directory          " :sited-read-directory)
		 ""
		 "Specify which network to use and the address"
		 "  (Chaos is used by preference):"
		 ""
		 (which-addr
		   "Network                 " :choose (:chaos :internet))
		 (sys-chaos
		   "Chaos Address <Octal>   " :number-or-nil)
		 (sys-internet
		   "Internet Address x.x.x.x" :string))
	       :function #'sys-host-window-option-validation-function
	       :label "Enter Sys Host / Site Directory Information")
	     (list
	       sys-host-name
	       (intern sys-type 'keyword)
	       (let((valid-chaos (and (typep sys-chaos '(integer 0))
				      sys-chaos))
		    (valid-internet (and (typep sys-internet 'string)
					 (>= (string-length sys-internet) 7)
					 sys-internet)))
		 (cond
		   ((null (or valid-chaos valid-internet))
		    (ferror "You must specify a valid Chaos or Internet address for the SYS HOST"))
		   ((and (eq which-addr :chaos) valid-chaos))
		   ((eq which-addr :chaos)
		    (if valid-internet
			(progn
			  (cerror "Use the Internet address ~a"
				  "No Chaos address specified for SYS HOST"
				  sys-internet)
			  sys-internet)
		      (ferror "No address specified for SYS HOST")))
		   ((and (eq which-addr :internet) valid-internet))
		   ((eq which-addr :internet)
		    (if valid-chaos
			(progn
			  (cerror "Use the Chaos address #o~o"
				  "No Internet address specified for SYS HOST"
				  sys-chaos)
			  sys-chaos)
		      (ferror "No address specified for SYS HOST")))))
	       (print-sited-directory-item sys-directory nil)))))))))

))
