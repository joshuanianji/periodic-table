module Router exposing (Model, Msg, init, subscriptions, update, updateRoute, view)

import Colours
import Element
import Element.Background as Background
import Html exposing (Html)
import Page.Atom as Atom
import Page.Home as Home
import Page.NotFound as NotFound
import Routes exposing (Route)
import SharedState exposing (SharedState)



---- MODEL ----


type alias Model =
    { page : Page
    , route : Maybe Route
    }


type Page
    = Home Home.Model
    | Atom Atom.Model
    | NotFound NotFound.Model


init : SharedState -> Maybe Route -> Model
init sharedState route =
    { page = routeToPage route sharedState
    , route = route
    }


routeToPage : Maybe Route -> SharedState -> Page
routeToPage route sharedState =
    case route of
        Just Routes.Home ->
            Home <| Home.init sharedState

        Just (Routes.Atom name) ->
            Atom <| Atom.init sharedState name

        Nothing ->
            NotFound <| NotFound.init



---- VIEW ----


view : SharedState -> Model -> Html Msg
view sharedState model =
    let
        pageView =
            case model.page of
                Home subModel ->
                    Home.view sharedState subModel
                        |> Element.map HomeMsg

                Atom subModel ->
                    Atom.view sharedState subModel
                        |> Element.map AtomMsg

                NotFound subModel ->
                    NotFound.view subModel
                        |> Element.map NotFoundMsg
    in
    Element.column
        [ Element.width Element.fill
        , Element.height Element.fill
        , Background.color Colours.appBackgroundGray
        ]
        [ pageView ]
        |> Element.layout []



---- UPDATE ----


type Msg
    = UpdateRoute (Maybe Route)
    | HomeMsg Home.Msg
    | AtomMsg Atom.Msg
    | NotFoundMsg NotFound.Msg



-- Main.elm calls this wrapper function when a new URL changes
-- this just lets us not expose the entire Msg(..) type


updateRoute : Maybe Route -> Msg
updateRoute =
    UpdateRoute


update : SharedState -> Msg -> Model -> ( Model, Cmd Msg )
update sharedState msg model =
    case ( model.page, msg ) of
        ( _, UpdateRoute route ) ->
            let
                newPage =
                    routeToPage route sharedState
            in
            ( { model
                | page = newPage
                , route = route
              }
            , Cmd.none
            )

        ( Home subModel, HomeMsg subMsg ) ->
            Home.update sharedState subMsg subModel
                |> updateWith Home HomeMsg model

        ( Atom subModel, AtomMsg subMsg ) ->
            Atom.update sharedState subMsg subModel
                |> updateWith Atom AtomMsg model

        ( NotFound subModel, NotFoundMsg subMsg ) ->
            NotFound.update sharedState subMsg subModel
                |> updateWith NotFound NotFoundMsg model

        ( _, _ ) ->
            ( model, Cmd.none )



-- updating the shared state is done in the Main.elm. This file only needs certain shared state updates to be intercepted.
-- we will NEED newCmd when we introduce popups


updateWith : (subModel -> Page) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toPage toMsg model ( subModel, subMsg ) =
    ( { model | page = toPage subModel }
    , Cmd.batch
        [ Cmd.map toMsg subMsg ]
    )



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
