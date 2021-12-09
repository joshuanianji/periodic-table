module Page.Home exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Colours
import Data.Atom as Atom exposing (Atom)
import Data.Molecule as Molecule exposing (ParsedMolecule, Molecule)
import Data.PeriodicTable as PeriodicTable
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Round
import Routes exposing (Route)
import SharedState exposing (SharedState)
import Parser exposing (DeadEnd)
import Html



---- MODEL


type alias Model =
    { inputMoleculeString : String
    , inputMolecule : ParsedMolecule
    , selectedAtoms : List Atom
    }


init : SharedState -> Model
init sharedState =
    let
        moleculeStr =
            "CuSO4 5H2O"
    in
    { inputMoleculeString = moleculeStr
    , inputMolecule = Molecule.fromString sharedState.ptable moleculeStr
    , selectedAtoms = []
    }



---- VIEW
-- Add legend???


{-| legend : Model -> Element Msg
legend model =
let
legendPadding =
Element.paddingEach { top = 0, right = 0, left = 400, bottom = 0 }

        viewLegendItem color label =
            Element.row
                []
                [ Element.el
                    [ Element.width (Element.px 10)
                    , Element.height (Element.px 10)
                    , Background.color color
                    ]
                    Element.none
                , Element.text label
                ]

        stateLegend =
            let
                allStates =
                    [ Atom.Solid
                    , Atom.Liquid
                    , Atom.Gas
                    , Atom.UnknownState
                    ]
            in
            List.map
                (\state -> viewLegendItem (Colours.stateColour state) (Atom.stateToString state))
                allStates
                |> Element.column []

        sectionLegend =
            let
                allSections =
                    [ Atom.Hydrogen
                    , Atom.Alkali
                    , Atom.AlkalineEarth
                    , Atom.TransitionMetal
                    , Atom.PostTransitionMetal
                    , Atom.Metalloid
                    , Atom.NonMetal
                    , Atom.Halogen
                    , Atom.NobleGas
                    , Atom.Lanthanide
                    , Atom.Actinide
                    , Atom.UnknownSection
                    ]
            in
            List.map
                (\section -> viewLegendItem (Colours.sectionColour section) (Atom.sectionToString section))
                allSections
                |> Element.column []
    in
    Element.row
        [ Element.width Element.fill
        , Element.spacing 30
        , legendPadding
        , Element.inFront (periodicTable model)
        ]
        [ sectionLegend
        , stateLegend
        ]

-}
view : SharedState -> Model -> Element Msg
view ss model =
    Element.column
        [ Element.spacing 30
        , Element.centerX
        , Element.paddingXY 12 16
        ]
        [ periodicTable ss model
        , molarMassCalc ss model
        ]

-- view periodic table stuff

periodicTable : SharedState -> Model -> Element Msg
periodicTable ss model =
    let
        -- display a single column of the periodic table
        viewGroup ptableElems group =
            PeriodicTable.getCol group ptableElems
                |> (List.map <| viewPTableElem model)
                |> Element.column
                    [ Element.alignBottom
                    , Element.spacing 10
                    ]

        ( upper, lower ) =
            PeriodicTable.splitUpperLower ss.ptable

        -- Upper Periodic Table is the periodic table for all the elements which aren't f block
        viewUpper =
            List.map
                (viewGroup upper)
                (List.range 1 18)
                |> Element.row
                    [ Element.spacing 2
                    , Element.centerX
                    ]

        viewLower =
            List.map
                (viewGroup lower)
                (List.range 3 17)
                |> Element.row
                    [ Element.spacing 2
                    , Element.centerX
                    ]
    in
    Element.column
        [ Element.centerX
        , Element.width Element.fill
        , Element.spacing 16
        , Background.color (Element.rgba 0 0 0 0)
        ]
        [ viewUpper
        , viewLower
        ]


viewPTableElem : Model -> PeriodicTable.PTableElem -> Element Msg
viewPTableElem model pTableElem =
    let
        borderWidths =
            { bottom = 2
            , left = 0
            , right = 0
            , top = 0
            }
    in
    case pTableElem of
        PeriodicTable.Atom atom ->
            let
                attributes =
                    [ Element.width (Element.px 70)
                    , Element.padding 10
                    , Font.color Colours.fontColour
                    , Border.widthEach borderWidths
                    , Border.color (Colours.sectionColour atom.section)
                    , Element.pointer
                    , Events.onClick (NavigateTo <| Routes.Atom atom.symbol)
                    , Element.spacing 2
                    ]
                        |> (::)
                            (if List.member atom model.selectedAtoms then
                                Background.color (Colours.sectionColour atom.section)

                             else
                                Background.color Colours.atomBoxBackground
                            )
            in
            Element.column
                attributes
                [ Element.el
                    [ Element.centerX
                    , Font.size 8
                    ]
                    (Element.text <| String.fromInt <| atom.protons)
                , Element.el
                    [ Element.centerX
                    , Font.size 30
                    , Font.bold
                    , Font.color (Colours.stateColour atom.state)
                    ]
                    (Element.text atom.symbol)
                , Element.el
                    [ Element.centerX
                    , Font.size 8
                    ]
                    (Element.text <| atom.weight)
                ]

        PeriodicTable.Placeholder placeholder ->
            let
                -- how many groups the placeholder is placing over lol
                groupSpan =
                    case placeholder.section of
                        Atom.Lanthanide ->
                            "57-71"

                        Atom.Actinide ->
                            "89-103"

                        _ ->
                            "THIS ISN'T SUPPOSED TO HAPPEN LOL SOMEONE HELP"
            in
            groupSpan
                |> Element.text
                |> Element.el
                    [ Font.color Colours.fontColour
                    , Font.size 15
                    , Element.centerY
                    , Element.centerX
                    ]
                |> Element.el
                    [ Element.width (Element.fill |> Element.minimum 70)
                    , Element.height (Element.px 72)
                    , Element.padding 10
                    , Background.color Colours.atomBoxBackground
                    , Font.color Colours.fontColour
                    , Border.widthEach borderWidths
                    , Border.color (Colours.sectionColour placeholder.section)
                    ]


-- Molar Mass stuff

molarMassCalc : SharedState -> Model -> Element Msg
molarMassCalc ss model = 
    let
        -- stringify molar mass
        stringifyMolarMass maybeMass =
            maybeMass
                -- the `round` function rounds the number and also converts it into a string
                |> Maybe.map (Round.round 3)
                |> Maybe.withDefault "0.000"

        molarMassString parsedMolecule =
            case parsedMolecule of
                Molecule.Good molecule ->
                    Molecule.molarMass molecule
                        |> stringifyMolarMass
                        |> Just

                _ ->
                    Nothing

        displayedMolarMass =
            Maybe.map 
                (\txt -> 
                    Element.el
                        [ Element.centerX
                        , Font.color Colours.fontColour
                        , Font.size 30
                        ]
                        (Element.text <| txt ++ " g/mol")
                )
                (molarMassString model.inputMolecule)

        -- the molecule which is displayed all fancy with the subscripts and stuff
        displayedCompound =
            viewParsedMolecule ss model.inputMolecule
                -- parserDebugDisplay model.inputMoleculeString
                |> Element.el
                    [ Element.centerX
                    , Font.color Colours.fontColour
                    , Font.size 30
                    ]

        inputBorder =
            Border.widthEach
                { bottom = 1
                , left = 0
                , right = 0
                , top = 0
                }

        -- the text box where the user inputs a molecule
        compoundInput =
            Input.text
                [ Font.center
                , Background.color Colours.appBackgroundGray
                , inputBorder
                , Border.rounded 0
                , Font.color Colours.fontColour
                ]
                { onChange = UpdateMoleculeParser
                , text = model.inputMoleculeString
                , placeholder = Nothing
                , label =
                    Input.labelAbove
                        [ Element.centerX
                        , Font.color Colours.fontColour
                        , Element.padding 10
                        ]
                        (Element.el []
                            (Element.text "Get your Molar Mass of a Compound Here!")
                        )
                }
    in
    Element.column 
        [ Element.width Element.fill
        , Element.spacing 4 
        ]
        [ compoundInput
        , displayedCompound
        , Maybe.withDefault Element.none displayedMolarMass
        ]


viewParsedMolecule : SharedState -> ParsedMolecule -> Element Msg
viewParsedMolecule ss parsedMolecule =
    case parsedMolecule of
        Molecule.Good molecule ->
            viewMolecule molecule 
        
        Molecule.LeFunny ->
            Element.image
                []
                { src = ss.sigmaStare
                , description = "This is not a molecule. This is a bad attempt at a funny joke."
                }

        Molecule.Bad errors ->
            stringifyDeadends errors
                |> Element.text


viewMolecule : Molecule -> Element Msg
viewMolecule molecule =
    let
        -- view a molecule in HTML
        -- using HTML so I can do subscripts really easily
        viewHtml m =
            case m of
                -- if there's a mono, first check for the MaybeAtom. then display the atom symbol with the quantity as the subscript
                Molecule.Mono maybeAtom quantity ->
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
                Molecule.Poly atomList quantity ->
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

                Molecule.Hydrate amount ->
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


-- my own thing that converts all the errors / deadends the parser accumulates into a string, using the Elm DeadEnd type (https://package.elm-lang.org/packages/elm/parser/latest/Parser#DeadEnd) I use filterMap because I only want my own errors I wrote out - not the others. Those are represented in the Problem thing.


stringifyDeadends : List DeadEnd -> String
stringifyDeadends deadends =
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

---- UPDATE


type Msg
    = NavigateTo Route
    | UpdateMoleculeParser String


update : SharedState -> Msg -> Model -> ( Model, Cmd Msg )
update sharedState msg model =
    case msg of
        NavigateTo route ->
            ( model, SharedState.navigateTo route sharedState )

        UpdateMoleculeParser text ->
            ( { model
                | inputMoleculeString = text
                , inputMolecule = Molecule.fromString sharedState.ptable text
                , selectedAtoms = Molecule.toAtomList sharedState.ptable (Molecule.fromString sharedState.ptable text)
              }
            , Cmd.none
            )



---- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
