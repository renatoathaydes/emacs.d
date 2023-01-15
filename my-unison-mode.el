;;; package --- Summary
;;; Unison code syntax highlighter.

;; Copyright © 2023, by Renato Athaydes

;; Author: Renato Athaydes ( renato@athaydes.com )
;; Version: 1.0
;; Created: 14 Jan 2023
;; Keywords: languages, Unison
;; Homepage: https://github.com/renatoathaydes/unison.el

;; This file is not part of GNU Emacs.

;;; License:

;; You can redistribute this program and/or modify it under the terms of the GNU General Public License version 2.

;;; Commentary:

;; This package was created because the unison-mode package is currently unmaintained.

;;; Code:

(defvar unison-highlights nil "Unison highlighter rules.")

(setq unison-highlights
      (let* (
             ;; define several category of keywords
             (x-keywords '("let" "type" "do" "else" "then" "if"
                           "ability" "where" "handle" "with" "cases"))
             (x-types '("Nat" "Text" "Int" "Optional" "Request" "Map" "List"))
             (x-constants '("unique" "structural"))
;;             (x-events '("at_rot_target" "at_target" "attach"))
;;             (x-functions '("llAbs" "llAcos" "llAddToLandBanList" "llAddToLandPassList"))

             ;; generate regex string for each category of keywords
             (x-keywords-regexp (regexp-opt x-keywords 'words))
             (x-types-regexp (regexp-opt x-types 'words))
             (x-constants-regexp (regexp-opt x-constants 'words)))
;;             (x-events-regexp (regexp-opt x-events 'words))
;;             (x-functions-regexp (regexp-opt x-functions 'words)))

        `(
          ("{\\|}" . 'font-lock-function-name-face)
          ("{\\([^<]+?\\)}" . (1 'font-lock-constant-face))
          (,x-types-regexp . 'font-lock-type-face)
          (,x-constants-regexp . 'font-lock-constant-face)
;;          (,x-events-regexp . 'font-lock-builtin-face)
;;          (,x-functions-regexp . 'font-lock-function-name-face)
          (,x-keywords-regexp . 'font-lock-keyword-face)
          ;; note: order above matters, because once colored, that part won't change.
          ;; in general, put longer words first
          )))

;;;###autoload
(define-derived-mode my-unison-mode fundamental-mode "Unison"
  "Major mode for editing Unison language code."
  (setq font-lock-defaults '((unison-highlights))))

(add-to-list 'auto-mode-alist '("\\.u\\'" . my-unison-mode))

;;; my-unison-mode.el ends here
