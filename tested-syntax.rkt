#lang racket
(require (for-syntax syntax/parse syntax/quote))

(module+ main)

(module+ test
  (require rackunit))

; type of a test-clause is either
;  - 
(define-syntax (define/tested stx)
  
  (define-splicing-syntax-class tests
    #:attributes (check mock)

    (pattern (~seq #:test-= name (id arg ...) rhs)
             #:with check #'(check-= (id arg ...) rhs 0 name)
             #:with mock  #'[(equal? (list arg ...) mock-args) rhs])
    
    #;(pattern (~seq #:test-equal? name val (_ arg ...)))
    #;(pattern (~seq #:test-true?  name (pred-left ...+) (_ arg ...)))
    #;(pattern (~seq #:test-false? name (pred-left ...+) (_ arg ...)))
    )
  
  (syntax-parse
   stx
   [(_ (id args ...) t:tests ...+ #:body content ...+)
    #`(begin
        (module+ test
          t.check
          ...)
        (module+ mock
          (provide id)
          (define (id . mock-args)
            (cond
              t.mock
              ...
              [else (error (format "unmocked value for: ~s" '(id args ...)))])))
        (provide id)
          (define (id args ...)
          content ...))]))

(define/tested (add2 a #:offset (offset 0))
  #:test-= "two and two is/are four -- elementary" (add2 2) 4
  ;#:test-= "crappy failing test" (add2 2 #:offset 1) 7
  ; #:test-equal? "two and two is/are four but we can offset a bit" (= 5) (add2 2 #:offset 1)
  ; #:test-= "crappy failing test" (= 6) (add2 2 #:offset 1)
  ; #:test-false? "crappy failing test" (add2 2 #:offset 1)
  #:body (+ a 2 offset))

#|
(require (prefix-in mok: (submod "." mock)))
mok:add2
|#