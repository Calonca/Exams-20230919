#lang racket

; Define a new construct called block-then which creates two scopes for variables, declared after the
; scopes, with two different binding. E.g. the evaluation of the following code:

(define-syntax block
  (syntax-rules (then where <-)
    ((_ (stmts ...) then (stmts2 ...) where (var <- a b) ...)
     (begin
       (let ((var a) ...) stmts ...)
       (let ((var b) ...) stmts2 ...)
       ))
    ))

(block
 ((displayln (+ x y))
  (displayln (* x y))
  (displayln (* z z)))
 then
 ((displayln (+ x y))
  (displayln (* z x)))
 where (x <- 12 3)(y <- 8 7)(z <- 3 2))

;  should show on the screen:
; 20
; 96
; 9
; 10
; 6