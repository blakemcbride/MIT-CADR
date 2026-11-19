;;; -*- Mode:Lisp; Readtable:CL; Package:SITE-DATA-EDIT; Base:10; Patch-File:T -*-
;;; Patch file for Site Data Editor version 5.1
;;; Reason:
;;;  Add changes for new network system:
;;;  
;;;  NETWORK class defines networks by name, addressing domains, network numbers, and subnet masks.
;;;  You can't give a processor an address that is on an unknown network.
;;;  You can't give a processor an address that is already used -- this is incompatible
;;;    with old system!
;;;  Fixed a few typos in documentation displayed to user.
;;;  Fixed a few bugs in checking of user parameters.
;;; Written 5-Aug-87 14:52:50 by pld (Peter L. DeWolf) at site LMI Cambridge
;;; while running on Azathoth from band 4
;;; with Experimental System 122.10, Experimental Local-File 73.0, Experimental FILE-Server 22.0, Experimental Unix-Interface 11.0, Experimental Tape 17.1, Experimental Tiger 26.0, Experimental KERMIT 33.1, Experimental ZMail 71.0, Experimental Lambda-Diag 15.0, Experimental Site Data Editor 5.0, microcode 1754, SDU Boot Tape 3.12, SDU ROM 102, the old ones.



; From file DJ: L.NETWORK.EDIT; ATTRIBUTE.LISP#9 at 5-Aug-87 14:52:51
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; ATTRIBUTE  "

