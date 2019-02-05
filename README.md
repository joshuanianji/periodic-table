# Joshua's Compsci IA

This README is mainly for me to document what I've done so far in this ia so I can write about it later.

# Changelog:


## February 5 - ZoomAtom

Clicking the atom to reveal a more detailed page of the atom was a design from the start, but I wanted them to stay on the same page, and maybe just overlay the more detailed `Element Msg` **on top** of the periodic table. I decided not to do that, and instead directed the user to another page, or another view function entirely. 

To do this, I made each `atomBox` have a onClick function that passed the `ZoomAtom` function from our [Msg](Msg.elm) module. This ZoomAtom function carries with it an Atom, so it can bring what atom was clicked into the update function.

```elm
-- (Msg.elm)            ZoomAtom is a Msg type that carries an Atom with it 
type Msg
    = ZoomAtom Atom
    | ...


-- (Atom/AtomBox.elm)   inside the atomBox function, I remember to include the Atom with the ZoomAtom. 
atomBox : Atom -> Element Msg
atomBox atom =
    column
        [ ...
        , onClick (ZoomAtom atom)
        ]
        [...]

-- (Update.elm)         the update function uses the atom the ZoomAtom carries.
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ZoomAtom atom ->
            ( { model | selectedAtom = Just atom, directory = ZoomAtomView }, Cmd.none )
        ...
```
I also changed the model and the Directory type in [Model.elm](Model.elm) so it can help the update function.
```elm
-- (Model.elm)
type alias Model =
    { directory : Directory
    , selectedAtom : Maybe Atom
    }

type Directory
    = TableAndParserView
    | ZoomAtomView
```
When the update function receives the ZoomAtom message, it changes the `model.selectedAtom` to the atom the ZoomAtom carried (it uses the `Just` keyword because i made it a `Maybe Atom`). It also changes the Directory to the ZoomAtomView.

Before, the Directory type was only the `TableAndParserView`, but now I added the ZoomAtomView. 
I also only have `selectedAtom` and `directory` as records in my type alias in my model, so why not change it all up like this?
```elm
-- (new and improved Update.elm??)
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ZoomAtom atom ->
            ( Model 
                (Just atom) 
                ZoomAtomView
            , Cmd.none )
```
Well it won't scale lol.

Anyways now that we can go *to* the zoom page, we need to actually display it. I just copy and pasted my atomBox function from [Atom/AtomBox.elm](src/Atom/AtomBox.elm) and made it 5x bigger to make my new and improved atomZoomBox!!! You can find it inside [AtomBoxZoom.elm](src/View/TableAndParser/AtomBoxZoom.elm), and I should prolly modulate it better, but the point is that i didn't do much for the zoom view. I need to add more details, but that goes later! I just want everything working for now!

Since I'm making a completely different view for when the user zooms upon an atom, an atomZoomBox will not suffice. We need a full screen page with an 'x' to close the zoom view. This is a lot easier than you may anticipate.

I made [AtomZoomView.elm](src/View/AtomZoomView.elm) that will hold our full screen page. It is, in its essence, an `Element.column` that holds the 'x' button on the upper right and our zoomBox in the middle (centered vertically and horizontally).
```elm
atomZoomView : Model -> Element Msg
atomZoomView model =
    column
        [ width fill
        , height fill
        ]
        [ closeButton
        , atomZoomThingy model.selectedAtom
        ]
```
I didn't use the actual atomZoomBox, because I had to use a wrapper. Our atomZoomBox as seen in [AtomBoxZoom.elm](src/View/TableAndParser/AtomBoxZoom.elm) has a type signature of `atomBoxZoom : Atom -> Element Msg`. This creates a problem, as our `model.selectedAtom`, as seen previously, has a type signature of `Maybe Atom`! Although `model.selectedAtom` will never be `Nothing` in this case, we must handle the exception because elm is a strong-typed language lol.
My wrapper looks like this:
```elm
-- atomBoxZoom view wrapper: atomZoomThingy for a lack of better name. Has to take in a Maybe Atom because that's what the Model has. If there is no atom, just output the errorAtom


atomZoomThingy : Maybe Atom -> Element Msg
atomZoomThingy maybeAtom =
    el
        [ centerX, centerY ]
    <|
        case maybeAtom of
            Just atom ->
                atomBoxZoom atom

            Nothing ->
                -- this shouldn't happen!
                atomBoxZoom errorAtom
```
Lol i had no idea what to call it so I just went with `atomZoomThingy` kekkkk. Anyways I also imported the errorAtom from [ParserTest.elm](src/DataBase/ParserTest.elm), you should go check it out its pretty sick lol. Tbh i should probably change that, i shouldn't import it from a **test** module lol.

