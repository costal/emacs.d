;;; init-go.el --- Go language support -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq-default go-ts-mode-indent-offset 4)

;; Tree-sitter grammar sources (treesit-auto handles installation)
(dolist (grammar '((go "https://github.com/tree-sitter/tree-sitter-go")
                   (gomod "https://github.com/camdencheek/tree-sitter-go-mod")))
  (add-to-list 'treesit-language-source-alist grammar))

;; LSP via eglot
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((go-ts-mode go-mode) . ("gopls"))))

(add-hook 'go-ts-mode-hook 'eglot-ensure)

;; Format on save with goimports (handles imports + formatting)
(when (maybe-require-package 'reformatter)
  (reformatter-define goimports
    :program "goimports"
    :args '("/dev/stdin"))
  (add-hook 'go-ts-mode-hook 'goimports-on-save-mode))

(provide 'init-go)
;;; init-go.el ends here
