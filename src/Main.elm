module Main exposing (main)

import Browser
import Browser.Events
import Colours
import Data.Atom as Atom exposing (Atom)
import Data.Molecule as Molecule exposing (MaybeMolecule)
import DataBase.DataParser as DataParser
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Round



-- | PROGRAM


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- | MODEL


type alias Model =
    { viewport : ScreenSize
    , directory : Directory
    , selectedAtom : Maybe Atom
    , moleculeData : MoleculeData
    }


type alias ScreenSize =
    { height : Int
    , width : Int
    }



-- molecule parser and whatnot


type alias MoleculeData =
    { inputMoleculeString : String
    , inputMolecule : MaybeMolecule
    , selectedAtoms : List Atom
    }



{-
   This type is my directory, which keeps track of which part of the app the user is on.

   TableAndParserView :: Periodic table and the Molecule parser.
   ZoomAtomView :: Close-up specifications of the atom
-}


type Directory
    = TableAndParserView
    | ZoomAtomView


type alias Flags =
    ScreenSize



-- init


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initModel flags, Cmd.none )


initModel : Flags -> Model
initModel flags =
    { viewport = flags
    , directory = TableAndParserView
    , selectedAtom = Nothing
    , moleculeData = moleculeDataInit
    }



{-
   Although we have a "default" input string to help the user know what's happening, we have nothing in our selectedAtoms list, because we want to keep our periodic table clean and undefiled lol.
-}


moleculeDataInit : MoleculeData
moleculeDataInit =
    { inputMoleculeString = "CuSO4 5H2O"
    , inputMolecule = Molecule.fromString "CuSO4 5H2O"
    , selectedAtoms = []
    }



-- | VIEW


htmlPage : Element Msg -> Html Msg
htmlPage pageElements =
    Element.layoutWith
        { options =
            [ Element.focusStyle
                { borderColor = Nothing
                , backgroundColor = Nothing
                , shadow = Nothing
                }
            ]
        }
        [ Background.color Colours.appBackgroundGray
        , Element.padding 10
        ]
        pageElements


view : Model -> Html Msg
view model =
    htmlPage <|
        case model.directory of
            TableAndParserView ->
                tableAndParserView model

            ZoomAtomView ->
                atomZoomView model



-- table and parser view


tableAndParserView : Model -> Element Msg
tableAndParserView model =
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
            (molarMassString model.moleculeData.inputMolecule ++ " g/mol")
                |> Element.text
                |> Element.el
                    [ Element.centerX
                    , Font.color Colours.fontColour
                    , Font.size 30
                    ]

        -- the molecule which is displayed all fancy with the subscripts and stuff
        displayedCompound =
            Molecule.viewMaybe model.moleculeData.inputMolecule
                -- parserDebugDisplay model.moleculeData.inputMoleculeString
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
                , text = model.moleculeData.inputMoleculeString
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
        ]
        [ periodicTable model
        , compoundInput
        , displayedCompound
        , displayedMolarMass
        ]


