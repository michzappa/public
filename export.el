(require 'ox-hugo)

(setq-default org-id-locations-file "org-id-locations"
              mz/date-format "%B %e %Y"
              mz/date-time-format "%l:%M %p on %B %e %Y"
              org-display-custom-times t
              org-export-date-timestamp-format mz/date-format
              org-html-metadata-timestamp-format mz/date-format
              org-time-stamp-custom-formats `(,mz/date-format . ,mz/date-time-format))

(add-to-list 'org-export-filter-timestamp-functions
             #'(lambda (timestamp backend _info)
                 (cond
                  ((org-export-derived-backend-p backend 'html)
                   (replace-regexp-in-string "&[lg]t;\\|[][]" "" timestamp)))))

;; tangle all Org-mode files in the /org directory into /content
(dolist (file (directory-files (expand-file-name "org/" default-directory) t ".*\.org"))
  (with-current-buffer (find-file file)
    (let ((org-confirm-babel-evaluate nil))
      (org-hugo-export-wim-to-md t))))
