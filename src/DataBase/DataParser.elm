module DataBase.DataParser exposing (atomList, retrieveAtom)

-- this module is used to parse the data.json (in AtomJson.elm) into a list of atoms

import Atom.Atom exposing (..)
import Atom.AtomBox exposing (atomBox)
import DataBase.AtomJson as AtomJson
import Debug
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import List
import Round exposing (round)



-- this is a miscellaneous piece of code to turn `Result Decode.Error (List Atom)` into (List Atom)


removeResult : Result Decode.Error (List a) -> List a
removeResult result =
    case result of
        Err err ->
            Debug.log ("error" ++ Debug.toString err) []

        Ok list ->
            list



{-
   This is where I decode all the other stuff, such as the atom State type and such.
-}
-- stateDecoder and literally all other union type decoders were inspired form this source: https://gist.github.com/focusaurus/1085181366a6399414f0b0049ece3750#gistcomment-2151035


stateDecoder : Decoder State
stateDecoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "Gas" ->
                        Decode.succeed Gas

                    "Solid" ->
                        Decode.succeed Solid

                    "Liquid" ->
                        Decode.succeed Liquid

                    _ ->
                        Decode.succeed UnknownState
            )


sectionDecoder : Decoder Section
sectionDecoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "hydrogen" ->
                        Decode.succeed Hydrogen

                    "alkali metal" ->
                        Decode.succeed Alkali

                    "alkaline earth metal" ->
                        Decode.succeed AlkalineEarth

                    "transition metal" ->
                        Decode.succeed TransitionMetal

                    "metalloid" ->
                        Decode.succeed Metalloid

                    "post-transition metal" ->
                        Decode.succeed PostTransitionMetal

                    "diatomic nonmetal" ->
                        Decode.succeed NonMetal

                    "polyatomic nonmetal" ->
                        Decode.succeed NonMetal

                    "halogen" ->
                        Decode.succeed Halogen

                    "noble gas" ->
                        Decode.succeed NobleGas

                    "lanthanide" ->
                        Decode.succeed Lanthanide

                    "actinide" ->
                        Decode.succeed Actinide

                    _ ->
                        Decode.succeed UnknownSection
            )


weightDecoder : Decoder String
weightDecoder =
    let
        atomWeightResult =
            Decode.decodeString Decode.float

        -- rounding the weight to 3 decimal places
        roundFloat : Float -> String
        roundFloat float =
            round 3 float
    in
    -- tbh I have no idea about Decode.andThen but the code works so whatever.
    Decode.float
        |> Decode.andThen
            (\inputWeight ->
                inputWeight
                    |> roundFloat
                    |> Decode.succeed
            )



-- the actual decoder for an atom. Used in `atomListResult`
-- I used the pipeline notation to convert json objects to type aliases instead of map functions from the Json.Decode.Pipeline module


atomDecoder : Decoder Atom
atomDecoder =
    Decode.succeed Atom
        |> required "name" Decode.string
        |> required "symbol" Decode.string
        -- `null` decodes to `Nothing`
        |> required "phase" stateDecoder
        |> required "category" sectionDecoder
        |> hardcoded (Multiple [ 1, -1 ])
        |> required "number" Decode.int
        |> hardcoded [ 1, 2, 3 ]
        |> required "xpos" Decode.int
        |> required "ypos" Decode.int
        |> required "atomic_mass" weightDecoder



{-

   THE LIST OF ATOMS FROM THE JSON DATA (code looks pretty good man)
   BIG thanks to https://riptutorial.com/elm/example/28373/decode-a-list-of-objects-containing-lists-of-objects for giving me example code. Thanks a ton! I had no idea what else to do before.

-}


atomList : List Atom
atomList =
    Decode.decodeString
        (Decode.list atomDecoder)
        AtomJson.atomData
        |> removeResult


{-|

    this gets an atom from the atom list. Since it's a maybe atom welp.

-}
retrieveAtom : String -> Maybe Atom
retrieveAtom name =
    let
        filteredAtomList =
            List.filter
                (\atom -> atom.name == name)
                atomList
    in
    case filteredAtomList of
        [ a ] ->
            Just a

        _ ->
            -- if there is anything else - e.g. multiple elements or no elements in the list, we will return nothing.
            Nothing
