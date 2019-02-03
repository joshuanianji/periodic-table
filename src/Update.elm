{-
   This bad boy handles all the messages that come through. (Elm actually handles the communication between the view, update and model for us so all we need to do is define then! That's pretty neat.)

-}


module Update exposing (update)

import Model exposing (Model)
import Msg exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )
