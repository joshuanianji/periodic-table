{-
   The Msg function defines all the commands and actions that happens on the app.

   For example, when the user clicks on an atom box on the periodic table and I need to change the periodic table to full screen, I will send a message called ZoomAtom which, originating from the atom box (as I will put an event handler on each atom box), will go through the update function that will ultimately change the view. This is all defined here.
-}


module Msg exposing (Msg(..))

import Atom.Atom exposing (Atom)
import Browser.Dom exposing (Viewport)
import Model exposing (Directory(..))


type Msg
    = GetViewport Viewport
    | BrowserResized Int Int
    | ZoomAtom Atom
    | UnZoomAtom
    | ChangeDirectory Directory
    | UpdateMoleculeParser String
