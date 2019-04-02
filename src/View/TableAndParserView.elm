{-
   This module specifies how the Periodic table and the molecule parser will look like. It's just a column of the periodic table and the parser if you look into it lol.

-}


module TableAndParserView exposing (tableAndParserView)

import Colours
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Model exposing (Model)
import Molecule.MolarMass exposing (..)
import Molecule.MoleculeParser exposing (..)
import Msg exposing (Msg(..))
import TableAndParser.PeriodicTable exposing (periodicTable)


tableAndParserView : Model -> Element Msg
tableAndParserView model =
    Element.column
        [ Element.spacing 30
        , Element.centerX
        ]
        [ periodicTable model
        , compoundInput model
        , displayedCompound model
        , displayedMolarMass model
        ]



-- the text box where the user inputs a molecule


compoundInput : Model -> Element Msg
compoundInput model =
    Input.text
        [ Font.center
        , Background.color Colours.appBackgroundGray
        , inputBorder
        , Border.rounded 0
        , Font.color Colours.fontColour
        ]
        { onChange = UpdateMoleculeParser
        , text = model.moleculeData.inputMoleculeString
        , placeholder = Nothing
        , label =
            Input.labelAbove
                [ Element.centerX
                , Font.color Colours.fontColour
                , Element.padding 10
                ]
                (Element.el []
                    (Element.text "Get your Molar Mass of a Compound Here!")
                )
        }


inputBorder : Attribute Msg
inputBorder =
    Border.widthEach
        { bottom = 1
        , left = 0
        , right = 0
        , top = 0
        }



-- the molecule which is displayed all fancy with the subscripts and stuff


displayedCompound : Model -> Element Msg
displayedCompound model =
    displayMolecule model.moleculeData.inputMolecule
        -- parserDebugDisplay model.moleculeData.inputMoleculeString
        |> Element.el
            [ Element.centerX
            , Font.color Colours.fontColour
            , Font.size 30
            ]



-- molar mass


displayedMolarMass : Model -> Element Msg
displayedMolarMass model =
    model.moleculeData.inputMolecule
        |> displayMolarMass
        |> appendTo " g/mol"
        |> Element.text
        |> Element.el
            [ Element.centerX
            , Font.color Colours.fontColour
            , Font.size 30
            ]


appendTo : String -> String -> String
appendTo s1 s2 =
    s2 ++ s1
