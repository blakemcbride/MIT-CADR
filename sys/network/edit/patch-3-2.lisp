;;; -*- Mode:Lisp; Readtable:CL; Package:SITE-DATA-EDIT; Base:10; Patch-File:T -*-
;;; Patch file for Site Data Editor version 3.2
;;; Reason:
;;;  Make sure stores exists before trying to create objects.
;;;  Help.
;;; Written 28-Mar-86 16:09:52 by RpK (Robert P. Krajewski) at site LMI Cambridge
;;; while running on David Bowie from band 2
;;; with Experimental System 110.159, Experimental Lambda-Diag 7.3, Experimental Local-File 68.5, Experimental FILE-Server 18.2, Experimental Unix-Interface 9.1, Experimental ZMail 65.10, Experimental Object Lisp 3.0, Experimental Tape 6.15, Experimental Site Data Editor 3.1, Experimental Tiger 24.0, Experimental KERMIT 31.2, Experimental Window-Maker 1.0, Experimental Gateway 4.3, Experimental TCP-Kernel 39.5, Experimental TCP-User 62.5, Experimental TCP-Server 45.5, Experimental MEDIUM-RESOLUTION-COLOR 3.1, Experimental MICRO-COMPILATION-TOOLS 3.2, microcode 1408, SDU ROM 102, Alpha III Cambridge.



; From modified file DJ: L.NETWORK.EDIT; MAIN.LISP#14 at 28-Mar-86 16:09:59
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; MAIN  "


(defun initialize-if-needed ()
  (assure-class-stores)
  (when *need-to-look-at-external-data*
    (format t "~&Loading in new data...")
    (clear-all-stores)
    (init-site-lists)
    (make-printers)
    (make-site si:site-name *site-option-alist*)
    (init-hosts)
    (make-hosts-complete)
    (setq *need-to-look-at-external-data* nil)
    (format t "done.~%")))

))

; From modified file DJ: L.NETWORK.EDIT; MAIN.LISP#14 at 28-Mar-86 16:10:11
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; MAIN  "


(defun _help ()
  (format *typeout-pane* "You are using the Site Data Editor.~%
The basic idea to select objects (like printers, the site, or hosts) and edit
their attributes.  When you have made a desired change to an object, you save
the changes to that object.  Then you can save out the new site files after you
have completed all the changes.

You can figure out how edit the attributes by paying attention to the who-line
documentation.  Be aware that some attributes can appear more than once or be
deleted.  Menus are used for choices among a set of alternatives.

The major commands appear in the Command Menu:~2%")
  (dolist (c *main-menu-commands*)
    (format *typeout-pane* "~A: ~A~%" (car c) (get c :documentation)))
  (format *typeout-pane* "~%See the Site Data Editor guide for more information.~2%"))

))

; From modified file DJ: L.NETWORK.EDIT; MAIN.LISP#14 at 28-Mar-86 16:10:17
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; MAIN  "


(defun command-loop-process-thing (thing)
  (catch 'abort-edit
    (initialize-if-needed)
    (typecase thing
      ((number character)
       (case (coerce thing 'character)
	 ((#\Help #\?) (_help)) ; not HELP, since that would cause lossage after package-dwim
	 ((#\Control-L #\Clear-Screen) (send *edit-pane* :refresh))
	 (otherwise (tv:beep 'no-command))))
      (cons ; a blip
       (case (first thing)
	 (:menu (send (fourth thing) :execute (second thing)))
	 (:mouse-button ())
	 (otherwise ; it's a blip to edit an object
	  (send (third thing) :edit-object (first thing) (second thing) (fourth thing)))))
      (t
       (complain "~&What is ~S ?" thing)))))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#26 at 28-Mar-86 16:10:33
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defun assure-class-stores ()
  (dolist (c *object-classes*)
    (find-or-create-store c)))

))
