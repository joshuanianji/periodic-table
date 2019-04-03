{-
   This Module can take in a string and creates a Molecule data type. Also does stuff in between, like converting the MaybeMolecule and to a list of atoms.

   If the string is "", then we output a BadMolecule stating that we have no input specified.
-}


module Molecule.MoleculeParser exposing (displayMolecule, parserDebugDisplay, stringToMolecule, toAtomList)

import Atom.Atom exposing (..)
import Char
import DataBase.DataParser as DataParser exposing (retrieveAtom)
import Element exposing (Element)
import Maybe.Extra exposing (combine)
import Molecule.Molecule exposing (..)
import Molecule.MoleculeDisplay exposing (moleculeText)
import Msg exposing (Msg)
import Parser exposing (..)
import Set



{-
   Decomposes a Molecule into a list of Atoms
-}


toAtomList : MaybeMolecule -> List Atom
toAtomList maybeMolecule =
    case maybeMolecule of
        GoodMolecule molecule ->
            let
                -- returns List MaybeAtom
                moleculeDecomposter mol =
                    case mol of
                        Mono maybeAtom amount ->
                            [ maybeAtom ]

                        Poly listMaybeAtom amount ->
                            List.concatMap moleculeDecomposter listMaybeAtom

                        Hydrate _ ->
                            [ retrieveAtom "H", retrieveAtom "O" ]
            in
            List.filterMap
                (\maybeAtom ->
                    case maybeAtom of
                        Success atom ->
                            Just atom

                        Fail str ->
                            Nothing
                )
                (List.map
                    identity
                    (moleculeDecomposter molecule)
                )

        BadMolecule _ ->
            []



{-
   Parse and display a Molecule! The big function we expose. Since the Model holds our MaybeMolecule as the user types, we don't need to convert it again from the string
-}


displayMolecule : MaybeMolecule -> Element Msg
displayMolecule molecule =
    molecule
        |> displayMoleculeClean



-- raw stuff for debugging. Shows the AtomParserData converted directly to a string. To use this you'll have to input the string the user inputs


parserDebugDisplay : String -> Element Msg
parserDebugDisplay string =
    run moleculeParser string
        |> displayTextRaw



-- converts our string to a Maybe molecule!


stringToMolecule : String -> MaybeMolecule
stringToMolecule string =
    run moleculeParser string
        |> removeResult



-- cleanly displays the text or errors without the raw data


displayMoleculeClean : MaybeMolecule -> Element Msg
displayMoleculeClean maybeMolecule =
    case maybeMolecule of
        GoodMolecule molecule ->
            moleculeText molecule

        BadMolecule errors ->
            cleanErrorsToString errors
                |> Element.text



-- displays all the data as AtomParserData converted directly to a string


displayTextRaw : Result (List DeadEnd) (List AtomParserData) -> Element Msg
displayTextRaw result =
    Element.text <|
        case result of
            Ok atomData ->
                atomData
                    |> List.map Debug.toString
                    |> String.join ","

            Err error ->
                allErrorsToString error



