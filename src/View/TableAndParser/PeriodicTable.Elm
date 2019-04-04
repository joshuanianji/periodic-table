{-
   this is the Periodic Table module that makes all the tables and such
   periodicTable is the actual Element msg that exports the entire periodic table (including lactanides and actinides)

-}


module TableAndParser.PeriodicTable exposing (periodicTable)

import Atom.Atom exposing (..)
import Atom.AtomBox exposing (..)
import Colours
import DataBase.DataParser exposing (pTableAtomList)
import Debug exposing (..)
import Element exposing (Color, Element, alignBottom, centerX, column, el, fill, height, none, paddingEach, px, row, spacing, text, width)
import Element.Background as Background
import List exposing (filter, map, range)
import Model exposing (Model)
import Msg exposing (..)



-- this is a function to make the group. takes in a list of atoms and outputs the column of elements.


tableGroup : List (Element Msg) -> Element Msg
tableGroup elementList =
    column
        [ alignBottom
        , spacing 10
        ]
        elementList



-- filterAtomGroup filters the list of pTableAtoms (elementList) by their group


filterAtomGroup : List PTableAtom -> Int -> List PTableAtom
filterAtomGroup pTableAtomList atomGroup =
    filter
        (\pTableAtom ->
            case pTableAtom of
                PTableAtom atom ->
                    atom.xpos == atomGroup

                PTablePlaceholder placeholder ->
                    placeholder.xpos == atomGroup
        )
        pTableAtomList



-- getfBlockElements keeps the f block elements (lanthanides and actinides)


getfBlockElements : List PTableAtom -> List PTableAtom
getfBlockElements pTableAtomList =
    filter
        (\pTableAtom ->
            case pTableAtom of
                PTableAtom atom ->
                    atom.section == Lanthanide || atom.section == Actinide

                _ ->
                    False
        )
        pTableAtomList



-- withoutfBlockElements takes out the f block elements


withoutfBlockElements : List PTableAtom -> List PTableAtom
withoutfBlockElements pTableAtomList =
    filter
        (\pTableAtom ->
            case pTableAtom of
                PTableAtom atom ->
                    not (atom.section == Lanthanide || atom.section == Actinide)

                _ ->
                    True
        )
        pTableAtomList



-- toBoxes takes in a list of atoms and returns a list of elements where they are all in the periodic table boxes


toBoxes : Model -> List PTableAtom -> List (Element Msg)
toBoxes model pTableAtoms =
    map
        (pTableBox model)
        pTableAtoms



{-
   I initially planned to define functions like this:

   g1 : Element msg
   g1 =
       filterAtoms 1
           |> toBoxes
           |> tableGroup

   so every group from 1 - 13 will be hard coded. But that's dumb and ruins the point of functional programming, so i changed it. I know have the function styleTableGroups that takes in a group (an integer), the list of atoms and returns the column of atom boxes that are in that group

-}


styleTableGroups : Model -> List PTableAtom -> Int -> Element Msg
styleTableGroups model pTableAtomList group =
    filterAtomGroup pTableAtomList group
        |> toBoxes model
        |> tableGroup



-- Upper Periodic Table is the periodic table for all the elements which aren't f block


upperPeriodicTable : Model -> Element Msg
upperPeriodicTable model =
    map
        (pTableAtomList
            |> withoutfBlockElements
            |> styleTableGroups model
        )
        (range 1 18)
        |> row
            [ spacing 2
            , centerX
            ]



-- lowerPeriodicTable is just the lanthanides and actinides
-- range 3 - 17 because the lanthanides and actinides go from group 3 to 17, at least from the JSON data lol


lowerPeriodicTable : Model -> Element Msg
lowerPeriodicTable model =
    map
        (pTableAtomList
            |> getfBlockElements
            |> styleTableGroups model
        )
        (range 3 17)
        |> row
            [ spacing 2
            , centerX
            ]



-- the periodic table we export


periodicTable : Model -> Element Msg
periodicTable model =
    column
        [ centerX
        , width fill
        , spacing 10
        , Background.color (Element.rgba 0 0 0 0)
        ]
        [ upperPeriodicTable model
        , lowerPeriodicTable model
        ]


legend : Model -> Element Msg
legend model =
    let
        legendPadding =
            paddingEach { top = 0, right = 0, left = 400, bottom = 0 }
    in
    row
        [ width fill
        , spacing 30
        , legendPadding
        , Element.inFront (periodicTable model)
        ]
        [ sectionLegend
        , stateLegend
        ]


sectionLegend =
    let
        allSections =
            [ Hydrogen
            , Alkali
            , AlkalineEarth
            , TransitionMetal
            , PostTransitionMetal
            , Metalloid
            , NonMetal
            , Halogen
            , NobleGas
            , Lanthanide
            , Actinide
            , UnknownSection
            ]
    in
    List.map
        (\section ->
            legendItem
                (Colours.sectionColour section)
                (" " ++ Debug.toString section)
        )
        allSections
        |> column []


stateLegend =
    let
        allStates =
            [ Solid
            , Liquid
            , Gas
            , UnknownState
            ]
    in
    List.map
        (\state ->
            legendItem
                (Colours.stateColour state)
                (" " ++ Debug.toString state)
        )
        allStates
        |> column []



-- each legend item with a colour box and a text


legendItem : Color -> String -> Element Msg
legendItem color string =
    row
        []
        [ Element.el
            [ width (px 10)
            , height (px 10)
            , Background.color color
            ]
            none
        , string |> text
        ]
