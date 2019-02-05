module Main exposing (main)

import Browser
import Html exposing (Html)
import Model exposing (Directory(..), Model)
import Msg exposing (Msg(..))
import Update exposing (update)
import View exposing (view)



{- INIT
   initializing the model. I make the default page the home page and make Model.stringContent the `InputStringContent Nothing` type

-}


initModel : Model
initModel =
    { directory = TableAndParserView
    , selectedAtom = Nothing
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( initModel, Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
