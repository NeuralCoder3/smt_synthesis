; either int -> command or directly vars
(set-logic ALL)
(set-option :produce-models true)

(declare-datatypes ((Triple 3)) 
    ((par (P Q R) ((triple (first P) (second Q) (third R)))))
)
(declare-datatype Instruction ((cmp) (mov) (cmovg) (cmovl)))

; declare the variables
(declare-const inst_1 Instruction)
(declare-const    a_1 Int)
(declare-const    b_1 Int)
(declare-const inst_2 Instruction)
(declare-const    a_2 Int)
(declare-const    b_2 Int)
(declare-const inst_3 Instruction)
(declare-const    a_3 Int)
(declare-const    b_3 Int)
(declare-const inst_4 Instruction)
(declare-const    a_4 Int)
(declare-const    b_4 Int)

; register restrictions
(assert (and (<= 0 a_1) (<= a_1 3)))
(assert (and (<= 0 b_1) (<= b_1 3)))
(assert (and (<= 0 a_2) (<= a_2 3)))
(assert (and (<= 0 b_2) (<= b_2 3)))
(assert (and (<= 0 a_3) (<= a_3 3)))
(assert (and (<= 0 b_3) (<= b_3 3)))
(assert (and (<= 0 a_4) (<= a_4 3)))
(assert (and (<= 0 b_4) (<= b_4 3)))


(define-fun apply 
    (
        (i Instruction) 
        (reg1 Int) ; 0<=reg1<=3
        (reg2 Int) ; 0<=reg2<=3
        (tup (Triple (Array Int Int) Bool Bool))
    ) 
    (Triple (Array Int Int) Bool Bool)
    ; (arr,lt,gt) = tup
    (let (
            (arr (first tup))
            (lt (second tup))
            (gt (third tup))
        )
    (let (
            (a (select arr reg1)) ; dest
            (b (select arr reg2)) ; src
        )
        (ite (= i cmp)
            (triple arr (< a b) (> a b))
            (ite (= i mov)
                (triple (store arr reg1 b) lt gt)
                (ite (= i cmovg)
                    (ite gt (triple (store arr reg1 b) lt gt) (triple arr lt gt))
                    (ite (= i cmovl)
                        (ite lt (triple (store arr reg1 b) lt gt) (triple arr lt gt))
                        ; error
                        (triple arr lt gt)
                    )
                )
            )
        )
    ))
)


(define-fun apply_all
    (
        (state (Triple (Array Int Int) Bool Bool))
    )
    (Triple (Array Int Int) Bool Bool)
    (apply inst_4 b_4 a_4
    (apply inst_3 b_3 a_3
    (apply inst_2 b_2 a_2
    (apply inst_1 b_1 a_1 
    state
    ))))
)

; apply on initial states (all six permutations)
; e.g. 123 => [1,2,3,0],false,false
(define-fun inital_state
    (
        (a Int) (b Int) (c Int)
    )
    (Triple (Array Int Int) Bool Bool)
    (triple 
        (store (store (store (store ((as const (Array Int Int)) 0) 0 a) 1 b) 2 c) 3 0)
        false
        false
    )
)

(define-fun check
    (
        (state (Triple (Array Int Int) Bool Bool))
    )
    Bool
    (
    let (
        (arr (first state))
    ) (and
        ; (= (select arr 0) 0)
        (= (select arr 0) 1)
        ; (= (select arr 1) 2)
        ; (= (select arr 2) 3)
    )
    )
)


; (assert (check (apply_all (inital_state 1 2 3))))
; (assert (check (apply_all (inital_state 1 3 2))))
; (assert (check (apply_all (inital_state 2 1 3))))
; (assert (check (apply_all (inital_state 2 3 1))))
; (assert (check (apply_all (inital_state 3 1 2))))
; (assert (check (apply_all (inital_state 3 2 1))))

; (assert (check (apply_all (inital_state 2 3 1))))
; (assert (check (apply_all (inital_state 3 2 1))))

; (assert (check (apply_all (inital_state 2 3 1))))
; (assert (check (apply_all (inital_state 1 2 3))))
; (assert (check (apply_all (triple (store (store (store (store ((as const (Array Int Int)) 0) 0 2) 1 3) 2 1) 3 0) false false))))
; (assert (check (apply_all (triple (store (store (store (store ((as const (Array Int Int)) 0) 0 1) 1 2) 2 3) 3 0) false false))))
(declare-const init231 (Array Int Int))
(declare-const init123 (Array Int Int))
(assert (= (select init231 0) 2))
(assert (= (select init231 1) 3))
(assert (= (select init231 2) 1))
(assert (= (select init231 3) 0))
(assert (= (select init123 0) 1))
(assert (= (select init123 1) 2))
(assert (= (select init123 2) 3))
(assert (= (select init123 3) 0))
(assert (check (apply_all (triple init231 false false))))
(assert (check (apply_all (triple init123 false false))))

; (assert (check (apply_all (inital_state 1 3 2))))
; (assert (check (apply_all (inital_state 1 2 3))))

; (assert (check (inital_state 1 3 2)))
; (assert (check (inital_state 1 2 3)))

; 4 instructions,
; want reg0 = 1
; => min out of 3 
; time: 
; 4min (error "Array theory solver does not yet support write-chains connecting two different constant arrays")

(check-sat)
(get-model)
; print the model readably as INSTR A B


; cvc5 sort_smt.smt --lang smt
