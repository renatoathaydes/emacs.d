;;; package --- Summary: elisp functions for LLMs to call ;; -*- lexical-binding: t; -*-

;;; Commentary:
;;; Allows gptel to let LLMs work inside Emacs projects.
;;; Code:
(with-eval-after-load 'gptel

  (defun my/gptel-root ()
    "Return the current project root, or `default-directory'."
    (if-let ((proj (project-current)))
        (project-root proj)
      default-directory))

  (defun my/gptel--xref-format (items)
    "Format a list of xref ITEMS as lines of text."
    (if items
        (mapconcat
         (lambda (item)
           (let ((loc (xref-item-location item)))
             (format "%s:%s: %s"
                     (xref-location-group loc)
                     (xref-location-line loc)
                     (xref-item-summary item))))
         items "\n")
      "No results."))

  ;; Read-only: find where a symbol is defined
  (gptel-make-tool
   :name "xref_find_definitions"
   :function (lambda (identifier)
               (let ((default-directory (my/gptel-root)))
                 (my/gptel--xref-format
                  (xref-backend-definitions
                   (xref-find-backend) identifier))))
   :description "Find where a symbol is defined in the current project."
   :args (list '(:name "identifier"
                 :type string
                 :description "The symbol name to look up."))
   :category "emacs"
   :confirm nil)

  ;; Read-only: find where a symbol is used
  (gptel-make-tool
   :name "xref_find_references"
   :function (lambda (identifier)
               (let ((default-directory (my/gptel-root)))
                 (my/gptel--xref-format
                  (xref-backend-references
                   (xref-find-backend) identifier))))
   :description "Find references to a symbol in the current project."
   :args (list '(:name "identifier"
                 :type string
                 :description "The symbol name to look up."))
   :category "emacs"
   :confirm nil)

  ;; Read-only: search the project with grep
  (gptel-make-tool
   :name "project_grep"
   :function (lambda (regexp)
               (let ((default-directory (my/gptel-root)))
                 (let ((out (shell-command-to-string
                             (format "grep -rnI -- %s . 2>&1 | head -n 200"
                                     (shell-quote-argument regexp)))))
                   (if (string-empty-p out) "No matches." out))))
   :description "Search the project for a regular expression. Returns up to 200 matching lines with file and line numbers."
   :args (list '(:name "regexp"
                 :type string
                 :description "The pattern to search for."))
   :category "emacs"
   :confirm nil)

  ;; Read-only: docstring and current value of a function or variable
  (gptel-make-tool
   :name "describe_symbol"
   :function (lambda (name)
               (let* ((sym (intern name))
                      (fdoc (and (fboundp sym) (documentation sym t)))
                      (vdoc (and (boundp sym)
                                 (documentation-property
                                  sym 'variable-documentation t))))
                 (string-join
                  (delq nil
                        (list
                         (and fdoc (format "Function docstring:\n%s" fdoc))
                         (and (boundp sym)
                              (format "Current value: %S"
                                      (symbol-value sym)))
                         (and vdoc (format "Variable docstring:\n%s" vdoc))
                         (unless (or fdoc (boundp sym))
                           (format "No function or variable named %s" name))))
                  "\n\n")))
   :description "Return the docstring and current value of an Emacs Lisp function or variable."
   :args (list '(:name "name"
                 :type string
                 :description "The function or variable name."))
   :category "emacs"
   :confirm nil)

  ;; Read-only: uncommitted git changes
  (gptel-make-tool
   :name "git_diff"
   :function (lambda ()
               (let* ((default-directory (my/gptel-root))
                      (out (shell-command-to-string "git diff 2>&1")))
                 (if (string-empty-p out) "No uncommitted changes." out)))
   :description "Show uncommitted changes in the current project (git diff)."
   :args nil
   :category "emacs"
   :confirm nil)

  ;; Runs a command: requires confirmation
  (gptel-make-tool
   :name "run_compile_command"
   :function (lambda (command)
               (let ((default-directory (my/gptel-root)))
                 (shell-command-to-string (concat command " 2>&1"))))
   :description "Run a shell command (such as a build or test command) in the project root and return its output."
   :args (list '(:name "command"
                 :type string
                 :description "The shell command to run."))
   :category "emacs"
   :confirm t))

(provide 'gptel-functions)

;;; gptel-functions.el ends here
