module Page.Home exposing 
    (Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )


import Data.Molecule as Molecule exposing (MaybeMolecule)
import Data.Atom as Atom exposing (Atom)
import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font 
import Element.Input as Input 
import Colours
import Routes exposing (Route)
import Element.Border as Border
import Round
import SharedState exposing (SharedState)
import Data.PeriodicTable as PeriodicTable
import Element.Events as Events
import SharedState exposing (SharedState)

---- MODEL
type alias Model = 
    { inputMoleculeString : String
    , inputMolecule : MaybeMolecule
    , selectedAtoms : List Atom
    }

init : SharedState -> Model
init sharedState = 
    let
        moleculeStr = "CuSO4 5H2O"
    in
    
    { inputMoleculeString = moleculeStr
    , inputMolecule = Molecule.fromString sharedState.ptable moleculeStr
    , selectedAtoms = []
    }


---- VIEW 

-- Add legend???
{-|
legend : Model -> Element Msg
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
    let
        -- stringify molar mass
        stringifyMolarMass maybeMass =
            maybeMass
                -- the `round` function rounds the number and also converts it into a string
                |> Maybe.map (Round.round 3)
                |> Maybe.withDefault "0.000"

        molarMassString maybeMolecule =
            case maybeMolecule of
                Molecule.GoodMolecule molecule ->
                    Molecule.molarMass molecule
                        |> stringifyMolarMass

                _ ->
                    "0.000"

        displayedMolarMass =
            (molarMassString model.inputMolecule ++ " g/mol")
                |> Element.text
                |> Element.el
                    [ Element.centerX
                    , Font.color Colours.fontColour
                    , Font.size 30
                    ]

        -- the molecule which is displayed all fancy with the subscripts and stuff
        displayedCompound =
            Molecule.viewMaybe model.inputMolecule
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
        [ Element.spacing 30
        , Element.centerX
        , Element.paddingXY 12 16
        ]
        [ periodicTable ss model 
        , compoundInput
        , displayedCompound
        , displayedMolarMass 
        ]



periodicTable : SharedState -> Model -> Element Msg
periodicTable ss model =
    let
        -- display a single column of the periodic table
        viewGroup ptableElems group  =
            PeriodicTable.getCol group ptableElems
                |> (List.map <| viewPTableElem model)
                |> Element.column
                    [ Element.alignBottom
                    , Element.spacing 10
                    ]
        
        (upper, lower) = PeriodicTable.splitUpperLower ss.ptable

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
                    , Events.onClick (NavigateTo <| Routes.Atom atom.name)
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



---- UPDATE



type Msg
    = NavigateTo Route 
    | UpdateMoleculeParser String


update : SharedState -> Msg -> Model -> ( Model, Cmd Msg )
update sharedState msg model =
    case msg of
        NavigateTo route ->
            ( model, SharedState.navigateTo route sharedState)

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