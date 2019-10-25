#lang racket
(require
  racket/async-channel
  net/url
  "logging.rkt")


(current-logger rapider-log)

(define urls-channel (make-async-channel))
(define workers-channel (make-async-channel))

(define get
  (λ (url [header (list)])
    (log-info url)
    (call/input-url
      (string->url url)
        (curry get-pure-port #:redirections 5)
      port->string
      header)))

(define post
  (λ (url [header (list)])
    (log-info url)
    (call/input-url
      (string->url url)
        (curry post-pure-port #:redirections 5)
      port->string
      header)))

(define put
  (λ (url [header (list)])
    (log-info url)
    (call/input-url
      (string->url url)
        (curry put-pure-port #:redirections 5)
      port->string
      header)))

(define delete
  (λ (url [header (list)])
    (log-info url)
    (call/input-url
      (string->url url)
        (curry delete-pure-port #:redirections 5)
      port->string
      header)))

(define threads-num (+ (* (processor-count) 2) 2))

(define (request cls url callbacks)
  (async-channel-put urls-channel (list cls url callbacks)))


(define (next cls doc callbacks)
  (cond 
    [(symbol? callbacks) (dynamic-send cls callbacks doc)]
    [else 
      (for ([callback callbacks])
        (dynamic-send cls callback doc))]))


(define (worker)
  (async-channel-put workers-channel
    (let loop ()
      (let ([elem (async-channel-try-get urls-channel)])
        (cond
          [(not elem) (kill-thread (current-thread))]
          [else
            (if (not (string? elem))
              (let*
                ([cls (first elem)] 
                  [url (second elem)]
                  [callbacks (last elem)]
                  [header (if (field-bound? header cls) (dynamic-get-field 'header cls) '())])
                (let ([rsp (get url header)])
                  (if (symbol? callbacks)
                    (dynamic-send cls callbacks rsp)
                  (for ([callback callbacks])
                    (dynamic-send cls callback rsp)))))
              (void))]))
      (loop))))


(define generate-workers 
  (lambda () 
    (map (lambda (x) (thread (lambda () (worker)))) (range threads-num))))

(provide
  generate-workers
  next
  request)