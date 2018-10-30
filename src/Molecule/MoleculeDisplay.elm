module MoleculeDisplay exposing (moleculeDisplay)

{-|

    this module is how to display the molecule. It takes in a molecule, with correct things and atoms, and outputs the Element Msg.

-}

import Atom exposing (Atom)
import Colours
import Element exposing (Element)
import Element.Font as Font
import Html exposing (Html)
import List exposing (map)
import Molecule exposing (..)
import String exposing (toInt)



--this moleculeSection makes the actual molecule <div> stuff, since the moleculeText is just the text


moleculeDisplay : Compound -> Element msg
moleculeDisplay compound =
    Element.el
        [ Element.centerX
        , Font.color Colours.fontColour
        , Font.size 40
        , Element.padding 20
        ]
        (moleculeText compound)



-- this takes in an Molecule and outputs an Element msg. it basically uses the moleculeTextHtml and uses the elm-ui Element.html (Html msg -> Element msg) to turn the Html msg into an Element msg


moleculeText : Compound -> Element msg
moleculeText compound =
    moleculeTextHtml compound
        |> Element.html



-- basically the compound with their subscripts (the amount). Since we have to use the Html module to do subscripts, we made this into an Html msg. we want an element msg though, so im goign to change that.


moleculeTextHtml : Compound -> Html msg
moleculeTextHtml compound =
    case compound of
        -- if there's a mono, first check for the MaybeAtom. then display the atom symbol with the quantity as the subscript
        Mono maybeAtom quantity ->
            case maybeAtom of
                Just atom ->
                    -- if there's only one of the atom don't write the subscript
                    if quantity == 1 then
                        Html.span
                            []
                            [ Html.text atom.symbol ]

                    else
                        Html.span
                            []
                            [ Html.text atom.symbol
                            , Html.sub
                                []
                                [ Html.text (String.fromInt quantity) ]
                            ]

                Nothing ->
                    Html.span
                        []
                        [ Html.text
                            ("Molecule error!! Idk where tho lmao. The atom quantity is "
                                ++ String.fromInt quantity
                                ++ " if that helps."
                            )
                        ]

        -- If its a poly, map through the elements inside the poly. if the polyatomic is greater than 1, display parentheses around the atom (e.g.  Ba(SO4)2)
        Poly atomList quantity ->
            if quantity == 1 then
                Html.span
                    []
                    (map
                        moleculeTextHtml
                        atomList
                    )

            else
                Html.span
                    []
                    ([ Html.text "(" ]
                        ++ map moleculeTextHtml atomList
                        ++ [ Html.text ")"
                           , Html.sub
                                []
                                [ Html.text (String.fromInt quantity) ]
                           ]
                    )
