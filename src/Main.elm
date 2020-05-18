module Main exposing (..)

import Array exposing (Array)
import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Gamepad.Ports exposing (..)
import Svg exposing (Svg)
import Svg.Attributes


main =
    Browser.document
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


type alias Model =
    { gamepads : List StandardGamepad
    }


type Msg
    = OnGamepadConnect StandardGamepad
    | OnGamepadDisconnect StandardGamepad
    | OnGamepadUpdate (List StandardGamepad)


init : () -> ( Model, Cmd Msg )
init _ =
    ( { gamepads = []
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ onStandardGamepadConnect OnGamepadConnect
        , onStandardGamepadDisconnect OnGamepadDisconnect
        , onStandardGamepadUpdate OnGamepadUpdate
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnGamepadConnect gamepad ->
            ( { model
                | gamepads = gamepad :: model.gamepads
              }
            , Gamepad.Ports.registerGamepadListener gamepad.index
            )

        OnGamepadDisconnect gamepad ->
            ( { model
                | gamepads =
                    List.filter
                        (\g -> g.index == gamepad.index)
                        model.gamepads
              }
            , Gamepad.Ports.unregisterGamepadListener gamepad.index
            )

        OnGamepadUpdate gamepads ->
            ( { model | gamepads = gamepads }
            , Cmd.none
            )


view : Model -> Browser.Document Msg
view model =
    { title = "gamepad-test"
    , body =
        [ layout [] <|
            case List.head model.gamepads of
                Just gamepad ->
                    let
                        gamepads =
                            toGamepadLabelsAndValues gamepad
                    in
                    table [ centerX, centerY, spacing 4 ]
                        { data = gamepads
                        , columns =
                            [ { header = none
                              , width = fill
                              , view = \r -> el [ Font.alignRight, width fill ] r.label
                              }
                            , { header = none
                              , width = fill
                              , view = .value
                              }
                            ]
                        }

                Nothing ->
                    el [ centerX, centerY ] <|
                        text "No Gamepad"
        ]
    }


toGamepadLabelsAndValues :
    StandardGamepad
    ->
        List
            { label : Element Msg
            , value : Element Msg
            }
toGamepadLabelsAndValues gamepad =
    List.map (\( a, b ) -> { label = a, value = b })
        [ ( text "id = "
          , text <| gamepad.id
          )
        , ( text "index = "
          , text <| String.fromInt gamepad.index
          )
        , ( text "mapping = "
          , text <| gamepad.mapping
          )
        , ( text "timestamp = "
          , text <| String.fromFloat gamepad.timestamp
          )
        , ( text "sticks = "
          , row []
                [ stickToSvg gamepad.sticks.left
                , stickToSvg gamepad.sticks.right
                ]
          )
        , ( text "buttons.a = "
          , text <| boolToString gamepad.buttons.a
          )
        , ( text "buttons.b = "
          , text <| boolToString gamepad.buttons.b
          )
        , ( text "buttons.x = "
          , text <| boolToString gamepad.buttons.x
          )
        , ( text "buttons.y = "
          , text <| boolToString gamepad.buttons.y
          )
        , ( text "buttons.start = "
          , text <| boolToString gamepad.buttons.start
          )
        , ( text "buttons.select = "
          , text <| boolToString gamepad.buttons.select
          )
        , ( text "dpad.up = "
          , text <| boolToString gamepad.dpad.up
          )
        , ( text "dpad.down = "
          , text <| boolToString gamepad.dpad.down
          )
        , ( text "dpad.left ="
          , text <| boolToString gamepad.dpad.left
          )
        , ( text "dpad.right = "
          , text <| boolToString gamepad.dpad.right
          )
        , ( text "bumpers.left = "
          , text <| boolToString gamepad.bumpers.left
          )
        , ( text "bumpers.right = "
          , text <| boolToString gamepad.bumpers.right
          )
        , ( text "triggers.left = "
          , text <| String.fromFloat gamepad.triggers.left
          )
        , ( text "triggers.right = "
          , text <| String.fromFloat gamepad.triggers.right
          )
        ]


stickToSvg : Stick -> Element msg
stickToSvg stick =
    let
        size =
            128

        border =
            4

        borderColor =
            if stick.pressed then
                "white"

            else
                "blue"

        bgColor =
            if stick.pressed then
                "blue"

            else
                "transparent"

        ballColor =
            if stick.pressed then
                "white"

            else
                "red"
    in
    elSvg
        [ Svg.Attributes.width <| String.fromFloat size
        , Svg.Attributes.height <| String.fromFloat size
        , Svg.Attributes.viewBox <|
            String.join " "
                [ "0"
                , "0"
                , String.fromFloat size
                , String.fromFloat size
                ]
        ]
    <|
        [ Svg.rect
            [ Svg.Attributes.stroke borderColor
            , Svg.Attributes.strokeWidth "1"
            , Svg.Attributes.fill bgColor
            , Svg.Attributes.x "0"
            , Svg.Attributes.y "0"
            , Svg.Attributes.width <| String.fromFloat size
            , Svg.Attributes.height <| String.fromFloat size
            , Svg.Attributes.rx "8"
            , Svg.Attributes.ry "8"
            ]
            []
        , Svg.circle
            [ Svg.Attributes.fill ballColor
            , Svg.Attributes.cx <|
                String.fromFloat (((size / 2) * stick.x) + (size / 2))
            , Svg.Attributes.cy <|
                String.fromFloat (((size / 2) * stick.y) + (size / 2))
            , Svg.Attributes.r "3"
            ]
            []
        ]


stickToString : Stick -> String
stickToString stick =
    let
        string =
            String.concat
                [ "x:"
                , String.fromFloat stick.x
                , ", y:"
                , String.fromFloat stick.y
                ]
    in
    if stick.pressed then
        String.concat [ "(", string, ")" ]

    else
        string


boolToString : Bool -> String
boolToString bool =
    if bool then
        "True"

    else
        "False"


elSvg : List (Svg.Attribute msg) -> List (Svg msg) -> Element msg
elSvg attrs svgs =
    html <| Svg.svg attrs svgs
