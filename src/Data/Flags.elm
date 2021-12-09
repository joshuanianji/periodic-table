module Data.Flags exposing (Flags, WindowSize, decoder)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
import Data.Atom as Atom exposing (Atom)


type alias Flags =
    { windowSize : WindowSize
    , atoms : List Atom 
    }


type alias WindowSize =
    { height : Int
    , width : Int
    }




-- DECODER


decoder : Decoder Flags
decoder =
    Decode.succeed Flags
        |> Pipeline.required "windowSize" windowSize
        |> Pipeline.required "atoms" (Decode.list Atom.decoder)



windowSize : Decoder WindowSize
windowSize =
    Decode.succeed WindowSize
        |> Pipeline.required "height" Decode.int
        |> Pipeline.required "width" Decode.int

