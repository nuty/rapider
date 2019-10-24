#lang racket/base
(require gregor)


(define (gmt)
  (let ([gmt (parameterize ([current-locale "en"])
    (~t (now/utc) "Y-M-d hh:mm:ss"))])
  gmt))


(define rapider-log (make-logger 'rapider))

(define rc1 (make-log-receiver rapider-log 'info))

(void 
  (thread 
    (λ()
      (let loop () 
        (define v (sync rc1))
         (printf "(~a) (~a) (~a) (crawled) \n" (vector-ref v 0) (gmt) (vector-ref v 1))
      (loop)))))

(provide 
  rapider-log)