#lang racket

; Define a function mix which takes a variable number of arguments x0 x1 x2 ... xn, the first one a function,
; and returns the list (x1 (x2 ... (x0(x1) x0(x2) ... x0(xn)) xn) xn-1) ... x1).
; E.g.
; (mix (lambda (x) (* x x)) 1 2 3 4 5)
; returns: '(1 (2 (3 (4 (5 (1 4 9 16 25) 5) 4) 3) 2) 1)

(define (concboth first acc)
  (list first acc first)
)

(define (mix fn . others)
    (begin
        ; apply fn to list
        (foldr concboth (map fn others) others)
        ;  (map fn others)
        )
)

