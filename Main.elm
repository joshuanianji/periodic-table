module Main exposing (main)

import Browser
import Browser.Dom exposing (Viewport)
import Html exposing (Html)
import Model exposing (Directory(..), Model, MoleculeData)
import Molecule.MoleculeParser exposing (stringToMolecule)
import Msg exposing (Msg(..))
import Subscriptions exposing (subscriptions)
import Task
import Update exposing (update)
import View exposing (view)



{- INIT
   initializing the model. I make the default page the home page and make Model.stringContent the `InputStringContent Nothing` type

-}


initModel : Model
initModel =
    { viewport = Nothing
    , directory = TableAndParserView
    , selectedAtom = Nothing
    , moleculeData = moleculeDataInit
    }


moleculeDataInit : MoleculeData
moleculeDataInit =
    { inputMoleculeString = "H"
    , inputMolecule = stringToMolecule "H"
    , selectedAtoms = []
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( initModel, Task.perform GetViewport Browser.Dom.getViewport )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


{-
    Here's all the element symbols lol : "HHeLiBeBCNOFNeNaMgAlSiPSClArKCaScTiVCrMnFeCoNiCuZnGaGeAsSeBrKrRbSrYZrNbMoTcRuRhPdAgCdInSbSnTeIXeCsBaLaCePrNdPmSmEuGdTbDyHoErTmYbLuHfTaWReOsIrPtAuHgTlPbBiPoAtRn"
-}