module MoleculeParser exposing (emptyTest, testParserStringBromide)

import DataParser
import Molecule exposing (Compound)
import Parser exposing (..)



-- Ba2S8 becomes [Mono Ba 2, Mono S 8]
-- Ba2(SO4)2 becomes [Mono Ba 2, Poly [Mono S 1, Mono O 4] 2]
-- This is the stepping stone to combine the compounds to the end compound later on.
-- I first try mono (look for a upper case letter) and then if that doesn't work then I'll try Poly (if it starts with an opening parenthesis)


compoundSeparator : Parser (List Compound)
compoundSeparator =
    succeed identity
        |= oneOf
            []



-- will provide an error if the atom does not exist (e.g. DataParser.retrieveAtom returns a Nothing. )
-- atoms : Parser Atom
-- Valid strings


testParserStringBromide =
    "Br2"



-- Invalid strings


emptyTest =
    ""
