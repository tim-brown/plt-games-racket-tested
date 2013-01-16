#lang racket
; See: http://docs.racket-lang.org/guide/syntax_module-reader.html?q=%23lang

(provide (except-out (all-from-out racket) #%module-begin)
         (rename-out [module-begin #%module-begin])
         define/tested)

(require (for-syntax syntax/parse))
(define-for-syntax MOCKS null)
(define-for-syntax IMPLS null)
(define-for-syntax TESTS null)

(define-syntax (get-MOCKS stx) (if #f #`(begin) #`(module* mock #f #,@MOCKS)))
(define-syntax (get-TESTS stx) (if #f #`(begin) #`(module* test #f (require rackunit) #,@TESTS)))
#;(define-syntax (get-IMPLS stx) (datum->syntax stx (append '(module main racket) IMPLS)))

(define-for-syntax (add-MOCK m-stx) (set! MOCKS (cons m-stx MOCKS)))
(define-for-syntax (add-TEST t-stx) (set! TESTS (cons t-stx TESTS)))
(define-for-syntax (add-IMPL i-stx) (set! IMPLS (cons i-stx IMPLS)))

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
             #:with mock  (syntax/loc stx  [(equal? (list arg ...) mock-args) #f])))
  
  (syntax-parse
   stx
   #:context stx
   [(_ (id args ...) t:tests ...+ content:expr ...+)    
    (add-MOCK #`(begin (provide id)
                       (define (id . mock-args)
                         (cond t.mock ...
                               [else (error (format "unmocked value for: ~s" `(id . ,mock-args)))]))))
    (add-TEST #`(begin t.check ...))
    #`(begin (define (id args ...) content ...) (provide id))
    ]
   [(_ (id args ...) t:tests ...+)
    (add-MOCK #`(begin
                  (provide id)
                  (define (id . mock-args)
                    (cond
                      t.mock ...
                      [else (error (format "unmocked value for: ~s" `(id . ,mock-args)))]))))
    #`(begin)]))

(define-syntax (module-begin stx)
  (syntax-parse
   stx
   #:context stx
   [(module-begin expr ...)
    (let ((rv
           #`(#%module-begin
              expr ...
              (get-MOCKS)
              #;#,@IMPLS
              (get-TESTS))))
      rv)]))
