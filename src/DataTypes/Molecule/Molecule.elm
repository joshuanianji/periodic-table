-- this module is just to define what a molecule is.


module Molecule.Molecule exposing (MaybeMolecule(..), Molecule(..))

import Atom.Atom exposing (..)
import Parser exposing (DeadEnd)



{-

   this molecule type alias is a union type to deal with nested compounds.

   A molecule such as S8 would be:
   Mono Sulfur 8

   A molecule such as H2O would be
   Poly
       [ Mono Hydrogen 2
       , Mono Oxygen 1 ]
       1

   A molecule such as Ba(NO3)2 (barium nitrate) would be:
   Poly
       [ Mono Barium 1
       , Poly
           [ Mono Nitrogen 1
           , Mono Oxygen 2
           ]
           2
       ]
       1

    Of course, Barium, Sulfur, Hydrogen. etc. are just placeholders to represent the Atoms. I have no names of the atoms, they are all type aliases in one big list. So this just got more complicated.

    In the end, a molecule would look more like this:

    bariumSulfate =
        Poly
            [ Mono (retrieveAtom "Ba") 1
            , Poly
                [ Mono (retrieveAtom "S") 1
                , Mono (retrieveAtom "O") 4
                ]
                2
            ]
            1
    where retrieveAtom gets the atom from the atomList. This is why we have a MaybeAtom type

    It even supports hydrates! The int tells us how many water molecules it has and can be put into a Poly for a hydrate

-}


type Molecule
    = Mono MaybeAtom Int
    | Poly (List Molecule) Int
    | Hydrate Int



{-
   We either successfully made a molecule or have a bunch or errors to display lol. These errors come from:
   Bad user inputs (e.g. typing in an uncapitalized symbol)
   Unknown atoms (e.g. Sq)
   Other stuff? (sorry i can't think of any more lol)

   The cool thing is there are multiple types of errors even they all lead to the same outcome - I can't find the specified atom. This means that the user will have a more comprehensive way to know what went wrong in the parser (i.e. how incapable they are in using this calculator)
-}


type MaybeMolecule
    = GoodMolecule Molecule
    | BadMolecule (List DeadEnd)
