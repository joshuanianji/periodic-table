{-
   this is the Periodic Table module that makes all the tables and such
   periodicTable is the actual Element msg that exports the entire periodic table (including lactanides and actinides)

-}


module TableAndParser.PeriodicTable exposing (periodicTable)

import Atom.Atom exposing (..)
import Atom.AtomBox exposing (..)
import DataBase.DataParser exposing (atomList)
import Debug exposing (..)
import Element exposing (Element, alignBottom, column, el)
import List exposing (filter, map, range)



-- this is a higher level function to make the group. takes in a list of atoms and outputs the column of elements.


tableGroup : List (Element msg) -> Element msg
tableGroup elementList =
    column
        [ alignBottom
        , Element.spacing 10
        ]
        elementList



-- filterAtomGroup filters the list of atoms (elementList) by their group


filterAtomGroup : List Atom -> Int -> List Atom
filterAtomGroup atomList atomGroup =
    filter
        (\atom -> atom.xPos == atomGroup)
        atomList



-- fBlockElements keeps the f block elements (lanthanides and actinides)


fBlockElements : List Atom -> List Atom
fBlockElements atomList =
    filter
        (\atom ->
            atom.section == Lanthanide || atom.section == Actinide
        )
        atomList



-- withoutFBlockElements takes out the f block elements


withoutFBlockElements : List Atom -> List Atom
withoutFBlockElements atomList =
    filter
        (\atom ->
            not (atom.section == Lanthanide || atom.section == Actinide)
        )
        atomList



-- boxAtoms takes in a list of atoms and returns a list of elements where they are all in the periodic table boxes


boxAtoms : List Atom -> List (Element msg)
boxAtoms atoms =
    map
        atomBox
        atoms



{-
   I initially planned to define functions like this:

   g1 : Element msg
   g1 =
       filterAtoms 1
           |> boxAtoms
           |> tableGroup

   so every group from 1 - 13 will be hard coded. But that's dumb and ruins the point of functional programming, so i changed it. I know have the function pTableGroup that takes in a group (an integer), the list of atoms and returns the column of atom boxes that are in that group

-}


pTableGroup : List Atom -> Int -> Element msg
pTableGroup atomList group =
    filterAtomGroup atomList group
        |> boxAtoms
        |> tableGroup



-- These are the big periodic table bunches.


upperPeriodicTableList : List (Element msg)
upperPeriodicTableList =
    map
        (atomList
            |> withoutFBlockElements
            |> pTableGroup
        )
        (range 1 18)



-- this is to make the code easier to read. the periodicTableList thing is just the actual list, this creates the actual periodic tabl thing into one Element msg


upperPeriodicTable : Element msg
upperPeriodicTable =
    Element.row
        [ Element.spacing 10
        , Element.centerX
        ]
        upperPeriodicTableList



-- lowerPeriodicTable is just the lanthanides and actinides
-- range 3 - 17 because the lanthanides and actinides go from group 3 to 17, at least from the JSON data lol


lowerPeriodicTableList : List (Element msg)
lowerPeriodicTableList =
    map
        (atomList
            |> fBlockElements
            |> pTableGroup
        )
        (range 3 17)


lowerPeriodicTable : Element msg
lowerPeriodicTable =
    Element.row
        [ Element.spacing 10
        , Element.centerX
        ]
        lowerPeriodicTableList



-- the periodic table we export


periodicTable =
    Element.column
        [ Element.spacing 20
        , Element.centerX
        ]
        [ upperPeriodicTable
        , lowerPeriodicTable
        ]
