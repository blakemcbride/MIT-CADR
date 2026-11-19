;;; -*- Mode:Lisp; Readtable:CL; Package:SITE-DATA-EDIT; Base:10; Patch-File:T -*-
;;; Patch file for Site Data Editor version 8.5
;;; Reason:
;;;  If a site option is a list of hosts and the user has manually entered
;;;  an unknown host into the list, the site editor can put you into the
;;;  cold load stream, or into the error handler in the mouse process,
;;;  when it tries to print the object.
;;; Written 23-Feb-88 15:57:46 by pld at site Gigamos Cambridge
;;; while running on Jack Flanders from band 2
;;; with Experimental System 123.204, Experimental Local-File 73.3, Experimental FILE-Server 22.1, Experimental Unix-Interface 11.0, Experimental KERMIT 34.3, Experimental ZMail 71.0, Experimental Lambda-Diag 15.0, Experimental Tape 21.1, Experimental Site Data Editor 8.4, microcode 1755, SDU Boot Tape 3.12, SDU ROM 8.



; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#42 at 23-Feb-88 15:57:52
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defmethod (object-list :print-value) (stream escape-p)
  (declare (ignore escape-p))
  (cond (elements
	 (write-char #\{ stream)
	 (do* ((vv elements (cdr vv))
	       (v (car vv) (car vv)))
	      ((null vv))
	   (when (second v)
	     (unless (eq vv elements)
	       (write-string ", " stream))
	     (write-string (send (second v) :name) stream)))
	 (write-char #\} stream))
	(t (write-string "empty" stream))))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#42 at 23-Feb-88 15:57:56
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defmethod (object-list :output-elements) (window)
  (do* ((vv elements (cdr vv))
	(v (car vv) (car vv)))
       ((null vv))
    (when (second v)
      (unless (eq vv elements)
	(send window :tyo #\Space))
      (send window :item1 v 'object-list-element
	    #'(lambda (ignore w)
		(send w :string-out (send (second v) :short-name)))))))

))
