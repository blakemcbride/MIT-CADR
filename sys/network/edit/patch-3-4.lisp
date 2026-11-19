;;; -*- Mode:Lisp; Readtable:CL; Package:SITE-DATA-EDIT; Base:10; Patch-File:T -*-
;;; Patch file for Site Data Editor version 3.4
;;; Reason:
;;;  :SELECTABLE-WINDOWS returns site-editor-frame (not interaction pane).
;;; Written 12-Sep-86 17:24:01 by mrc (Meryl R. Cohen) at site LMI Cambridge
;;; while running on Boris Badinoff from band 1
;;; with System 110.232, Local-File 68.7, FILE-Server 18.4, Unix-Interface 9.1, Tape 6.39, Tiger 24.0, KERMIT 31.3, MICRO-COMPILATION-TOOLS 3.4, ZMail 65.14, Lambda-Diag 7.17, TCP-Kernel 41.0, TCP-User 63.0, TCP-Server 46.0, Object Lisp 5.0, Site Data Editor 3.3, System Revision Level 3.174, microcode 1581, SDU Boot Tape 3.12, SDU ROM 102, Real Release 3.0 	 (mrc 9/10/86).



; From modified file LAD: RELEASE-3.NETWORK.EDIT; MAIN.LISP#27 at 12-Sep-86 17:24:02
#10R SITE-DATA-EDIT#: 
(COMPILER-LET ((*PACKAGE* (PKG-FIND-PACKAGE "SITE-DATA-EDIT")))
  (COMPILER::PATCH-SOURCE-FILE "SYS: NETWORK; EDIT; MAIN  "

(defmethod (site-editor-frame :selectable-windows) ()
  `(("Site Editor" ,self)))

))
