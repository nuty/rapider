#lang racket

(require 
  rapider
  html-parsing
  sxml)


(define tr-partern "/html/body/div[2]/div[4]/div[1]/table/tr")
(define td-partern "//td/text()")


(define xinfadi-spider%
  (class spider%

    (init-field 
      (name "xinfadi")
      (pages 100)
      (header '("User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36"))
      (base-url "http://www.xinfadi.com.cn/marketanalysis/0/list/")
      (start-urls 
        (map 
          (λ (x) 
            (string-append base-url (number->string x) ".shtml")) (range 1 pages))))

    (define/public (start)
      (for ([url start-urls])
        (request this url 'parse-list)))

    (define/public (parse-list rsp)
      (void))

  (super-new)))



(run-spider xinfadi-spider%)