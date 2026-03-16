;;; init-flymake.el --- Configure Flymake behaviour -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Flymake is built-in since Emacs 26
(require 'flymake)

;; Optional: use Flycheck checkers through Flymake
(when (maybe-require-package 'flymake-flycheck)

  ;; Disable overlapping Flycheck checkers
  (with-eval-after-load 'flycheck
    (setq flycheck-disabled-checkers
          (append flycheck-disabled-checkers
                  '(emacs-lisp
                    emacs-lisp-checkdoc
                    emacs-lisp-package
                    sh-shellcheck))))

  (add-hook 'flymake-mode-hook #'flymake-flycheck-auto))

;; Enable Flymake automatically
(add-hook 'prog-mode-hook #'flymake-mode)
(add-hook 'text-mode-hook #'flymake-mode)

(with-eval-after-load 'flymake
  ;; Flycheck-like keybindings
  (define-key flymake-mode-map (kbd "C-c ! l") #'flymake-show-buffer-diagnostics)
  (define-key flymake-mode-map (kbd "C-c ! n") #'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "C-c ! p") #'flymake-goto-prev-error)
  (define-key flymake-mode-map (kbd "C-c ! c") #'flymake-start))

;; Better eldoc integration (Emacs ≥28)
(when (version<= "28.1" emacs-version)
  (setq eldoc-documentation-strategy #'eldoc-documentation-compose)

  (add-hook 'flymake-mode-hook
            (lambda ()
              (add-hook 'eldoc-documentation-functions
                        #'flymake-eldoc-function
                        nil t))))

(provide 'init-flymake)
;;; init-flymake.el ends here
