#lang racket
; See: http://docs.racket-lang.org/guide/syntax_module-reader.html?q=%23lang

(provide (except-out (all-from-out racket) #%module-begin)
         (rename-out [module-begin #%module-begin])
         define/tested)

(require (for-syntax syntax/parse racket/syntax rackunit))

(define-for-syntax the-tests null)
(define-for-syntax (add-tests tsts) (set! the-tests (append the-tests tsts)))
(define-syntax (get-TESTS stx) (datum->syntax stx (cons 'begin the-tests)))

(define-for-syntax the-provides null)
(define-for-syntax (add-prov stx prv) (set! the-provides (cons (cons stx prv) the-provides)))
(define-syntax (get-PROVS stx) #`(provide #,@(map (lambda (s.p) (datum->syntax (car s.p) (cdr s.p)))
                                                the-provides)))



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
    (let ((mock-name (format-id #'id "mock-~a" #'id)))
      #;(add-tests (syntax->datum #`(t.check ...)))
      #;(add-prov stx (syntax->datum #'id))
      #`(begin        
          (define (id args ...) content ...) (provide id)
          (module+ test #;(require rackunit) t.check ...)
          #;(provide #,mock-name)
          #;(define (#,mock-name . mock-args)
              (cond t.mock ...
                    [else (error (format "unmocked value for: ~s" `(id . ,mock-args)))]))))]
   [(_ (id args ...) t:tests ...+)
    (let ((mock-name (format-id #'id "~a" #'id))) ; that's right -- it's id itself!
      #`(begin        
          #;(provide #,mock-name)
          #;(define (#,mock-name . mock-args)
              (cond t.mock ...
                    [else (error (format "unmocked value for: ~s" `(id . ,mock-args)))]))))    
    ]))

(define-syntax (module-begin stx)
  (syntax-parse
   stx
   #:context stx
   [(module-begin expr ...)
    #`(#%module-begin
       (module+ test (require rackunit))
       (require rackunit)
       expr ...
       #;(get-PROVS)
       #;(get-TESTS)
       #;(module+ test (require rackunit) ))
    ]))