(defflavor user-property () (value-variable-mixin attribute)
  (:default-init-plist :ok-if-void-p t :name "Property")
  (:documentation "Represents an arbitrary property.
This consists of a keyword (stored in the KEY) instance variable and a value, which can be
any Lisp object."))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#33 at 5-Aug-87 14:56:33
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "

(defflavor network-address (addressing-domain address) (value-method-mixin attribute)
  (:default-init-plist :name "Address" :ok-if-void-p t)
  (:init-keywords :value))

(defmethod (network-address :set-value) (list)
  (setf `(,addressing-domain ,address) list))

(defmethod (network-address :print-value) (stream escape-p)
  (write-char #\{ stream)
  (write addressing-domain :stream stream :escape escape-p)
  (when address
    (write-string ", " stream)
    (write-string (net::unparse-address address addressing-domain) stream))
  (write-char #\} stream))

(defmethod (network-address :value) ()
  (list addressing-domain address))

(defmethod (network-address :void-p) ()
  (null addressing-domain))

(defmethod (network-address :output-value) (window)
  (let ((x self) (-addressing-domain- addressing-domain) (-address- address))
    (send window :set-current-font cue-font)
    (write-string "Addressing domain " window)
    (send window :set-current-font default-font)
    (send window :item1 x 'network-address-addressing-domain
	  #'(lambda (ignore window)
	      (send window :string-out (symbol-name -addressing-domain-))))
    (send window :tyo #\Space)
    (send window :set-current-font cue-font)
    (write-string "Address " window)
    (send window :set-current-font default-font)
    (send window :item1 x 'network-address-address
	  #'(lambda (ignore window)
	      (send window :string-out
		    (if -address- (net::unparse-address -address- -addressing-domain-) "Fill in"))))))

(defun (:property :internet valid-address-p) (x)
  (and (typep x '(integer #16r1000000 #16rFFFFFFFF))
       (cond ((= (ldb (byte 1 31) x) 0)
	      (not (zerop (ldb (byte 24 0) x))))
	     ((= (ldb (byte 2 30) x) 2)
	      (not (zerop (ldb (byte 16 0) x))))
	     ((= (ldb (byte 3 29) x) 6)
	      (not (zerop (ldb (byte 8 0) x))))
	     (t nil))))

(defun valid-address-for-addressing-domain-p (addressing-domain address)
  (funcall (or (get addressing-domain 'valid-address-p) #'identity) address))

(defun valid-address-p (address)
  (valid-address-for-addressing-domain-p (car address) (cadr address)))

(defmethod (network-address :case :edit network-address-addressing-domain) ()
  (let ((new (choose-or-read (get-restriction 'addressing-domain) #'string-to-keyword "Addressing Domain")))
    (when address
      (check-shared-addresses new address)
      (unless (valid-address-for-addressing-domain-p new address)
	(format *query-io* "~A is not a valid address for the ~A addressing domain.~%"
		(net::unparse-address address addressing-domain) new)
	(if (fquery '(:beep t :type :tyi :list-choices t :fresh-line t
			    :choices (((nil "Keep addressing domain") #\K) ((t "Erase address") #\E)))
		    "Keep the old addressing-domain (~A) or Erase the current address ? " addressing-domain)
	    (setq address nil)
	  (abort-edit))))
    (setq addressing-domain new)))

;;; This can be called after clicking on a void address
(defmethod (network-address :case :edit network-address) ()
  (send self :edit 'network-address-addressing-domain)
  (send self :edit 'network-address-address))

(defmethod (network-address :case :edit network-address-address) ()
  (if addressing-domain
      (let ((new
	      (funcall (if (member addressing-domain (get-restriction 'addressing-domain))
			   (let ((-addressing-domain- addressing-domain)) ; grumble....
			     #'(lambda (string) (net:parse-address string -addressing-domain-)))
			 #'identity)
		       (query-read-line "Address: "))))
	(check-shared-addresses addressing-domain new)
	(setq address new))
    (progn
      (complain "You need to specify a addressing domain first.")
      (abort-edit))))

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
  (let ((network-number (funcall (get addressing-domain 'network-number-from-address #'identity) address)))
    (unless (find-network-by-network-number network-number addressing-domain)
      (complain "~A address ~A is on network ~A, which is unknown"
		addressing-domain
		(net::unparse-address address addressing-domain)
		(net::unparse-address network-number addressing-domain))
      (abort-edit))))

(defun (:property :chaos network-number-from-address) (address)
  (ldb (byte 8 8) address))

(defun (:property :internet network-number-from-address) (address)
  (cond ((= (ldb (byte 1 31) address) 0)
	 (dpb (ldb (byte 8 24) address) (byte 8 24) 0))
	((= (ldb (byte 2 30) address) 2)
	 (dpb (ldb (byte 16 16) address) (byte 16 16) 0))
	((= (ldb (byte 3 29) address) 6)
	 (dpb (ldb (byte 24 8) address) (byte 24 8) 0))
	(t address)))

(compile-flavor-methods network-address)

(add-restrictions 'addressing-domain :chaos :internet)

))

; From modified file DJ: L.NETWORK.EDIT; MAIN.LISP#31 at 6-Aug-87 12:22:17
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
		  (send object :remove))
	      (progn
		(complain "Some objects are currently referring to this object:")
		(terpri *error-output*)
		(format:print-list *error-output* "~A" referrers)
		(terpri *error-output*))))
	(complain "You can't delete this object.")))))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#33 at 6-Aug-87 12:31:58
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "

;;; Network-spec: (addressing-domain network-number [subnet-mask])
(defflavor network-spec (addressing-domain network-number subnet-mask) (value-method-mixin attribute)
  (:default-init-plist :name "Network Spec" :ok-if-void-p t)
  (:init-keywords :value))

(defmethod (network-spec :set-value) (list)
  (setf `(,addressing-domain ,network-number ,subnet-mask) list))

(defmethod (network-spec :print-value) (stream escape-p)
  (write-char #\( stream)
  (write addressing-domain :stream stream :escape escape-p)
  (write-char #\Space stream)
  (write-string (net::unparse-address network-number addressing-domain) stream)
  (when subnet-mask
    (write-char #\Space stream)
    (write-string (net::unparse-address subnet-mask addressing-domain) stream))
  (write-char #\) stream))

(defmethod (network-spec :value) ()
  (append (ncons addressing-domain)
	  (ncons network-number)
	  (if subnet-mask (ncons subnet-mask))))

(defmethod (network-spec :multiple-p) () t)

(defmethod (network-spec :void-p) ()
  (null addressing-domain))

(defmethod (network-spec :cue-string) () "")

(defmethod (network-spec :output-value) (window)
  (let ((x self)
	(-addressing-domain- addressing-domain)
	(-network-number- network-number)
	(-subnet-mask- subnet-mask))
    (send window :set-current-font cue-font)
    (write-string "Addressing Domain " window)
    (send window :set-current-font default-font)
    (send window :item1 x 'network-spec-addressing-domain
	  #'(lambda (ignore window)
	      (send window :string-out (symbol-name -addressing-domain-))))
    (send window :tyo #\Space)
    (send window :set-current-font cue-font)
    (write-string "Network Number " window)
    (send window :set-current-font default-font)
    (send window :item1 x 'network-spec-network-number
	  #'(lambda (ignore window)
	      (send window :string-out (and -network-number-
					    (net::unparse-address -network-number- -addressing-domain-)))))
    (send window :tyo #\Space)
    (send window :set-current-font cue-font)
    (write-string "Subnet Mask " window)
    (send window :set-current-font default-font)
    (send window :item1 x 'network-spec-subnet-mask
	  #'(lambda (ignore window)
	      (send window :string-out (and -subnet-mask-
					    (net::unparse-address -subnet-mask- -addressing-domain-)))))))

(defmethod (network-spec :case :edit network-spec-addressing-domain) ()
  (let ((new (choose-or-read (get-restriction 'addressing-domain) #'string-to-keyword "Addressing Domain")))
    (setq addressing-domain new)))

(defmethod (network-spec :case :edit network-spec-network-number) ()
  (let ((new (funcall (let ((-addressing-domain- addressing-domain))	; grumble....
			#'(lambda (string) (net:parse-address string -addressing-domain-)))
		      (query-read-line "Network Number: "))))
    (unless (valid-network-for-addressing-domain-p addressing-domain new)
      (format *query-io* "~A is not a valid network for the ~A addressing domain.~%"
	      (net::unparse-address new addressing-domain) addressing-domain)
      (abort-edit))
    (let ((network (find-network-by-network-number new addressing-domain)))
      (when network
	(format *query-io* "~A already has ~A network number ~A.~%"
		(send network :name)
		addressing-domain
		(net::unparse-address new addressing-domain))
	(abort-edit)))
    (setq network-number new)))

(defun (:property :chaos valid-network-p) (x)
  (and x (not (minusp x)) (< x 256)))

(defun (:property :internet valid-network-p) (x)
  (or (and (= (ldb (byte 1 31) x) 0)
	   (not (zerop (ldb (byte 8 24) x)))
	   (zerop (ldb (byte 24 0) x)))
      (and (= (ldb (byte 2 30) x) 2)
	   (zerop (ldb (byte 16 0) x)))
      (and (= (ldb (byte 3 29) x) 6)
	   (zerop (ldb (byte 8 0) x)))))

(defun valid-network-for-addressing-domain-p (addressing-domain network)
  (funcall (or (get addressing-domain 'valid-network-p) #'identity) network))

(defmethod (network-spec :case :edit network-spec-subnet-mask) ()
  (when (addressing-domain-needs-subnet-mask addressing-domain)
    (let* ((string (query-read-line "Subnet Mask: "))
	   (new (and (plusp (length string))
		     (let ((-addressing-domain- addressing-domain))	; grumble....
		       (net:parse-address string -addressing-domain-)))))
      (unless (valid-subnet-mask-for-addressing-domain-and-network-number-p addressing-domain network-number new)
	(format *query-io* "~A is not a valid subnet mask for network ~A in the ~A addressing domain.~%"
		(net::unparse-address new addressing-domain)
		(net::unparse-address network-number addressing-domain)
		addressing-domain)
	(abort-edit))
      (setq subnet-mask new))))

(defun (:property :chaos valid-subnet-mask-p) (network-number subnet-mask)
  (declare (ignore network-number))
  (null subnet-mask))

(defun (:property :internet valid-subnet-mask-p) (network-number subnet-mask)
  (or (null subnet-mask)
      (and (= (ldb (byte 1 31) network-number) 0)
	   (= (ldb (byte 8 24) subnet-mask) #xff))
      (and (= (ldb (byte 2 30) network-number) 2)
	   (= (ldb (byte 16 16) subnet-mask) #xffff))
      (and (= (ldb (byte 3 29) network-number) 6)
	   (= (ldb (byte 24 8) subnet-mask) #xffffff))))

(defun valid-subnet-mask-for-addressing-domain-and-network-number-p (addressing-domain network subnet-mask)
  (let ((func (get addressing-domain 'valid-subnet-mask-p)))
    (if func
	(funcall func network subnet-mask)
      (null subnet-mask))))

(setf (get :chaos 'subnet-mask-p) nil)
(setf (get :internet 'subnet-mask-p) t)

(defun addressing-domain-needs-subnet-mask (addressing-domain)
  (get addressing-domain 'subnet-mask-p))

;;; This can be called after clicking on a void network-spec
(defmethod (network-spec :case :edit network-spec) ()
  (send self :edit 'network-spec-addressing-domain)
  (send self :edit 'network-spec-network-number)
  (if (addressing-domain-needs-subnet-mask addressing-domain)
      (send self :edit 'network-spec-subnet-mask)
    (setq subnet-mask nil)))

(compile-flavor-methods network-spec)

))

; From modified file DJ: L.NETWORK.EDIT; MAIN.LISP#31 at 6-Aug-87 12:33:12
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; MAIN  "

(defun read-outside-data ()
  (format t "~&Loading data from:~
             ~%  Site Wide Option Table: ~S~
             ~%  Host    Option   Table: ~S~
             ~%  Host    Address  Table: ~S"
	  *site-option-file*
	  *machine-location-alist-file*
	  *hosts2-table-file*)
  (assure-class-stores)
  (clear-all-stores)
  (init-site-variables)
  (make-printers)
  (make-site *site-name* *site-option-alist*)
  (init-hosts)
  (make-hosts-complete)
  (make-networks)
  (setq *need-to-look-at-external-data* nil)
  (setq *data-loaded-once-p* t))

))

; From modified file DJ: L.NETWORK.EDIT; DATA-TYPES.LISP#33 at 6-Aug-87 12:38:36
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; DATA-TYPES  "

;;;Network class
(defclass network (:documentation "Represents a network at this site")
  ((network-specs nil))
  ()
  :inittable-instance-variables
  (:init-keywords :spec)
  (:required-init-keywords :spec)
  :gettable-instance-variables)

(defmethod (network :deletable-p) () t)

(defmethod (network :short-name) ()
  (or (getp 'short-name)
      (car nicknames)
      name))

(defmethod (network :before :init) (plist)
  (setq network-specs (get plist :spec)))

(defmethod (network :spec) ()
  network-specs)

;;; Not exactly the most efficient thing the world...
(defmethod (network :network-names) ()
  (append nicknames (ncons name)))

(defmethod (network :append :editor-attributes) ()
  (let ((attributes (make-list-of-attributes 'network-spec network-specs)))
    (when (getp 'short-name)
      (push (make-instance 'self-name :name "Short Name" :key 'short-name
			   :value (getp 'short-name) :object self :class :network)
	    attributes))
    attributes
    ))

(defmethod (network :case :update-property network-spec) (newval oldval)
  (if oldval
      (setf (car (member oldval network-specs :test #'equal)) newval)
    (push newval network-specs)))

(defmethod (network :case :delete-property network-spec) (oldval)
  (setq network-specs (delete oldval network-specs :test #'equal)))

(define-ignored-site-attribute :network-names)

(defmethod (network :make-copy) ()
  (let ((n (make-instance 'network
			  :name (generate-name (send self :site-name) :network)
			  :nicknames ()
			  :spec ())))
    (send n :add)
    n))

(defmethod (network :dump-to-site-info) ()
  (push	(list (cons name nicknames) (send self :spec)) (get-site-wide-option :network-names)))

(defun make-networks ()
  (map ()
    #'(lambda (entry)
	(send (make-instance 'network
			     :name (first (first entry))
			     :nicknames (rest (first entry))
			     :spec (second entry))
	      :add))
    (get-site-wide-option :network-names))
  (unless (all-class-objects :network)
    (format *query-io* "No Networks are defined in the site files.  Please name one.")
    (ask-user-for-network-name)))

(defun find-network-by-network-number (number domain)
  (dolist (x (all-class-objects :network))
    (dolist (network-spec (send x :spec))
      (and (eq domain (first network-spec))
	   (= number (second network-spec))
	   (return-from find-network-by-network-number x)))))

(compile-flavor-methods network)

(defun ask-user-for-network-name ()
  (flet ((ask ()
	   (let ((string (prompt-and-read :string-or-nil "~&Network Name: ")))
	     (and string (string-upcase string)))))
    (do ((string (ask) (ask)))
	(nil)
      (cond ((null string)
	     (format *query-io* "~&Please supply a name."))
	    ((find-object-of-class :network string)
	     (format *query-io* "~&That name has already been given to another network."))
	    ((verify-string string atomic-name-bit-vector)
	     (send (make-instance 'network :name string :nicknames () :spec ()) :add)
	     (return string))
	    (t
	     (format *query-io*
		     "~&The name should have only type of characters that a host name would have."))))))

))
