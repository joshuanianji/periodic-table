{-
   Model essentially stores all the data that my app handles.

   This holds the Directory and the selectedAtom, which is what atom the user selected when they click on it.
-}


module Model exposing (Directory(..), Model)

import Atom.Atom exposing (Atom)


type alias Model =
    { directory : Directory
    , selectedAtom : Maybe Atom
    }



{-
   This type is my directory, which keeps track of which part of the app the user is on.

   TableAndParserView :: Periodic table and the Molecule parser.
   ZoomAtomView :: Close-up specifications of the atom
-}


type Directory
    = TableAndParserView
    | ZoomAtomView
