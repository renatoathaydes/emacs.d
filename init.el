;;; init.el --- Renato's Emacs init file
;;; Code:

(eval-when-compile
  (require 'use-package))

(put 'erase-buffer 'disabled nil)
(setq inhibit-splash-screen t)
(transient-mark-mode 1)
(savehist-mode 1)
(setq visible-bell t)
(setq ring-bell-function 'ignore)
(add-hook 'after-init-hook 'global-company-mode)
(setq dired-listing-switches "-alh")
(setq ido-enable-flex-matching t)
(display-time-mode 1)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;; Fixes issue with https: https://emacs.stackexchange.com/questions/61386/package-refresh-hangs
(custom-set-variables
 '(gnutls-algorithm-priority "normal:-vers-tls1.3"))


;;; Commentary:
;; 

(require 'package)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")))

(require 'ido)
(ido-mode t)

;; External packages

(setq inferior-lisp-program "/usr/local/bin/sbcl")

(use-package markdown-mode :ensure t)
(use-package magit :ensure t)
(use-package flycheck :ensure t
  :init (global-flycheck-mode))
(use-package lsp-mode :ensure t)
(use-package rustic :ensure t)
(use-package rust-playground :ensure t)
(use-package crux :ensure t
  :bind (("C-a" . crux-move-beginning-of-line)
         ("s-<return>" . crux-smart-open-line)
         ("s-S-<return>" . crux-smart-open-line-above)
         ("C-c d" . crux-duplicate-current-line-or-region)
         ("C-c k" . crux-kill-other-buffers)))

(use-package projectile
  :ensure t
  :init (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map)))

(use-package org
  :ensure t
  :init (org-babel-do-load-languages
	     'org-babel-load-languages
	     '((rust . t))))

;; Beautify org-mode: https://zzamboni.org/post/beautifying-org-mode-in-emacs/
(setq org-hide-emphasis-markers t)

(find-file "~/.emacs.d/init.el")

(provide 'init)

;;; init.el ends here
