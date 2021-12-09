module Data.Flags exposing (Flags, WindowSize, Media, decoder)

import Data.PeriodicTable as PeriodicTable exposing (PeriodicTable)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline


type alias Flags =
    { windowSize : WindowSize
    , ptable : PeriodicTable
    , media : Media 
    }


type alias WindowSize =
    { height : Int
    , width : Int
    }

type alias Media =
    { sigmaStare : String
    , remilkLook : String
    }


-- DECODER


decoder : Decoder Flags
decoder =
    Decode.succeed Flags
        |> Pipeline.required "windowSize" windowSize
        |> Pipeline.required "ptable" PeriodicTable.decoder
        |> Pipeline.required "media" media


windowSize : Decoder WindowSize
windowSize =
    Decode.succeed WindowSize
        |> Pipeline.required "height" Decode.int
        |> Pipeline.required "width" Decode.int

media : Decoder Media
media =
    Decode.succeed Media
        |> Pipeline.required "sigmaStare" Decode.string
        |> Pipeline.required "remilkLook" Decode.string