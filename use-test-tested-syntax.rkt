#lang racket
(require "test-tested-syntax.rkt")
(require (only-in (submod "test-tested-syntax.rkt" mock) fact))

(add2 3)
(fact 4)