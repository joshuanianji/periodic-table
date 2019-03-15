{-
   Subscriptions mean we tune in to the changes of certain actions. For example, I can "subscribe" to mouse clicks or keyboard clicks, and especially screen resizes.

   This means everytime the screen resizes, they will run the GetViewport Msg function, which carries with it the width and the height of the enw screen. I dont use these btw lol.

   Check out the Elm subscription on its website: https://package.elm-lang.org/packages/elm/core/latest/Platform-Sub
-}


module Subscriptions exposing (ViewPortArgs(..), screenDimension, subscriptions)

import Browser.Events as Browser
import Element exposing (Attribute, height, px, width)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Platform.Sub as Sub


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.onResize BrowserResized



-- this is a helper function to return the List (Attribute Msg) of the height or width of the viewport, or both


type ViewPortArgs
    = Height
    | Width


screenDimension : ViewPortArgs -> Model -> Float
screenDimension viewPortArg model =
    case model.viewport of
        Just viewport ->
            let
                viewportHeight =
                    viewport.height

                viewportWidth =
                    viewport.width
            in
            case viewPortArg of
                Height ->
                    viewportHeight

                Width ->
                    viewportWidth

        Nothing ->
            0
