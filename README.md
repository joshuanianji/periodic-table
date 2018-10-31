# Joshua's Compsci IA

This README is mainly for me to document what I've done so far in this ia so I can write about it later.

## October 31

This is my initial commit, which is pretty late tbh rip.
So right now I'll document what I've done so far.
So far I've made a couple of types, the `Atom` type and `Molecule`. , while the `Molecule` type is a recursive type to make nested plyatomics work.

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