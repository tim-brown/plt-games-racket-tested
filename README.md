plt-games-racket-tested
=======================

Syntax extensions to ease TDD in racket (but I'll call it a new language!)


[Racket][] provides for unit testing (through the `rackunit` module).
But there is no way to force functions to be tested.
[Racket]: http://www.racket-lang.org

I'll only be able to "force" functions to be `define/tested` if I can suppress
`define`.

TODO:

  * define the `define/tested` syntax
  * create a `#lang` the replaces (disables) `define` with `define/tested`
  * create mock functions
  * handle inner `define`s/named `let`s

