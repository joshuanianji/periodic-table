-- this module is just to define what a molecule is.


module Data.Molecule exposing (ParsedMolecule(..), Molecule(..), fromString, molarMass, toAtomList)

import Data.Atom as Atom exposing (Atom, MaybeAtom)
import Data.PeriodicTable as PeriodicTable exposing (PeriodicTable)
import Maybe.Extra
import Parser exposing ((|.), (|=), DeadEnd, Parser, Step)
import Set



{-

   this molecule data type is a union type to deal with nested compounds.

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


type ParsedMolecule
    = Good Molecule
    | LeFunny -- when the user types in a funny
    | Bad (List DeadEnd)



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


-- converts our string to a Maybe molecule!
-- Requires the periodic table to lookup the atoms


fromString : PeriodicTable -> String -> ParsedMolecule
fromString ptable string =
    Parser.run moleculeWithMemeParser string
        |> toMolecule ptable



type MoleculeWithMemes
    = ActualMolecule (List AtomParserData)
    | LeFunnyThing


moleculeWithMemeParser : Parser MoleculeWithMemes
moleculeWithMemeParser =
    Parser.oneOf
        [ Parser.map ActualMolecule moleculeParser
        , Parser.map (always LeFunnyThing) parseFunny
        ]

-- reserved when the user is a top notch comedian
parseFunny : Parser ()
parseFunny =
    ["poop", "penis", "amongus", "pp", "amogus", "sus", "sussy"]
        |> List.map Parser.token 
        |> Parser.oneOf 



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


toMolecule : PeriodicTable -> Result (List DeadEnd) MoleculeWithMemes -> ParsedMolecule
toMolecule ptable test =
    case test of
        Ok LeFunnyThing ->
            LeFunny 
        
        Ok (ActualMolecule parsedAtomData) ->
            parserDataToCompound ptable parsedAtomData 1

        Err error ->
            Bad error



{-
   Turns the list of atomParserData into a MaybeCompound!
   I have an Integer parameter because parserDataToCompound might have to convert a nested parserData into a molecule, and those have
-}


parserDataToCompound : PeriodicTable -> List AtomParserData -> Int -> ParsedMolecule
parserDataToCompound ptable atomParserData amount =
    let
        compoundList =
            List.map
                (parserDatumToCompound ptable)
                atomParserData
                |> Maybe.Extra.combine
    in
    case compoundList of
        Nothing ->
            Bad [ DeadEnd 1 1 (Parser.Problem "CompoundList is Nothing") ]

        Just list ->
            if list == [] then
                Bad [ DeadEnd 1 1 (Parser.Problem "No recognized input specified") ]

            else
                Good <| Poly list amount



-- turns one (1) AtomParserData to a Maybe Conpound


parserDatumToCompound : PeriodicTable -> AtomParserData -> Maybe Molecule
parserDatumToCompound ptable data =
    case data of
        SingleAtom symbol amount ->
            Just <|
                Mono (Atom.fromMaybe <| PeriodicTable.findAtom symbol ptable) amount

        PolyAtom atoms amount ->
            case parserDataToCompound ptable atoms amount of
                Good molecule ->
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
            if String.length name > 1000 then
                Parser.problem ("Unknown atom: " ++ name)

            else
                Parser.succeed atomParserData

        _ ->
            -- technically this shouldn't happen because I only call checkAtomName after parsing a SingleAtom but I have to do the else branches anyway
            Parser.succeed atomParserData



-- HELPERS


toAtomList : PeriodicTable -> ParsedMolecule -> List Atom
toAtomList ptable parsedMolecule =
    case parsedMolecule of
        Good molecule ->
            let
                -- returns List MaybeAtom
                moleculeDecomposter mol =
                    case mol of
                        Mono maybeAtom _ ->
                            [ maybeAtom ]

                        Poly listMaybeAtom _ ->
                            List.concatMap moleculeDecomposter listMaybeAtom

                        Hydrate _ ->
                            [ PeriodicTable.findAtom "H" ptable
                            , PeriodicTable.findAtom "O" ptable
                            ]
                                |> List.map Atom.fromMaybe
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

        LeFunny -> 
            []

        Bad _ ->
            []
