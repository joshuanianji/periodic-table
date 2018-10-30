module Atom exposing (Atom, Charge(..), Isotopes, Section(..), State(..))

-- list of the isotopes - atomic masses. Remember - atomic mass is just the protons and neutrons of one atom!


type alias Isotopes =
    List Int



-- a singular charge or multiple charges


type Charge
    = Singular Int
    | Multiple (List Int)



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



-- i made the name HardCodedAtomAlias to differentiate it between the Atom type in the DataParser. Lmao it used to be Atom


type alias Atom =
    { name : String
    , symbol : String
    , state : State
    , section : Section
    , charge : Charge
    , protons : Int
    , isotopes : Isotopes
    , xPos : Int
    , yPos : Int
    , weight : String -- So i can keep sig. digs. (for example if the weight is 16.000 elm will automatically write 16, but string will keep 16.000)
    }
