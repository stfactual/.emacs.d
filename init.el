;; turn off emacs startup message
(setq inhibit-startup-message t)

;; not necessary for OS X
(menu-bar-mode -1)
(tool-bar-mode -1)

;; make transparent if the window manager supports it
(add-to-list 'default-frame-alist '(alpha 85 75))

(setq frame-title-format '("%f"))

;; allow emacsclient to open files in a running emacs
(server-start)

;; do not wrap lines
(setq-default truncate-lines t)

;; tab width as two, using spaces
(setq default-tab-width 2)
(setq-default indent-tabs-mode nil)
(setq-default fill-column 100)

;; show column numbers
(setq column-number-mode t)

;; turn off scroll-bars
(scroll-bar-mode -1)

(put 'scroll-left 'disabled nil)

;; personally, I can do without all those ~ files
(setq make-backup-files nil)

(add-hook 'before-save-hook 'whitespace-cleanup)

;; undo/redo pane configuration with C-c left/right arrow
(winner-mode 1)

(defun toggle-fullscreen (&optional f)
  (interactive)
  (let ((current-value (frame-parameter nil 'fullscreen)))
    (set-frame-parameter nil 'fullscreen
     (if (equal 'fullboth current-value)
         (if (boundp 'old-fullscreen) old-fullscreen nil)
       (progn (setq old-fullscreen current-value)
              'fullboth)))))

(if (eq system-type 'darwin)
  (progn
    (global-set-key (kbd "M-RET") 'ns-toggle-fullscreen)
    (global-set-key (kbd "<s-wheel-up>") 'text-scale-increase)
    (global-set-key (kbd "<s-wheel-down>") 'text-scale-decrease))

  ;; linux
  (progn
    (global-set-key (kbd "M-RET") 'toggle-fullscreen)
    (global-set-key (kbd "<s-mouse-4>") 'text-scale-increase)
    (global-set-key (kbd "<s-double-mouse-4>") 'text-scale-increase)
    (global-set-key (kbd "<s-triple-mouse-4>") 'text-scale-increase)
    (global-set-key (kbd "<s-mouse-5>") 'text-scale-decrease)
    (global-set-key (kbd "<s-double-mouse-5>") 'text-scale-decrease)
    (global-set-key (kbd "<s-triple-mouse-5>") 'text-scale-decrease)

    (global-set-key (kbd "s-s") 'save-buffer)
    (global-set-key (kbd "s-x") 'clipboard-kill-region)
    (global-set-key (kbd "s-c") 'clipboard-kill-ring-save)
    (global-set-key (kbd "s-v") 'clipboard-yank)
    (global-set-key (kbd "s-f") 'isearch-forward)
    (global-set-key (kbd "s-g") 'isearch-repeat-forward)
    (global-set-key (kbd "s-z") 'undo)
    (global-set-key (kbd "s-q") 'save-buffers-kill-terminal)))

(global-set-key [f5] 'revert-buffer)
(global-set-key [f12] 'other-window)

(global-set-key (kbd "<s-right>") 'other-window)
(global-set-key (kbd "<s-left>") '(lambda () "backwards other-window" (interactive) (other-window -1)))

(global-set-key (kbd "C-c c") 'toggle-truncate-lines)
(global-set-key (kbd "C-c ;") 'comment-or-uncomment-region)

;; keyboard macro key bindings
(global-set-key (kbd "C-,")        'kmacro-start-macro-or-insert-counter)
(global-set-key (kbd "C-.")        'kmacro-end-or-call-macro)

(defun find-init-file ()
  "Visit init.el."
  (interactive)
  (find-file "~/.emacs.d/init.el"))

(global-set-key (kbd "s-i") 'find-init-file)
(global-set-key (kbd "s-I") 'eval-buffer)

(global-set-key (kbd "s-{") 'shrink-window-horizontally)
(global-set-key (kbd "s-}") 'enlarge-window-horizontally)
(global-set-key (kbd "s-[") 'shrink-window)
(global-set-key (kbd "s-]") 'enlarge-window)

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 (if (eq system-type 'darwin)
   '(default ((t (:height 140))))
   '(default ((t (:height 110))))))

;; add all subdirs of ~/.emacs.d to your load-path
(add-to-list 'load-path "~/.emacs.d")
(dolist (f (file-expand-wildcards "~/.emacs.d/*"))
  (add-to-list 'load-path f))

;; load color-theme
(require 'color-theme)
(color-theme-initialize)
(setq color-theme-is-global t)
;; use wombat
(load-file "~/.emacs.d/color-theme/themes/wombat.el")
(color-theme-wombat)

;; TODO: is something similar to this hack needed for nrepl?
;; printing strings in slime with unusual characters crashes without this
(setq slime-net-coding-system 'utf-8-unix)

(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)

(let (refreshed)
  (dolist (package '(clojure-mode clojure-test-mode nrepl auto-complete ac-nrepl))
    (unless (package-installed-p package)
      (when (not refreshed)
        (package-refresh-contents)
        (setq refreshed t))
      (package-install package))))

;; load clojure mode
(require 'clojure-mode)

;; auto-complete-mode
(require 'auto-complete-config)
(ac-config-default)

(require 'ac-nrepl)
(add-hook 'nrepl-mode-hook 'ac-nrepl-setup)
(add-hook 'nrepl-interaction-mode-hook 'ac-nrepl-setup)
(eval-after-load "auto-complete"
'(add-to-list 'ac-modes 'nrepl-mode))

(define-key nrepl-interaction-mode-map (kbd "C-c C-d") 'ac-nrepl-popup-doc)

(add-hook 'nrepl-interaction-mode-hook
  'nrepl-turn-on-eldoc-mode)

;; indent let? the same as let
(define-clojure-indent
  (let? 1))

(require 'paredit)
(dolist (mode '(clojure emacs-lisp lisp scheme lisp-interaction))
  (add-hook (first (read-from-string (concat (symbol-name mode) "-mode-hook")))
            (lambda ()
            (paredit-mode 1)
            (local-set-key (kbd "<C-left>") 'backward-sexp)
            (local-set-key (kbd "<C-right>") 'forward-sexp)
;;            (local-set-key (kbd "<M-left>") 'paredit-convolute-sexp)
;;            (auto-complete-mode 1)
)))

;; Toggle fold-dwim-org mode with C-tab.
;; While fold-dwim-org mode is enabled:
;;  tab shows/hides block,
;;  S-tab shows/hides all blocks.
(require 'fold-dwim-org)
(global-set-key (kbd "<C-tab>") 'fold-dwim-org/minor-mode)

;; supports fold-dwim-org
;; add separately from other lispish mode hooks because it messes up the nrepl buffer
(add-hook 'clojure-mode-hook 'hs-minor-mode)

(defun forward-select-sexp ()
  "Select sexp after point."
  (interactive)
  ;; skip comments
  (paredit-forward)
  (paredit-backward)
  (set-mark (point))
  (paredit-forward))

(defun backward-select-sexp ()
  "Select sexp before point."
  (interactive)
  ;; skip comments
  (paredit-backward)
  (paredit-forward)
  (set-mark (point))
  (paredit-backward))

;; rainbow parentheses
(require 'highlight-parentheses)
(add-hook 'clojure-mode-hook '(lambda () (highlight-parentheses-mode 1)))
 (setq hl-paren-colors
       '("orange1" "yellow1" "greenyellow" "green1"
         "springgreen1" "cyan1" "slateblue1" "magenta1" "purple"))

(dolist (mode '(clojure nrepl emacs-lisp lisp scheme lisp-interaction))
  (add-hook (first (read-from-string (concat (symbol-name mode) "-mode-hook")))
            (lambda ()
            (highlight-parentheses-mode 1)
            (paredit-mode 1)
            (local-set-key (kbd "<M-left>") 'paredit-convolute-sexp)
            (local-set-key (kbd "<C-M-s-right>") 'forward-select-sexp)
            (local-set-key (kbd "<C-M-s-left>") 'backward-select-sexp)
            )))

(defmacro defclojureface (name color desc &optional others)
  `(defface ,name '((((class color)) (:foreground ,color ,@others))) ,desc :group 'faces))

; Dim parens - http://briancarper.net/blog/emacs-clojure-colors
(defclojureface clojure-parens       "DimGrey"   "Clojure parens")
(defclojureface clojure-braces       "#49b2c7"   "Clojure braces")
(defclojureface clojure-brackets     "SteelBlue" "Clojure brackets")
(defclojureface clojure-keyword      "khaki"     "Clojure keywords")
(defclojureface clojure-namespace    "#c476f1"   "Clojure namespace")
(defclojureface clojure-java-call    "#4bcf68"   "Clojure Java calls")
(defclojureface clojure-special      "#b8bb00"   "Clojure special")
(defclojureface clojure-double-quote "#b8bb00"   "Clojure special" (:background "unspecified"))

(defun tweak-clojure-syntax ()
  (mapcar (lambda (x) (font-lock-add-keywords nil x))
          '((("#?['`]*(\\|)"       . 'clojure-parens))
            (("#?\\^?{\\|}"        . 'clojure-brackets))
            (("\\[\\|\\]"          . 'clojure-braces))
            ((":\\w+"              . 'clojure-keyword))
            (("#?\""               0 'clojure-double-quote prepend))
            (("\\<nil\\>\\|\\<true\\>\\|\\<false\\>\\|\\<%[1-9]?\\>" . 'clojure-special))
            (("(\\(\\.[^ \n)]*\\|[^ \n)]+\\.\\|new\\)\\([ )\n]\\|$\\)" 1 'clojure-java-call)))))

(add-hook 'clojure-mode-hook 'tweak-clojure-syntax)

(defun smart-line-beginning ()
  "Move point to the beginning of text
on the current line; if that is already
the current position of point, then move
it to the beginning of the line."
  (interactive)
  (let ((pt (point)))
    (beginning-of-line-text)
    (when (eq pt (point))
      (beginning-of-line))))

(global-set-key "\C-a" 'smart-line-beginning)

;; auto-complete-mode
(require 'auto-complete-config)
(ac-config-default)

;; slime auto complete
(require 'ac-slime)
(add-hook 'slime-mode-hook 'set-up-slime-ac)

;; fix indenting in repl
(add-hook 'slime-repl-mode-hook
          (lambda ()
            (define-key slime-repl-mode-map (kbd "<C-return>") nil)
            (setq lisp-indent-function 'clojure-indent-function)
            (set-syntax-table clojure-mode-syntax-table)))

;; end of Lance's init.el


;; start of Evan's additions

(setq make-backup-files nil)

(global-set-key (kbd "M-RET") 'ns-toggle-fullscreen)

(put 'scroll-left 'disabled nil)

(server-start)

(global-set-key (kbd "<f10>") nil)
(global-set-key (kbd "<f11>") nil)
(global-set-key (kbd "<f12>") 'other-window)

(global-set-key (kbd "<s-right>") 'other-window)
(global-set-key (kbd "<s-left>") '(lambda () "backwards other-window" (interactive) (other-window -1)))

(global-set-key (kbd "C-c c") 'toggle-truncate-lines)
(global-set-key (kbd "C-c ;") 'comment-or-uncomment-region)

(defun transpose-windows ()
  (interactive)
  (let ((this-buffer (window-buffer (selected-window)))
        (other-buffer (prog2
                          (other-window +1)
                          (window-buffer (selected-window))
                        (other-window -1))))
    (switch-to-buffer other-buffer)
    (switch-to-buffer-other-window this-buffer)
    (other-window -1)))

(global-set-key (kbd "<s-S-right>") 'transpose-windows)

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "black" :foreground "#f6f3e8"
                :inverse-video nil :box nil :strike-through nil :overline nil
                :underline nil :slant normal :weight normal :height 70 :width normal
                :foundry "unknown" :family "Monospace")))))

;; enable awesome file prompting
(ido-mode t)
(setq ido-enable-prefix nil
      ido-enable-flex-matching t
      ido-create-new-buffer 'always
;     ido-use-filename-at-point t
      ido-max-prospects 10)

;; smex: ido for M-x
(require 'smex)
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

;; display pretty lambdas
(font-lock-add-keywords 'emacs-lisp-mode
    '(("(\\(lambda\\)\\>" (0 (prog1 ()
                               (compose-region (match-beginning 1)
                                               (match-end 1)
                                               ?λ))))))

;; Pretty clojure symbols (disabled for now)
(defun keyword-transform (pattern char)
  `(,pattern (0 (prog1 () (compose-region (match-beginning 1)
                                          (match-end 1)
                                          ,char)))))

(font-lock-add-keywords 'clojure-mode
                        (list (keyword-transform "\\(;\\+\\)" ?·)))

(when nil
  (font-lock-add-keywords 'clojure-mode
                          (list (keyword-transform "(\\(map \\)" ?·)
                                (keyword-transform "(\\(mapcat \\)" ?≫)
                                (keyword-transform "(\\(constantly \\)" ?κ)
                                (keyword-transform "(\\(reduce \\)" ?∫)
                                (keyword-transform "(\\(let \\)" ?∟))))

;; turn off scroll-bars
(scroll-bar-mode -1)

(setq slime-net-coding-system 'utf-8-unix)

(defun start-nrepl ()
  (interactive)
  (nrepl-restart))

(global-set-key (kbd "s-=") 'start-nrepl)

(defun nrepl-set-ns-switch-to-repl-buffer ()
  (interactive)
  (nrepl-set-ns (nrepl-current-ns))
  (nrepl-switch-to-repl-buffer))

(defun nrepl-save-and-load-current-buffer ()
  (interactive)
  (save-buffer)
  (nrepl-load-current-buffer))

(defun nrepl-custom-keys ()
  (define-key nrepl-interaction-mode-map (kbd "C-c C-n") 'nrepl-set-ns-switch-to-repl-buffer)
  (define-key nrepl-interaction-mode-map (kbd "C-c C-k") 'nrepl-save-and-load-current-buffer)
  (define-key nrepl-mode-map (kbd "<s-up>") 'nrepl-backward-input)
  (define-key nrepl-mode-map (kbd "<s-down>") 'nrepl-forward-input))

(add-hook 'nrepl-mode-hook 'nrepl-custom-keys)

(defun squeeze-whitespace ()
  "Squeeze white space (including new lines) between objects around point.
Leave one space or none, according to the context."
  (interactive "*")
  (skip-chars-backward " \t\r\n\f")
  (set-mark (point))
  (skip-chars-forward " \t\r\n\f")
  (kill-region (point) (mark))
  (insert ?\s)
  (fixup-whitespace))

(global-set-key (kbd "s-6") 'squeeze-whitespace)

(defun insert-line-numbers (beg end &optional start-line)
  "Insert line numbers into buffer."
  (interactive "r")
  (save-excursion
    (let ((max (count-lines beg end))
          (line (or start-line 1))
          (counter 1))
      (goto-char beg)
      (while (<= counter max)
        (insert (format "%0d	" line))
        (beginning-of-line 2)
        (incf line)
        (incf counter)))))

(defun insert-line-numbers+ ()
  "Insert line numbers into buffer."
  (interactive)
  (if mark-active
      (insert-line-numbers (region-beginning) (region-end) (read-number "Start line: "))
    (insert-line-numbers (point-min) (point-max))))

(defun strip-blank-lines ()
  "Strip blank lines in region.
   If no region strip all blank lines in current buffer."
  (interactive)
  (strip-regular-expression-string "^[ \t]*\n"))

(defun strip-line-numbers ()
  "Strip line numbers in region.
   If no region strip all the line numbers in current buffer."
  (interactive)
  (strip-regular-expression-string "^[0-9]+[ \t]?"))

(defun strip-regular-expression-string (regex)
  "Strip all strings that match regex in region.
   If no region strip current buffer."
  (interactive)
  (let ((begin (point-min))
        (end (point-max)))
    (if mark-active
        (setq begin (region-beginning)
              end (region-end)))
    (save-excursion
      (goto-char end)
      (while (and (> (point) begin)
                  (re-search-backward regex nil t))
        (replace-match "" t t)))))

(define-clojure-indent
  (let? 1))

(global-set-key (kbd "<s-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<s-wheel-down>") 'text-scale-decrease)

(global-set-key (kbd "<s-mouse-4>") 'text-scale-increase)
(global-set-key (kbd "<s-mouse-5>") 'text-scale-decrease)

(defun find-init-file ()
  "Visit init.el."
  (interactive)
  (find-file "~/.emacs.d/init.el"))

(global-set-key (kbd "s-i") 'find-init-file)
(global-set-key (kbd "s-I") 'eval-buffer)

(setq font-lock-verbose nil)

(global-set-key (kbd "s-{") 'shrink-window-horizontally)
(global-set-key (kbd "s-}") 'enlarge-window-horizontally)
(global-set-key (kbd "s-[") 'shrink-window)
(global-set-key (kbd "s-]") 'enlarge-window)

;; show column numbers
(setq column-number-mode t)

(require 'ace-jump-mode)
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)
(define-key global-map (kbd "C-c C-SPC") 'ace-jump-mode)

(require 'fill-column-indicator)
(setq fci-rule-color "#222222")

(defun setup-three-windows ()
  (interactive)
  (split-window-horizontally)
  (split-window-horizontally)
  (balance-windows-area))

(defun set-window-width ()
  (interactive)
  (enlarge-window (- 101 (window-width)) 'horizontal))

(global-set-key (kbd "C-x #") 'setup-three-windows)
(global-set-key (kbd "C-x @") 'set-window-width)

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(menu-bar-mode nil)
 '(show-paren-mode t)
 '(tool-bar-mode nil))

(add-to-list 'default-frame-alist '(width . 214))
(add-to-list 'default-frame-alist '(alpha 90 90))
(add-to-list 'default-frame-alist '(background-color . "black"))

(add-hook 'prog-mode-hook 'auto-fill-mode)
(add-hook 'prog-mode-hook 'fci-mode)

(add-hook 'text-mode-hook 'auto-fill-mode)
(add-hook 'text-mode-hook 'fci-mode)

(setq-default c-basic-offset 2)

(defun find-word-under-cursor (arg)
  (interactive "p")
  (if (looking-at "\\<") () (re-search-backward "\\<" (point-min)))
  (isearch-forward))

(global-set-key (kbd "s-s") 'find-word-under-cursor)

;; http://hugoheden.wordpress.com/2009/03/08/copypaste-with-emacs-in-terminal/
;; I prefer using the "clipboard" selection (the one the
;; typically is used by c-c/c-v) before the primary selection
;; (that uses mouse-select/middle-button-click)
(setq x-select-enable-clipboard t)

;; If emacs is run in a terminal, the clipboard- functions have no
;; effect. Instead, we use of xsel, see
;; http://www.vergenet.net/~conrad/software/xsel/ -- "a command-line
;; program for getting and setting the contents of the X selection"
(unless window-system
 (when (getenv "DISPLAY")
  ;; Callback for when user cuts
  (defun xsel-cut-function (text &optional push)
    ;; Insert text to temp-buffer, and "send" content to xsel stdin
    (with-temp-buffer
      (insert text)
      ;; I prefer using the "clipboard" selection (the one the
      ;; typically is used by c-c/c-v) before the primary selection
      ;; (that uses mouse-select/middle-button-click)
      (call-process-region (point-min) (point-max) "xsel" nil 0 nil "--clipboard" "--input")))
  ;; Call back for when user pastes
  (defun xsel-paste-function()
    ;; Find out what is current selection by xsel. If it is different
    ;; from the top of the kill-ring (car kill-ring), then return
    ;; it. Else, nil is returned, so whatever is in the top of the
    ;; kill-ring will be used.
    (let ((xsel-output (shell-command-to-string "xsel --clipboard --output")))
      (unless (string= (car kill-ring) xsel-output)
        xsel-output)))
  ;; Attach callbacks to hooks
  (setq interprogram-cut-function 'xsel-cut-function)
  (setq interprogram-paste-function 'xsel-paste-function)
  ;; Idea from
  ;; http://shreevatsa.wordpress.com/2006/10/22/emacs-copypaste-and-x/
  ;; http://www.mail-archive.com/help-gnu-emacs@gnu.org/msg03577.html
  ))

(setq scroll-step 1)
(setq scroll-conservatively 10000)
(setq auto-window-vscroll nil)

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed t) ;; accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse

(require 'evil)
(evil-mode 1)

(defun kill-start-of-line ()
  "kill from point to start of line. If at the beginning of the line, kill line break."
  (interactive)
  (if (bolp)
    (progn
      (move-end-of-line 0)
      (kill-line))
    (kill-line 0)))

(defun save-and-kill-buffer ()
  (interactive)
  (save-current-buffer)
  (kill-buffer (current-buffer)))

(define-key evil-insert-state-map (kbd "C-u") 'kill-start-of-line)
(define-key evil-normal-state-map "q" 'save-and-kill-buffer)

(defun evil-universal-key (key binding)
  (define-key evil-insert-state-map key binding)
  (define-key evil-normal-state-map key binding))

(evil-universal-key (kbd "M-.") 'slime-edit-definition)
(evil-universal-key (kbd "M-,") 'slime-pop-find-definition-stack)

(require 'undo-tree)

(setq js-indent-level 2)
