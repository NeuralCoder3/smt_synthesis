; ( set-logic LIA )
; ( set-logic ALL_SUPPORTED )
( set-logic ALL )
; (declare-datatype Pair (mkPair (X Y) ((pair (first X) (second Y)))))
; (declare-datatypes () ((Pair (mk-pair (first Int) (second Int)))))
; http://cvc4.cs.stanford.edu/wiki/Datatypes
; (declare-datatype ((pair 2))
;     ((par (T) (mkPair (first T) (second T))))
; )

; https://github.com/cvc5/cvc5/blob/main/examples/api/smtlib/relations.smt2

; function from T to T with T = [0..3]^4 * bool * bool
; first argument are the registers (3 numbers, 1 swap register)
; then less than and greater than flag
; function can be cmp, mov, cmovg, cmovl
; each instruction has two arguments (source, destination register)



; f on [x,y,z,0,false,false] with x,y,z in [1..3] and distinct
; => [1,2,3,?,?,?]
; 

( synth-fun f 
    ((arr (Array Int Int))) 
    (Array Int Int)
    ( (Start (Array Int Int)) )
    (
        (Start (Array Int Int) (
            arr
        )
            ; (tuple (store arr 1 1) false false)
            ; (tuple (store arr 2 2) false false)
            ; (tuple (store arr 3 3) false false)
        )
    )
)

(declare-var x Int)
(declare-var y Int)
(declare-var z Int)
(declare-var in_array (Array Int Int))
(declare-var out_array (Array Int Int))
(constraint
    (=>
        (and
            (>= x 1)
            (<= x 3)
            (>= y 1)
            (<= y 3)
            (>= z 1)
            (<= z 3)
            (distinct x y)
            (distinct x z)
            (distinct y z)
            (= (select in_array 1) x)
            (= (select in_array 2) y)
            (= (select in_array 3) z)
            (= (select in_array 4) 0) ; swap register
            (= (select in_array 5) 0) ; lt
            (= (select in_array 6) 0) ; gt
            (= 
                ; f [x,y,z,0] false false 
                (f in_array) 
                ; => (out,lt,gt)
                out_array
            )
        )
        (and
            ; ; in 1 ... 3
            ; (>= (select out_array 1) 1)
            ; (<= (select out_array 1) 3)
            ; (>= (select out_array 2) 1)
            ; (<= (select out_array 2) 3)
            ; (>= (select out_array 3) 1)
            ; (<= (select out_array 3) 3)
            ; ; distinct
            ; (distinct (select out_array 1) (select out_array 2))
            ; (distinct (select out_array 1) (select out_array 3))
            ; (distinct (select out_array 2) (select out_array 3))
            ; ; ascending
            ; (<= (select out_array 1) (select out_array 2))
            ; (<= (select out_array 2) (select out_array 3))
            ; alternative => just 123
            (= (select out_array 1) 1)
            (= (select out_array 2) 2)
            (= (select out_array 3) 3)
        )
    )
)


( check-synth )
; call with cvc5 --lang=sygus2 <file>
; cvc5 --lang help
