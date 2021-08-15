(eval-when-compile
  (require 'use-package))

(put 'erase-buffer 'disabled nil)
(setq inhibit-splash-screen t)
(transient-mark-mode 1)
(savehist-mode 1)
(add-hook 'after-init-hook 'global-company-mode)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;; Fixes issue with https: https://emacs.stackexchange.com/questions/61386/package-refresh-hangs
(custom-set-variables
 '(gnutls-algorithm-priority "normal:-vers-tls1.3"))

;; Fixes flickering on Mac: https://www.reddit.com/r/emacs/comments/mc82yk/flickering_emacs_on_macos/
(modify-all-frames-parameters '((inhibit-double-buffering . t)))

;; Custom key bindings
(global-set-key "\C-c\C-d" "\C-a\C- \C-n\M-w\C-y")

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
(use-package rust-mode :ensure t)

(use-package projectile
  :ensure t
  :init (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map)))

(use-package org
  :ensure t
  :init (org-babel-do-load-languages
	 'org-babel-load-languages
	 '((java . t))))


;; Beautify org-mode: https://zzamboni.org/post/beautifying-org-mode-in-emacs/
(setq org-hide-emphasis-markers t)

(find-file "~/.emacs.d/init.el")
