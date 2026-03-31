;;; init-org-roam.el --- Org-roam + org-roam-bibtex + Citar + org-noter combo -*- lexical-binding: t -*-
;;; Commentary:
;;; Bibliography-backed note-taking: org-roam, ORB, Citar (Org only), org-noter.
;;; In Org buffers Citar handles insert-citation (org-cite) and literature workflow.
;;; LaTeX keeps using ivy-bibtex (init-tex.el unchanged).
;;; Code:

;; ---------------------------------------------------------------------------
;; 1. Paths (customize these; same .bib/PDFs as ivy-bibtex if desired)
;; ---------------------------------------------------------------------------
(defvar sanityinc/org-roam-directory (expand-file-name "~/org/roam")
  "Root directory for org-roam notes.")
(defvar sanityinc/citar-bibliography (list (expand-file-name "~/Documents/references/references.bib"))
  "BibTeX files for Citar. Match bibtex-completion-bibliography if using both.")
(defvar sanityinc/citar-library-paths (list (expand-file-name "~/Documents/references/papers")
                                            (expand-file-name "~/Documents/Books"))
  "Directories where PDFs live. Match bibtex-completion-library-path if using both.")

(setq org-roam-directory (file-truename sanityinc/org-roam-directory))
(setq org-roam-db-location (expand-file-name "org-roam.db" org-roam-directory))

;; Literature notes subdir (ORB / citar-org-roam)
(defvar sanityinc/org-roam-references-dir "references"
  "Subdir of org-roam-directory for bibliography notes (citekey.org).")

