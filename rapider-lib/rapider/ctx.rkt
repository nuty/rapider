#lang racket/base
(require
  net/url
  json
  racket/port
  net/url-string
  net/head
  racket/dict
  racket/string)

;;; thanks for https://gist.github.com/DarrenN/b2a764c0e8f80dc19dbb3858700749c1

(define-struct status (version code text) #:transparent)
(define-struct response (url status headers content) #:transparent)

(define get-url
  (λ (url-string [h (list)])
    (define-values (port header)
      (get-pure-port/headers 
        (string->url url-string) 
        h
        #:redirections 10
        #:status? #t))
    (define status (parse-status (get-status header)))
    (define headers (headers->jsoneq (extract-all-fields header)))
    (make-response url-string status headers (port->string port))))

(define (headers->jsoneq header-dict)
  (for/hasheq ([hd header-dict])
    (values (string->symbol (car hd)) (string-trim (cdr hd)))))

(define (get-status header-string)
  (if 
    (string-contains? (car (regexp-match #px"[\\w/ .]*" header-string)) "OK") 
      (car (regexp-match #px"[\\w/ .]*" header-string)) 
  (string-append (car (regexp-match #px"[\\w/ .]*" header-string)) "OK")))

(define (parse-status status-str)
  (define-values (version code text) (apply values (string-split status-str)))
  (make-status version code text))


(provide 
  (all-defined-out))