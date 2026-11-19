;;;-*- Mode:LISP; Package:SYSTEM-INTERNALS; Base:8 -*-

(DEFSITE :LM-3
  (:TIMEZONE 5)	    ;EST

  ;; These two say how to log in to get error tables, etc.
  (:SYS-LOGIN-NAME "LISPM")
  (:SYS-LOGIN-PASSWORD "LISPM")

  ;; Hosts suspected of supporting time servers
  (:CHAOS-TIME-SERVER-HOSTS '("LOCAL-BRIDGE"))

  (:NON-CHAOS-HOST-TABLE-FILE "SYS: SITE; EXTRA HOSTS")

  )
