from metalift.ir import *
from metalift.analysis_new import VariableTracker, analyze

# x y z, swap register, le flag, ge flag
StateType = lambda: TupleT(TupleT(Int(), Int(), Int()), Int(), Bool(), Bool())

def targetLang():
  state = Var("state", StateType())
  xyz = TupleGet(state, IntLit(0))
  x = TupleGet(xyz, IntLit(0))
  y = TupleGet(xyz, IntLit(1))
  z = TupleGet(xyz, IntLit(2))
  swap = TupleGet(state, IntLit(1))
  le = TupleGet(state, IntLit(2))
  ge = TupleGet(state, IntLit(3))
  
  swap12Gt = FnDecl("swap12Gt",
                StateType(),
               Ite(Gt(x, y), Tuple(Tuple(y, x, z), swap, le, ge), state),
                state)
  swap13Gt = FnDecl("swap13Gt",
                StateType(),
                 Ite(Gt(x, z), Tuple(Tuple(z, y, x), swap, le, ge), state),
                 state)
  swap23Gt = FnDecl("swap23Gt",
                StateType(),
                 Ite(Gt(y, z), Tuple(Tuple(x, z, y), swap, le, ge), state),
                 state)
  return [swap12Gt, swap13Gt, swap23Gt]

x = Var("x", Int())
y = Var("y", Int())
z = Var("z", Int())

xyz = Tuple(x, y, z)
init = Tuple(xyz, IntLit(0), BoolLit(False), BoolLit(False))

# res = Call("f", StateType(), init)
res = Call("f", StateType(), x, y, z)
res_xyz = TupleGet(res, IntLit(0))
rx = TupleGet(res_xyz, IntLit(0))
ry = TupleGet(res_xyz, IntLit(1))
rz = TupleGet(res_xyz, IntLit(2))

correct = And(
  Le(rx, ry),
  Le(ry, rz)
)
  

print(correct.toSMT())

lang = targetLang()
for f in lang:
  print(f.name())

grammar = init

for i in range(5):
  calls = [
    Call(f.name(), StateType(), grammar) for f in lang
  ]
  grammar = Choose(
    *calls,
    grammar # no-op
  )


synthF = Synth(
  "f", # function name
  grammar, # body
  # init, # arguments
  x,y,z
)


from metalift.synthesize_auto import synthesize
result = synthesize(
  "example", # name of the synthesis problem
  lang, # list of utility functions
  [x,y,z], # list of variables to verify over
  [synthF], # list of functions to synthesize
  [], # list of predicates
  correct, # verification condition
  [synthF], # type metadata for functions to synthesize, just pass the Synth node otherwise
  unboundedInts=True, # verify against the full range of integers (by default integers are restricted to a fixed number of bits)
)

print(result)
