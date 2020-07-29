-- this module is just to define what a molecule is.


module Data.Molecule exposing (MaybeMolecule(..), Molecule(..), fromString, molarMass, toAtomList, view, viewMaybe)

import Data.Atom as Atom exposing (Atom, MaybeAtom)
import DataBase.DataParser exposing (retrieveAtom)
import Element exposing (Element)
import Html
import Maybe.Extra
import Parser exposing ((|.), (|=), DeadEnd, Parser, Step)
import Set



{-

   this molecule type alias is a union type to deal with nested compounds.

   A molecule such as S8 would be:
   Mono Sulfur 8

   A molecule such as H2O would be
   Poly
       [ Mono Hydrogen 2
       , Mono Oxygen 1 ]
       1

   A molecule such as Ba(NO3)2 (barium nitrate) would be:
   Poly
       [ Mono Barium 1
       , Poly
           [ Mono Nitrogen 1
           , Mono Oxygen 2
           ]
           2
       ]
       1

    Of course, Barium, Sulfur, Hydrogen. etc. are just placeholders to represent the Atoms. I have no names of the atoms, they are all type aliases in one big list. So this just got more complicated.

    In the end, a molecule would look more like this:

    bariumSulfate =
        Poly
            [ Mono (retrieveAtom "Ba") 1
            , Poly
                [ Mono (retrieveAtom "S") 1
                , Mono (retrieveAtom "O") 4
                ]
                2
            ]
            1
    where retrieveAtom gets the atom from the atomList. This is why we have a MaybeAtom type

    It even supports hydrates! The int tells us how many water molecules it has and can be put into a Poly for a hydrate

-}


type Molecule
    = Mono MaybeAtom Int
    | Poly (List Molecule) Int
    | Hydrate Int