-- my own thing that converts all the errors / deadends the parser accumulates into a string, using the Elm DeadEnd type (https://package.elm-lang.org/packages/elm/parser/latest/Parser#DeadEnd) I use filterMap because I only want my own errors I wrote out - not the others. Those are represented in the Problem thing.


cleanErrorsToString : List DeadEnd -> String
cleanErrorsToString deadends =
    List.filterMap
        (\deadend ->
            case deadend.problem of
                -- These are the errors I generate.
                Problem string ->
                    Just string

                -- no closing parentheses
                ExpectingSymbol symbol ->
                    if symbol == ")" then
                        Just "Remember to close your parentheses!"

                    else
                        Nothing

                -- starts off with a number or without a capital
                ExpectingVariable ->
                    Just "Element symbols start off with an upper case letter!"

                ExpectingKeyword keyword ->
                    -- literally should always do this - I have no other mention of keywords in my parser
                    if keyword == "H2O" then
                        Just "Expecting a hydrate"

                    else
                        Nothing

                _ ->
                    Nothing
        )
        deadends
        |> String.join ","
        |> (++) "error: "



-- when I'm debugging and want every single error


allErrorsToString : List DeadEnd -> String
allErrorsToString deadends =
    List.map
        (\deadend ->
            Debug.toString deadend
                ++ " at row "
                ++ String.fromInt deadend.row
                ++ " and column "
                ++ String.fromInt deadend.col
        )
        deadends
        |> String.join ","
        |> (++) "error: "


removeResult : Result (List DeadEnd) (List AtomParserData) -> MaybeMolecule
removeResult test =
    case test of
        Ok result ->
            parserDataToCompound result 1

        Err error ->
            BadMolecule error



{-
   Turns the list of atomParserData into a MaybeCompound!
   I have an Integer parameter because parserDataToCompound might have to convert a nested parserData into a molecule, and those have
-}


parserDataToCompound : List AtomParserData -> Int -> MaybeMolecule
parserDataToCompound atomParserData amount =
    let
        compoundList =
            List.map
                parserDatumToCompound
                atomParserData
                |> collapseMaybeList
    in
    case compoundList of
        Nothing ->
            BadMolecule [ DeadEnd 1 1 (Problem "CompoundList is Nothing") ]

        Just list ->
            if list == [] then
                BadMolecule [ DeadEnd 1 1 (Problem "No recognized input specified") ]

            else
                Poly
                    list
                    amount
                    |> GoodMolecule



{-
   If one thing fails (is a Nothing) - ALL OF THEM FAIL!
-}


collapseMaybeList : List (Maybe a) -> Maybe (List a)
collapseMaybeList list =
    combine list



-- turns one (1) AtomParserData to a Maybe Conpound


parserDatumToCompound : AtomParserData -> Maybe Molecule
parserDatumToCompound data =
    case data of
        SingleAtom symbol amount ->
            Just <|
                Mono (retrieveAtom symbol) amount

        PolyAtom atoms amount ->
            case parserDataToCompound atoms amount of
                GoodMolecule molecule ->
                    Just molecule

                _ ->
                    Nothing

        HydrateAtom amount ->
            Just <|
                Hydrate amount

        Unknown string ->
            -- Honestly it probably won't run lol
            Nothing



{-
   this loops through the string with the help of moleculeHelper, which uses atomParser to break up the string into AtomParserData types. This lets us work with the data far more easily.
-}


moleculeParser : Parser (List AtomParserData)
moleculeParser =
    loop [] moleculeHelper


moleculeHelper : List AtomParserData -> Parser (Step (List AtomParserData) (List AtomParserData))
moleculeHelper molecule =
    let
        checkMolecule atomsSoFar atomData =
            case atomData of
                SingleAtom atom amount ->
                    Loop (Debug.log "Added SingleAtom" atomData :: atomsSoFar)

                PolyAtom atoms amount ->
                    Loop (Debug.log "added PolyAtom" atomData :: atomsSoFar)

                HydrateAtom amount ->
                    Loop (Debug.log "added Hydrate " atomData :: atomsSoFar)

                Unknown str ->
                    if str == "" then
                        Done (List.reverse (Debug.log "we're done! Atoms so far is" atomsSoFar))

                    else
                        -- I'm pretty sure this doesn't happen
                        Done (List.reverse (Debug.log "Terminated unsuccessfully!" atomsSoFar))
    in
    succeed (checkMolecule molecule)
        |= atomParser



{-
   this parser data is all the types of data that will occur throughout the molecule. I don't automatically convert them to the Molecule type because I want to store then by their element symbols first then convert them to Atoms. If i separate the code this way it'll be easier to catch errors and track them (but it's not like I have good error management anyways lol)

   This even supports dick jokes! If the user types in "penis" or other variants I'll say "haha ur so funny lol"
-}


type AtomParserData
    = SingleAtom String Int
    | PolyAtom (List AtomParserData) Int -- Polyatomic that has the list of atoms.
    | HydrateAtom Int
    | Unknown String



-- actually parses each individual atom or group of atoms one by one.


atomParser : Parser AtomParserData
atomParser =
    oneOf
        [ -- if it's a hydrate (e.g. 5H2O)
          succeed HydrateAtom
            |. oneOrMoreSpaces
            |= oneOf
                [ integer
                    |. keyword "H2O"
                , succeed 1
                    |. keyword "H2O"
                ]

        -- if it's a single type of atom
        , succeed SingleAtom
            |= variable
                -- this just gets a bunch of text based on my specifications. Here, I say the atom symbols must start with an upper case, have lower case characters inside, though there are no reserved names (special variables)
                { start = Char.isUpper
                , inner = Char.isLower
                , reserved = Set.fromList []
                }
            |= oneOf
                [ integer
                , succeed 1
                ]
            |> andThen checkAtomName

        -- if it's multiple types of atoms (with parentheses around)
        , succeed PolyAtom
            |. symbol "("
            |. spaces
            |= moleculeParser
            |. spaces
            -- parse the stuff inside recursively!
            |. symbol ")"
            |= oneOf
                -- checks to see if there's a number after the parentheses - if there isn't make the "amount" 1
                [ integer
                , succeed 1
                ]

        -- if we reach the end of the string
        , succeed ()
            |. keyword ""
            |> getChompedString
            |> map Unknown

        -- If all else fails lol. I don't add anything because the other parsers will already have their own error statements.
        , problem "unknown parser thing"
        ]



-- to have at least 1 space (used for a hydrate - there's always one space before a hydrate)


oneOrMoreSpaces : Parser ()
oneOrMoreSpaces =
    chompIf (\c -> c == ' ')
        |. chompWhile (\c -> c == ' ')



{-
   the Elm implementation of an integer parser accepts values like 1e30, and we don't want to deal with the letter 'E' in numbers because we use that letter in element symbols! Therefore I found a parser that only acceptes numerical digits
-}


integer : Parser Int
integer =
    getChompedString (chompWhile Char.isDigit)
        |> andThen
            (\str ->
                case String.toInt str of
                    Just n ->
                        succeed n

                    Nothing ->
                        problem "No Integer"
            )



-- makes sure the atom symbol is less than 3 characters long


checkAtomName : AtomParserData -> Parser AtomParserData
checkAtomName atomParserData =
    case atomParserData of
        SingleAtom name amount ->
            if String.length name > 2 then
                problem ("Unknown atom " ++ name)

            else
                succeed atomParserData

        _ ->
            -- technically this shouldn't happen because I only call checkAtomName after parsing a SingleAtom but I have to do the else branches anyway
            succeed atomParserData
