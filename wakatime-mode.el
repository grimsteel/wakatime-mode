;;; package --- Minor mode for WakaTime
;;; Commentary:
;;; Code:

(defconst wakatime-user-agent "wakatime-mode")

(defgroup wakatime nil
  "Customizations for WakaTime"
  :group 'convenience
  :prefix "wakatime-")

(defcustom wakatime-api-key nil
  "API key for WakaTime."
  :type 'string
  :group 'wakatime)

(defcustom wakatime-cli-path nil
  "Path of CLI client for WakaTime."
  :type 'string
  :group 'wakatime)

(defun wakatime-client-command (savep)
  "Return cons of client command executable and arguments.
Set SAVEP to non-nil for write action."
  (cons
   (format "/usr/bin/python %s" wakatime-cli-path)
   (format "--file %s %s --plugin %s --key %s"
           (buffer-file-name (current-buffer))
           (if savep "--write" "")
           wakatime-user-agent
           wakatime-api-key)))

(defun wakatime-call (savep)
  "Call WakaTime service.  Set SAVEP to non-nil for write action."
  (let* ((command (wakatime-client-command savep))
         (executable (car command))
         (args (cdr command)))
    (start-process-shell-command "wakatime" "*WakaTime messages*" (concat executable " " args))))

(defun wakatime-ping ()
  "Send ping notice to WakaTime."
  (wakatime-call nil))

(defun wakatime-save ()
  "Send save notice to WakaTime."
  (wakatime-call t))

(defun wakatime-turn-on ()
  "Turn on WakaTime."
  (add-hook 'after-save-hook 'wakatime-save nil t)
  (add-hook 'auto-save-hook 'wakatime-save nil t)
  (add-hook 'first-change-hook 'wakatime-ping nil t))

(defun wakatime-turn-off ()
  "Turn off WakaTime."
  (remove-hook 'after-save-hook 'wakatime-save t)
  (remove-hook 'auto-save-hook 'wakatime-save t)
  (remove-hook 'first-change-hook 'wakatime-ping t))

;;;###autoload
(define-minor-mode wakatime-mode
  "Toggle WakaTime (WakaTime mode).
With a prefix argument ARG, enable Whitespace mode if ARG is
positive, and disable it otherwise.  If called from Lisp, enable
the mode if ARG is omitted or nil."
  :lighter    " waka"
  :init-value nil
  :global     nil
  :group      'wakatime
  (cond
   (noninteractive
    (setq wakatime-mode nil))
   (wakatime-mode
    (wakatime-turn-on))
   (t
    (wakatime-turn-off))))

(provide 'wakatime-mode)
;;; wakatime-mode.el ends here