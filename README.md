## Overview

Rapider is a web scraping micro-framework based on thread, written with `racket` and `async-channel`, JUST FOR FUN.

## Installation


``` shell
raco pkg install rapider
```

## Usage

### Item & Field
Item and Field used to extract data by xpath from xexp doc. I use [SXML](https://docs.racket-lang.org/sxml/index.html "SXML") library.

```racket
#lang racket
;;; items.rkt

(require rapider)

(provide
  quote-item
  about-item)

(define quote-item
  (item
    (item-field #:name "title" #:xpath "//*[@class='text']/text()" #:filter (λ (x) (car x)))
    (item-field #:name "author" #:xpath "//*[@class='author']/text()" #:filter (λ (x) (car x)))
    (item-field
      #:name "about-url" 
      #:xpath "//span[2]/a/@href/text()"
      #:filter (λ (x) (string-append "http://quotes.toscrape.com" (car x))))
    (item-field #:name "tags" #:xpath "//*[@class='tag']/text()")))

(define about-item 
  (item
    (item-field #:name "author" #:xpath "//*[@class='author-title']/text()" #:filter (λ (x) (car x)))
    (item-field #:name "born-date" #:xpath "//*[@class='author-born-date']/text()" #:filter (λ (x) (car x)))
    (item-field #:name "born-location" #:xpath "//*[@class='author-born-location']/text()" #:filter (λ (x) (car x)))
    (item-field #:name "description" #:xpath "//*[@class='author-description']/text()")))
```

### Spider

`Spider` is used for control requests.

```racket
#lang racket
;;; crawler.rkt

(require 
  rapider
  "items.rkt")

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
       ;;;lets handle quote data
      (displayln quote-items)
      (request this (hash-ref quote-items "about-url") 'about))

    (define/public (about rsp)
      ;;;lets handle quote data
      (displayln (about-item (html->xexp (response-content rsp)))))

  (super-new)))

(run-spider quote-spider%)
```

Run `racket crawler.rkt`:

``` shell
(info) (2019-10-22 02:50:08) (rapider: http://quotes.toscrape.com/author/Mother-Teresa) (crawled)
(info) (2019-10-22 02:50:08) (rapider: http://quotes.toscrape.com/author/J-K-Rowling) (crawled)
(info) (2019-10-22 02:50:08) (rapider: http://quotes.toscrape.com/author/Charles-M-Schulz) (crawled)
(info) (2019-10-22 02:50:08) (rapider: http://quotes.toscrape.com/author/William-Nicholson) (crawled)
(info) (2019-10-22 02:50:08) (rapider: http://quotes.toscrape.com/author/Albert-Einstein) (crawled)
(info) (2019-10-22 02:50:08) (rapider: http://quotes.toscrape.com/author/Jorge-Luis-Borges) (crawled)
(info) (2019-10-22 02:50:09) (rapider: http://quotes.toscrape.com/author/George-Eliot) (crawled)
(info) (2019-10-22 02:50:09) (rapider: http://quotes.toscrape.com/author/Jane-Austen) (crawled)
(info) (2019-10-22 02:50:09) (rapider: http://quotes.toscrape.com/author/Eleanor-Roosevelt) (crawled)
(info) (2019-10-22 02:50:09) (rapider: http://quotes.toscrape.com/author/Marilyn-Monroe) (crawled)
(info) (2019-10-22 02:50:09) (rapider: http://quotes.toscrape.com/author/Albert-Einstein) (crawled)
(info) (2019-10-22 02:50:09) (rapider: http://quotes.toscrape.com/author/Haruki-Murakami) (crawled)
(info) (2019-10-22 02:50:09) (rapider: http://quotes.toscrape.com/author/Alexandre-Dumas-fils) (crawled)
```


### examples
----------
[Realworld spider](https://github.com/nuty/news-spider).

[Demos](https://github.com/nuty/rapider/tree/master/examples).
