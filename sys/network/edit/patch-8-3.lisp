;;; -*- Mode:Lisp; Readtable:CL; Package:SITE-DATA-EDIT; Base:10; Patch-File:T -*-
;;; Patch file for Site Data Editor version 8.3
;;; Reason:
;;;  When the Site Editor is in Expert Mode, the command menu does not include the
;;;  comments.  If you then recompile a menu command, the frame is asked to
;;;  recompute its menu, and you end up with the comments.  Slight change to the
;;;  :sort-menu-commands methods fixes this.
;;; Written 19-Nov-87 14:52:55 by pld at site Gigamos Cambridge
;;; while running on Jack Flanders from band 2
;;; with Experimental System 123.115, Experimental Local-File 73.2, Experimental FILE-Server 22.1, Experimental Unix-Interface 11.0, Experimental Tape 18.0, Experimental KERMIT 34.0, Experimental ZMail 71.0, Experimental Lambda-Diag 15.0, Experimental Site Data Editor 8.0, microcode 1754, SDU Boot Tape 3.12, SDU ROM 8.



; From modified file DJ: L.NETWORK.EDIT; MAIN.LISP#40 at 19-Nov-87 14:53:20
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; MAIN  "


(defmethod (menu-pane :sort-menu-commands) (&optional (commands *main-menu-commands*))
  (let ((preferred '("-- Site Editor Database --"
		     "Flush Database" "Reload"
		     "-- External Site Files --"
		     "Point to Site Files"
		     "Load Site Files" "Save Site Files"
		     "Compile Files"
		     "-- Editing Objects --"
		     "Edit" "Copy" "Delete" "Save Object Changes"
		     "-- Special Commands --"
		     "Parameters"
		     "Configure Window")))
    (send self :set-item-list
	       (sort (copy-list commands)
		     #'(lambda (a b)
			 (when (zl:mem #'string-equal (car a) preferred)
			   (> (length (zl:mem #'string-equal (car a) preferred))
			      (length (zl:mem #'string-equal (car b) preferred)))))))))

;;; The site editor frame

))

; From modified file DJ: L.NETWORK.EDIT; MAIN.LISP#40 at 19-Nov-87 14:53:34
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; MAIN  "


(defmethod (site-editor-frame :sort-menu-commands) (&optional (mode tv:configuration))
  (let ((command-menu (send self :get-pane 'command-menu)))
    (send command-menu :sort-menu-commands
		       ;;Exclude comment items in expert mode
		       (case mode
			 (expert
			  (loop for item in *main-menu-commands*
				as  itype = (second item)
				when (neq itype :no-select)
				collect item))
			 (t *main-menu-commands*)))
    (send command-menu :item-list)))

))

; From modified file DJ: L.NETWORK.EDIT; MAIN.LISP#40 at 19-Nov-87 14:53:39
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; MAIN  "


(defcommand config-expert "Configure Window"
	    "Set preferred window configuration"
  (let ((choice (tv:menu-choose '(normal expert)
				"--Choose Configuration--"
				'(:mouse)
				'normal)))
    (when choice
      (let ((mode (configure-appropriately choice)))
	(send *site-editor-frame* :sort-menu-commands mode)
	(send *site-editor-frame* :set-configuration mode)))))

;;; The Site Editor window

))
