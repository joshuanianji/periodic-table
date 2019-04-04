module Colours exposing
    ( actinide
    , alkali
    , alkalineEarth
    , appBackgroundGray
    , atomBoxBackground
    , fontColour
    , gaseousState
    , halogen
    , hydrogen
    , lanthanide
    , linkColour
    , liquidState
    , metalloid
    , navbarBackground
    , nobleGas
    , nonMetal
    , postTransitionMetal
    , sectionColour
    , solidState
    , stateColour
    , transitionMetal
    , unknown
    )

-- this is responsible for the material design dark colours - basically just naming them lol.
-- rgb takes in a value between 0 and 1 - not 1 and 255, so I use rgb255

import Atom.Atom exposing (Section(..), State(..))
import Element exposing (Color, rgb, rgb255, rgba)
import Element.Background exposing (color)



-- My inspiration for the dark theme come from Rally, a fake financial app with material design.
-- https://material.io/design/material-studies/rally.html#color
-- also a shout out to https://www.colorhexa.com for helping me convert hex to rgb!! YEAH!
-- The font is automatically plain white


fontColour : Color
fontColour =
    -- rgb255 132 132 138
    rgb255 255 255 255



-- colour for links


linkColour : Color
linkColour =
    rgb255 1 92 204



-- unknowns are gray


unknown : Color
unknown =
    rgb255 134 133 138



-- background colour of the entire website


appBackgroundGray : Color
appBackgroundGray =
    rgb255 51 51 61



-- background for navbar


navbarBackground : Color
navbarBackground =
    rgb255 51 51 61



-- Background colour of each element block - completely transparent


atomBoxBackground : Color
atomBoxBackground =
    rgba 0 0 0 0



-- COLOURS OF THE ELEMENT SYMBOLS FOR DIFFERENT STATES
-- solid is black


solidState : Color
solidState =
    -- rgb255 0 0 0
    rgb255 142 142 163



-- for grey
-- liquid is blue - same blue as the nonmetals actually wowow lol


liquidState : Color
liquidState =
    rgb255 21 127 196



-- gaseous is red


gaseousState : Color
gaseousState =
    rgb255 255 104 89



-- COLOURS OF THE SECTIONS (E.G. ALKALI, ALKALINE EARTH, ETC)
-- Hydrogen is going to be the same as the non-metals for now, i might change it later : blue


hydrogen : Color
hydrogen =
    rgb255 21 127 196



-- red for the alkalis


alkali : Color
alkali =
    rgb255 234 32 45



-- orange for the alkalines


alkalineEarth : Color
alkalineEarth =
    rgb255 245 147 49



-- Yellow for the transition metals


transitionMetal : Color
transitionMetal =
    rgb255 254 241 53



-- green for post transition metals


postTransitionMetal : Color
postTransitionMetal =
    rgb255 27 164 85



-- light blue for the transition metals


metalloid : Color
metalloid =
    rgb255 27 184 239



-- Same blue as the hydrogen


nonMetal : Color
nonMetal =
    rgb255 21 127 196



-- purple for halogens


halogen : Color
halogen =
    rgb255 119 48 142



-- dark purple for the noble gases


nobleGas : Color
nobleGas =
    rgb255 52 10 85



-- pinkish for lanthanides


lanthanide : Color
lanthanide =
    rgb255 239 116 172



-- magents ish for actinides


actinide : Color
actinide =
    rgb255 196 32 140



-- HERE ARE THE FUCNTIONS USED TO COLOUR THE ATOM NAMES AND STUFF (STATES AND GROUPS)
-- function used in atomSymbol function - returns the colour for the state at room temperature


stateColour : State -> Color
stateColour state =
    case state of
        Solid ->
            solidState

        Liquid ->
            liquidState

        Gas ->
            gaseousState

        UnknownState ->
            unknown



-- function used to get Section (e.g. Alkali, AlialineEarth, etc.) and return the corresponding colour associated with it
-- TODO: lanthanide and actinide colours - maybe also make the s for the metals more different?


sectionColour : Section -> Color
sectionColour section =
    case section of
        Hydrogen ->
            hydrogen

        Alkali ->
            alkali

        AlkalineEarth ->
            alkalineEarth

        TransitionMetal ->
            transitionMetal

        PostTransitionMetal ->
            postTransitionMetal

        Metalloid ->
            metalloid

        NonMetal ->
            nonMetal

        Halogen ->
            halogen

        NobleGas ->
            nobleGas

        Lanthanide ->
            lanthanide

        Actinide ->
            actinide

        UnknownSection ->
            unknown