periodicTable : Model -> Element Msg
periodicTable model =
    let
        filterAtomsByGroup pTableAtomList atomGroup =
            List.filter
                (\pTableAtom ->
                    case pTableAtom of
                        Atom.PTableAtom atom ->
                            atom.xpos == atomGroup

                        Atom.PTablePlaceholder placeholder ->
                            placeholder.xpos == atomGroup
                )
                pTableAtomList

        styleTableGroups pTableAtomList group =
            filterAtomsByGroup pTableAtomList group
                |> (List.map <| pTableBox model)
                |> Element.column
                    [ Element.alignBottom
                    , Element.spacing 10
                    ]

        -- Upper Periodic Table is the periodic table for all the elements which aren't f block
        upperPeriodicTable =
            let
                -- withoutfBlockElements filters out the f block elements
                withoutfBlockElements pTableAtomList =
                    List.filter
                        (\pTableAtom ->
                            case pTableAtom of
                                Atom.PTableAtom atom ->
                                    not (atom.section == Atom.Lanthanide || atom.section == Atom.Actinide)

                                _ ->
                                    True
                        )
                        pTableAtomList
            in
            List.map
                (DataParser.pTableAtoms
                    |> withoutfBlockElements
                    |> styleTableGroups
                )
                (List.range 1 18)
                |> Element.row
                    [ Element.spacing 2
                    , Element.centerX
                    ]

        lowerPeriodicTable =
            let
                getfBlockElements pTableAtomList =
                    List.filter
                        (\pTableAtom ->
                            case pTableAtom of
                                Atom.PTableAtom atom ->
                                    atom.section == Atom.Lanthanide || atom.section == Atom.Actinide

                                _ ->
                                    False
                        )
                        pTableAtomList
            in
            List.map
                (DataParser.pTableAtoms
                    |> getfBlockElements
                    |> styleTableGroups
                )
                (List.range 3 17)
                |> Element.row
                    [ Element.spacing 2
                    , Element.centerX
                    ]
    in
    Element.column
        [ Element.centerX
        , Element.width Element.fill
        , Element.spacing 10
        , Background.color (Element.rgba 0 0 0 0)
        ]
        [ upperPeriodicTable
        , lowerPeriodicTable
        ]



-- little box in the periodic table


