import { Elm } from './src/Main.elm'
import ptable from './assets/elements.json'

// Main entrypoint of the Vite app (I think)

Elm.Main.init({
    node: document.getElementById('elm'),
    flags: {
        ptable: ptable,
        windowSize: {
            height: window.innerHeight,
            width: window.innerWidth
        }
    }
})