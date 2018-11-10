module Atom.AtomBox exposing (atomBox)

-- this module is to make a box in the periodic table

import Atom.Atom exposing (..)
import Atom.HardCodedData exposing (..)
import Colours
import Element exposing (Color, Element, alignLeft, centerX, centerY, column, fill, maximum, minimum, row, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font



-- SOME INTER MODULAR COLOUR THINGS (COLOURS FOR THE STATES AND THE GROUPS)
-- function used in atomSymbol function - returns the colour for the state at room temperature


stateColour : State -> Color
stateColour state =
    case state of
        Solid ->
            Colours.solidState

        Liquid ->
            Colours.liquidState

        Gas ->
            Colours.gaseousState

        UnknownState ->
            Colours.unknown



-- function used to get Section (e.g. Alkali, AlialineEarth, etc.) and return the corresponding colour associated with it
-- TODO: lanthanide and actinide colours - maybe also make the s for the metals more different?


sectionColour : Section -> Color
sectionColour section =
    case section of
        Hydrogen ->
            Colours.hydrogen

        Alkali ->
            Colours.alkali

        AlkalineEarth ->
            Colours.alkalineEarth

        TransitionMetal ->
            Colours.transitionMetal

        PostTransitionMetal ->
            Colours.postTransitionMetal

        Metalloid ->
            Colours.metalloid

        NonMetal ->
            Colours.nonMetal

        Halogen ->
            Colours.halogen

        NobleGas ->
            Colours.nobleGas

        Lanthanide ->
            Colours.lanthanide

        Actinide ->
            Colours.actinide

        UnknownSection ->
            Colours.unknown



-- this is literally just for the element symbol


atomSymbol : Atom -> Element msg
atomSymbol atom =
    Element.el
        [ centerX
        , Font.size 30
        , Font.bold
        , Font.color (stateColour atom.state)
        ]
        (text atom.symbol)



-- just to display the element name below the element symbol


atomName : Atom -> Element msg
atomName atom =
    Element.el
        [ centerX
        , Font.size 10
        ]
        (text atom.name)


{-| I don't need the atomic weight - I'll show it when they click on the atom

-- displays atomic weight below atom

atomWeight : Atom -> Element msg
atomWeight atom =
Element.el
[ centerX
, Font.size 9
]
(text <| String.fromFloat <| atom.weight)

-}



-- displays the element number (amount of protons)


atomNum : Atom -> Element msg
atomNum atom =
    Element.el
        [ centerX
        , Font.size 8
        ]
        (text <| String.fromInt <| atom.protons)



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

   TBH 100px seems like a good amount though

-}


atomBox : Atom -> Element msg
atomBox atom =
    column
        [ width (Element.px 70)
        , Element.spacing 2
        , Element.padding 10
        , Background.color Colours.atomBoxBackground
        , Font.color Colours.fontColour
        , Border.widthEach borderWidths
        , Border.color (sectionColour atom.section)
        ]
        [ atomNum atom
        , atomSymbol atom
        , atomName atom

        -- because I don't need atomic weight haha
        -- , atomWeight atom
        ]
