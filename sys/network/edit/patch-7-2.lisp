;;; -*- Mode:Lisp; Readtable:CL; Package:SITE-DATA-EDIT; Base:10; Patch-File:T -*-
;;; Patch file for Site Data Editor version 7.2
;;; Reason:
;;;  cosmetic - error message improvements.
;;; Written 6-Nov-87 14:30:24 by keith (Keith Corbett) at site LMI
;;; while running on Opus from band 1
;;; with Experimental System 123.101, Experimental Local-File 73.0, Experimental FILE-Server 22.0, Experimental Unix-Interface 11.0, Experimental Tape 18.0, Experimental KERMIT 34.0, Experimental ZMail 71.0, Experimental Lambda-Diag 15.0, Experimental Tiger 27.0, Experimental Site Data Editor 7.1, microcode 1754, SDU Boot Tape 3.14, SDU ROM 8, site/patches/tiger.



; From modified file OPUS: L.NETWORK.EDIT; MAIN.LISP#36 at 6-Nov-87 14:30:49
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; MAIN  "


(defun set-sys-host-smart(&optional (stream terminal-io))
  (multiple-value-bind (args aborted)
      (get-sys-host-smart)
    (or aborted
	(and (listp args)
	     (let((host (first args))
		  (type (second args))
		  (addr (third args))
		  (sdir (fourth args)))
	       (and
		 (yes-or-no-p
		   (if (or type addr)
		       "Set SYS HOST to host ~a, type ~a, address is ~:[#o~o~;~s~],~%  directory is ~s.~%Confirm: "
		     "Set SYS HOST to local machine; ~4*directory is ~s.~%Confirm: ")
		   host type
		   (not(numberp addr)) addr
		   sdir)
		 (or (not (catch-error (si:parse-host host) nil))
		     (progn
		       (format t "~2%Warning: ~a is already a known host." host)
		       (format t "~%If you try to change its address 'on the fly', SET-SYS-HOST will fail.")
		       (format t "~%Instead, we can generate a phony host name to contact.")
		       (if (y-or-n-p "Just to be safe - use a phony name? ")
			   (setq host (string (let((si:*gensym-prefix* "$syshost"))(gensym))))))
		     t)
		 (or 
		   (catch-error (si:set-sys-host host type addr sdir))
		   (format stream "~%??? SET SYS HOST failed."))
		 (let((file (catch-error (truename "sys:site;sys.translations"))))
		   (if file
		       (progn 
			 (load file)
			 (format stream "~%You probably should load site files, now."))
		     (progn
		       (beep)
		       (format stream "~%??? Warning: SET SYS HOST failed - couldn't load SYS.TRANSLATIONS;"))))))))))

))
