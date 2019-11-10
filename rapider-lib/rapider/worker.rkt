#lang racket
(require
  racket/async-channel
  "ctx.rkt")


(define urls-channel (make-async-channel))
(define workers-channel (make-async-channel))
(define threads-num (+ (* (processor-count) 2) 2))

(define (request cls url callbacks [extra '()])
  (async-channel-put urls-channel (list cls url callbacks extra)))

(define (next cls doc callbacks [extra '()])
  (cond 
    [(symbol? callbacks) 
      (if 
        (empty? extra) 
          (dynamic-send cls callbacks doc)
        (dynamic-send cls callbacks doc extra))]
    [else 
      (for ([callback callbacks])
        (if 
          (empty? extra) 
            (dynamic-send cls callback doc)
          (dynamic-send cls callback doc extra)))]))


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
                  [callbacks (third elem)]
                  [extra (fourth elem)]
                  [header (if (field-bound? header cls) (dynamic-get-field 'header cls) '())])
                (let ([rsp (get-url url header)])
                  (cond [(empty? extra) 
                    (if (symbol? callbacks)
                      (dynamic-send cls callbacks rsp)
                    (for ([callback callbacks])
                      (dynamic-send cls callback rsp)))]
                    [else (if (symbol? callbacks)
                      (dynamic-send cls callbacks rsp extra)
                    (for ([callback callbacks])
                      (dynamic-send cls callback rsp extra)))])))
              (void))]))
      (loop))))

(define generate-workers 
  (lambda () 
    (map (lambda (x) (thread (lambda () (worker)))) (range threads-num))))

(provide
  request
  next
  generate-workers)