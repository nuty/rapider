#lang racket/base
(require
  net/url
  json
  racket/port
  net/url-string
  net/head
  racket/dict
  racket/string
  "logging.rkt")


(current-logger rapider-log)

(struct status (version code text) #:transparent)
(struct response (url status headers content) #:transparent)


(define (get-url url-string)
  (log-info url-string)
  (define-values (port header)
    (get-pure-port/headers (string->url url-string) #:redirections 5
                           #:status? #t))
  (define status (parse-status (get-status header)))
  (define headers (headers->jsoneq (extract-all-fields header)))
  (response url-string status headers (port->string port)))

(define (headers->jsoneq header-dict)
  (for/hasheq ([hd header-dict])
    (values (string->symbol (car hd)) (string-trim (cdr hd)))))

(define (get-status header-string)
  (car (regexp-match #px"[\\w/ .]*" header-string)))

(define (parse-status status-str)
  (define-values (version code text) (apply values (string-split status-str)))
  (status version code text))


(provide get-url)