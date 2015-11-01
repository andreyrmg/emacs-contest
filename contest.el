(defvar script-path (file-name-directory (or load-file-name buffer-file-name)))

(add-hook 'c++-mode-hook
          (lambda ()
            (set (make-local-variable 'compile-command)
                 (format "c++ -Wall -Wextra -std=c++11 -o %s %s"
                         (shell-quote-argument (file-name-base buffer-file-name))
                         (shell-quote-argument buffer-file-name)))))

(global-set-key [f5] 'recompile)
(global-set-key [(shift f5)] 'compile)

(defun run-single-test (run-command test-name)
  (insert "\nTest: " (file-name-base test-name) "\n")
  (call-process run-command test-name t)
  (insert "\n"))

(defun list-tests (solution)
  (file-expand-wildcards
   (concat solution "*.in")))

(defun run-tests (solution)
  (with-current-buffer (get-buffer-create "*Output*")
    (erase-buffer)
    (insert "Running tests at " (format-time-string "%H:%M:%S") "\n")
    (display-buffer "*Output*")
    (dolist (test (list-tests solution))
      (run-single-test solution test))))

(global-set-key [f6]
                (lambda ()
                  (interactive)
                  (let ((solution (file-name-sans-extension buffer-file-name)))
                    (run-tests solution))))

(defun new-solution-file ()
  (read-file-name "Solution name: "))

(global-set-key [f3]
                (lambda ()
                  (interactive)
                  (let ((solution-name (read-file-name "Solution name: ")))
                    (find-file solution-name)
                    (if (not (file-exists-p solution-name))
                        (insert-file-contents
                         (concat script-path
                                 "template"
                                 (file-name-extension solution-name t))))
                    (save-buffer)
                    (message solution-name))))
