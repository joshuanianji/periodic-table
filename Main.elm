module Main exposing (main)

-- Atom holds all the modulated html stuff, database holds all the information about the atoms
{-
   This module is is I want to flex off my periodic table

    import HardCodedData exposing (..)
    import PeriodicTable exposing (upperPeriodicTable)
-}

import AtomBox exposing (atomBox)
import Colours
import DataParser exposing (atomList)
import Element exposing (Element)
import Element.Background as Background
import HardCodedMolecules exposing (..)
import Html exposing (Html)
import Molecule exposing (..)
import MoleculeDisplay exposing (..)
import MoleculeParser
import PeriodicTable exposing (periodicTable)



-- htmlPage changes the element msg to Html msg and makes a dark theme
-- element.layout is basically the HTML or BODY tag so I made the entire html have a dark background
-- I also made the HTML or BODY, I don't really care honestly, have a padding of 10px


htmlPage : Element msg -> Html msg
htmlPage pageElements =
    Element.layout
        [ Background.color Colours.appBackgroundGray
        , Element.padding 10
        ]
        pageElements


main : Html msg
main =
    Element.column
        [ Element.spacing 40
        , Element.centerX
        ]
        [ periodicTable
        , moleculeDisplay caffeine
        , MoleculeParser.parserTest
        ]
        |> htmlPage
