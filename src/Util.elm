module Util exposing (find, mapFirst)

find : (a -> Bool) -> List a -> Maybe a
find f =
    List.foldl
        (\y acc ->
            if f y then
                Just y

            else
                acc
        )
        Nothing


mapFirst : (a -> c) -> ( a, b ) -> ( c, b )
mapFirst f ( x, y ) =
    ( f x, y )
