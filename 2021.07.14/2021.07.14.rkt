#lang racket
; defun f (x1 x2 ...) body

; (ret x)

(define-syntax defun
  (syntax-rules () ; no other needed keywords
    ((_ f (var ...) body ...) ; pattern P
     (define (f var ...) ; expansion of P
       (body ...
       )))))