{-
   We either successfully made a molecule or have a bunch or errors to display lol. These errors come from:
   Bad user inputs (e.g. typing in an uncapitalized symbol)
   Unknown atoms (e.g. Sq)
   Other stuff? (sorry i can't think of any more lol)

   The cool thing is there are multiple types of errors even they all lead to the same outcome - I can't find the specified atom. This means that the user will have a more comprehensive way to know what went wrong in the parser (i.e. how incapable they are in using this calculator)
-}


type MaybeMolecule
    = GoodMolecule Molecule
    | BadMolecule (List DeadEnd)



-- VIEW


view : Molecule -> Element msg
view molecule =
    let
        -- view a molecule in HTML
        viewHtml m =
            case m of
                -- if there's a mono, first check for the MaybeAtom. then display the atom symbol with the quantity as the subscript
                Mono maybeAtom quantity ->
                    case maybeAtom of
                        Atom.Success atom ->
                            -- if there's only one of the atom don't write the subscript
                            if quantity == 1 then
                                Html.span
                                    []
                                    [ Html.text atom.symbol ]

                            else
                                Html.span
                                    []
                                    [ Html.text atom.symbol
                                    , Html.sub
                                        []
                                        [ Html.text (String.fromInt quantity) ]
                                    ]

                        Atom.Fail symbol ->
                            Html.span
                                []
                                [ Html.text ("error: Unknown Atom " ++ symbol) ]

                -- If its a poly, map through the elements inside the poly. if the polyatomic is greater than 1, display parentheses around the atom (e.g.  Ba(SO4)2)
                Poly atomList quantity ->
                    if quantity == 1 then
                        Html.span
                            []
                        <|
                            List.map viewHtml atomList

                    else
                        Html.span
                            []
                            (Html.text "("
                                :: List.map viewHtml atomList
                                ++ [ Html.text ")"
                                   , Html.sub
                                        []
                                        [ Html.text (String.fromInt quantity) ]
                                   ]
                            )

                Hydrate amount ->
                    let
                        waterText =
                            Html.span []
                                [ Html.text "H"
                                , Html.sub
                                    []
                                    [ Html.text "2" ]
                                , Html.text "O"
                                ]
                    in
                    if amount == 1 then
                        Html.span
                            []
                            [ Html.text " • "
                            , waterText
                            ]

                    else
                        Html.span
                            []
                            [ Html.text " • "
                            , Html.text (String.fromInt amount)
                            , waterText
                            ]
    in
    Element.html <| viewHtml molecule



-- MOLAR MASS


molarMass : Molecule -> Maybe Float
molarMass molecule =
    case molecule of
        Mono maybeAtom amount ->
            case maybeAtom of
                Atom.Success atom ->
                    Maybe.map
                        (\weight -> weight * toFloat amount)
                        (String.toFloat atom.weight)

                Atom.Fail _ ->
                    Nothing

        Poly maybeAtoms amount ->
            List.map
                molarMass
                maybeAtoms
                |> Maybe.Extra.combine
                |> Maybe.map List.sum
                |> Maybe.map ((*) (toFloat amount))

        Hydrate amount ->
            Just <|
                18.015
                    * toFloat amount



-- PARSER


viewMaybe : MaybeMolecule -> Element msg
viewMaybe molecule =
    molecule
        |> displayMoleculeClean



-- raw stuff for debugging. Shows the AtomParserData converted directly to a string. To use this you'll have to input the string the user inputs


parserDebugDisplay : String -> Element msg
parserDebugDisplay string =
    Parser.run moleculeParser string
        |> displayTextRaw



-- converts our string to a Maybe molecule!


fromString : String -> MaybeMolecule
fromString string =
    Parser.run moleculeParser string
        |> removeResult



-- cleanly displays the text or errors without the raw data


displayMoleculeClean : MaybeMolecule -> Element msg
displayMoleculeClean maybeMolecule =
    case maybeMolecule of
        GoodMolecule molecule ->
            view molecule

        BadMolecule errors ->
            cleanErrorsToString errors
                |> Element.text



-- displays all the data as AtomParserData converted directly to a string


displayTextRaw : Result (List DeadEnd) (List AtomParserData) -> Element msg
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
                Parser.Problem string ->
                    if string == "" then
                        Nothing

                    else
                        Just string

                -- no closing parentheses
                Parser.ExpectingSymbol symbol ->
                    if symbol == ")" then
                        Just "Remember to close your parentheses!"

                    else
                        Nothing

                -- starts off with a number or without a capital
                Parser.ExpectingVariable ->
                    Just "Element symbols start off with an upper case letter!"

                Parser.ExpectingKeyword keyword ->
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
    let
        deadEndsToString deadEnds =
            let
                deadEndToString : DeadEnd -> String
                deadEndToString deadEnd =
                    let
                        position : String
                        position =
                            "row:" ++ String.fromInt deadEnd.row ++ " col:" ++ String.fromInt deadEnd.col ++ "\n"
                    in
                    case deadEnd.problem of
                        Parser.Expecting str ->
                            "Expecting " ++ str ++ "at " ++ position

                        Parser.ExpectingInt ->
                            "ExpectingInt at " ++ position

                        Parser.ExpectingHex ->
                            "ExpectingHex at " ++ position

                        Parser.ExpectingOctal ->
                            "ExpectingOctal at " ++ position

                        Parser.ExpectingBinary ->
                            "ExpectingBinary at " ++ position

                        Parser.ExpectingFloat ->
                            "ExpectingFloat at " ++ position

                        Parser.ExpectingNumber ->
                            "ExpectingNumber at " ++ position

                        Parser.ExpectingVariable ->
                            "ExpectingVariable at " ++ position

                        Parser.ExpectingSymbol str ->
                            "ExpectingSymbol " ++ str ++ " at " ++ position

                        Parser.ExpectingKeyword str ->
                            "ExpectingKeyword " ++ str ++ "at " ++ position

                        Parser.ExpectingEnd ->
                            "ExpectingEnd at " ++ position

                        Parser.UnexpectedChar ->
                            "UnexpectedChar at " ++ position

                        Parser.Problem str ->
                            "ProblemString " ++ str ++ " at " ++ position

                        Parser.BadRepeat ->
                            "BadRepeat at " ++ position
            in
            List.foldl (++) "" (List.map deadEndToString deadEnds)
    in
    List.map
        (\deadend ->
            Parser.deadEndsToString deadends
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
                |> Maybe.Extra.combine
    in
    case compoundList of
        Nothing ->
            BadMolecule [ DeadEnd 1 1 (Parser.Problem "CompoundList is Nothing") ]

        Just list ->
            if list == [] then
                BadMolecule [ DeadEnd 1 1 (Parser.Problem "No recognized input specified") ]

            else
                Poly
                    list
                    amount
                    |> GoodMolecule



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

        Unknown _ ->
            -- Honestly it probably won't run lol
            Nothing



{-
   this loops through the string with the help of moleculeHelper, which uses atomParser to break up the string into AtomParserData types. This lets us work with the data far more easily.
-}


moleculeParser : Parser (List AtomParserData)
moleculeParser =
    Parser.loop [] moleculeHelper


moleculeHelper : List AtomParserData -> Parser (Step (List AtomParserData) (List AtomParserData))
moleculeHelper molecule =
    let
        checkMolecule atomsSoFar atomData =
            case atomData of
                SingleAtom _ _ ->
                    Parser.Loop (atomData :: atomsSoFar)

                PolyAtom _ _ ->
                    Parser.Loop (atomData :: atomsSoFar)

                HydrateAtom _ ->
                    Parser.Loop (atomData :: atomsSoFar)

                Unknown str ->
                    if str == "" then
                        Parser.Done (List.reverse atomsSoFar)

                    else
                        -- I'm pretty sure this doesn't happen
                        Parser.Done (List.reverse atomsSoFar)
    in
    Parser.succeed (checkMolecule molecule)
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
    Parser.oneOf
        [ -- if it's a hydrate (e.g. 5H2O)
          Parser.succeed HydrateAtom
            |. oneOrMoreSpaces
            |= Parser.oneOf
                [ integer
                    |. Parser.keyword "H2O"
                , Parser.succeed 1
                    |. Parser.keyword "H2O"
                ]

        -- if it's a single type of atom
        , Parser.succeed SingleAtom
            |= Parser.variable
                -- this just gets a bunch of text based on my specifications. Here, I say the atom symbols must start with an upper case, have lower case characters inside, though there are no reserved names (special variables)
                { start = Char.isUpper
                , inner = Char.isLower
                , reserved = Set.fromList []
                }
            |= Parser.oneOf
                [ integer
                , Parser.succeed 1
                ]
            |> Parser.andThen checkAtomName

        -- if it's multiple types of atoms (with parentheses around)
        , Parser.succeed PolyAtom
            |. Parser.symbol "("
            |. Parser.spaces
            |= moleculeParser
            |. Parser.spaces
            -- parse the stuff inside recursively!
            |. Parser.symbol ")"
            |= Parser.oneOf
                -- checks to see if there's a number after the parentheses - if there isn't make the "amount" 1
                [ integer
                , Parser.succeed 1
                ]

        -- if we reach the end of the string
        , Parser.succeed ()
            |. Parser.keyword ""
            |> Parser.getChompedString
            |> Parser.map Unknown

        -- If all else fails lol. I don't add anything because the other parsers will already have their own error statements.
        , Parser.problem ""
        ]



-- to have at least 1 space (used for a hydrate - there's always one space before a hydrate)


oneOrMoreSpaces : Parser ()
oneOrMoreSpaces =
    Parser.chompIf (\c -> c == ' ')
        |. Parser.chompWhile (\c -> c == ' ')



{-
   the Elm implementation of an integer parser accepts values like 1e30, and we don't want to deal with the letter 'E' in numbers because we use that letter in element symbols! Therefore I found a parser that only acceptes numerical digits
-}


integer : Parser Int
integer =
    Parser.getChompedString (Parser.chompWhile Char.isDigit)
        |> Parser.andThen
            (\str ->
                case String.toInt str of
                    Just n ->
                        Parser.succeed n

                    Nothing ->
                        Parser.problem "No Integer"
            )



-- makes sure the atom symbol is less than 3 characters long


checkAtomName : AtomParserData -> Parser AtomParserData
checkAtomName atomParserData =
    case atomParserData of
        SingleAtom name _ ->
            if String.length name > 2 then
                Parser.problem ("Unknown atom " ++ name)

            else
                Parser.succeed atomParserData

        _ ->
            -- technically this shouldn't happen because I only call checkAtomName after parsing a SingleAtom but I have to do the else branches anyway
            Parser.succeed atomParserData



-- HELPERS


toAtomList : MaybeMolecule -> List Atom
toAtomList maybeMolecule =
    case maybeMolecule of
        GoodMolecule molecule ->
            let
                -- returns List MaybeAtom
                moleculeDecomposter mol =
                    case mol of
                        Mono maybeAtom _ ->
                            [ maybeAtom ]

                        Poly listMaybeAtom _ ->
                            List.concatMap moleculeDecomposter listMaybeAtom

                        Hydrate _ ->
                            [ retrieveAtom "H", retrieveAtom "O" ]
            in
            List.filterMap
                (\maybeAtom ->
                    case maybeAtom of
                        Atom.Success atom ->
                            Just atom

                        Atom.Fail _ ->
                            Nothing
                )
                (moleculeDecomposter molecule)

        BadMolecule _ ->
            []
