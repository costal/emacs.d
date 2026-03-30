;;; -*- lexical-binding: t -*-
(require-package 'code-library)

(setq code-library-directory (expand-file-name "code-library/" org-directory))
(setq code-library-mode-file-alist
      '((c-mode . "c_cpp.org")
        (c++-mode . "c_cpp.org")
        (python-mode . "python.org")
        (latex-mode . "tex.org")))

(provide 'init-code)
