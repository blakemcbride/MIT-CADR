;;; -*- Mode:Lisp; Readtable:ZL; Package:USER; Base:8; Patch-File:T -*-
;;; Patch file for System version 300.8
;;; Reason:
;;;  MAYBE-GET-DISK-RQB: New macro.
;;;  MAYBE-DISK-RQB: New function.
;;; Written 24-Oct-24 21:17:55 by ams,
;;; while running on Lisp Machine One from band 3
;;; with Experimental System 300.0, microcode 323.



; From file OZ: /sys/io/disk.lisp.294 at 24-Oct-24 21:18:06
#8R SYSTEM-INTERNALS#:
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SYSTEM-INTERNALS")))
  (COMPILER::PATCH-SOURCE-FILE "OZ: //sys//io//disk"

(DEFUN MAYBE-GET-DISK-RQB (&REST L)
  (DECLARE (ARGLIST &OPTIONAL (N-PAGES 1) LEADER-LENGTH)
	   (VALUES RQB RETURNP))
  (COND ((TYPEP (CAR L) 'ARRAY)
	 (VALUES (CAR L) NIL))
	('ELSE
	 (VALUES (APPLY 'GET-DISK-RQB L) T))))

(DEFUN MAKE-DISK-RQB (IGNORE N-PAGES LEADER-LENGTH)
  (LET* ((OVERHEAD (+ 4 4 3 LEADER-LENGTH))
	 (ARRAY-LENGTH (* (- (* (1+ N-PAGES) PAGE-SIZE) OVERHEAD) 2))
	 RQB-BUFFER
	 RQB-8-BIT-BUFFER
	 RQB)
    ;; Compute how much overhead there is in the RQB-BUFFER,
    ;; RQB-8-BIT-BUFFER, and in the RQB's leader and header.  4 for the
    ;; RQB-BUFFER indirect-offset array, 4 for the RQB-8-BIT-BUFFER
    ;; indirect-offset array, 3 for the RQB's header, plus the RQB's leader.
    ;; Then set the length (in halfwords) of the array to be sufficient so
    ;; that it plus the overhead is a multiple of the page size, making it
    ;; possible to wire down RQB's.
    (WHEN (> ARRAY-LENGTH %ARRAY-MAX-SHORT-INDEX-LENGTH)
      (INCF OVERHEAD 1)
      (DECF ARRAY-LENGTH 2)
      (UNLESS (> ARRAY-LENGTH %ARRAY-MAX-SHORT-INDEX-LENGTH)
	(FERROR NIL "Impossible to make this RQB array fit")))
    ;; See if the CCW list will run off the end of the first page, and hence
    ;; not be stored in consecutive physical addresses.
    (IF (> (+ OVERHEAD (FLOOR %DISK-RQ-CCW-LIST 2) N-PAGES) PAGE-SIZE)
	(FERROR 'RQB-TOO-LARGE "CCW list doesn't fit on first RQB page, ~S pages is too many"
		N-PAGES))
    (TAGBODY
     L	(SETQ RQB-BUFFER (MAKE-ARRAY (* PAGE-SIZE 2 N-PAGES)
				     :TYPE ART-16B
				     :AREA DISK-BUFFER-AREA
				     :DISPLACED-TO ""
				     :DISPLACED-INDEX-OFFSET	;To second page of RQB
				     	(- ARRAY-LENGTH (* PAGE-SIZE 2 N-PAGES)))
	      RQB-8-BIT-BUFFER (MAKE-ARRAY (* PAGE-SIZE 4 N-PAGES)
					   :TYPE ART-STRING
					   :AREA DISK-BUFFER-AREA
					   :DISPLACED-TO ""
					   :DISPLACED-INDEX-OFFSET
					   	(* 2 (- ARRAY-LENGTH (* PAGE-SIZE 2 N-PAGES))))
	      RQB (MAKE-ARRAY ARRAY-LENGTH
			      :AREA DISK-BUFFER-AREA
			      :TYPE ART-16B
			      :LEADER-LENGTH LEADER-LENGTH))
	(WHEN ( (%REGION-NUMBER RQB-BUFFER)	;make sure a new region
		 (%REGION-NUMBER RQB))		;didn't screw us completely
	  ;; Screwed! Try again.  Make sure don't lose same way again by
	  ;;  using up region that didnt hold it.
	  (RETURN-ARRAY RQB)
	  (LET ((RN (%REGION-NUMBER RQB-BUFFER)))
	    (RETURN-ARRAY RQB-BUFFER)
	    (%USE-UP-REGION RN))
	  (GO L)))
    (MAKE-SURE-FREE-POINTER-OF-REGION-IS-AT-PAGE-BOUNDARY
      'DISK-BUFFER-AREA (%REGION-NUMBER RQB))
    (%P-STORE-CONTENTS-OFFSET RQB RQB-BUFFER 1)	;Displace RQB-BUFFER to RQB
    (%P-STORE-CONTENTS-OFFSET RQB RQB-8-BIT-BUFFER 1)
    (STORE-ARRAY-LEADER (+ %DISK-RQ-CCW-LIST (* 2 N-PAGES))
			RQB
			%DISK-RQ-LEADER-N-HWDS)
    (SETF (ARRAY-LEADER RQB %DISK-RQ-LEADER-N-PAGES) N-PAGES)
    (SETF (ARRAY-LEADER RQB %DISK-RQ-LEADER-BUFFER) RQB-BUFFER)
    (SETF (ARRAY-LEADER RQB %DISK-RQ-LEADER-8-BIT-BUFFER) RQB-8-BIT-BUFFER)
    RQB))

))
