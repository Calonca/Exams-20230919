#lang racket

(define (make-mat n default)
  (define mat (make-vector n #f))
  (let loop ((x 0))
    (if (= n x)
        mat
        (begin
          (vector-set! mat x (make-vector n default))
          (loop (+ x 1)))))
  )

(define (mat-ref mat y x)
  (vector-ref (vector-ref mat y) x)
  )

(define (list-eq list1 list2)
  ; (display list1)
  ; (display list2)
  ; (display "\n")
  (if (= (car list1) (car list2))
      (= (car (cdr list1)) (car (cdr list2)))
      #f)
  )

(define (bijection mat)
  (define len (vector-length mat))
  (call/cc
   (lambda (exit)
     (let loop ((y 0))
       (if (< y len)
           (let loop2 ((x 0))
             (if (< x y)
                 (if (list-eq (mat-ref mat x y) (mat-ref mat y x))
                     (loop2 (+ x 1))
                     (exit #f))
                 (loop (+ y 1))
                 )
             )
           #t
           )
       )
     ))
  )

(define (print-mat mat)
  (define n (vector-length mat))
  (let loop ((x 0))
    (if (>= x n)
        (display "\n")
        (begin
          (display "\n")
          (display (vector-ref mat x))
          (loop (+ x 1))
          )))
  )

(define mat (make-mat 4 '(20 2)))
(vector-set! (vector-ref mat 1) 2 '(10 2))
(bijection mat)

(vector-set! (vector-ref mat 2) 1 '(10 2))
(bijection mat)
(print-mat mat)
