{-
   This bad boy handles all the messages that come through. (Elm actually handles the communication between the view, update and model for us so all we need to do is define then! That's pretty neat.)

-}


module Update exposing (update)

import Model exposing (Directory(..), Model, ScreenSize)
import Molecule.MoleculeParser exposing (stringToMolecule, toAtomList)
import Msg exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetViewport viewport ->
            ( { model | viewport = Just (ScreenSize viewport.viewport.height viewport.viewport.width) }, Cmd.none )

        BrowserResized width height ->
            ( { model | viewport = Just (ScreenSize (toFloat height) (toFloat width)) }, Cmd.none )

        ZoomAtom atom ->
            ( { model | selectedAtom = Just atom, directory = ZoomAtomView }, Cmd.none )

        UnZoomAtom ->
            ( { model | selectedAtom = Nothing, directory = TableAndParserView }, Cmd.none )

        ChangeDirectory dir ->
            ( { model | directory = dir }, Cmd.none )

        UpdateMoleculeParser text ->
            -- updating a nested type alias
            let
                c =
                    model.moleculeData
            in
            ( { model
                | moleculeData =
                    { c
                        | inputMoleculeString = text
                        , inputMolecule = stringToMolecule text
                        , selectedAtoms = toAtomList (stringToMolecule text)
                    }
              }
            , Cmd.none
            )
