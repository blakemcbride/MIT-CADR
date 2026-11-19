;;; -*- Mode:Lisp; Readtable:CL; Package:SITE-DATA-EDIT; Base:10; Patch-File:T -*-
;;; Patch file for Site Data Editor version 3.1
;;; Reason:
;;;  Generation and validation of network addresses, make the blinker blinker in the
;;;   query window, and tell the user what's going on when snarfing data.
;;; Written 7-Mar-86 21:24:37 by rpk (Bob Krajewski) at site LMI Cambridge
;;; while running on David Byrne from band 2
;;; with Experimental System 110.104, Experimental ZMail 65.7, Experimental Unix-Interface 9.0, Experimental Local-File 66.1, Experimental MagTape 4.1, Experimental FILE-Server 18.1, Experimental Site Data Editor 3.0, microcode 1408, SDU ROM 102, Nifty.



; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#25 at 7-Mar-86 21:24:44
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "

(defmethod (network-address :output-value) (window)
  (let ((x self) (-network- network) (-address- address))
    (send window :set-current-font cue-font)
    (write-string "Network " window)
    (send window :set-current-font default-font)
    (send window :item1 x 'network-address-network
	  #'(lambda (ignore window)
	      (send window :string-out (symbol-name -network-))))
    (send window :tyo #\Space)
    (send window :set-current-font cue-font)
    (write-string "Address " window)
    (send window :set-current-font default-font)
    (send window :item1 x 'network-address-address
	  #'(lambda (ignore window)
	      (send window :string-out
		    (if -address- (net::unparse-address -address- -network-) "Fill in"))))))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#25 at 7-Mar-86 21:24:47
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defun (:property :chaos valid-address-p) (x)
  (typep x '(fixnum #16r100 #16rFFFF)))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#25 at 7-Mar-86 21:24:48
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defun (:property :internet valid-address-p) (x)
  (typep x '(integer #16r1000000 #16rFFFFFFFF)))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#25 at 7-Mar-86 21:24:50
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defun valid-address-for-network-p (network-type address)
  (funcall (or (get network-type 'valid-address-p) #'identity) address))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#25 at 7-Mar-86 21:24:51
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defun valid-address-p (address)
  (valid-address-for-network-p (car address) (cadr address)))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#25 at 7-Mar-86 21:24:53
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defmethod (network-address :case :edit network-address-network) ()
  (let ((new (choose-or-read (get-restriction 'network) #'string-to-keyword "Network")))
    (when address
      (let ((host (get-host-from-address (list new address))))
	(when host
	  (complain "~A already has the ~A address of ~A." host network
		    (net::unparse-address new network))
	  (abort-edit)))
      (unless (valid-address-for-network-p new address)
	(format *query-io* "~A is not a valid address for the ~A network.~%"
		(net::unparse-address address network) new)
	(if
	  (fquery '(:beep t :type :tyi :list-choices t :fresh-line t
		    :choices (((t "Erase address") #\E) ((nil "Keep network") #\K)))
		  "Keep the old network (~A) or Erase the current address ? " network)
	  (setq address nil)
	  (abort-edit))))
    (setq network new)))



;;; This can be called after clicking on a void address

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#25 at 7-Mar-86 21:24:56
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defmethod (network-address :case :edit network-address-address) ()
  (if network
      (let ((new
	      (funcall (if (member network (get-restriction 'network))
			   (let ((-network- network)) ; grumble....
			     #'(lambda (string) (net:parse-address string -network-)))
			 #'identity)
		       (query-read-line "Address: "))))
	(let ((host (get-host-from-address (list network new))))
	  (when host
	    (complain "~A already has the ~A address of ~A." host network
		      (net::unparse-address new network))
	    (abort-edit)))
	(setq address new))
    (complain "You need to specify a network type first.")
    (abort-edit)))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#25 at 7-Mar-86 21:24:59
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defmethod (host :network-address-p) (address)
  (zl:member address addresses))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#25 at 7-Mar-86 21:25:01
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defun get-host-from-address (address)
  (car (member address (all-class-objects :host)
	       :test #'(lambda (a h) (send h :network-address-p a)))))

;;; >Assuming numeric addresses here, not hacking subnets

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#25 at 7-Mar-86 21:25:04
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "

(defun generate-new-address (address)
  (let ((test-address (copy-list address)))
    (loop
      (if (get-host-from-address test-address)
	  (incf (second test-address))
	(return test-address)))))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#25 at 7-Mar-86 21:25:05
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "


(defun make-like-addresses (addresses)
  (mapcar #'generate-new-address addresses))

))

; From modified file DJ: L.NETWORK.EDIT; MAIN.LISP#13 at 7-Mar-86 21:25:36
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; MAIN  "

(defun initialize-if-needed ()
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

; From modified file DJ: L.NETWORK.EDIT; MAIN.LISP#13 at 7-Mar-86 21:25:47
#10R SITE-DATA-EDIT#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; MAIN  "

(defmethod (site-editor-frame :after :select) (&rest ignore)
  ;;>> How are you sure to get the TEXT blinker ?
  (let ((blinker (car (send self :send-pane 'typeout-pane :blinker-list))))
    (send blinker :set-visibility :blink)))

))
