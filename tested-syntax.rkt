#lang racket
(require (for-syntax syntax/parse))

(module+ test (require rackunit))

(define-syntax (define/tested stx)
  (syntax-parse
   stx
   [(_ (id args ...)
       #:tests
       (test-name (test-pred-left ...+) (_ test-args ...)) ...+
       #:body
       content ...+)
    #'(begin
        (module+ test
          (check-true (test-pred-left ... (id test-args ...))
                 test-name) ...)
        (define (id args ...) content ...))]))

(define/tested (add2 a #:offset (offset 0))
  #:tests
  ("two and two is/are four -- elementary" (= 4) (a 2))
  ("two and two is/are four but we can offset a bit"
   (= 5) (a 2 #:offset 1))
  #:body
  (+ a 2 offset))
