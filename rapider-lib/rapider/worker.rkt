#lang racket
(require
  racket/async-channel
  "ctx.rkt")

(define urls-channel (make-async-channel))
(define workers-channel (make-async-channel))
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
                (let ([rsp (get-url url header)])
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
  request
  next
  generate-workers)