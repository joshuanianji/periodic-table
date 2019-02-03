{-
   Model essentially stores all the data that my app handles.

   I'm not letting it store the AtomList and stuff because I don't think it's necessary yet: right now (february 2) it only handles the Directory, or what page the app is on.
-}


module Model exposing (Directory(..), Model)


type alias Model =
    { directory : Directory }



{-
   This type is my directory, which keeps track of which part of the app the user is on.

   TableAndParserView :: Periodic table and the Molecule parser.
-}


type Directory
    = TableAndParserView
