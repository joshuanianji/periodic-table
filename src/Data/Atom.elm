module Data.Atom exposing
    ( Atom
    , MaybeAtom(..)
    , PhaseChanges
    , Section(..)
    , State(..)
    , decoder
    , fromMaybe
    , isFBlock
    , sectionToString
    , stateToString
    )

-- state at room temperature

import Json.Decode as Decode exposing (Decoder, Error(..))
import Json.Decode.Pipeline exposing (hardcoded, required)
import Round


type alias Atom =
    { name : String
    , symbol : String
    , state : State
    , section : Section
    , protons : Int
    , xpos : Int
    , ypos : Int
    , weight : String -- So i can keep sig. digs. (for example if the weight is 16.000 elm will automatically write 16, but string will keep 16.000)
    , electronShells : List Int
    , wikiLink : String -- link to the wikipedia page lol
    , summary : String -- a paragraph explaining  the element
    , discoveredBy : String -- "not found" if it is a null value
    , namedBy : String -- also "not found" if it is a null value
    , phaseChanges : PhaseChanges -- which Kelvin temperatures the element changes phases in
    }


type State
    = Solid
    | Liquid
    | Gas
    | UnknownState


stateToString : State -> String
stateToString state =
    case state of
        Solid ->
            "Solid"

        Liquid ->
            "Liquid"

        Gas ->
            "Gas"

        UnknownState ->
            "UnknownState"



-- we'll have different colour representing sections


type Section
    = Hydrogen
    | Alkali
    | AlkalineEarth
    | TransitionMetal
    | PostTransitionMetal
    | Metalloid
    | NonMetal
    | Halogen
    | NobleGas
    | Lanthanide
    | Actinide
    | UnknownSection


sectionToString : Section -> String
sectionToString section =
    case section of
        Hydrogen ->
            "Hydrogen"

        Alkali ->
            "Alkali"

        AlkalineEarth ->
            "AlkalineEarth"

        TransitionMetal ->
            "TransitionMetal"

        PostTransitionMetal ->
            "PostTransitionMetal"

        Metalloid ->
            "Metalloid"

        NonMetal ->
            "NonMetal"

        Halogen ->
            "Halogen"

        NobleGas ->
            "NobleGas"

        Lanthanide ->
            "Lanthanide"

        Actinide ->
            "Actinide"

        UnknownSection ->
            "UnknownSection"



-- these phase changes are all in Kelvins


type alias PhaseChanges =
    { melt : Maybe Float
    , boil : Maybe Float
    }



{-
   in instances such as the Molar Mass calculator, the user may not input a correct atom symbol. Then we have an error.

   We could just use a Maybe Atom type, but that only has the Just Atom and the Nothing type, and doesn't give us much information.

   Using this MaybeAtom type, if the MaybeAtom is a fail, then we can attach the unsuccessful user inputted atom symbol in so the error messages will be better.
   We can also attach other messages there

-}


type MaybeAtom
    = Success Atom
    | Fail String -- the string is the Atom Symbol and it helps for debugging



---- DECODERS


decoder : Decoder Atom
decoder =
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


phaseChangeDecoder : Decoder PhaseChanges
phaseChangeDecoder =
    Decode.succeed PhaseChanges
        -- Decode.nullable makes it a Maybe type - Nothing if it is a null
        |> required "melt" (Decode.nullable Decode.float)
        |> required "boil" (Decode.nullable Decode.float)


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
        -- rounding the weight to 3 decimal places. Converts it into a string!!
        roundFloat float =
            Round.round 3 float
    in
    Decode.float
        |> Decode.andThen
            (\inputWeight ->
                inputWeight
                    |> roundFloat
                    |> Decode.succeed
            )


badName : Decoder String
badName =
    Decode.oneOf
        [ Decode.string
        , Decode.null "Not found"
        ]



---- HELPERS


isFBlock : Atom -> Bool
isFBlock atom =
    atom.section == Lanthanide || atom.section == Actinide


fromMaybe : Maybe Atom -> MaybeAtom
fromMaybe maybeAtom =
    case maybeAtom of
        Nothing ->
            Fail "Atom not found"

        Just atom ->
            Success atom
