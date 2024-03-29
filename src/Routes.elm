module Routes exposing (Route(..), fromUrl, navigateTo, tabTitle)

import Browser.Navigation as Nav
import Data.Atom exposing (Atom)
import Url exposing (Url)
import Url.Parser as Url exposing ((</>), Parser)



-- TYPES AND PARSER


type Route
    = Home
    | Atom AtomSymbol


type alias AtomSymbol =
    String


urlParser : Parser (Route -> a) a
urlParser =
    Url.oneOf
        [ Url.map Home Url.top -- "/"
        , Url.map Atom Url.string -- "/<atom symbol>"
        ]



-- PUBLIC HELPERS


navigateTo : Nav.Key -> Route -> Cmd msg
navigateTo key route =
    Nav.pushUrl key (toUrlString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Url.parse urlParser


tabTitle : Maybe Route -> String
tabTitle route =
    let
        prefix =
            case route of
                Just Home ->
                    ""

                Just (Atom symbol) ->
                    symbol ++ " - "

                Nothing ->
                    "Not Found - "
    in
    prefix ++ "PTable"



-- INTERNAL


toUrlString : Route -> String
toUrlString route =
    let
        urlPieces =
            case route of
                Home ->
                    []

                Atom symbol ->
                    [ symbol ]
    in
    "#/" ++ String.join "/" urlPieces
