;;; org-mtg.el - Support for links to scryfall pages in Org mode

(require 'org)
(require 'request)

(org-link-set-parameters "mtg" :follow #'org-mtg-open-card)

(defun org-mtg-open-card (cardname)
  (let* ((normalized-cardname (org-mtg-normalize-cardname cardname))
         (link (org-mtg-scryfall-link normalized-cardname)))
    (org-open-link-from-string link)))

(defun org-mtg-normalize-cardname (cardname)
  (replace-regexp-in-string "[',]" "" cardname))

(defun org-mtg-scryfall-link (cardname)
  (let* ((req
         (request "api.scryfall.com/cards/named"
                  :params (list (cons "fuzzy" cardname))
                  :sync t
                  :parser 'json-read))
         (data (request-response-data req)))
    (alist-get 'scryfall_uri data)))

(org-link-set-parameters "mtg" :complete #'org-mtg-autocomplete)

(defun org-mtg-autocomplete-request (cardname &optional predicate-fn flag)
  (let*
      ((req (request "api.scryfall.com/cards/autocomplete"
                     :sync t
                     :parser (lambda ()
                               (let ((json-array-type 'list))
                                 (json-read)))
                     :params (list (cons "q" cardname))))
       (guesses (alist-get 'data (request-response-data req))))
      guesses
    ))

(defun org-mtg-autocomplete (&optional prefix)
  (format "mtg:%s"
          (completing-read "Enter card name: " #'org-mtg-autocomplete-request)))

(provide 'org-mtg)