pTableBox : Model -> Atom.PTableAtom -> Element Msg
pTableBox model pTableAtom =
    let
        borderWidths =
            { bottom = 2
            , left = 0
            , right = 0
            , top = 0
            }
    in
    case pTableAtom of
        Atom.PTableAtom atom ->
            let
                attributes =
                    [ Element.width (Element.px 70)
                    , Element.padding 10
                    , Font.color Colours.fontColour
                    , Border.widthEach borderWidths
                    , Border.color (Colours.sectionColour atom.section)
                    , Element.pointer
                    , Events.onClick (ZoomAtom atom)
                    , Element.spacing 2
                    ]
                        |> (::)
                            (if List.member atom model.moleculeData.selectedAtoms then
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

        Atom.PTablePlaceholder placeholder ->
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



-- atom zoom view


atomZoomView : Model -> Element Msg
atomZoomView model =
    let
        closeButton =
            Element.el
                [ Element.width Element.shrink
                , Element.height Element.shrink
                , Font.size 40
                , Element.alignTop
                , Element.alignRight
                , Element.padding 20
                , Font.color Colours.fontColour
                , Events.onClick UnZoomAtom
                , Element.pointer
                , Font.center
                ]
                (Element.text "×")
    in
    Element.column
        [ Element.width Element.fill
        , Element.height Element.fill
        , Font.color Colours.fontColour
        ]
        [ closeButton
        , atomZoomContent model
        ]


atomZoomContent : Model -> Element Msg
atomZoomContent model =
    let
        atom =
            case model.selectedAtom of
                Just a ->
                    a

                Nothing ->
                    -- this shouldn't happen!
                    Atom.errorAtom

        atomBoxZoom =
            let
                atomSymbol =
                    Element.el
                        [ Element.centerX
                        , Font.size 150
                        , Font.bold
                        , Font.color (Colours.stateColour atom.state)
                        ]
                        (Element.text atom.symbol)

                atomName =
                    Element.el
                        [ Element.centerX
                        , Font.size 50
                        ]
                        (Element.text atom.name)

                atomNum =
                    Element.el
                        [ Element.centerX
                        , Font.size 40
                        ]
                        (Element.text <| String.fromInt <| atom.protons)

                atomWeight =
                    Element.el
                        [ Element.centerX
                        , Font.size 30
                        ]
                        (Element.text <| atom.weight)

                atomShells =
                    Element.column
                        [ Element.alignTop
                        , Element.alignRight
                        , Font.size 20
                        , Element.padding 10
                        ]
                        (List.map
                            (\x ->
                                x
                                    |> String.fromInt
                                    |> Element.text
                                    |> Element.el []
                            )
                            atom.electronShells
                        )
            in
            Element.column
                [ Element.width (Element.px 350)
                , Element.spacing 10
                , Element.padding 50
                , Background.color Colours.atomBoxBackground
                , Element.inFront atomShells
                ]
                [ atomNum
                , atomSymbol
                , atomName
                , atomWeight
                ]

        extraInfo =
            Element.column
                [ Element.width Element.fill
                , Element.height Element.fill
                , Element.spacing 20
                ]
                [ Element.paragraph []
                    [ Element.el [ Font.bold ] (Element.text "Discovered by: ")
                    , Element.el [ Font.light ] (Element.text atom.discoveredBy)
                    ]
                , Element.paragraph []
                    [ Element.el [ Font.bold ] (Element.text "Named by: ")
                    , Element.el [ Font.light ] (Element.text atom.namedBy)
                    ]

                -- info about when it boils, whe it melts, etc. I made it colourful so its a lot of code lol
                , Element.column
                    [ Element.width Element.fill ]
                    [ Element.paragraph []
                        [ Element.el [ Font.bold, Font.color Colours.liquidState ] (Element.text "Melting")
                        , Element.el [] (Element.text " / ")
                        , Element.el [ Font.bold, Font.color Colours.solidState ] (Element.text "Freezing")
                        , Element.el [ Font.bold ] (Element.text " point: ")
                        , Element.el
                            [ Font.light ]
                            (atom.phaseChanges.melt
                                |> Maybe.map String.fromFloat
                                -- `Maybe float` to `Maybe String` via Maybe.map function
                                |> Maybe.map (\x -> x ++ "K")
                                -- if the x is a valid value add "K" to the end. Using map again
                                |> Maybe.withDefault "none"
                                -- `Maybe String -> String` : if its Nothing use "none"
                                |> Element.text
                             -- pipe the value into the text function
                            )
                        ]
                    , Element.paragraph []
                        [ Element.el [ Font.bold, Font.color Colours.gaseousState ] (Element.text "Boiling")
                        , Element.el [] (Element.text " / ")
                        , Element.el [ Font.bold, Font.color Colours.liquidState ] (Element.text "Condensation")
                        , Element.el [ Font.bold ] (Element.text " point: ")
                        , Element.el
                            [ Font.light ]
                            (atom.phaseChanges.boil
                                |> Maybe.map String.fromFloat
                                |> Maybe.map (\x -> x ++ "K")
                                |> Maybe.withDefault "none"
                                |> Element.text
                            )
                        ]
                    ]
                , Element.paragraph [ Font.light ] [ Element.text atom.summary ]
                , Element.newTabLink
                    [ Font.color Colours.linkColour ]
                    { url = atom.wikiLink
                    , label = Element.text "Read More"
                    }
                ]
    in
    Element.row
        [ Element.spacing 50
        , Element.width (Element.maximum 1080 Element.fill)
        , Element.centerX
        , Element.centerY
        ]
        [ atomBoxZoom
        , extraInfo
        ]



-- TODO: LEGEND


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



-- | UPDATE


type Msg
    = WindowResize ScreenSize
    | ZoomAtom Atom
    | UnZoomAtom
    | UpdateMoleculeParser String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WindowResize windowSize ->
            ( { model | viewport = windowSize }, Cmd.none )

        ZoomAtom atom ->
            ( { model | selectedAtom = Just atom, directory = ZoomAtomView }, Cmd.none )

        UnZoomAtom ->
            ( { model | selectedAtom = Nothing, directory = TableAndParserView }, Cmd.none )

        UpdateMoleculeParser text ->
            -- updating a nested type alias
            let
                c =
                    model.moleculeData
            in
            ( { model
                | moleculeData =
                    { c
                        | inputMoleculeString = text
                        , inputMolecule = Molecule.fromString text
                        , selectedAtoms = Molecule.toAtomList (Molecule.fromString text)
                    }
              }
            , Cmd.none
            )



-- | SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onResize
        (\x y -> WindowResize (ScreenSize x y))
