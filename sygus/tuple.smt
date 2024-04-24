( set-logic ALL )
( set-option :produce-models true )

; for define sort
; https://cvc5.github.io/docs/cvc5-1.0.0/examples/datatypes.html

; (declare-sort P 0)
; (declare-sort Q 0)
; (declare-sort R 0)
(define-sort P () Int)
(define-sort Q () Int)
(define-sort R () Int)

(declare-fun tuple_access_0 ((Tuple P Q R)) P)
(declare-fun tuple_access_1 ((Tuple P Q R)) Q)
(declare-fun tuple_access_2 ((Tuple P Q R)) R)

; (declare-const a P)
; (declare-const b Q)
; (declare-const c R)

; (assert (= (tuple_access_0 (tuple a b c)) a))
; (assert (= (tuple_access_1 (tuple a b c)) b))
; (assert (= (tuple_access_2 (tuple a b c)) c))
; (assert (distinct a b c))

(assert
    (forall ((a P) (b Q) (c R))
        (and
            (= (tuple_access_0 (tuple a b c)) a)
            (= (tuple_access_1 (tuple a b c)) b)
            (= (tuple_access_2 (tuple a b c)) c)
        )
    )
)

(check-sat)
(get-model)
; test function
(get-value (tuple_access_0 (tuple 1 2 3)))
(get-value (tuple_access_1 (tuple 1 2 3)))
(get-value (tuple_access_2 (tuple 1 2 3)))
