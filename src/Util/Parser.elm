module Util.Parser exposing (iToken)

import Parser exposing (Parser, (|.))


-- parse case insensitive
-- https://discourse.elm-lang.org/t/solved-elm-parser-parsing-keyword-in-a-case-insensitive-way/3169/4
iToken : String -> Parser ()
iToken token =
    Parser.backtrackable (Parser.loop token iTokenHelp)


iTokenHelp : String -> Parser (Parser.Step String ())
iTokenHelp chars =
    case String.uncons chars of
        Just ( char, remainingChars ) ->
            Parser.oneOf
                [ Parser.succeed (Parser.Loop remainingChars)
                    |. Parser.chompIf (\c -> Char.toLower c == char)
                -- , Parser.problem ("Expected case insensitive \"" ++ chars ++ "\"")
                -- hide errors, or else "expecting case insensitive amongus" will pollute the error messages
                , Parser.problem ""
                ]

        Nothing ->
            Parser.succeed <| Parser.Done ()
