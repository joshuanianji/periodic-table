module DetailedElementView exposing (atomZoomView)

{-
   When we click on an atom the entire page will change to display the atom zoom view and the close button.

-}

import Atom.Atom exposing (Atom)
import Colours
import DataBase.DataParser exposing (errorAtom)
import Element exposing (Element, alignRight, alignTop, centerX, centerY, column, el, fill, height, newTabLink, padding, paragraph, pointer, px, row, shrink, spacing, text, width)
import Element.Events exposing (onClick)
import Element.Font as Font
import Model exposing (Model)
import Msg exposing (Msg(..))
import Subscriptions exposing (..)
import TableAndParser.DetailedAtomBox exposing (atomBoxZoom)



-- close button.


closeButton : Element Msg
closeButton =
    el
        [ width shrink
        , height shrink
        , Font.size 40
        , alignTop
        , alignRight
        , padding 20
        , Font.color Colours.fontColour
        , onClick UnZoomAtom
        , pointer
        , Font.center
        ]
        (text "×")



-- info about when it boils, whe it melts, etc. I made it colourful so its a lot of code lol


phaseChanges : Atom -> Element Msg
phaseChanges atom =
    let
        thisAtom =
            atom.phaseChanges
    in
    column
        [ width fill ]
        [ paragraph []
            [ el [ Font.bold, Font.color Colours.liquidState ] (text "Melting")
            , el [] (text " / ")
            , el [ Font.bold, Font.color Colours.solidState ] (text "Freezing")
            , el [ Font.bold ] (text " point: ")
            , el
                [ Font.light ]
                (thisAtom.melt
                    |> Maybe.map String.fromFloat
                    -- `Maybe float` to `Maybe String` via Maybe.map function
                    |> Maybe.map (\x -> x ++ "K")
                    -- if the x is a valid value add "K" to the end. Using map again
                    |> Maybe.withDefault "none"
                    -- `Maybe String -> String` : if its Nothing use "none"
                    |> text
                 -- pipe the value into the text function
                )
            ]
        , paragraph []
            [ el [ Font.bold, Font.color Colours.gaseousState ] (text "Boiling")
            , el [] (text " / ")
            , el [ Font.bold, Font.color Colours.liquidState ] (text "Condensation")
            , el [ Font.bold ] (text " point: ")
            , el
                [ Font.light ]
                (thisAtom.boil
                    |> Maybe.map String.fromFloat
                    |> Maybe.map (\x -> x ++ "K")
                    |> Maybe.withDefault "none"
                    |> text
                )
            ]
        ]



-- shows the discovered by, named by, phase changes, summary and link to wikipedia page


extraInfo : Atom -> Element Msg
extraInfo atom =
    column
        [ width fill
        , height fill
        , spacing 20
        ]
        [ paragraph []
            [ el [ Font.bold ] (text "Discovered by: ")
            , el [ Font.light ] (text atom.discoveredBy)
            ]
        , paragraph []
            [ el [ Font.bold ] (text "Named by: ")
            , el [ Font.light ] (text atom.namedBy)
            ]
        , phaseChanges atom
        , paragraph [ Font.light ] [ text atom.summary ]
        , newTabLink
            [ Font.color Colours.linkColour ]
            { url = atom.wikiLink
            , label = text "Read More"
            }
        ]



-- atomBoxZoom view wrapper: atomZoomContent for a lack of better name. Has to take in a Maybe Atom because that's what the Model has. If there is no atom, just output the errorAtom


atomZoomContent : Model -> Element Msg
atomZoomContent model =
    let
        atom =
            case model.selectedAtom of
                Just a ->
                    a

                Nothing ->
                    -- this shouldn't happen!
                    errorAtom

        screenWidth =
            screenDimension Width model
    in
    el
        [ centerX, centerY ]
    <|
        row
            [ spacing 50
            , width <| px <| round <| (screenWidth * 3 / 4) -- makes the zoomContent three quarters of the screen width
            ]
            [ atomBoxZoom atom
            , extraInfo atom
            ]



-- actual page view.


atomZoomView : Model -> Element Msg
atomZoomView model =
    column
        [ width fill
        , height fill
        , Font.color Colours.fontColour
        ]
        [ closeButton
        , atomZoomContent model
        ]
