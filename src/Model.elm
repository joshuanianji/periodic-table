{-
   Model essentially stores all the data that my app handles.

   This holds the Directory and the selectedAtom, which is what atom the user selected when they click on it.
-}


module Model exposing (Directory(..), Model, MoleculeData, ScreenSize)

import Atom.Atom exposing (Atom)
import Molecule.Molecule exposing (MaybeMolecule)


type alias ScreenSize =
    { height : Float
    , width : Float
    }



-- molecule parser and whatnot


type alias MoleculeData =
    { inputMoleculeString : String
    , inputMolecule : MaybeMolecule
    , selectedAtoms : List Atom
    }


type alias Model =
    { viewport : Maybe ScreenSize -- only because in the beginning we don't have the data on the viewport
    , directory : Directory
    , selectedAtom : Maybe Atom
    , moleculeData : MoleculeData
    }



{-
   This type is my directory, which keeps track of which part of the app the user is on.

   TableAndParserView :: Periodic table and the Molecule parser.
   ZoomAtomView :: Close-up specifications of the atom
   QuizzerView :: where the user is quizzed
-}


type Directory
    = TableAndParserView
    | ZoomAtomView



-- | QuizzerView
