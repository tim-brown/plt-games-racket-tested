#lang racket

(provide (except-out (all-from-out racket)
                     #%module-begin)
         (all-from-out rackunit)
         (rename-out [module-begin #%module-begin])
         define/tested)

(require rackunit)
(require (for-syntax syntax/parse))

;(module+ main)

(module+ mock)

;(module+ test (require rackunit))
(define-syntax (define/tested stx)
  
  (define-splicing-syntax-class tests
    #:attributes (check mock)
    
    (pattern (~seq #:test-= name (id arg ...) rhs)
             #:with check (syntax/loc stx (check-= (id arg ...) rhs 0 name))
             #:with mock  (syntax/loc stx  [(equal? (list arg ...) mock-args) rhs]))
    
    (pattern (~seq #:test-equal? name (id arg ...) rhs)
             #:with check (syntax/loc stx (check-equal? (id arg ...) rhs name))
             #:with mock  (syntax/loc stx  [(equal? (list arg ...) mock-args) rhs]))
    
    (pattern (~seq #:test-true? name (id arg ...) rhs)
             #:with check (syntax/loc stx (check-true? (id arg ...)))
             #:with mock  (syntax/loc stx  [(equal? (list arg ...) mock-args) #t]))
    
    (pattern (~seq #:test-false? name (_ arg ...) rhs)
             #:with check (syntax/loc stx (check-false? (id arg ...) name))
             #:with mock  (syntax/loc stx  [(equal? (list arg ...) mock-args) #f]))
    )
  
  (syntax-parse
   stx
   #:context stx
   [(_ (id args ...) t:tests ...+ content:expr ...+)
    #`(begin
        (module+ test t.check ...)
        (module+ mock
          (provide id)
          (define (id . mock-args)
            (cond
              t.mock
              ...
              [else (error (format "unmocked value for: ~s" '(id args ...)))])))
        (provide id)
        (define (id args ...) content ...))]
   [(_ (id args ...) t:tests ...+)
    #`(begin
        (module+ mock
          (provide id)
          (define (id . mock-args)
            (cond
              t.mock
              ...
              [else (error (format "unmocked value for: ~s" '(id args ...)))])))
        #;(require (only-in 'mock id))
        )]))

#|
(require (prefix-in mok: (submod "." mock))) mok:add2 (mok:add2 2)
|#
(define-syntax (module-begin stx)
  (syntax-parse stx #:context stx
                [(module-begin expr ...)
                 #`(#%module-begin
                    ;#,@MOCKS
                    ;#,@IMPLS
                    ;#,@TESTS
                    expr ...)]))