;;; init-agent-shell.el --- LLM agent shells (Claude + Cursor via ACP) -*- lexical-binding: t -*-
;;; Commentary:
;;  [agent-shell](https://github.com/xenodium/agent-shell) talks to ACP agents from Emacs.
;;  External CLIs (install globally so they are on PATH used by Emacs):
;;    npm install -g @zed-industries/claude-agent-acp
;;    npm install -g @blowmage/cursor-agent-acp
;;  See upstream README for auth (login vs API key).
;;; Code:

(when (version< emacs-version "29.1")
  (message "agent-shell requires Emacs 29.1 or newer; skipping"))

(unless (version< emacs-version "29.1")
  (require-package 'agent-shell)
  (require 'agent-shell)

  ;; So spawned processes see your normal PATH (npm -g binaries, etc.).
  (setq agent-shell-anthropic-claude-environment
        (agent-shell-make-environment-variables :inherit-env t))
  (setq agent-shell-cursor-environment
        (agent-shell-make-environment-variables :inherit-env t))

  ;; M-x agent-shell offers only these two; remove this `setq' to get all default agents.
  (setq agent-shell-agent-configs
        (list (agent-shell-anthropic-make-claude-code-config)
              (agent-shell-cursor-make-agent-config))))

(provide 'init-agent-shell)
;;; init-agent-shell.el ends here
