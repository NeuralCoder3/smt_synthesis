The current files implement a sorting algorithm for three elements using MetaLift.

MetaLift is a synthesis framework developed for DSLs on top of Rosette.
Rosette is a smt-based synthesis extension on Racket.

The synthesis facilities of MetaLift are based on providing a grammar, also called sketch, from which a program is synthesised fulfilling a specification (which might be the behaviour of another program).

In its nature, the sketch is in the style of functional programming.
Therefore, we model the sorting using a transformation on a world state.