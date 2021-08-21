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
(setq dired-listing-switches "-alh")
(display-time-mode t)
(show-paren-mode t)
(setq tab-width 2)
(setq-default indent-tabs-mode nil)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;; Fixes issue with https: https://emacs.stackexchange.com/questions/61386/package-refresh-hangs
(custom-set-variables
 '(gnutls-algorithm-priority "normal:-vers-tls1.3"))

;; highlight matching parens
(electric-pair-mode 1)
;; electric-newline-add-maybe-indent shortcut is not needed,
;; I want this for inserting snippets as in IntelliJ
(global-unset-key (kbd "C-j"))
(setq inferior-lisp-program "/usr/local/bin/sbcl")

;;; Package repositories
(require 'package)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")))

;;; Built-in packages:

;;; ido suggests and auto-completes buffers and files
(require 'ido)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode t)

;;; enable recentf to display recently visited files
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

;;; External packages

;; auto-complete inside text/code buffers
(use-package company :ensure t :hook (('after-init-hook . 'global-company-mode)))
;; shows which keys can be pressed after an initial keystroke
(use-package which-key :ensure t :init (which-key-mode))
;; move text up/down easily
(use-package move-text :ensure t
  :bind (("s-<up>" . 'move-text-up) ("s-<down>" . 'move-text-down)))
;; support for markdown
(use-package markdown-mode :ensure t)
;; support for git
(use-package magit :ensure t)
;; syntax checker on the fly
(use-package flycheck :ensure t :init (global-flycheck-mode))
;; enable ido in more places
(use-package ido-completing-read+ :ensure t :init (ido-ubiquitous-mode 1))
;; expands marked region easily
(use-package expand-region :ensure t
  :bind (("M-<up>" . 'er/expand-region) ("M-<down>" . 'er/contract-region)))
;; better way to switch between open windows
(use-package ace-window :ensure t :bind ("C-<tab>" . 'ace-window))

;; God mode (modal editing)
(defun my-god-mode-update-cursor-type ()
  (setq cursor-type (if (or god-local-mode buffer-read-only) 'box 'bar)))
(use-package god-mode :ensure t
  :bind (("<escape>" . #'god-mode-all))
  :config (add-hook 'post-command-hook #'my-god-mode-update-cursor-type)
  :init (require 'god-mode-isearch)
  (define-key isearch-mode-map (kbd "<escape>") #'god-mode-isearch-activate)
  (define-key god-mode-isearch-map (kbd "<escape>") #'god-mode-isearch-disable))

;; LSP (Language Server Protocol) - support for multiple languages
(use-package lsp-mode
  :hook ((lsp-mode . lsp-enable-which-key-integration))
  :config
	(setq lsp-completion-enable t lsp-enable-on-type-formatting t)
	(require 'lsp-ido)
	(global-set-key (kbd "M-s-l") 'lsp-format-buffer)
  (global-set-key (kbd "C-c h") 'lsp-ui-doc-focus-frame)
  :hook ((lsp-mode . lsp-enable-which-key-integration)))

;; shows up code actions, documentation etc. on the screen
(use-package lsp-ui
  :bind (:map lsp-mode-map ("C-c C-h" . lsp-ui-doc-glance))
  :config (setq lsp-ui-doc-enable nil))

;; Rust
(use-package rustic :ensure t)
(use-package ob-rust :ensure t)

;; Java
(use-package lsp-java
  :config (add-hook 'java-mode-hook 'lsp)
  :init (setq
	 ;; Fetch less results from the Eclipse server
         lsp-java-completion-max-results 20))

(defun my-java-mode-hook ()
  (auto-fill-mode)
  (subword-mode))
(add-hook 'java-mode-hook 'my-java-mode-hook)

;; TODO edit Java formatter in emacs
;; https://gist.github.com/fbricon/30c5971f7e492c8a74ca2b2d7a7bb966

;; Debugger
(use-package dap-mode :after lsp-mode :config (dap-auto-configure-mode))
;; (use-package dap-java :ensure nil)
;; (use-package helm-lsp)
;; (use-package helm
;; :config (helm-mode))

;; (use-package dap-java
;;   :ensure t
;;   :after (lsp-java)
;;   :config
;;   (global-set-key (kbd "<f7>") 'dap-step-in)
;;   (global-set-key (kbd "<f8>") 'dap-next)
;;   (global-set-key (kbd "<f9>") 'dap-continue))

;; Groovy
(use-package groovy-mode :ensure t)

;; Inserts code snippets
(use-package yasnippet :ensure t :init (yas-global-mode 1)
  :bind (("C-j" . yas-insert-snippet)))

;; Fancy project tree
(use-package treemacs :ensure t)
(use-package lsp-treemacs :ensure t)

;; Crux provides a few helpful basic functions
(use-package crux :ensure t
  :bind (("C-a" . crux-move-beginning-of-line)
         ("s-<return>" . crux-smart-open-line)
         ("s-S-<return>" . crux-smart-open-line-above)
         ("C-c C-d" . crux-duplicate-current-line-or-region)
         ("C-c k" . crux-kill-other-buffers)))

;; Projectile adds support for projects
(use-package projectile
  :ensure t
  :init (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map)))
;; Org-mode
(use-package org
  :ensure t
  :init
  (org-babel-do-load-languages
   'org-babel-load-languages '((rust . t)))
  ;; Beautify org-mode: https://zzamboni.org/post/beautifying-org-mode-in-emacs/
  (setq org-hide-emphasis-markers t))


(find-file "~/.emacs.d/init.el")

(provide 'init)

;;; init.el ends here
