{-
   This is the view function that handles what the user sees.
   In the actual `view` function, we only refer to our tableAndParserView, which is retrieved from View/TableAndParser/TableAndParserView.elm. Yeah, a bad name, so I'll probably change it later. But rn it is all we have because I only have 1 page at the moment.

   I also have an htmlPage function that makes the background the dark grey and gives everything a padding of 10, as well as changing the `Element Msg` to `Html Msg`.

   I have to use this because Elm Ui, which is the module I'm using to help me style the webpage more easily, creates Element Msg data types as I style the web page by its rules, so I have to change it to Html Msg which is the data type Elm actually uses to convert to HTML.
-}


module View exposing (view)

import AtomZoomView exposing (atomZoomView)
import Colours
import Element exposing (Element, FocusStyle)
import Element.Background as Background
import Html exposing (Html)
import Model exposing (Directory(..), Model)
import Msg exposing (Msg)
import QuizzerView exposing (quizzerView)
import TableAndParserView exposing (tableAndParserView)



-- htmlPage changes the element msg to Html msg and makes a dark theme
-- element.layout is basically the HTML or BODY tag so I made the entire html have a dark background
-- I also made the HTML or BODY, I don't really care honestly, have a padding of 10px


htmlPage : Element Msg -> Html Msg
htmlPage pageElements =
    Element.layoutWith
        { options = [ Element.focusStyle focusStyle ] }
        [ Background.color Colours.appBackgroundGray
        , Element.padding 10
        ]
        pageElements


view : Model -> Html Msg
view model =
    htmlPage <|
        case model.directory of
            TableAndParserView ->
                tableAndParserView model

            ZoomAtomView ->
                atomZoomView model



-- QuizzerView ->
--     quizzerView model
-- this makes all the buttons not have that ugly blue border. uncomment this and change the view function so it'll not have the options = [ Element.focusStyle focusStyle ], and change layoutWith to layout. It'll be so much uglier lol.


{--}
focusStyle : FocusStyle
focusStyle =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }
--}
