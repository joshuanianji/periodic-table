module HardCodedMolecules exposing (bariumSulfate, caffeine, sulfur)

{-| This module is just a bunch of molecules that are hard coded lmao feels bad
-}

import DataParser exposing (retrieveAtom)
import Molecule exposing (..)


{-| creating molecules are pretty easy, but searching for the atom is wack. So that's why we have the retrieveAtom function. Also this naming scheme is really bad I should change it. Nahhh whatever
-}
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


sulfur =
    Mono (retrieveAtom "Sulfur") 8


caffeine =
    Poly
        [ Mono (retrieveAtom "Carbon") 8
        , Mono (retrieveAtom "Hydrogen") 10
        , Mono (retrieveAtom "Nitrogen") 10
        , Mono (retrieveAtom "Oxygen") 2
        ]
        1
