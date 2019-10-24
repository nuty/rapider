#lang racket

(require 
  rapider
  html-parsing
  sxml)



(define fast-spider%
  (class spider%

    (init-field 
      (name "fast")
      (pages 100)
      (base-url "http://www.xinfadi.com.cn/marketanalysis/0/list/")
      (start-urls 
        (map 
          (λ (x) 
            (string-append base-url (number->string x) ".shtml")) (range 1 pages))))

    (define/public (start)
      (for ([url start-urls])
        (request this url (list 'parse-list 'parse-list1))))

    (define/public (parse-list rsp)
      (displayln rsp))

    (define/public (parse-list1 rsp)
       (displayln (html->xexp rsp)))

  (super-new)))


(run-spider fast-spider%)