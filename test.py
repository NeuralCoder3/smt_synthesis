from metalift import ir

x = ir.Var("x", ir.Int())

correct = ir.And(
  # f(x) >= 0
  ir.Ge(
    ir.Call(
      'f', # function name
      ir.Int(), # return type
      x # arguments
    ),
    ir.IntLit(0)
  ),
  # f(x) >= x
  ir.Ge(
    ir.Call('f', ir.Int(), x),
    x
  )
)

print(correct.toSMT())



grammar = x

for i in range(2):
  grammar = ir.Choose(
    ir.Add(grammar, grammar),
    ir.Sub(grammar, grammar),
    ir.Mul(grammar, grammar)
  )


synthF = ir.Synth(
  "f", # function name
  grammar, # body
  x, # arguments
)


from metalift.synthesize_auto import synthesize
result = synthesize(
  "example", # name of the synthesis problem
  [], # list of utility functions
  [x], # list of variables to verify over
  [synthF], # list of functions to synthesize
  [], # list of predicates
  correct, # verification condition
  [synthF], # type metadata for functions to synthesize, just pass the Synth node otherwise
  unboundedInts=True, # verify against the full range of integers (by default integers are restricted to a fixed number of bits)
)

print(result)
