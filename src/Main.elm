module Main exposing (main)

import Browser
import Element exposing (Element)
import Router 
import Html exposing (Html)
import Json.Encode as Encode
import Routes exposing (Route)
import SharedState exposing (SharedState)
import Router
import Json.Decode
import Browser.Navigation as Nav
import Url exposing (Url)
import Element.Font as Font 
import Colours
import Browser.Events
import Data.Flags as Flags 
import Data.Flags exposing (WindowSize)
import Browser exposing (UrlRequest(..))



---- PROGRAM ----


main : Program Encode.Value Model Msg
main =
    Browser.application
        { view = viewApplication
        , init = init
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        }


---- MODEL -----


type alias Model =
    { appState : AppState
    , navKey : Nav.Key
    , route : Maybe Route
    }

type alias AppState
    = Result (Json.Decode.Error) (SharedState, Router.Model)



init : Encode.Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flagsValue url navKey =
    let
        decodedFlags =
            Json.Decode.decodeValue Flags.decoder flagsValue
        mRoute = Routes.fromUrl url
    in
    case decodedFlags of
        Ok flags ->
            let 
                sharedState = SharedState.init flags navKey
            in
            ( { appState = Ok (sharedState, (Router.init sharedState mRoute))
              , navKey = navKey
              , route = mRoute
              }
            , Cmd.none 
            )

        Err err ->
            ( { appState = Err err
              , navKey = navKey
              , route = mRoute
              }
            , Cmd.none
            )



---- VIEW ----

viewApplication : Model -> Browser.Document Msg
viewApplication model =
    { title = Routes.tabTitle model.route
    , body =
        [ view model ]
    }


view : Model -> Html Msg
view model =
    case model.appState of
        Ok (sharedState, routerModel) ->
            Router.view sharedState routerModel 
                |> Html.map RouterMsg

        Err err ->
            viewError err 


viewError : Json.Decode.Error -> Html Msg 
viewError err =
    Element.el 
        [ Font.color Colours.gaseousState ]
        (Element.text <| Json.Decode.errorToString err)
        |> Element.layout []



-- | UPDATE


type Msg
    = ChangedUrl Url
    | ClickedLink UrlRequest
    | WindowResize WindowSize
    | RouterMsg Router.Msg 


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (model.appState, msg) of
        (Ok (sharedState, subModel), ChangedUrl url) ->
            let
                newRoute =
                    Routes.fromUrl url
            in 
            Router.update sharedState (Router.updateRoute newRoute) subModel
                |> updateRouterWith { model | route = newRoute } sharedState

        ( _, ClickedLink urlRequest ) ->
            case urlRequest of
                Internal url ->
                    ( model, Nav.pushUrl model.navKey <| Url.toString url )

                External url ->
                    ( model, Nav.load url )

        (_, WindowResize windowSize) ->
            case model.appState of
                Ok (sharedState, routerModel) ->
                    let
                        newAppState = Ok (SharedState.updateScreenSize windowSize sharedState, routerModel)
                    in
                    ({ model | appState = newAppState }, Cmd.none)
                    
                Err _ -> 
                    (model, Cmd.none)
        
        (Ok (sharedState, routerModel), RouterMsg subMsg) ->
            let
                (newRouterModel, routerCmd) = Router.update sharedState subMsg routerModel
                newAppState = Ok (sharedState, newRouterModel)
            in
            ({ model | appState = newAppState }, Cmd.map RouterMsg routerCmd)

        ( _, _ ) ->
            (model, Cmd.none)




updateRouterWith : Model -> SharedState -> ( Router.Model, Cmd Router.Msg ) -> ( Model, Cmd Msg )
updateRouterWith model sharedState ( nextRouterModel, routerCmd ) =
    ( { model | appState = Ok (sharedState, nextRouterModel) }
    , Cmd.map RouterMsg routerCmd
    )


-- | SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onResize
        (\x y -> WindowResize (WindowSize x y))
