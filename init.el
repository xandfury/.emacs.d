;;; This file bootstraps the configuration, which is divided into
;;; a number of other files.

(let ((minver "23.3"))
  (when (version<= emacs-version "23.1")
    (error "Your Emacs is too old -- this config requires v%s or higher" minver)))
(when (version<= emacs-version "24")
  (message "Your Emacs is old, and some functionality in this config will be disabled. Please upgrade if possible."))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'init-benchmarking) ;; Measure startup time

(defconst *spell-check-support-enabled* nil) ;; Enable with t if you prefer
(defconst *is-a-mac* (eq system-type 'darwin))

;;; delete the fowwlowing two lines later - abhinav
;; (require 'package)
(package-initialize)
;;----------------------------------------------------------------------------
;; Temporarily reduce garbage collection during startup
;;----------------------------------------------------------------------------
(defconst sanityinc/initial-gc-cons-threshold gc-cons-threshold
  "Initial value of `gc-cons-threshold' at start-up time.")
(setq gc-cons-threshold (* 128 1024 1024))
(add-hook 'after-init-hook
          (lambda () (setq gc-cons-threshold sanityinc/initial-gc-cons-threshold)))

;;----------------------------------------------------------------------------
;; Bootstrap config
;;----------------------------------------------------------------------------
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(require 'init-compat)
(require 'init-utils)
(require 'init-site-lisp) ;; Must come before elpa, as it may provide package.el
;; Calls (package-initialize)
(require 'init-elpa)      ;; Machinery for installing required packages
(require 'init-exec-path) ;; Set up $PATH

;;----------------------------------------------------------------------------
;; Allow users to provide an optional "init-preload-local.el"
;;----------------------------------------------------------------------------
(require 'init-preload-local nil t)

;;----------------------------------------------------------------------------
;; Load configs for specific features and modes
;;----------------------------------------------------------------------------

(require-package 'wgrep)
(require-package 'project-local-variables)
(require-package 'diminish)
(require-package 'scratch)
(require-package 'mwe-log-commands)

(require 'init-frame-hooks)
(require 'init-xterm)
(require 'init-themes)
(require 'init-osx-keys)
(require 'init-gui-frames)
(require 'init-dired)
(require 'init-isearch)
(require 'init-grep)
(require 'init-uniquify)
(require 'init-ibuffer)
(require 'init-flycheck)

(require 'init-recentf)
(require 'init-ido)
(require 'init-hippie-expand)
(require 'init-company)
(require 'init-windows)
(require 'init-sessions)
(require 'init-fonts)
(require 'init-mmm)

(require 'init-editing-utils)
(require 'init-whitespace)
(require 'init-fci)

(require 'init-vc)
(require 'init-darcs)
(require 'init-git)
(require 'init-github)

(require 'init-projectile)

(require 'init-compile)
(require 'init-crontab)
(require 'init-textile)
(require 'init-markdown)
(require 'init-csv)
(require 'init-erlang)
(require 'init-javascript)
(require 'init-php)
(require 'init-org)
(require 'init-nxml)
(require 'init-html)
(require 'init-css)
(require 'init-haml)
(require 'init-python-mode)
(unless (version<= emacs-version "24.3")
  (require 'init-haskell))
(require 'init-elm)
(require 'init-ruby-mode)
(require 'init-rails)
(require 'init-sql)

(require 'init-paredit)
(require 'init-lisp)
(require 'init-slime)
(unless (version<= emacs-version "24.2")
  (require 'init-clojure)
  (require 'init-clojure-cider))
(require 'init-common-lisp)

(when *spell-check-support-enabled*
  (require 'init-spelling))

(require 'init-misc)

(require 'init-dash)
(require 'init-ledger)
;; Extra packages which don't require any configuration

(require-package 'gnuplot)
(require-package 'lua-mode)
(require-package 'htmlize)
(require-package 'dsvn)
(when *is-a-mac*
  (require-package 'osx-location))
(require-package 'regex-tool)

;;----------------------------------------------------------------------------
;; Allow access from emacsclient
;;----------------------------------------------------------------------------
(require 'server)
(unless (server-running-p)
  (server-start))


;;----------------------------------------------------------------------------
;; Variables configured via the interactive 'customize' interface
;;----------------------------------------------------------------------------
(when (file-exists-p custom-file)
  (load custom-file))


;;----------------------------------------------------------------------------
;; Allow users to provide an optional "init-local" containing personal settings
;;----------------------------------------------------------------------------
(when (file-exists-p (expand-file-name "init-local.el" user-emacs-directory))
  (error "Please move init-local.el to ~/.emacs.d/lisp"))
(require 'init-local nil t)


;;----------------------------------------------------------------------------
;; Locales (setting them earlier in this file doesn't work in X)
;;----------------------------------------------------------------------------
(require 'init-locales)

(add-hook 'after-init-hook
          (lambda ()
            (message "init completed in %.2fms"
                     (sanityinc/time-subtract-millis after-init-time before-init-time))))

;;; Minted package installation for syntax highlighting

;; stop emacs asking for confirmation
(setq org-confirm-babel-evaluate nil)
;;; Custom templates for adding C and shell source code blocks
;;; For C code
(add-to-list 'org-structure-template-alist
             '("C" "#+BEGIN_SRC c +n \n?\n#+END_SRC\n"))
;;; For shell code
(add-to-list 'org-structure-template-alist
             '("sh" "#+BEGIN_SRC sh +n \n?\n#+END_SRC\n"))
;;; VERSE
(add-to-list 'org-structure-template-alist
             '("v" "#+BEGIN_VERSE \n?\n#+END_VERSE\n"))
;;; LaTeX
(add-to-list 'org-structure-template-alist
             '("l" "#+NAME: ?\n#+BEGIN_LATEX +n \n\n#+END_LATEX\n"))
;;; For BEGIN_EXAMPLE
(add-to-list 'org-structure-template-alist
             '("ex" "#+BEGIN_EXAMPLE \n?\n#+END_EXAMPLE\n"))
;;; For Image caption
(add-to-list 'org-structure-template-alist
             '("cap" "#+CAPTION: Output of the program\n[[./img/?.png]]"))

(require 'ox-latex)
(add-to-list 'org-latex-packages-alist '("" "minted"))
(setq org-latex-listings 'minted)
;; (setq org-latex-minted-options
;;       '(("cache" "false") ("frame" "lines") ("linenos=true")))

(setq org-latex-pdf-process
      '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
        "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
        "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))

;;* Export settings
;; (setq org-latex-default-packages-alist
;;       ("" "minted" nil))
;; ;; this is for code syntax highlighting in export
;; (setq org-latex-listings 'minted)
;;; Set the minted content in a box
(setq org-latex-minted-options
      '(("mathescape" "true")
        ("linenos" "true")
        ("numbersep" "5pt")
        ("frame" "lines")
        ("framesep" "2mm")))
;; '(("frame" "single")
;;   ("linenos" "")))
;; for minted you must run latex with -shell-escape because it calls pygmentize as an external program
;; (setq org-latex-pdf-process
;;       '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %b"
;;         "bibtex %b"
;;         "makeindex %b"
;;         "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %b"
;;         "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %b"))

;;; Reveal JS org mode
(require 'org)
(require 'ox-reveal)

;;----------------------------------------------------------------------------
;; Load the black beard theme:
;;----------------------------------------------------------------------------
(add-to-list 'custom-theme-load-path "~/.emacs.d/blackboard-theme")
(load-theme 'blackboard t)              ;Load the theme

;;; Load language C for executing the command code
(org-babel-do-load-languages
 'org-babel-load-languages '((C . t)))


(provide 'init)

;; Local Variables:
;; coding: utf-8
;; no-byte-compile: t
;; End:
