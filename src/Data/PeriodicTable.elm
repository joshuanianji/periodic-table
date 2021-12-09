module Data.PeriodicTable exposing 
    ( PeriodicTable
    , PTableElem(..)
    , findAtom
    , getCol
    , splitUpperLower
    , decoder
    )

-- Essentially a glorified list of atoms
-- But we add a bit more info

import Data.Atom as Atom exposing (Atom, Section) 
import Util
import Json.Decode as Decode exposing (Decoder)

---- DATA


type PeriodicTable = PeriodicTable (List Atom) (List PTableElem) -- stores the atom for easier access internally


-- when making the periodic table, I have to have a choice : Either an atom or a placeholder, since they are used differently.


type PTableElem
    = Atom Atom
    | Placeholder PlaceholderElem


-- this is for the Periodic Table for the Lanthanide placeholders (they do nothing when clicked)


type alias PlaceholderElem =
    { name : String
    , section : Section
    , xpos : Int
    }



placeholders : List PlaceholderElem
placeholders =
    [ { name = "Lanthanide"
        , section = Atom.Lanthanide
        , xpos = 3
        }
    , { name = "Actinide"
        , section = Atom.Actinide
        , xpos = 3
        }
    ]

---- PUBLIC HELPERS

-- finds an atom by name

findAtom : String -> PeriodicTable -> Maybe Atom
findAtom name (PeriodicTable atoms _) = Util.find (\atom -> atom.name == name) atoms

-- get a column of elements

getCol : Int -> List PTableElem -> List PTableElem
getCol col elems = 
    List.filter
        (\elem ->
            case elem of
                Atom atom ->
                    atom.xpos == col

                Placeholder placeholder ->
                    placeholder.xpos == col
        )
    elems 


-- split ptable into upper and lower halves
-- first one with f blocks, second one without
splitUpperLower : PeriodicTable -> (List PTableElem, List PTableElem)
splitUpperLower (PeriodicTable _ elems) =
    List.foldr (\elem (nonFBlocks, fBlocks) -> 
        case elem of
            Atom atom ->
                if Atom.isFBlock atom
                    then (nonFBlocks, elem::fBlocks)
                    else (elem::nonFBlocks, fBlocks)
            
            -- placeholders are never f blocks, because they represent the F block positions
            Placeholder _ ->
                (elem::nonFBlocks, fBlocks)
    ) ([], []) elems



---- DECODER ----

decoder : Decoder PeriodicTable
decoder = 
    Decode.field "elements" (Decode.list Atom.decoder)
        -- |> Decode.map sortAtoms
        |> Decode.map fromAtoms


---- INTERNALS ----


-- Create a periodic table from a list of atoms
-- this just adds in the placeholders

fromAtoms : List Atom -> PeriodicTable
fromAtoms atoms =
    List.map Atom atoms ++ (List.map Placeholder placeholders)
        |> PeriodicTable atoms
