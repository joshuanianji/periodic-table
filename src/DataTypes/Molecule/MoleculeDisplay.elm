module Molecule.MoleculeDisplay exposing (moleculeText)

{-|

    this module is how to display the molecule. It takes in a molecule, with correct things and atoms, and outputs the Element Msg.

-}

import Atom.Atom exposing (..)
import Colours
import Element exposing (Element)
import Element.Font as Font
import Html exposing (Html)
import List exposing (map)
import Molecule.Molecule exposing (..)
import Msg exposing (Msg)
import String exposing (toInt)



{-
   this takes in an Molecule and outputs an Element msg. it basically uses the moleculeTextHtml and uses the elm-ui Element.html (Html msg -> Element msg) to turn the Html msg into an Element msg
-}


moleculeText : Molecule -> Element Msg
moleculeText molecule =
    moleculeTextHtml molecule
        |> Element.html



-- basically the molecule with their subscripts (the amount). Since we have to use the Html module to do subscripts, we made this into an Html msg. we want an element msg though, so im goign to change that.


moleculeTextHtml : Molecule -> Html Msg
moleculeTextHtml molecule =
    case molecule of
        -- if there's a mono, first check for the MaybeAtom. then display the atom symbol with the quantity as the subscript
        Mono maybeAtom quantity ->
            case maybeAtom of
                Success atom ->
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

                Fail symbol ->
                    Html.span
                        []
                        [ Html.text
                            (" (Unable to find atom "
                                ++ symbol
                                ++ ") "
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

        Hydrate amount ->
            let
                waterText =
                    Html.span []
                        [ Html.text "H"
                        , Html.sub
                            []
                            [ Html.text "2" ]
                        , Html.text "O"
                        ]
            in
            if amount == 1 then
                Html.span
                    []
                    [ Html.text " • "
                    , waterText
                    ]

            else
                Html.span
                    []
                    [ Html.text " • "
                    , Html.text (String.fromInt amount)
                    , waterText
                    ]
