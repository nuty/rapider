#lang racket
(require
  sxml
  racket/logging)

(define (extract-data html partern)
  ((sxpath partern) html))


(define (item-field
        #:name    name
        #:xpath   xpath
        #:filter  [filter (void)])
  (list name xpath filter))


(define (make-item-hash fields) 
  (define item-hash (make-hash))
    (for/list ([field (in-list fields)])
      (let*
        ([name (first field)]
         [xpath (second field)]
         [filter (third field)])
        (cond 
          [(equal? filter (void)) (hash-set! item-hash name (hash 'xpath xpath))]
          [else
            (hash-set! item-hash name (hash 'xpath xpath 'filter filter))])))
  item-hash)


(define (item . fields)
  (define item-hash (make-item-hash fields))
  
  (define (parse-item doc)
    (define result-hash (make-hash))
    (for ([key (hash-keys item-hash)])
      (let*
        ([meta (hash-ref item-hash key)]
         [xpath (hash-ref meta 'xpath)]
         [filter (if (hash-has-key? meta 'filter) (hash-ref meta 'filter) "")])
        (cond 
          [(equal? filter "")
            (let 
              ([origin-data (extract-data doc xpath)])
              (hash-set! result-hash key origin-data))]
          [else
            (let* 
              ([origin-data (extract-data doc xpath)]
                [filter-data (filter origin-data)])
              (hash-set! result-hash key filter-data))])))
      result-hash)
  parse-item)


(provide 
  item
  item-field
  extract-data)