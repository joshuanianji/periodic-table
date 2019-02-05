module AtomZoomView exposing (atomZoomView)

{-
   When we click on an atom the entire page will change to display the atom zoom view and the close button.

-}

import Atom.Atom exposing (Atom)
import Colours
import DataBase.ParserTest exposing (errorAtom)
import Element exposing (Element, alignRight, alignTop, centerX, centerY, column, el, fill, height, padding, pointer, shrink, text, width)
import Element.Events exposing (onClick)
import Element.Font as Font
import Model exposing (Model)
import Msg exposing (Msg(..))
import TableAndParser.AtomBoxZoom exposing (atomBoxZoom)



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



-- atomBoxZoom view wrapper: atomZoomThingy for a lack of better name. Has to take in a Maybe Atom because that's what the Model has. If there is no atom, just output the errorAtom


atomZoomThingy : Maybe Atom -> Element Msg
atomZoomThingy maybeAtom =
    el
        [ centerX, centerY ]
    <|
        case maybeAtom of
            Just atom ->
                atomBoxZoom atom

            Nothing ->
                -- this shouldn't happen!
                atomBoxZoom errorAtom



-- actual page view.


atomZoomView : Model -> Element Msg
atomZoomView model =
    column
        [ width fill
        , height fill
        ]
        [ closeButton
        , atomZoomThingy model.selectedAtom
        ]
