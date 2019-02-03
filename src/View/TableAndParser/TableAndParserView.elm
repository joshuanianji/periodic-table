module TableAndParser.TableAndParserView exposing (tableAndParserView)

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