;; ---------------------------------------------------------------------------
;; 2. Packages (load order: emacsql backend -> org-roam -> org-roam-bibtex -> citar -> ...)
;; ---------------------------------------------------------------------------
;; EmacsSQL SQLite backend (required before org-roam).
;; sqlite-builtin is part of the main emacsql package (not a separate MELPA package).
(require-package 'emacsql)
(if (>= emacs-major-version 29)
    (progn
      (setq org-roam-database-connector 'sqlite-builtin)
      (require 'emacsql-sqlite-builtin))
  (progn
    (require-package 'emacsql-sqlite)
    (setq org-roam-database-connector 'sqlite)
    (require 'emacsql-sqlite)))

(require-package 'org-roam)
(require-package 'org-roam-bibtex)
(require-package 'citar)
(require-package 'citar-org-roam)
(require-package 'org-noter)
(require-package 'pdf-tools)

(require 'org-roam)
(require 'org-roam-bibtex)
(require 'citar)
(require 'citar-org-roam)
(require 'org-noter)

;; ---------------------------------------------------------------------------
;; 3. Org-roam core
;; ---------------------------------------------------------------------------
(with-eval-after-load 'org-roam
  (org-roam-db-autosync-mode)
  (setq org-roam-node-display-template "${title:*} ${tags:10}"))

;; ---------------------------------------------------------------------------
;; 4. Org-roam capture templates (default + bibliography with NOTER_DOCUMENT)
;; ---------------------------------------------------------------------------
(setq org-roam-capture-templates
      `(("d" "default" plain "%?"
         :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
         :unnarrowed t)
        ("r" "bibliography reference" plain "%?"
         :target (file+head
                  ,(concat sanityinc/org-roam-references-dir "/${citekey}.org")
                  "#+title: ${title}\n#+subtitle: ${author-or-editor}, ${date}\n\n:PROPERTIES:\n:Custom_ID: ${citekey}\n:NOTER_DOCUMENT: %^{file}\n:ROAM_REFS: cite:${citekey}\n:END:\n\n")
         :unnarrowed t)))

;; ---------------------------------------------------------------------------
;; 5. Org-roam-bibtex (ORB)
;; ---------------------------------------------------------------------------
(with-eval-after-load 'org-roam-bibtex
  (setq orb-preformat-keywords '("citekey" "title" "file" "author-or-editor" "date" "url" "keywords" "entry-type")
        orb-process-file-keyword t
        orb-attached-file-extensions '("pdf")
        orb-insert-interface 'ivy
        orb-note-actions-interface 'ivy))

;; ---------------------------------------------------------------------------
;; 6. Citar (bibliography + PDF open; for Org / combo only)
;; ---------------------------------------------------------------------------
(with-eval-after-load 'citar
  (setq citar-bibliography sanityinc/citar-bibliography
        citar-library-paths sanityinc/citar-library-paths))

(with-eval-after-load 'citar
  (setq citar-at-point-function 'citar-citation-at-point))

;; ---------------------------------------------------------------------------
;; 7. Org-cite: use Citar in Org for insert/follow/activate (combo cohesion)
;; ---------------------------------------------------------------------------
(with-eval-after-load 'org
  (with-eval-after-load 'citar
    (setq org-cite-insert-processor 'citar
          org-cite-follow-processor 'citar
          org-cite-activate-processor 'citar)))

;; ---------------------------------------------------------------------------
;; 8. Citar–org-roam integration (ORB-backed notes source)
;; ---------------------------------------------------------------------------
(with-eval-after-load 'citar-org-roam
  (citar-register-notes-source
   'orb-citar-source (list :name "Org-Roam Notes"
                           :category 'org-roam-node
                           :items #'citar-org-roam--get-candidates
                           :hasitems #'citar-org-roam-has-notes
                           :open #'citar-org-roam-open-note
                           :create #'orb-citar-edit-note
                           :annotate #'citar-org-roam--annotate))
  (setq citar-notes-source 'orb-citar-source
        citar-org-roam-capture-template-key "r"
        citar-org-roam-subdir sanityinc/org-roam-references-dir
        citar-org-roam-template-fields
        '((:citar-citekey "key")
          (:citar-title "title")
          (:citar-author "author" "editor")
          (:citar-date "date" "year" "issued")
          (:citar-pages "pages")
          (:citar-type "=type="))))

;; ---------------------------------------------------------------------------
;; 9. NOTER_DOCUMENT when creating note from Citar (org-noter link)
;; ---------------------------------------------------------------------------
(defun sanityinc/citar-add-org-noter-document-property (key &optional _entry)
  "Set NOTER_DOCUMENT and related properties when a new Citar note is created."
  (when (derived-mode-p 'org-mode)
    (let ((file-path (and (fboundp 'citar-get-file) (citar-get-file key))))
      (when file-path (org-set-property "NOTER_DOCUMENT" file-path))
      (org-set-property "Custom_ID" key)
      (when (fboundp 'org-roam-ref-add) (org-roam-ref-add (concat "@" key)))
      (org-id-get-create))))

(with-eval-after-load 'citar
  (advice-add 'citar-create-note :after #'sanityinc/citar-add-org-noter-document-property))

;; ---------------------------------------------------------------------------
;; 10. Org-noter (find notes when viewing PDF)
;; ---------------------------------------------------------------------------
(with-eval-after-load 'org-noter
  (setq org-noter-notes-search-path
        (list org-roam-directory
              (expand-file-name sanityinc/org-roam-references-dir org-roam-directory))))

;; Optional: org-noter integration for org-roam (see org-noter docs)
(with-eval-after-load 'org-noter
  (when (fboundp 'org-noter-enable-org-roam-integration)
    (org-noter-enable-org-roam-integration)))

;; ---------------------------------------------------------------------------
;; 11. pdf-tools for org-noter (better PDF sync)
;; ---------------------------------------------------------------------------
(pdf-loader-install)

;; ---------------------------------------------------------------------------
;; 12. Keybindings (C-c r = roam combo; C-c r b = Citar open)
;; ---------------------------------------------------------------------------
(defvar sanityinc/org-roam-prefix-map (make-sparse-keymap)
  "Prefix keymap for org-roam combo.")
(define-key sanityinc/org-roam-prefix-map (kbd "f") 'org-roam-node-find)
(define-key sanityinc/org-roam-prefix-map (kbd "i") 'org-roam-node-insert)
(define-key sanityinc/org-roam-prefix-map (kbd "c") 'org-roam-capture)
(define-key sanityinc/org-roam-prefix-map (kbd "b") 'citar-open)
(define-key sanityinc/org-roam-prefix-map (kbd "B") 'org-roam-buffer-toggle)
(define-key sanityinc/org-roam-prefix-map (kbd "l") 'orb-insert-link)
(define-key global-map (kbd "C-c r") sanityinc/org-roam-prefix-map)

;; org-noter: from PDF buffer (e.g. M-n)
(global-set-key (kbd "M-n") 'org-noter)

(provide 'init-org-roam)
;;; init-org-roam.el ends here
