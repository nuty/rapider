#lang racket

(require 
  rapider
  html-parsing
  sxml/sxpath)


(define tr-partern "/html/body/div[2]/div[4]/div[1]/table/tr")
(define td-partern "//td/text()")


(define souhu-spider%
  (class spider%

    (init-field 
      (name "souhu")
      (pages 100)
      (header '("User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36"))
      (base-url "https://www.guancha.cn/internation?s=dhguoji"))


    (define/public (start)
      ; (for ([url start-urls])
      (request this base-url 'parse-list))

    (define/public (parse-list rsp)
      (displayln (html->xexp rsp)))

  (super-new)))



(run-spider souhu-spider%)