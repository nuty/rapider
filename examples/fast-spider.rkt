#lang racket

(require 
  rapider
  html-parsing)



(define fast-spider%
  (class spider%

    (init-field 
      (name "fast")
      (pages 2)
      (base-url "http://www.xinfadi.com.cn/marketanalysis/0/list/")
      (start-urls 
        (map 
          (λ (x) 
            (string-append base-url (number->string x) ".shtml")) (range 1 pages))))

    (define/public (start)
      (for ([url start-urls])
        (request this url (list 'parse-list))))

    (define/public (parse-list rsp)
      (displayln (response-url rsp))
      (displayln (response-status rsp)))


  (super-new)))


(run-spider fast-spider%)