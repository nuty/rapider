#lang racket

(require 
  ; rapider
  "../rapider-lib/rapider/main.rkt"
  html-parsing
  db
  sxml/sxpath)


(define blog-item
  (item    
    (item-field #:name "title" #:xpath "//*[@class='more']/@href")
    (item-field #:name "author" #:xpath "//*[@class='more']/@href" #:filter (λ (x) (displayln x)))
    (item-field #:name "date" #:xpath "//*[@class='more']/@href")
    (item-field #:name "content" #:xpath "//*[@class='more']/@href" #:filter (λ (x) (displayln x)))))


(define item-url-partern "//*[@class='more']/@href")

(define blog-spider%
  (class spider%
    (init-field 
      (pages 16)
      (base-url "http://blog.racket-lang.org")
      (start-urls 
        (map 
          (λ (x) 
            (string-append base-url "/index-" (number->string x) ".html")) (range 2 pages))))

    (define/public (start)
      (for ([url start-urls])
        (request this url 'parse-list)))

    (define/public (parse-list rsp)
      (for ([item (extract-data (html->xexp (response-content rsp)) item-url-partern)])
        (let ([item-url (string-append base-url (car (cdr item)))])
          (request this item-url 'parse-blog))))


    (define/public (parse-blog rsp)
      (void))
      ; (displayln (html->xexp rsp)))

  (super-new)))



(run-spider
  blog-spider%)


