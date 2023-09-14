from metalift.ir import *
from metalift.analysis_new import VariableTracker, analyze

# compare tests/llvm/fma_dsl.py

IntTriple = lambda: TupleT(Int(), Int(), Int())

# def grammar(name, args, ret):
#   inputVars = Choose(*args))
#   state = inputVars
#   for i in range(5):
#     state = Choose(
#       Call("swap12Gt", IntTriple(), state),
#       Call("swap13Gt", IntTriple(), state),
#       Call("swap23Gt", IntTriple(), state),
#     )
#   summary = Eq(ret, state)
#   return Synth(name, summary, ret, *args)

def targetLang():
  xyz = Var("xyz", IntTriple())
  x = TupleGet(xyz, IntLit(0))
  y = TupleGet(xyz, IntLit(1))
  z = TupleGet(xyz, IntLit(2))
  swap12Gt = FnDecl("swap12Gt",
               IntTriple(),
               Ite(Ge(x, y), Tuple(y, x, z), Tuple(x, y, z)),
               xyz)
  swap13Gt = FnDecl("swap13Gt",
               IntTriple(),
                Ite(Ge(x, z), Tuple(z, y, x), Tuple(x, y, z)),
                xyz)
  swap23Gt = FnDecl("swap23Gt",
               IntTriple(),
                Ite(Ge(y, z), Tuple(x, z, y), Tuple(x, y, z)),
                xyz)
  return [swap12Gt, swap13Gt, swap23Gt]

# x = Var("x", Int())
# y = Var("y", Int())
# z = Var("z", Int())
xyz = Var("xyz", IntTriple())

# res = Call("f", IntTriple(), Tuple(x, y, z))
res = Call("f", IntTriple(), xyz)
rx = TupleGet(res, IntLit(0))
ry = TupleGet(res, IntLit(1))
rz = TupleGet(res, IntLit(2))

correct = And(
  Le(rx, ry),
  Le(ry, rz)
)
  

print(correct.toSMT())

lang = targetLang()

grammar = xyz

for i in range(8):
  grammar = Choose(
    Call("swap12Gt", IntTriple(), grammar),
    Call("swap13Gt", IntTriple(), grammar),
    Call("swap23Gt", IntTriple(), grammar),
    grammar
  )


synthF = Synth(
  "f", # function name
  grammar, # body
  xyz, # arguments
)


from metalift.synthesize_auto import synthesize
result = synthesize(
  "example", # name of the synthesis problem
  lang, # list of utility functions
  [xyz], # list of variables to verify over
  [synthF], # list of functions to synthesize
  [], # list of predicates
  correct, # verification condition
  [synthF], # type metadata for functions to synthesize, just pass the Synth node otherwise
  unboundedInts=True, # verify against the full range of integers (by default integers are restricted to a fixed number of bits)
)

print(result)
