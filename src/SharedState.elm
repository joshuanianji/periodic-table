module SharedState exposing (SharedState, init, navigateTo, updateScreenSize)

import Browser.Navigation as Nav
import Data.Flags exposing (Flags, WindowSize)
import Data.PeriodicTable exposing (PeriodicTable)
import Element
import Routes exposing (Route)



---- DATA


type alias SharedState =
    { windowSize : WindowSize
    , device : Element.Device
    , key : Nav.Key
    , ptable : PeriodicTable
    , sigmaStare : String -- URL location of sigma stare
    }


init : Flags -> Nav.Key -> SharedState
init { windowSize, ptable, sigmaStare } key =
    { windowSize = windowSize
    , device = Element.classifyDevice windowSize
    , key = key
    , ptable = ptable
    , sigmaStare = sigmaStare
    }



---- HELPERS


navigateTo : Route -> SharedState -> Cmd msg
navigateTo route sharedState =
    Routes.navigateTo sharedState.key route


updateScreenSize : WindowSize -> SharedState -> SharedState
updateScreenSize windowSize sharedState =
    { sharedState | windowSize = windowSize }
