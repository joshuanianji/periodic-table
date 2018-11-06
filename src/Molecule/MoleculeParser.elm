module MoleculeParser exposing (parserTest)

import Char
import DataParser
import Element exposing (Element)
import Molecule exposing (Compound)
import Parser exposing (..)


parserTest : Element msg
parserTest =
    testParserThing
        |> stringParserTest
        |> displayStringParserTest


displayStringParserTest : String -> Element msg
displayStringParserTest parserTestString =
    Element.text parserTestString


stringParserTest : Result (List DeadEnd) String -> String
stringParserTest test =
    case test of
        Ok result ->
            result

        Err error ->
            deadEndsToString error ++ "Dead End thing btw"


testParserThing : Result (List DeadEnd) String
testParserThing =
    run testParser testParserBromide



-- Ba2S8 becomes [Mono Ba 2, Mono S 8]
-- Ba2(SO4)2 becomes [Mono Ba 2, Poly [Mono S 1, Mono O 4] 2]
-- This is the stepping stone to combine the compounds to the end compound later on.
-- I first try mono (look for a upper case letter) and then if that doesn't work then I'll try Poly (if it starts with an opening parenthesis)


{-| compoundSeparator : Parser (List Compound)
compoundSeparator =
succeed identity
|= oneOf
[ atoms ]
-}



--  WOOHOO THIS WORKS


testParser : Parser String
testParser =
    succeed identity
        |= oneOf
            [ atom ]



-- will provide an error if the atom does not exist (e.g. DataParser.retrieveAtom returns a Nothing. )


atom : Parser String
atom =
    succeed ()
        |. chompIf isCapital
        |. chompIf isLower
        |> getChompedString



-- checks if the character is capital


isCapital : Char -> Bool
isCapital char =
    Char.isUpper char


isLower : Char -> Bool
isLower char =
    Char.isLower char



-- this is just to get strings until a certain (Char -> Bool) parameter function outputs false


zeroOrMore : (Char -> Bool) -> Parser String
zeroOrMore isOk =
    succeed ()
        |. chompWhile isOk
        |> getChompedString



-- Valid strings


testParserMagnesiumBromide =
    "MgBr2"


testParserBromide =
    "Br2"


testCarbonDisulfide =
    "CS2"



-- Invalid strings


emptyTest =
    ""