Anyways, our thing works! I used a unicode 'x' to make the exit button ("×"), but now we need to make the button work.

I'm too lazy to actually code in the button, so I just made the exit "button" an `Element.el` with the `pointer : Attribute Msg` in its attributes so the mouse will be a pointer when it hovers over top of it. Probably a bad idea tbh.

```elm
-- close button.


closeButton : Element Msg
closeButton =
    el
        [ width shrink
        , height shrink
        , Font.size 40
        , alignTop
        , alignRight
        , padding 20
        , Font.color Colours.fontColour
        , onClick UnZoomAtom
        -- so the mouse will be a pointer! : ' )
        , pointer
        , Font.center
        ]
        (text "×")
```
Boom now we also have a close button and if you check out [Msg.elm](src/Msg.elm) you can see that `UnZoomAtom` basically does the opposite of `ZoomAtom`. It makes `model.selectedAtom = Nothing` and `model.directory = TableAndParserView`. And it works!

To check out how the [view]((src/View.elm)) function handles it, it just looks at `model.directory` using case analysis and returns the appropriate view function.

## February 2 - Rearranging of the files

I need to start thinking of expanding my app. Right now I only have a main function that is an `Html Msg` type, and if I want to render clicks and other stuff, as well as handle multiple pages, I'll need to use a full on model - view - update architecture. I also made a View folder where I put my [TableParserView.elm](View/TableAndParser/TableParserView.elm) where it holds the view for the periodic table and the molecule parser, but not the logic behind it. I also made a bunch of new files for the model-view-update architecture, but visually I haven't changed anything yet.

I also added a bunch of comments on the [Model](src/Model.elm), [Update](src/Update.elm), [Msg](src/Msg.elm) and [View](src/View.elm) files so wow I'm such a good programmer ree.

## November 7 - Colours.elm is in /src folder

Moved [Colours.elm](src/Colours.elm) to /src folder (used to be in /src/Atom).
Also changed [elm.json](elm.json) to not include all subdirectories in `source-directories`. Now in [Main.elm](Main.elm) I'll have to type in `import Molecule.MoleculeDisplay exposing (..)` instead of `import MoleculeDisplay exposing (..)`.

## November 5 - My Parser fails!

My parser code for an Atom looks like this:

```elm
atom : Parser String
atom =
    succeed ()
        |. chompIf isCapital
        |. chompIf isLower
        |> getChompedString
```

So I just returns the string of the first element symbol. It works for strings like "MgBr2" (it returns "Mg") but for single letter atoms like "CS2" it gets messed up rip. I thought `chompIf` wouldn't return errors but I guess it does. Welp.

## October 31 - Parsing??

Holy crap my parser thing is starting to work I can parse retrieve the symbol of one atom from the string "MgBr2" (it outputs Mg) and I could easily do it from a while loop and Char.isUpper and stuff but I don't care cuz I'm so confused right now and I think this is the starting block to get things done.

