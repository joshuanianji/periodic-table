{-
   AtomBoxZoom specifies  the "zoomed" atom box should look like. This is the larger atom box on the left when the user clicks on an atom box.

   A lot of these elements are very similar to fucnitons found in AtomBox, but whatever lol.

   Everything is scaled up 5x from the AtomBox
-}


module TableAndParser.AtomBoxZoom exposing (atomBoxZoom)

import Atom.Atom exposing (..)
import Colours
import Element exposing (Attribute, Element, alignRight, alignTop, centerX, column, inFront, padding, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Msg exposing (Msg(..))



-- Element symbol


atomSymbol : Atom -> Element Msg
atomSymbol atom =
    Element.el
        [ centerX
        , Font.size 150
        , Font.bold
        , Font.color (Colours.stateColour atom.state)
        ]
        (text atom.symbol)



-- element name below the element symbol


atomName : Atom -> Element Msg
atomName atom =
    Element.el
        [ centerX
        , Font.size 50
        ]
        (text atom.name)



-- displays the element number (amount of protons)


atomNum : Atom -> Element Msg
atomNum atom =
    Element.el
        [ centerX
        , Font.size 40
        ]
        (text <| String.fromInt <| atom.protons)



-- displays atomic weight below atom


atomWeight : Atom -> Element Msg
atomWeight atom =
    Element.el
        [ centerX
        , Font.size 30
        ]
        (text <| atom.weight)


atomShells : Atom -> Element Msg
atomShells atom =
    Element.column
        [ alignTop
        , alignRight
        , Font.size 20
        , padding 10
        ]
        (List.map
            (\x ->
                x
                    |> String.fromInt
                    |> text
                    |> Element.el []
            )
            atom.electronShells
        )



{-
   This is the real deal! The Big Zoom box. I made it around 350 px wide and stuff lol.
-}


atomBoxZoom : Atom -> Element Msg
atomBoxZoom atom =
    column
        [ width (Element.px 350)
        , Element.spacing 10
        , Element.padding 50
        , Background.color Colours.atomBoxBackground
        , inFront (atomShells atom)
        ]
        [ atomNum atom
        , atomSymbol atom
        , atomName atom
        , atomWeight atom
        ]
