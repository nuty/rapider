#lang racket

(require 
  ; "../../rapider-lib/rapider/main.rkt"
  rapider
)


(define play-spider%
  (class spider%

    (init-field 
      (name "play")
      (pages 100)
      (header '("User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36"))
      (base-url "http://0.0.0.0:8000/")
      (start-urls 
        (map 
          (λ (x) 
            base-url) (range 1 pages))))

    (define/public (start)
      (for ([url start-urls])
        (request this url 'parse-list)))

    (define/public (parse-list rsp)
      (display rsp))

  (super-new)))



(run-spider play-spider%)