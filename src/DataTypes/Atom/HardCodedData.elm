{-
   I initially wanted to hard code all the data for theHardCodedAtomAliass, but then was like nah, let's use a json file instead. So this was my first data base, which is not finished, but works for the website I have now. Once the database I have is finished I will be able to import the stuff.
-}


module Atom.HardCodedData exposing (fakeData)

import Atom.Atom exposing (..)


fakeData =
    1



{-

   -- listing all the elements and stuff (do I even need this? prolly)


   elementList =
       [ hydrogen
       , helium
       , lithium
       , beryllium
       , boron
       , carbon
       , nitrogen
       , oxygen
       , flourine
       , neon
       , sodium
       , magnesium
       , aluminium
       , silicon
       , phosphorus
       , sulfur
       , chlorine
       , argon
       , potassium
       , calcium
       , scandium
       , titanium
       , vanadium
       , chromium
       ]


   hydrogen : Atom
   hydrogen =
       Atom
           "Hydrogen"
           "H"
           Gas
           Hydrogen
           (Multiple [ 1, -1 ])
           1
           [ 1, 2, 3 ]
           (Position 1 1)
           1.008


   helium : Atom
   helium =
       Atom
           "Helium"
           "He"
           Gas
           NobleGas
           (Singular 0)
           2
           [ 3, 4 ]
           -- 3 and 4 are just the stable ones - there are 9 known isotopes
           (Position 1 18)
           4.003


   lithium : Atom
   lithium =
       Atom
           "Lithium"
           "Li"
           Solid
           Alkali
           (Singular 1)
           3
           [ 6, 7 ]
           (Position 2 1)
           6.941


   beryllium : Atom
   beryllium =
       Atom
           "Beryllium"
           "Be"
           Solid
           AlkalineEarth
           (Singular 2)
           4
           [ 9 ]
           -- Beryllium has one stable isotope
           (Position 2 2)
           9.012


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


   carbon : Atom
   carbon =
       Atom
           "Carbon"
           "C"
           Solid
           NonMetal
           (Singular 0)
           -- since it doesn't usually form ionic bonds I'm going to go with 0 charge
           6
           [ 12, 13, 14 ]
           -- three naturally occuring isotopes
           (Position 2 14)
           12.011


   nitrogen : Atom
   nitrogen =
       Atom
           "Nitrogen"
           "N"
           Gas
           NonMetal
           (Singular -3)
           7
           [ 13, 14, 15 ]
           (Position 2 15)
           14.007


   oxygen : Atom
   oxygen =
       Atom
           "Oxygen"
           "O"
           Gas
           NonMetal
           (Singular -2)
           8
           [ 16, 17, 18 ]
           (Position 2 16)
           16.0


   flourine : Atom
   flourine =
       Atom
           "Flourine"
           "F"
           Gas
           NonMetal
           (Singular -1)
           9
           [ 19 ]
           (Position 2 17)
           18.998


   neon : Atom
   neon =
       Atom
           "Neon"
           "Ne"
           Gas
           NobleGas
           (Singular 0)
           10
           [ 20, 21, 22 ]
           (Position 2 18)
           20.18


   sodium : Atom
   sodium =
       Atom
           "Sodium"
           "Na"
           Solid
           Alkali
           (Singular 1)
           11
           [ 23 ]
           (Position 3 1)
           22.99


   magnesium : Atom
   magnesium =
       Atom
           "Magnesium"
           "Mg"
           Solid
           AlkalineEarth
           (Singular 2)
           12
           [ 24, 25, 26 ]
           (Position 3 2)
           24.305


   aluminium : Atom
   aluminium =
       Atom
           "Aluminium"
           "Al"
           Solid
           Metal
           (Singular 3)
           13
           [ 27 ]
           (Position 3 13)
           26.982


   silicon : Atom
   silicon =
       Atom
           "Silicon"
           "Si"
           Solid
           Transition
           (Singular 0)
           14
           [ 28, 29, 30 ]
           (Position 3 14)
           28.086


   phosphorus : Atom
   phosphorus =
       Atom
           "Phosphorus"
           "P"
           Solid
           NonMetal
           (Singular -3)
           15
           [ 31 ]
           (Position 3 15)
           30.974


   sulfur : Atom
   sulfur =
       Atom
           "Sulfur"
           "S"
           Solid
           NonMetal
           (Singular -2)
           16
           [ 32, 33, 34, 36 ]
           (Position 3 16)
           32.065


   chlorine : Atom
   chlorine =
       Atom
           "Chlorine"
           "Cl"
           Gas
           NonMetal
           (Singular -1)
           17
           [ 35, 37 ]
           (Position 3 17)
           35.453


   argon : Atom
   argon =
       Atom
           "Argon"
           "Ar"
           Gas
           NobleGas
           (Singular 0)
           18
           [ 36, 38, 40 ]
           (Position 3 18)
           39.948


   potassium : Atom
   potassium =
       Atom
           "Potassium"
           "K"
           Solid
           Alkali
           (Singular 1)
           19
           [ 39, 41 ]
           (Position 4 1)
           39.098


   calcium : Atom
   calcium =
       Atom
           "Calcium"
           "Ca"
           Solid
           AlkalineEarth
           (Singular 2)
           20
           [ 42, 43, 44, 46 ]
           (Position 4 2)
           40.078


   scandium : Atom
   scandium =
       Atom
           "Scandium"
           "Sc"
           Solid
           Metal
           (Singular 3)
           21
           [ 45 ]
           (Position 4 3)
           44.956


   titanium : Atom
   titanium =
       Atom
           "Titanium"
           "Ti"
           Solid
           Metal
           (Multiple [ 4, 3 ])
           22
           [ 46, 47, 48, 49, 50 ]
           (Position 4 4)
           47.867


   vanadium : Atom
   vanadium =
       Atom
           "Vanadium"
           "V"
           Solid
           Metal
           (Multiple [ 5, 4 ])
           23
           [ 50, 51 ]
           (Position 4 5)
           50.942


   chromium : Atom
   chromium =
       Atom
           "Chromium"
           "Cr"
           Solid
           Metal
           (Multiple [ 3, 2 ])
           24
           [ 50, 52, 53, 54 ]
           (Position 4 6)
           51.996


-}
