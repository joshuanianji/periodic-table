module Atom.Atom exposing (Atom, MaybeAtom(..), PTableAtom(..), PhaseChanges, Placeholder, Section(..), State(..))

-- state at room temperature


type State
    = Solid
    | Liquid
    | Gas
    | UnknownState



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



-- these phase changes are all in Kelvins


type alias PhaseChanges =
    { melt : Maybe Float
    , boil : Maybe Float
    }



-- i made the name HardCodedAtomAlias to differentiate it between the Atom type in the DataParser. Lmao it used to be Atom


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
    , phaseChanges : PhaseChanges -- which Kelvin Temperatures the element changes phases in
    }



-- this is for the Periodic Table for the Lanthanide placeholders (they do nothing when clicked)


type alias Placeholder =
    { name : String
    , section : Section
    , xpos : Int
    }



-- when making the periodic table, I have to have a choice : Either an atom or a placeholder, since they are used differently.


type PTableAtom
    = PTableAtom Atom
    | PTablePlaceholder Placeholder



{-
   in instances such as the Molar Mass calculator, the user may not input a correct atom symbol. Then we have an error.

   We could just use a Maybe Atom type, but that only has the Just Atom and the Nothing type, and doesn't give us much information.

   Using this MaybeAtom type, if the MaybeAtom is a fail, then we can attach the unsuccessful user inputted atom symbol in so the error messages will be better.
   We can also attach other messages there

-}


type MaybeAtom
    = Success Atom
    | Fail String -- the string is the Atom Symbol and it helps for debugging
