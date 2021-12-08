#!/bin/sh

# https://guide.elm-lang.org/optimization/asset_size.html
# Use as: ./optimize.sh src/Main.elm

set -e

js="public/elm.js"
min="public/elm.min.js"

elm make --optimize --output=$js "$@"

uglifyjs $js --compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output $min

echo "Compiled size:$(wc -c < $js) bytes  ($js)"
echo "Minified size:$(wc -c < $min) bytes  ($min)"
echo "Gzipped size: $(gzip $min -c | wc -c) bytes"