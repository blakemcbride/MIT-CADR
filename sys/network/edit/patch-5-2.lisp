;;; -*- Mode:Lisp; Readtable:CL; Package:SITE-DATA-EDIT; Base:10; Patch-File:T -*-
;;; Patch file for Site Data Editor version 5.2
;;; Reason:
;;;  Update mouse documentation to indicate you can edit a network...
;;; Written 6-Aug-87 15:43:40 by pld (Peter L. DeWolf) at site LMI Cambridge
;;; while running on Azathoth from band 4
;;; with Experimental System 122.10, Experimental Local-File 73.0, Experimental FILE-Server 22.0, Experimental Unix-Interface 11.0, Experimental Tape 17.1, Experimental Tiger 26.0, Experimental KERMIT 33.1, Experimental ZMail 71.0, Experimental Lambda-Diag 15.0, Experimental Site Data Editor 5.1, microcode 1754, SDU Boot Tape 3.12, SDU ROM 102, the old ones.



; From modified file DJ: L.NETWORK.EDIT; MAIN.LISP#32 at 6-Aug-87 15:43:42
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; MAIN  "

(defcommand edit-object "Edit" "Edit a host, network, printer, or this site"
  (read-if-needed)
  (let ((old (editor-window-changed-object *edit-pane*)))
    (unless (and old
		 (not (yes-or-no-p "You have changed ~A; do you want to annull the changes ?"
				   old)))
      (let ((object (choose-any-object :use "to edit")))
	(when object
	  (send *edit-pane* :set-object object)
	  (send *typeout-pane* :clear-window))))))

))
