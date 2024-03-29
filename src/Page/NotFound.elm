module Page.NotFound exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Element exposing (Element)
import SharedState exposing (SharedState)



---- MODEL


type alias Model =
    ()


init : Model
init =
    ()



---- VIEW


view : Model -> Element Msg
view _ =
    Element.text "Page not found"



---- UPDATE


type Msg
    = Msg Never


update : SharedState -> Msg -> Model -> ( Model, Cmd Msg )
update _ _ m =
    ( m, Cmd.none )



---- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
