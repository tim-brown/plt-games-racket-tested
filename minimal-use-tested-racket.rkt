#lang reader "minimal-tested-racket.rkt"

(define/tested (add2 a #:offset (offset 0))
  #:test-= "two and two is/are four -- elementary" (add2 2) 4
  (+ a 2 offset))

(add2 2)