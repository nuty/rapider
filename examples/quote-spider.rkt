#lang racket

(require 
  rapider
  html-parsing
  sxml/sxpath)


(define quote-item
  (item
    (item-field #:name "title" #:xpath "//*[@class='text']/text()" #:filter (λ (x) (car x)))
    (item-field #:name "author" #:xpath "//*[@class='author']/text()" #:filter (λ (x) (car x)))
    (item-field #:name "about-url" #:xpath "//span[2]/a/@href/text()" #:filter (λ (x) (string-append "http://quotes.toscrape.com" (car x))))
    (item-field #:name "tags" #:xpath "//*[@class='tag']/text()")))

(define about-item 
  (item
    (item-field #:name "author" #:xpath "//*[@class='author-title']/text()" #:filter (λ (x) (car x)))
    (item-field #:name "born-date" #:xpath "//*[@class='author-born-date']/text()" #:filter (λ (x) (car x)))
    (item-field #:name "born-location" #:xpath "//*[@class='author-born-location']/text()" #:filter (λ (x) (car x)))
    (item-field #:name "description" #:xpath "//*[@class='author-description']/text()")))

(define quote-spider%
  (class spider%

    (init-field
      (pages 10)
      (header '("User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36"))
      (base-url "http://quotes.toscrape.com")
      (start-urls (map (λ (x) (string-append base-url "/page/" (number->string x))) (range 1 pages))))

    (define/public (start)
      (for ([url start-urls])
        (request this url 'quotes-list)))

    (define/public (quotes-list rsp)
      (for ([item (extract-data (html->xexp (response-content rsp)) "//*[@class='quote']")])
        (next this item 'quote-element)))

    (define/public (quote-element rsp)
      (define quote-items (quote-item rsp))
      (displayln quote-items)
      (request this (hash-ref quote-items "about-url") 'about))

    (define/public (about rsp)
      (displayln (about-item (html->xexp (response-content rsp)))))

  (super-new)))

(run-spider quote-spider%)