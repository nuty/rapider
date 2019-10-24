#lang racket
(require
  racket/logging
  net/url
  html-parsing
  sxml
  "ctx.rkt")


(define spider%
  (class object%
    (super-new)))


(define run-spider 
  (lambda (spider-class)
    (sync
      (thread
        (lambda ()
          (send (make-object spider-class) start))))
    (for-each sync (generate-workers))))


(provide
  spider%
  run-spider)