I dont really know what's happening right now I'm just following this talk called ["Demystifying Parsers"](https://youtu.be/M9ulswr1z0E) by Tereza Sokol and I'm kinda just copying and pasting her code and failing. Wow I do not understand parsing at all.

## October 30 - First Commit

This is my initial commit, which is pretty late tbh rip.
So right now I'll document what I've done so far.
So far I've made a couple of types, the `Atom` type and `Molecule`. , while the `Molecule` type is a recursive type to make nested plyatomics work.

I've also parsed a JSON file containing the information for my periodic table, created my HTML periodic table (with the help of [Elm Ui](https://github.com/mdgriffith/elm-ui/tree/1.1.0)) and was able to correctly display my Molecule with subscripts and stuff in Html given the data tree.

I've started to work on parsing molecules (get a text, for example "Ba(SO4)2" and output the data tree) but it'll take a while.

### `Atom` Type

The `Atom` type is just a type alias.

```elm
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
```

The `Isoptopes` type, `Section` type as well as the other types I've defined myself are all inside the [Atom.elm file](src/Atom/Atom.elm).

#### Other Modules inside the Atom Folder

Inside the Atom Folder, I also have the [AtomBox.elm](src/Atom/AtomBox.elm) file to hold the `atomBox` function, that is a function that takes in an `Atom` and outputs an `Element msg` that's just the box that holds the element stuff in the periodic table.

The [Colours.elm](src/Atom/Colours.elm) is a module which I honestly think does not belong in the Atom folder. It is just a module which holds a bunch of my defined `Color` types (Color is a module defined by elm-ui). FOr example, `appBackgroundGray`, which is a `Color` that defines the background colour of my entire website/app, is defined as follows:

```elm
appBackgroundGray : Color
appBackgroundGray =
    rgb255 51 51 61
```

The [HardCodedData.elm](src/Atom/HardCodedData.elm) is a module I initially tried to make to define all the atoms in the periodic table. I actually got like 24 atoms down before I realized that I could just import a JSON and parse it so I just did that lmao. I'm still keeping it here for the lols.

I actually made Caleb hard code some of the atoms. Since Atom is a type alias and a function, an example of defining an atom will be:

```elm
boron : Atom
boron =
    Atom
        "Boron"
        "B"
        Solid
        Transition
        (Singular 0)
        -- boron doesn't usually have charges - I'm only doing charges for ionic compounds stuff lol
        5
        [ 10, 11 ]
        (Position 2 13)
        10.811
```

### `Molecule` Type

The Molecule type is defined partially recursively to allow for polyatomics and nested molecules.
`Mono` is to define atomic structures with only one atom, such as S<sub>8</sub>, while Poly is used to define literally anything else, such as Ba(SO<sub>4</sub>)<sub>2</sub>.

The first argument to the Mono and poly are the atoms, and the Integer after is to represent the amount.

```elm
type Compound
    = Mono (Maybe Atom) Int
    | Poly (List Compound) Int
```

To see this code in action, we first have to define how we actually get our Atoms. Pur `atomList` function in our [DataParser.elm](src/DataBase.DataParser.elm) file is only a list of the Atom type aliases, without any tags or anything, unlike dictionary - but maybe I'll make a dictionary as it also has a O(logn) time complexity for retrieving elements. Because of this, we have to search through the list linearly with my `retrieveAtom` fucntion (`String -> Maybe Atom`) that takes in the element name and outputs a maybe element. This is also defined in the [DataParser.elm](src/DataBase.DataParser.elm) file.

Examples of this is seen in the [HardCodedMolecules.elm](src/DataBase.HardCodedMolecules.elm) file, or in the many comments in my [Molecule.elm](src/DataBase.Molecule.elm) file. I'll still talk about it here though haha.

```elm
{-| Ba(SO4)2 -}
bariumSulfate =
    Poly
        [ Mono (retrieveAtom "Barium") 1
        , Poly
            [ Mono (retrieveAtom "Sulfur") 1
            , Mono (retrieveAtom "Oxygen") 4
            ]
            2
        ]
        1
```

#### HardCodedMolecules

This is just a collection of molecules and polyatomic ions that I'll make a database of. For polyatomic ions I'll probably have to make a new type that specifies the charge as well, such as

```elm
type PolyAtomic
    = PolyAtomic Compound Int



-- example:


sulfate : PolyAtomic
sulfate =
    PolyAtomic
        Poly
        [ Mono (retrieveAtom "Sulfur") 1
        , Mono (retrieveAtom "Oxygen") 4
        ]
        2
        -2
```

I haven't implemented this though lol.

#### MoleculeDisplay

This is to display the Compound type tree into an html thing that can be like Ba(SO<sub>4</sub>)<sub>2</sub>, with all the subscripts and stuff.

So I initially wanted to use elm-ui but i couldn't find any elm-ui thing for the HTML subscript tag, so I just used the elm core library's `Html.sub : Html msg` to use subs, then converted it to the elm ui's `Element msg` type with the `Element.html` function defined in elm-ui. I converted it to `Element msg` because it'll be easier to style and stuff with my predefined style sets (basically non-existence except for the things in my [Colours.elm](src/Atom/Colours.elm) file)

Ok so this is probably confusing. So basically elm-ui doesn't have `<sub>` as far as I know, so I used `Html.sub` which has a type of `Html msg`. This was how I built my `moleculeTextHtml` function, which has a type signature of `Compound -> Html msg`. I also used a lot of case statements to build that function because of the Maybe Atom and how I don't display the quantity of the atom if it's 1, so hopefully I can use the knowledge I gained from that monad video on computerphile and shorten my code form that lmao. But I still am pretty lost to what a monad is and how it works so whatever.

This is bad because I use things with `Element msg` types to build my app. So I have to convert `Html msg` to `Element msg`, which is convenient from elm-ui's `Element.html` function. `moleculeText` is then just the converted `moleculeTextHtml`, which has a type signature of `Compound -> Element msg`

So that's all fine and dandy, but this is only the text, defined by html span tags. I want to make this nice! So I just made `moleculeDisplay` that wraps the `moleculeTextHtml` in an `Element.el` function, which is basically the equivalent of an html `<div>`, which allows me to style it accordingly. So yay that looks nice!

### JSON Parser and stuff

Time to talk about my JSON parser! If you're wondering this post is ordered chronologically, so the earliest things I've done so far at the top, to help the readers. The actual posts themselves will be ordered with the newest at the top, though.

Anyways JSON parsers were a wild ride, wow. I found a massive JSON file of atoms and their data and just copied and pasted the text from that into `atomData` inside the [AtomJson.elm](src/Database/AtomJson.elm) file.
Initially I wanted to just import the JSON file into an elm file as a string and then parse it, but I had no idea how to do that. All the online tutorials have fancy http requests and hosting the database on your computer or something, but this data is static and need not to be hosted. I just copied and pasted the data into an elm file lol because I literally wasn't able to find any way to import JSON file contents to an elm file.

Anyways the [DataParser.elm](src/Database/DataParser.elm) is where the juicy stuff happens. Using the magic of the internat and copy and paste, I was able to finish the parser in like 3 days which is surprising cuz I had almost no idea what I was doing lmao.

Anyways it works and I think it's pretty neat. I also believe doing that gives me some more base knowledge and practice with decoders for my parser (More info below!! It'll be very disappointing though cuz spoiler alert I've literally done nothing for my parser so far).

What I did was basically map my Atom decoder through the JSON list of obejcts with with Decode.list function.

```elm
-- atom decoder!!

atomDecoder : Decoder Atom
atomDecoder =
    Decode.succeed Atom
        |> required "name" Decode.string
        |> required "symbol" Decode.string
        -- `null` decodes to `Nothing`
        |> required "phase" stateDecoder
        |> required "category" sectionDecoder
        |> hardcoded (Multiple [ 1, -1 ])
        |> required "number" Decode.int
        |> hardcoded [ 1, 2, 3 ]
        |> required "xpos" Decode.int
        |> required "ypos" Decode.int
        |> required "atomic_mass" weightDecoder


{-|

I'm pretty sure decode.list just maps the decoder through the JSON list lmao. After that I just used my removeResult function but don't worry it's just a miscellaneous function with a type signature of:
Result Decode.Error (List Atom) -> (List Atom)
Since Decode.DecodeString normally outputs a Result Decode.Error (List Atom).

So it removes the Result Decode.Error part from the list

-}
atomList : List Atom
atomList =
    Decode.decodeString
        (Decode.list atomDecoder)
        AtomJson.atomData
        |> removeResult
```

Heyyyy that's petty good. `atomList` is now a list of Atoms which I'll import into a lot of other files.

### Displaying the Periodic Table

So now that I have the list of atoms, I have to display the periodic table!

My thinking is to have 18 columns, for the 18 groups, and just add the elements to those 18 groups. Below are the lanthanides and actinides.

I first have a function that can filter elements in the atomList based on their group, called `filterAtomGroup : List Atom -> Int -> List Atom`. The JSON has an xpos and ypos so I just looked at the xpos.

I also have two functions that filters the atomList to leave out and only leave the lanthanides and actinides to put them in later.

I also have a fucntion called boxAtoms `boxAtoms : List Atom -> List (Element msg)` that takes in a list of atims and puts the atomBox around each one.

Combining them, I got a function called `pTableGroup : List Atom -> Int -> Element msg` that takes in a list of atoms (esp. from the same group) and returns clean Element msg that is basically a periodic table column.

`upperPeriodicTableList : List (Element msg)` is basically an 18 element list of the pTableGroup. I use this list to create the actual "upper periodic table" (upperPeriodicTable : Element msg) that has the correct spacing and styling.

`lowerPeriodicTable : Element msg` follows the same concept, and I then use `Element.column` to put the upper and lost periodic table on top of each other and make that `periodicTable : Element msg`. Exporting that to the [Main.elm](src/Main.elm), I have the periodic table!

#### Molecule Parser

So now that I have all my types ready, I wanted to make a parser for my Molecule. This will take in a string, such as "Ba(SO4)2", and output:

```elm
bariumSulfate =
    Poly
        [ Mono (retrieveAtom "Barium") 1
        , Poly
            [ Mono (retrieveAtom "Sulfur") 1
            , Mono (retrieveAtom "Oxygen") 4
            ]
            2
        ]
        1
```

I've just recently started and honestly it doens't seem that hard since the Elm parser's really good.