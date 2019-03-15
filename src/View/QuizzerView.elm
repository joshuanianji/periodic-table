module QuizzerView exposing (quizzerView)

import Element exposing (Element)
import Element.Input as Input
import Model exposing (Model)
import Msg exposing (Msg(..))
import Navbar exposing (navbar)


quizzerView : Model -> Element Msg
quizzerView model =
    Element.column
        [ Element.spacing 40
        , Element.centerX
        ]
        [ navbar model
        , Element.el [] Element.none
        ]
