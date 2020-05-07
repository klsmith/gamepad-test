module Main exposing (..)

import Browser exposing (Document)
import Dict exposing (Dict)
import Element exposing (..)
import Gamepad exposing (Gamepad)
import Gamepad.Advanced
import Gamepad.Simple exposing (FrameStuff)
import GamepadPort
import Html
import Math.Vector2 as Vec2 exposing (Vec2, vec2)



-- main


main =
    Gamepad.Simple.document
        { onAnimationFrame = OnAnimationFrame
        , onBlob = GamepadPort.onBlob
        , saveToLocalStorage = GamepadPort.saveToLocalStorage
        , controls = []
        }
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- init


init : () -> ( Model, Cmd Msg )
init _ =
    ( Starting
    , Cmd.none
    )



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- types


type Model
    = Starting
    | Running FrameStuff


type Msg
    = OnAnimationFrame Gamepad.Simple.FrameStuff



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnAnimationFrame frameStuff ->
            ( Running frameStuff
            , Cmd.none
            )



-- view


view : Model -> Document Msg
view model =
    { title = "gamepad-test"
    , body =
        [ Element.layout [] <|
            viewElements model
        ]
    }


viewElements : Model -> Element Msg
viewElements model =
    case model of
        Starting ->
            text "Starting..."

        Running frameStuff ->
            el [] <|
                column
                    [ maxWidth 640 ]
                    [ paragraph []
                        [ text <|
                            Debug.toString frameStuff
                        ]
                    , text "BRUH"
                    ]


maxWidth : Int -> Attribute msg
maxWidth value =
    width (maximum value fill)
