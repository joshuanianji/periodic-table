{-
   This module specifies how the Periodic table and the molecule parser will look like. It's just a colimn of the periodic table and the parser if you look into it lol.

-}


module TableAndParserView exposing (tableAndParserView)

import Element exposing (Element)
import Molecule.HardCodedMolecules as Molecules
import Molecule.MoleculeDisplay exposing (moleculeDisplay)
import Molecule.MoleculeParser as MoleculeParser
import Msg exposing (Msg(..))
import TableAndParser.PeriodicTable exposing (periodicTable)


tableAndParserView : Element Msg
tableAndParserView =
    Element.column
        [ Element.spacing 40
        , Element.centerX
        ]
        [ periodicTable
        , moleculeDisplay Molecules.caffeine
        , MoleculeParser.parserTest
        ]
