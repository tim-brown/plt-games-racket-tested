#lang racket
; See: http://docs.racket-lang.org/guide/syntax_module-reader.html?q=%23lang

(provide (except-out (all-from-out racket) #%module-begin)
         (rename-out [module-begin #%module-begin])
         define/tested)

(require (for-syntax syntax/parse racket/syntax rackunit))

(define-for-syntax the-tests null)

(define-syntax (define/tested stx) 
  (define-splicing-syntax-class tests
    #:attributes (check)    
    (pattern (~seq #:test-= name (id arg ...) rhs)
             #:with check (syntax/loc stx (check-= (id arg ...) rhs 0 name))))
  
  (syntax-parse
   stx
   #:context stx
   [(_ (id args ...) t:tests ...+ content:expr ...+)    
    #`(begin        
          (define (id args ...) content ...) (provide id)
          (module+ test t.check ...))]))

(define-syntax (module-begin stx)
  (syntax-parse
   stx
   #:context stx
   [(module-begin expr ...)
    #`(#%module-begin
       (module+ test (require rackunit))
       (require rackunit)
       expr ...)]))
