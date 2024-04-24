from cvc5.pythonic import *

# extract from a tuple

# >>> pair, mk_pair, (first, second) = TupleSort("pair", [IntSort(), BoolSort()])
# >>> b = Bool('b')
# >>> i = Int('i')
# >>> p = mk_pair(i, b)
# >>> p
# pair(i, b)
# >>> solve([b != second(p)])

b = Bool('b')
i = Int('i')
r = Real('r')

triple, mk_triple, (first, second, third) = TupleSort("triple", [IntSort(), BoolSort(), RealSort()])

t = mk_triple(i, b, r)

solve([b != second(t), i != first(t), r != third(t)])

