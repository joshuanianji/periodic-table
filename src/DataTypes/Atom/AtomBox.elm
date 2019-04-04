{-
   AtomBox holds the specifications to make each little box in the periodic table.

   Also Colours is my own module, not Elm's

-}


module Atom.AtomBox exposing (pTableBox)

import Atom.Atom exposing (..)
import Colours
import Element exposing (Element, alignLeft, centerX, centerY, column, fill, maximum, minimum, pointer, row, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Model exposing (Model)
import Msg exposing (Msg(..))



-- this is literally just for the element symbol


atomSymbol : Atom -> Element Msg
atomSymbol atom =
    Element.el
        [ centerX
        , Font.size 30
        , Font.bold
        , Font.color (Colours.stateColour atom.state)
        ]
        (text atom.symbol)



-- displays the element number (amount of protons)


atomNum : Atom -> Element Msg
atomNum atom =
    Element.el
        [ centerX
        , Font.size 8
        ]
        (text <| String.fromInt <| atom.protons)



-- displays atomic molar mass below symbol


atomMolarMass : Atom -> Element Msg
atomMolarMass atom =
    Element.el
        [ centerX
        , Font.size 8
        ]
        (text <| atom.weight)



-- border stuff - I only want the bottom border!!


borderWidths =
    { bottom = 2
    , left = 0
    , right = 0
    , top = 0
    }



{-

   This is just to display the element box on the periodic table

   Because the boxes don't have borders around them, I made them have a margin of about 10. You actually don't see that here because the margin is the `Element.spacing 10` in the Main.elm.

   They also have a fixed width cuz I need them to be uniform. Right now, I have width fill because idk how long the names are going to be, but I have a todo to change the width after I'm done

   TBH 70px seems like a good amount though

   pointer (near the bottom of the Attribute Msg list) allows the mouse to be pointed when hovering the atomBox

-}


atomBox : Model -> Atom -> Element Msg
atomBox model atom =
    let
        attributes =
            [ width (Element.px 70)
            , Element.padding 10
            , Font.color Colours.fontColour
            , Border.widthEach borderWidths
            , Border.color (Colours.sectionColour atom.section)
            , pointer
            , onClick (ZoomAtom atom)
            , Element.spacing 2
            ]
                |> (::)
                    (if List.member atom model.moleculeData.selectedAtoms then
                        Background.color (Colours.sectionColour atom.section)

                     else
                        Background.color Colours.atomBoxBackground
                    )
    in
    column
        attributes
        [ atomNum atom
        , atomSymbol atom
        , atomMolarMass atom
        ]



{-
   This is to specify how to show Placeholders
-}


placeholderBox : Placeholder -> Element Msg
placeholderBox placeholder =
    let
        -- how many groups the placeholder is placing over lol
        groupSpan =
            case placeholder.section of
                Lanthanide ->
                    "57-71"

                Actinide ->
                    "89-103"

                _ ->
                    "THIS ISN'T SUPPOSED TO HAPPEN LOL SOMEONE HELP"
    in
    groupSpan
        |> text
        |> Element.el
            [ Font.color Colours.fontColour
            , Font.size 15
            , centerY
            , centerX
            ]
        |> Element.el
            [ width (fill |> minimum 70)
            , Element.height (Element.px 72)
            , Element.padding 10
            , Background.color Colours.atomBoxBackground
            , Font.color Colours.fontColour
            , Border.widthEach borderWidths
            , Border.color (Colours.sectionColour placeholder.section)
            ]


pTableBox : Model -> PTableAtom -> Element Msg
pTableBox model pTableAtom =
    case pTableAtom of
        PTableAtom atom ->
            atomBox model atom

        PTablePlaceholder placeholder ->
            placeholderBox placeholder
