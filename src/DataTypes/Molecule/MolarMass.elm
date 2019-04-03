{-
   I just became tired of seeing my code from the other modules so I made a new one just to calculate molar mass lol.
   Clean file, less headaches

   I have a Maybe Float type because if the Molecule contains a
-}


module Molecule.MolarMass exposing (molarMassString)

import Atom.Atom exposing (..)
import Maybe.Extra exposing (combine)
import Molecule.Molecule exposing (..)
import Msg exposing (Msg)
import Round exposing (round)



-- calculates from a MaybeMolecule


molarMassString : MaybeMolecule -> String
molarMassString maybeMolecule =
    case maybeMolecule of
        GoodMolecule molecule ->
            molecule
                |> calculateMolarMass
                |> stringify

        _ ->
            "0.000"


stringify : Maybe Float -> String
stringify maybeMass =
    maybeMass
        -- the `round` function rounds the number and also converts it into a string
        |> Maybe.map (round 3)
        |> Maybe.withDefault "0.000"



{-
   This uses recursion to add the molar mass of every single atom in the Molecule type, and also to multiply it by the amount of atoms
-}


calculateMolarMass : Molecule -> Maybe Float
calculateMolarMass molecule =
    case molecule of
        Mono maybeAtom amount ->
            case maybeAtom of
                Success atom ->
                    Maybe.map
                        (\weight -> weight * toFloat amount)
                        (String.toFloat atom.weight)

                Fail symbol ->
                    Nothing

        Poly maybeAtoms amount ->
            List.map
                calculateMolarMass
                maybeAtoms
                |> combine
                |> Maybe.map addAll
                |> Maybe.map ((*) (toFloat amount))

        Hydrate amount ->
            Just <|
                18.015
                    * toFloat amount



-- adds everything in a list


addAll : List Float -> Float
addAll list =
    List.foldr (+) 0 list
