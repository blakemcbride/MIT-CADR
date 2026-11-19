;;; -*- Mode:Lisp; Readtable:ZL; Package:USER; Base:10; Patch-File:T -*-
;;; Patch file for System version 301.5
;;; Reason:
;;;  EXPAND-TWO-LIST-DEFSETF: Add function; used by new SETF.
;;; Written 11-Dec-24 18:20:40 by ams,
;;; while running on Lisp Machine One from band 6
;;; with Experimental System 301.4, Experimental ZWEI 129.0, microcode 323, A.



; From file OZ: /sys/sys2/setf.lisp at 11-Dec-24 18:20:40
#10R SYSTEM-INTERNALS#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SYSTEM-INTERNALS")))
  (COMPILER::PATCH-SOURCE-FILE "OZ: //sys//sys2//setf"

;;; >> We need a general argument-list parser !
(defun expand-two-list-defsetf (access-function access-ll value-names body)
  (let ((single-arg-names '())
	(rest-arg nil)) ; has to be treated specially
    (do* ((ll access-ll (cdr ll))
	  (element (car ll) (car ll)))
	 ((null ll))
      (cond ((eq element '&rest)
	     (pop ll)
	     (pop ll rest-arg))
	    ((lisp:member element lambda-list-keywords))
	    (t (push (etypecase element
		       (symbol element)
		       (cons (car element)))
		     single-arg-names))))
    (setq single-arg-names (nreverse single-arg-names))
    `(let* ((single-tempvars (setf-make-n-tempvars ,(length single-arg-names)))
	    ,@(when rest-arg
		`((rest-tempvars (setf-make-n-tempvars (length ,rest-arg)))))
	    (storevar (gensym))
	    (tempvars ,(if rest-arg ; list of temporaries
			   '(append single-tempvars rest-tempvars)
			 'single-tempvars)))
       (values tempvars
	       ,(if rest-arg ; list of forms that correspond to the temporaries
		    `(list* ,@single-arg-names ,rest-arg)
		  `(list ,@single-arg-names))
	       (list storevar)
	       ;; We put the body inside a let where the values of the parameters
	       ;; of the lambda list aren't the actual forms, but the gensyms instead
	       ;; (and actually, the rest arg is a LIST of gensyms).
	       (let ((,(car value-names) storevar)
		     ;; Rebind single-argument parameters
		     ,@(loop for arg in single-arg-names
			      for i from 0
			      collect `(,arg (nth ,i tempvars)))
		     ;; Rebind &REST argument parameter
		     ,@(when rest-arg
			 `((,rest-arg rest-tempvars))))
		 . ,body)
	       `(,',access-function . ,tempvars)))))

))
