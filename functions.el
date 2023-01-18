;;; functions.el --- My functions.

;; Copyright (C) 2023 Renato Athaydes


;; Author: Renato Athaydes
;; Version: 1.0
;; Keywords: personal
;; URL: https://github.com/renatoathaydes/emacs.d

;;; Commentary:

;; My personal functions for Emacs.

;;; Code:

(defun workspace-unison ()
  "Open an Unison workspace."
  (interactive)
  (functions/workspace2
   (lambda ()
     (find-file "~/programming/experiments/unison/scratch.u"))
   (lambda ()
     (shell)
     (insert "ucm")
     (funcall (lookup-key (current-local-map) (kbd "RET"))))))

(defun workspace-lisp ()
  "Open a SLIME workspace."
  (interactive)
  (functions/workspace2
   (lambda ()
     (find-file "~/programming/experiments/lisp/scratch.lisp"))
   (lambda () (slime))))

(defun functions/workspace2 (buffer-left buffer-right)
  "Open the Unison scratch next to a shell running UCM.
`BUFFER-LEFT` should be a function that runs while on the left buffer.
`BUFFER-RIGHT` runs while on the rigth buffer.'"
  (delete-other-windows)
  (funcall buffer-left)
  (split-window-right)
  (other-window 0)
  (funcall buffer-right))

;; Helpful functions (available everywhere, including eshell)
(defun j11 ()
  "Use Java 11."
  (setenv "JAVA_HOME" (expand-file-name "~/.sdkman/candidates/java/11.0.13-zulu")))
(defun j17 ()
  "Use Java 17."
  (setenv "JAVA_HOME" (expand-file-name "/~.sdkman/candidates/java/17.0.5-zulu")))

(provide 'functions)
;;; functions.el ends here
