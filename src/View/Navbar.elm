{-

   i'm going to create my Navbar using a mapping over a list to save space.

   First we have a navbarMapList which holds all the data.

   Next we have the navbarFramework that gives out a navbar element when given the tuple that the navbarMapList is constructed out of.

   Navbar framework also has to take in the Model to account for the fact that navbarElementAttributes, the helper function that changes the bolding of the navbar when we're in specific directories, takes in a tuple

   mapping navbarFramework over navbarMapList gives us a list of Element Msg's that we can put in row. This list looks like this:

   [ el [ centerX, width fill, onClick (ChangeDirectory PeriodicTablePage) ] (text "Periodic Table")
   , el [ centerX, width fill, onClick (ChangeDirectory QuizzerView) ] (text "Quiz Yourself!")
   ]

-}


module Navbar exposing (navbar)

import Colours
import Element exposing (Attribute, Element, centerX, el, fill, height, padding, paddingEach, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input exposing (button)
import List exposing (map)
import Model exposing (Directory(..), Model)
import Msg exposing (Msg(..))



-- navbar information to map over to create the navbar


navbarMapList : List ( String, Directory )
navbarMapList =
    [ ( "Periodic Table", TableAndParserView )
    , ( "Quiz Yourself!", QuizzerView )
    ]



-- each little navbar button


navbarFramework : Model -> ( String, Directory ) -> Element Msg
navbarFramework model ( name, directory ) =
    button
        (navbarElementAttributes model directory)
        { onPress = Just (ChangeDirectory directory)
        , label = el [] (text name)
        }



-- checks to see in the model if we're in that specific directory. if we are we do an underline


navbarElementAttributes : Model -> Directory -> List (Attribute Msg)
navbarElementAttributes model dir =
    let
        navbarPadding =
            paddingEach
                { top = 30, right = 0, bottom = 20, left = 0 }

        basicNavBarAttributes =
            [ navbarPadding
            , width fill
            , navbarBorderWidths
            , Font.color Colours.fontColour
            , Background.color Colours.navbarBackground
            ]

        navbarBorderWidths =
            Border.widthEach
                { bottom = 3
                , left = 0
                , right = 0
                , top = 0
                }
    in
    if model.directory == dir then
        Border.color Colours.fontColour :: basicNavBarAttributes

    else
        Border.color Colours.appBackgroundGray :: basicNavBarAttributes



-- the actual thing we're exporting


navbar : Model -> Element Msg
navbar model =
    row
        [ centerX
        , spacing 20
        ]
        (map
            (navbarFramework model)
            navbarMapList
        )
