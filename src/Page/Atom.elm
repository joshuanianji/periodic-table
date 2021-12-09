module Page.Atom exposing 
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )


import Element exposing (Element) 
import Routes
import Element.Font as Font 
import Element.Events as Events 
import Element.Background as Background 
import Colours
import Data.Atom as Atom exposing (Atom)
import Routes
import SharedState exposing (SharedState)
import Routes exposing (Route)
import Data.PeriodicTable as PeriodicTable exposing (PeriodicTable)

---- MODEL 

type alias Model = 
    { atom : Maybe Atom }

init : SharedState -> String -> Model 
init sharedState atomName = 
    { atom = PeriodicTable.findAtom atomName sharedState.ptable }

---- VIEW 

view : SharedState -> Model -> Element Msg
view _ model = 
    let
        closeButton =
            Element.el
                [ Element.width Element.shrink
                , Element.height Element.shrink
                , Font.size 40
                , Element.alignTop
                , Element.alignRight
                , Element.padding 20
                , Font.color Colours.fontColour
                , Events.onClick <| NavigateTo Routes.Home
                , Element.pointer
                , Font.center
                ]
                (Element.text "×")
    in
    Element.column
        [ Element.width Element.fill
        , Element.height Element.fill
        , Font.color Colours.fontColour
        ]
        [ closeButton
        , content model
        ]


content : Model -> Element Msg
content model =
    case model.atom of 
        Just atom ->
            Element.row
                [ Element.spacing 50
                , Element.width (Element.maximum 1080 Element.fill)
                , Element.centerX
                , Element.centerY
                ]
                [ zoomedBox atom
                , extraInfo atom
                ]
        Nothing ->
            Element.row
                [ Element.spacing 50
                , Element.width (Element.maximum 1080 Element.fill)
                , Element.centerX
                , Element.centerY
                ]
                [ Element.text "Atom not found" ]

zoomedBox : Atom -> Element Msg
zoomedBox atom =
            let
                symbol =
                    Element.el
                        [ Element.centerX
                        , Font.size 150
                        , Font.bold
                        , Font.color (Colours.stateColour atom.state)
                        ]
                        (Element.text atom.symbol)

                name =
                    Element.el
                        [ Element.centerX
                        , Font.size 50
                        ]
                        (Element.text atom.name)

                num =
                    Element.el
                        [ Element.centerX
                        , Font.size 40
                        ]
                        (Element.text <| String.fromInt <| atom.protons)

                weight =
                    Element.el
                        [ Element.centerX
                        , Font.size 30
                        ]
                        (Element.text <| atom.weight)

                shells =
                    Element.column
                        [ Element.alignTop
                        , Element.alignRight
                        , Font.size 20
                        , Element.padding 10
                        ]
                        (List.map
                            (\x ->
                                x
                                    |> String.fromInt
                                    |> Element.text
                                    |> Element.el []
                            )
                            atom.electronShells
                        )
            in
            Element.column
                [ Element.width (Element.px 350)
                , Element.spacing 10
                , Element.padding 50
                , Background.color Colours.atomBoxBackground
                , Element.inFront shells
                ]
                [ num
                , symbol
                , name
                , weight
                ]
extraInfo : Atom -> Element Msg
extraInfo atom =
            Element.column
                [ Element.width Element.fill
                , Element.height Element.fill
                , Element.spacing 20
                ]
                [ Element.paragraph []
                    [ Element.el [ Font.bold ] (Element.text "Discovered by: ")
                    , Element.el [ Font.light ] (Element.text atom.discoveredBy)
                    ]
                , Element.paragraph []
                    [ Element.el [ Font.bold ] (Element.text "Named by: ")
                    , Element.el [ Font.light ] (Element.text atom.namedBy)
                    ]

                -- info about when it boils, whe it melts, etc. I made it colourful so its a lot of code lol
                , Element.column
                    [ Element.width Element.fill
                    , Element.spacing 4 
                    ]
                    [ Element.paragraph []
                        [ Element.el [ Font.bold, Font.color Colours.liquidState ] (Element.text "Melting")
                        , Element.el [] (Element.text " / ")
                        , Element.el [ Font.bold, Font.color Colours.solidState ] (Element.text "Freezing")
                        , Element.el [ Font.bold ] (Element.text " point: ")
                        , Element.el
                            [ Font.light ]
                            (atom.phaseChanges.melt
                                |> Maybe.map String.fromFloat
                                -- `Maybe float` to `Maybe String` via Maybe.map function
                                |> Maybe.map (\x -> x ++ "K")
                                -- if the x is a valid value add "K" to the end. Using map again
                                |> Maybe.withDefault "none"
                                -- `Maybe String -> String` : if its Nothing use "none"
                                |> Element.text
                             -- pipe the value into the text function
                            )
                        ]
                    , Element.paragraph []
                        [ Element.el [ Font.bold, Font.color Colours.gaseousState ] (Element.text "Boiling")
                        , Element.el [] (Element.text " / ")
                        , Element.el [ Font.bold, Font.color Colours.liquidState ] (Element.text "Condensation")
                        , Element.el [ Font.bold ] (Element.text " point: ")
                        , Element.el
                            [ Font.light ]
                            (atom.phaseChanges.boil
                                |> Maybe.map String.fromFloat
                                |> Maybe.map (\x -> x ++ "K")
                                |> Maybe.withDefault "none"
                                |> Element.text
                            )
                        ]
                    ]
                , Element.paragraph [ Font.light ] [ Element.text atom.summary ]
                , Element.newTabLink
                    [ Font.color Colours.linkColour ]
                    { url = atom.wikiLink
                    , label = Element.text "Read More"
                    }
                ]

---- UPDATE

type Msg = NavigateTo Route

update : SharedState -> Msg -> Model -> (Model, Cmd Msg)
update sharedState (NavigateTo route) model =
    ( model, SharedState.navigateTo route sharedState)


---- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none 