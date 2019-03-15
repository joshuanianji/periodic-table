module DataBase.DataParser exposing (atomList, errorAtom, pTableAtomList, retrieveAtom)

-- this module is used to parse the data.json (in AtomJson.elm) into a list of atoms

import Atom.Atom exposing (..)
import DataBase.AtomJson as AtomJson
import Json.Decode as Decode exposing (Decoder, Error(..))
import Json.Decode.Pipeline exposing (hardcoded, required)
import Result.Extra as Result
import Round exposing (round)



-- the atom to show when an error happens


errorAtom : Atom
errorAtom =
    Atom
        "Error"
        "Err"
        Gas
        TransitionMetal
        1
        1
        1
        "69.6969"
        [ 6, 9 ]
        "https://en.wikipedia.org/wiki/PewDiePie_vs_T-Series"
        "ree"
        "Joshua Ji"
        "Penis Parker"
        (PhaseChanges
            (Just 2000)
            (Just 4000)
        )



-- this is a miscellaneous piece of code to turn `Result Decode.Error (List Atom)` into (List Atom)


removeResult : Result error (List a) -> List a
removeResult result =
    case result of
        Err err ->
            Debug.log ("error while pruning Atom List: " ++ Debug.toString err) []

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

        -- rounding the weight to 3 decimal places. Converts it into a string!!
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



-- if the name is a null, then output "Not found"


badName : Decoder String
badName =
    Decode.oneOf
        [ Decode.string
        , Decode.null "Not found"
        ]



-- decoder for the PhaseChange


phaseChangeDecoder : Decoder PhaseChanges
phaseChangeDecoder =
    Decode.succeed PhaseChanges
        -- Decode.nullable makes it a Maybe type - Nothing if it is a null
        |> required "melt" (Decode.nullable Decode.float)
        |> required "boil" (Decode.nullable Decode.float)



{-
   the actual decoder for an atom. Used in `atomListResult`

   I used the pipeline notation to convert json objects to type aliases instead of map functions from the Json.Decode.Pipeline module

   I first used the phaseChangeDecoder and piped that value into the other atom decoder stuff.
-}


atomDecoder : Decoder Atom
atomDecoder =
    phaseChangeDecoder
        |> Decode.andThen
            (\phaseChanges ->
                Decode.succeed Atom
                    |> required "name" Decode.string
                    |> required "symbol" Decode.string
                    -- `null` decodes to `Nothing`
                    |> required "phase" stateDecoder
                    |> required "category" sectionDecoder
                    |> required "number" Decode.int
                    |> required "xpos" Decode.int
                    |> required "ypos" Decode.int
                    |> required "atomic_mass" weightDecoder
                    |> required "shells" (Decode.list Decode.int)
                    |> required "source" Decode.string
                    |> required "summary" Decode.string
                    |> required "discovered_by" badName
                    |> required "named_by" badName
                    |> hardcoded phaseChanges
            )



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



{-
   I get ready to export a new list - a list ready to be shown on the Periodic Table. it basically has the Lanthanide and Actinide placeholders
-}


placeholders : List PTableAtom
placeholders =
    [ PTablePlaceholder
        { name = "Lanthanide"
        , section = Lanthanide
        , xpos = 3
        }
    , PTablePlaceholder
        { name = "Actinide"
        , section = Actinide
        , xpos = 3
        }
    ]



--Here is the list where I store the atoms ready to be shown in the Periodic Table. i.e. I have the Lanthanide and Actinide placeholder here


pTableAtomList : List PTableAtom
pTableAtomList =
    List.map
        (\atom -> PTableAtom atom)
        atomList
        ++ placeholders


{-|

    this gets an atom from the atom list based on its symbol, and it's a MaybeAtom because it might not be in the atomList

-}
retrieveAtom : String -> MaybeAtom
retrieveAtom symbol =
    let
        filteredAtomList =
            List.filter
                (\atom -> atom.symbol == symbol)
                atomList
    in
    case filteredAtomList of
        [ a ] ->
            Success a

        _ ->
            -- if there is anything else - e.g. multiple elements or no elements in the list, we will return nothing.
            Fail symbol
