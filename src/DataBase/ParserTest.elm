module ParserTest exposing (testAtom)

-- this module is a test for a single element of the JSON file. I used hydrogen. It works! So this is kinda deprecated but its prolly good to look back to when writing my IA

import Atom exposing (..)
import Json.Decode as Decode exposing (Decoder, float, int, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)



-- WHAT TO DO:
{-
   Basically what i said in the TODO file lol
   "Make the dataParser do the json - what I think I need to do is to make a type called (jsonAtom String) that holds the string value of the specific json alias and then parse it. Maybe also a JsonVal union type."
-}
-- Json.Decode.Pipeline makes me use pipeline notation to convert Jason strings to type aliases instead of map functions, cuz I'll have to use map9 or something for my Atom function.
{-
   this testAtomData is just a test for my code. I guess it works!
-}


testAtomData =
    """
    {
        "atomicNumber": 1,
        "symbol": "H",
        "name": "Hydrogen",
        "atomicMass": "1.00794(4)",
        "cpkHexColor": "FFFFFF",
        "electronicConfiguration": "1s1",
        "electronegativity": 2.2,
        "atomicRadius": 37,
        "ionRadius": "",
        "vanDelWaalsRadius": 120,
        "ionizationEnergy": 1312,
        "electronAffinity": -73,
        "oxidationStates": "-1, 1",
        "standardState": "gas",
        "bondingType": "diatomic",
        "meltingPoint": 14,
        "boilingPoint": 20,
        "density": 0.0000899,
        "groupBlock": "nonmetal",
        "yearDiscovered": 1766
    }
    """



-- takes in a json string and outputs the atom
-- the atom to show when an error happens


errorAtom : Atom
errorAtom =
    Atom
        "Error"
        "Err"
        Gas
        Metal
        (Multiple [ 1, -1 ])
        1
        [ 1, 2, 3 ]
        (Position 1 1)
        69.6969



-- the actual decoder for an atom


atomDecoder : Decoder Atom
atomDecoder =
    Decode.succeed Atom
        |> required "name" string
        |> required "symbol" string
        -- `null` decodes to `Nothing`
        |> hardcoded Gas
        |> hardcoded Alkali
        |> hardcoded (Multiple [ 1, -1 ])
        |> hardcoded 8
        |> hardcoded [ 1, 2, 3 ]
        |> hardcoded (Position 1 1)
        |> hardcoded 1.008



-- the takes in a Json string and outputs a Result Error Atom


atomResultFrom : String -> Result Decode.Error Atom
atomResultFrom atomJsonString =
    Decode.decodeString
        atomDecoder
        atomJsonString



-- the actual thing - it works!!


testAtom : Atom
testAtom =
    let
        atomResult =
            atomResultFrom testAtomData
    in
    case atomResult of
        Err _ ->
            errorAtom

        Ok atom ->
            atom



{-

   reference for me to see the what a hydrogen looks like - taken from HardCodedData

   hydrogen : HardCodedAtomAlias
   hydrogen =
       Atom
           "Hydrogen"
           "H"
           Gas
           Hydrogen
           (Multiple [ 1, -1 ])
           1
           [ 1, 2, 3 ]
           (Position 1 1)
           1.008

-}
