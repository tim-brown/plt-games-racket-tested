#lang racket
(provide (except-out (all-from-out racket) #%module-begin define)
         (rename-out (module-begin #%module-begin) (my-define define)))

(require (for-syntax syntax/parse))
(define-for-syntax counter 0)

(define-syntax (my-define stx)
  (syntax-parse
   stx
   [(_ i v) (set! counter (add1 counter)) #`(define i v)]
   
   [(_ (i args ...) v ...+) (set! counter (add1 counter))
                            #`(define (i args ...) v ...)]))

(define-syntax (module-begin stx)
  (syntax-parse
   stx
   [(_ expr ...)
    #`(#%module-begin expr ...
       (define defines-count #,counter)
       (provide defines-count))]))