;;; -*- Mode:Lisp; Readtable:CL; Package:SITE-DATA-EDIT; Base:10; Patch-File:T -*-
;;; Patch file for Site Data Editor version 8.2
;;; Reason:
;;;  When you flush the database, clear the current item from the window.
;;;  When you delete the currently edited object, clear it from window.
;;;  Speed up the :delete-all-items method (delete from end, rather than top
;;;  of list -- no more scrolling!)
;;;  The :site-option initialization now calls (flush-database) rather
;;;  than (forget-buffered-data), so when you reload the site files
;;;  your current object is cleared.
;;; Written 19-Nov-87 12:51:46 by pld at site Gigamos Cambridge
;;; while running on Jack Flanders from band 2
;;; with Experimental System 123.115, Experimental Local-File 73.2, Experimental FILE-Server 22.1, Experimental Unix-Interface 11.0, Experimental Tape 18.0, Experimental KERMIT 34.0, Experimental ZMail 71.0, Experimental Lambda-Diag 15.0, Experimental Site Data Editor 8.0, microcode 1754, SDU Boot Tape 3.12, SDU ROM 8.



; From modified file DJ: L.NETWORK.EDIT; MAIN.LISP#39 at 19-Nov-87 13:05:43
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; MAIN  "


(add-initialization "Site Editor Data Decache"
		    '(flush-database)
		    '(:site-option :normal))

))

; From modified file DJ: L.NETWORK.EDIT; MAIN.LISP#39 at 19-Nov-87 13:05:46
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; MAIN  "


(defcommand flush-database "Flush Database" "Forget any changes; will need to reload later"
  (when (boundp '*edit-pane*)
    (send *edit-pane* :set-object nil))
  (forget-buffered-data)
  (assure-class-stores))

))

; From modified file DJ: L.NETWORK.EDIT; WINDOW.LISP#15 at 19-Nov-87 13:07:23
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; WINDOW  "

(defmethod (object-editor-window :delete-all-items) (&optional (index 0))
  (do ((max (array-leader items 0) (1- max)))
      ((< max index) nil)
    (send self :delete-item max)))

))

; From modified file DJ: L.NETWORK.EDIT; MAIN.LISP#40 at 19-Nov-87 14:31:58
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; MAIN  "

(defcommand delete-object "Delete" "Delete an object; confirmation is necessary"
  (read-if-needed) ; 'cos you must have something to delete
  (let ((object (choose-any-object :use "to delete")))
    (when object
      (if (send object :deletable-p)
	  (let ((referrers (send object :all-object-referrers)))
	    (if (null referrers)
		(when
		  (tv:mouse-y-or-n-p (format () "Delete ~A" (send object :name)))
		  (send object :remove)
		  (when (eq object (send *edit-pane* :object))
		    (send *edit-pane* :set-object nil)))
	      (progn
		(complain "Some objects are currently referring to this object:")
		(terpri *error-output*)
		(format:print-list *error-output* "~A" referrers)
		(terpri *error-output*))))
	(complain "You can't delete this object.")))))

))
