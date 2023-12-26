;;; init.el --- Renato's Emacs init file

;;; Commentary:
;;
;; Renato Athaydes' Emacs Config.
;; 

;;; Code:

;;; Package repositories
(require 'package)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")))

(require 'bind-key)

(put 'erase-buffer 'disabled nil)
(setq inhibit-splash-screen t)
(transient-mark-mode 1)
(savehist-mode 1)
(setq visible-bell t)
(setq ring-bell-function 'ignore)
(setq dired-listing-switches "-alh")
(display-time-mode t)
(show-paren-mode t)
(display-line-numbers-mode t)
(setq tab-width 2)
(setq-default indent-tabs-mode nil)
(setq-default css-indent-offset 2)
(global-hl-line-mode t)
(tool-bar-mode -1)
(fset 'yes-or-no-p 'y-or-n-p)
(delete-selection-mode 1)

;; Fixes issue with https: https://emacs.stackexchange.com/questions/61386/package-refresh-hangs
;;(custom-set-variables
;; '(gnutls-algorithm-priority "normal:-vers-tls1.3"))

;; File backups
(setq backup-directory-alist `(("." . "~/.emacs.d/.file-backups"))
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 10
      kept-old-versions 5
      version-control t)

;; highlight matching parens
(electric-pair-mode 1)
;; electric-newline-add-maybe-indent shortcut is not needed,
;; I want this for inserting snippets as in IntelliJ
(global-unset-key (kbd "C-j"))
(setq inferior-lisp-program (if (eq system-type 'gnu/linux)
                                "/usr/bin/sbcl"
                              "/usr/local/bin/sbcl"))

;; enable recentf to display recently visited files
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)
(global-set-key (kbd "s-r") 'revert-buffer-quick)

;; jump back and forth between cursor positions
(global-set-key (kbd "s-[") 'pop-global-mark)
(global-set-key (kbd "s-]") #'(lambda ()
                                (interactive)
                                (set-mark-command t)))

;; comment-uncomment region
(global-set-key (kbd "s-/") 'comment-or-uncomment-region)

;; start marking a region
(global-set-key (kbd "C-,") 'set-mark-command)

;; unindent
(global-set-key (kbd "<backtab>") 'indent-rigidly-left-to-tab-stop)

(global-set-key (kbd "M-s-l") 'eglot-format-buffer)

;;; External packages

;; auto-complete inside text/code buffers
(use-package company :ensure t :init (global-company-mode t))
;; shows which keys can be pressed after an initial keystroke
(use-package which-key :ensure t :init (which-key-mode))
;; move text up/down easily
(use-package move-text :ensure t
  :bind (("s-<up>" . 'move-text-up) ("s-<down>" . 'move-text-down)))
;; support for markdown
(use-package markdown-mode :ensure t)
;; support for git
(use-package magit :ensure t)
;; highlight modified/added regions of the code
(use-package diff-hl :ensure t :init (global-diff-hl-mode))
;; syntax checker on the fly
(use-package flycheck :ensure t :init (global-flycheck-mode))
;; expands marked region easily
(use-package expand-region :ensure t
  :bind (("M-<up>" . 'er/expand-region) ("M-<down>" . 'er/contract-region)))
;; better way to switch between open windows
(use-package ace-window :ensure t :bind ("C-<tab>" . 'ace-window))
(use-package ivy :ensure t
  :bind (("\C-s" . 'swiper))
  :init (ivy-mode))
(use-package counsel :ensure t :after (ivy))
;;(use-package multiple-cursors :ensure t
;;  :bind (("s-;" . 'mc/edit-lines)))

;; God mode (modal editing)
(defun my-god-mode-update-cursor-type ()
  "Change God mode cursor type."
  (setq cursor-type (if (or god-local-mode buffer-read-only) 'box 'bar)))
(use-package god-mode :ensure t
  :bind (("<escape>" . #'god-mode-all))
  :config (add-hook 'post-command-hook #'my-god-mode-update-cursor-type)
  :init (god-mode))

;; SLIME
(use-package slime :ensure t
  :config (setq slime-contribs '(slime-fancy slime-cl-indent)))
(use-package slime-company :ensure t
  :after (slime company)
  :init
  (slime-setup '(slime-fancy slime-company))
  (add-to-list 'slime-contribs 'slime-autodoc)
  :config (setq slime-company-completion 'fuzzy
                slime-company-after-completion 'slime-company-just-one-space))

(use-package yaml-mode :ensure t
  :init (add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode)))

;; D
(use-package d-mode :ensure t
  :init (with-eval-after-load 'eglot
          (add-to-list 'eglot-server-programs
                       '(d-mode . ("~/programming/apps/serve-d")))))

;; Nim
(use-package nim-mode :ensure t
  :init (with-eval-after-load 'eglot
          (add-to-list 'eglot-server-programs
                       '(nim-mode . ("nimlsp")))))

;; Rust
(use-package rustic :ensure t
  :config
  (setq rustic-lsp-client 'eglot)
  :custom
  (rustic-analyzer-command '("rustup" "run" "stable" "rust-analyzer")))

;; (add-hook 'dart-mode-hook 'lsp)
;; Dart
(use-package dart-mode :ensure t)

;; ZIG
(use-package zig-mode :ensure t
  :bind (("C-x C-t" . zig-test-buffer))
  :custom (zig-format-on-save nil))

;; Lua
(use-package lua-mode :ensure t)

;; TODO edit Java formatter in emacs
;; https://gist.github.com/fbricon/30c5971f7e492c8a74ca2b2d7a7bb966

;; Groovy
(use-package groovy-mode :ensure t)

;; Go
(use-package go-mode :ensure t
  :hook ((go-mode . (lambda () (setq tab-width 4)))))

;; Inserts code snippets
(use-package yasnippet :ensure t :init (yas-global-mode 1)
  :bind (("C-j" . yas-insert-snippet)))

;; Crux provides a few helpful basic functions
(use-package crux :ensure t
  :bind (("C-a" . crux-move-beginning-of-line)
         ("s-<return>" . crux-smart-open-line)
         ("s-S-<return>" . crux-smart-open-line-above)
         ("s-d" . crux-duplicate-current-line-or-region)
         ("C-c k" . crux-kill-other-buffers)))

;; Org-mode
(use-package org
  :ensure t
  :init
  (org-babel-do-load-languages
   'org-babel-load-languages '((rust . t)))
  ;; Beautify org-mode: https://zzamboni.org/post/beautifying-org-mode-in-emacs/
  (setq org-hide-emphasis-markers t))

(use-package elfeed
  :ensure t
  :init
  (setq elfeed-feeds
        '("http://nullprogram.com/feed/"
          "https://renato.athaydes.com/news/index.xml"
          "https://planet.emacslife.com/atom.xml"
          "https://ziglang.org/news/index.xml")))

(use-package dashboard
  :ensure t
  :init
  (setq dashboard-items '((recents  . 15) (projects . 5) (registers . 5)))
  :config
  (dashboard-setup-startup-hook))

(provide 'init)
(load "~/.emacs.d/functions")
(load "~/.emacs.d/my-unison-mode")

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)


;;; init.el ends here
