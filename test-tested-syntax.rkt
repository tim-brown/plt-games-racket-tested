#lang reader "tested-racket.rkt"

(define/tested (add2 a #:offset (offset 0))
  #:test-= "two and two is/are four -- elementary" (add2 2) 4
  ; #:test-= "crappy failing test" (add2 2 #:offset 1) 7
  ; #:test-equal? "two and two is/are four but we can offset a bit" (= 5) (add2 2 #:offset 1)
  ; #:test-= "crappy failing test" (= 6) (add2 2 #:offset 1)
  ; #:test-false? "crappy failing test" (add2 2 #:offset 1)
  (+ a 2 offset))

(define/tested (fact a)
    #:test-= "(fact 0) = 1" (fact 0) 1
    #:test-= "(fact 1) = 1" (fact 1) 1
    #:test-= "(fact 2) = 2" (fact 2) 2
    #:test-= "(fact 3) = 6" (fact 3) 6
    #:test-= "(fact 4) = 24" (fact 4) 24)
