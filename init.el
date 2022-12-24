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

;; Bootstrap 'use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))
(require 'bind-key)
(setq use-package-always-ensure t)

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
(display-line-numbers-mode t)
(setq tab-width 2)
(setq-default indent-tabs-mode nil)
(setq-default css-indent-offset 2)
(global-hl-line-mode t)
(tool-bar-mode -1)
(fset 'yes-or-no-p 'y-or-n-p)
(delete-selection-mode 1)

;; Fixes issue with https: https://emacs.stackexchange.com/questions/61386/package-refresh-hangs
(custom-set-variables
 '(gnutls-algorithm-priority "normal:-vers-tls1.3"))

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
(setq inferior-lisp-program "/usr/local/bin/sbcl")

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
(use-package counsel :after (ivy))
(use-package multiple-cursors
  :bind (("s-;" . 'mc/edit-lines)))

;; God mode (modal editing)
(defun my-god-mode-update-cursor-type ()
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

;; LSP (Language Server Protocol) - support for multiple languages
(use-package lsp-mode
  :hook ((lsp-mode . lsp-enable-which-key-integration))
  :config
  (setq lsp-completion-enable t lsp-enable-on-type-formatting t)
  (global-set-key (kbd "M-s-l") 'lsp-format-buffer)
  (global-set-key (kbd "<M-return>") 'lsp-execute-code-action)
  (global-set-key (kbd "C-c h") 'lsp-ui-doc-focus-frame)
  (global-set-key (kbd "s-b") 'lsp-find-references)
  :hook ((lsp-mode . lsp-enable-which-key-integration)))

;; shows up code actions, documentation etc. on the screen
(use-package lsp-ui
  :bind (:map lsp-mode-map ("C-c C-h" . lsp-ui-doc-glance))
  :config (setq lsp-ui-doc-enable nil))

;; (add-hook 'dart-mode-hook 'lsp)
;; Dart
(use-package dart-mode :ensure t)
(use-package lsp-dart :ensure t
  :hook ((dart-mode . lsp-deferred)))

;; Rust
(use-package rustic :ensure t)
(use-package ob-rust :ensure t)

;; ZIG
(use-package zig-mode :ensure t
  :bind (("C-x C-t" . zig-test-buffer))
  :custom (zig-format-on-save nil)
  :init
  (setq lsp-zig-zls-executable (mapconcat #'identity (list (getenv "HOME") "/programming/apps/zls/zls") ""))
  (add-hook 'zig-mode-hook #'lsp-deferred))

;; Lua and Terra
(use-package lua-mode :ensure t
  :custom
  (lsp-clients-lua-language-server-bin "/usr/local/bin/lua-language-server")
  (lsp-clients-lua-language-server-install-dir "/usr/local/Cellar/lua-language-server/3.3.0")
  (lsp-clients-lua-language-server-main-location "/usr/local/Cellar/lua-language-server/3.3.0/libexec/main.lua")
  :hook (lua-mode . lsp-deferred))
(use-package terra-mode
  :load-path "manual-packages")

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

;; Go
(use-package go-mode :ensure t
  :hook ((go-mode . (lambda () (setq tab-width 4)))
         (go-mode . lsp-deferred))
  :custom
  (lsp-go-gopls-server-path "/Users/renato/go/bin/gopls")
  :init
  (defun lsp-go-install-save-hooks ()
    (add-hook 'before-save-hook #'lsp-format-buffer t t)
    (add-hook 'before-save-hook #'lsp-organize-imports t t))
  (add-hook 'go-mode-hook #'lsp-go-install-save-hooks))

(use-package go-projectile :ensure t)

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
         ("C-c d" . crux-duplicate-current-line-or-region)
         ("C-c k" . crux-kill-other-buffers)))

;; Projectile adds support for projects
(use-package projectile
  :ensure t
  :init (progn
          (projectile-mode +1)
          (projectile-register-project-type 'jbuild '("jbuild.yaml")
                                            :project-file "jbuild.yaml"
				            :compile "jb compile"
				            :test "jb -p test test"
				            :run "jb run"))
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

(use-package elfeed
  :ensure t
  :init
  (setq elfeed-feeds
        '("http://nullprogram.com/feed/"
          "https://renato.athaydes.com/news/index.xml"
          "https://planet.emacslife.com/atom.xml"
          "https://ziglang.org/news/index.xml")))

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;; Helpful functions (available everywhere, including eshell)
(defun j11 ()
    (setenv "JAVA_HOME" "/Users/renato/.sdkman/candidates/java/11.0.13-zulu"))
(defun j17 ()
    (setenv "JAVA_HOME" "/Users/renato/.sdkman/candidates/java/17.0.5-zulu"))

(find-file "~/.emacs.d/init.el")

(provide 'init)

;;; init.el ends here
