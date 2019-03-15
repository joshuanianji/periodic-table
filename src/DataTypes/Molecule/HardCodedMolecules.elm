module Molecule.HardCodedMolecules exposing (bariumSulfate, caffeine, sulfur)

{-| This module is just a bunch of molecules that are hard coded lmao feels bad
-}

import DataBase.DataParser exposing (retrieveAtom)
import Molecule.Molecule exposing (..)


{-| creating molecules are pretty easy, but searching for the atom is wack. So that's why we have the retrieveAtom function. Also this naming scheme is really bad I should change it. Nahhh whatever
-}
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


sulfur =
    Mono (retrieveAtom "S") 8


caffeine =
    Poly
        [ Mono (retrieveAtom "C") 8
        , Mono (retrieveAtom "H") 10
        , Mono (retrieveAtom "N") 10
        , Mono (retrieveAtom "O") 2
        ]
        1
