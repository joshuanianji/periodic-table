-- this module is just to define what a compound is. I call it a compound a molecule is too rigid of a definition. Maybe I should change this file name?


module Molecule exposing (Compound(..))

import Atom exposing (Atom)



{-

   this compound type alias is a union type to deal with nested compounds.

   A compound such as S8 would be:
   Mono Sulfur 8

   A compound such as H2O would be
   Poly
       [ Mono Hydrogen 2
       , Mono Oxygen 1 ]
       1

   A compound such as Ba(SO4)2 (barium sulfate) would be:
   Poly
       [ Mono Barium 1
       , Poly
           [ Mono Sulfur 1
           , Mono Oxygen 4
           ]
           2
       ]

    Of course, Barium, Sulfur, Hydrogen. etc. are just placeholders to represent the Atoms. I have no names of the atoms, they are all type aliases in one big list. So this just got more complicated.

    In the end, a molecule would look more like this:

    bariumSulfate =
        Poly
            [ Mono (retrieveAtom "Barium") 1
            , Poly
                [ Mono (retrieveAtom "Sulfur") 1
                , Mono (retrieveAtom "Oxygen") 4
                ]
                2
            ]
            1
    where retrieveAtom gets the atom from the atomList

-}
-- Mono has the type of Maybe Atom because searching for an Atom in a list leads to a Maybe Atom.


type Compound
    = Mono (Maybe Atom) Int
    | Poly (List Compound) Int
