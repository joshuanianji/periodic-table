module SharedState exposing (SharedState, init, navigateTo, updateScreenSize)

import Browser.Navigation as Nav
import Element
import Data.Flags exposing (Flags, WindowSize)
import Routes exposing (Route)
import Data.PeriodicTable exposing (PeriodicTable)

---- DATA 
type alias SharedState = 
    { windowSize : WindowSize
    , device : Element.Device
    , key : Nav.Key 
    , ptable : PeriodicTable
    }


init : Flags -> Nav.Key -> SharedState
init { windowSize, ptable } key =
    { windowSize = windowSize
    , device = Element.classifyDevice windowSize
    , key = key
    , ptable = ptable
    }

---- HELPERS



navigateTo : Route -> SharedState -> Cmd msg
navigateTo route sharedState =
    Routes.navigateTo sharedState.key route

updateScreenSize : WindowSize -> SharedState -> SharedState
updateScreenSize windowSize sharedState =
    { sharedState | windowSize = windowSize }