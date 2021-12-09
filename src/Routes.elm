module Routes exposing (Route(..), navigateTo, fromUrl, tabTitle)

import Data.Atom exposing (Atom)
import Browser.Navigation as Nav 
import Url.Parser as Url exposing (Parser, (</>))
import Url exposing (Url)



-- TYPES AND PARSER


type Route
    = Home
    | Atom AtomName


type alias AtomName = String 


urlParser : Parser (Route -> a) a
urlParser =
  Url.oneOf
    [ Url.map Home Url.top -- "/"
    , Url.map Atom Url.string -- "/<atom name>"
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

                Just (Atom name) ->
                    name ++ " - "

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

                Atom name ->
                    [name]

    in
    "#/" ++ String.join "/" urlPieces
