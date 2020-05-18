port module Gamepad.Ports exposing (StandardGamepad, Stick, onStandardGamepadConnect, onStandardGamepadDisconnect, onStandardGamepadUpdate, registerGamepadListener, unregisterGamepadListener)

import Array exposing (Array)



-- PRIVATE RAW STUFF


type alias RawGamepad =
    { axes : List Float
    , buttons : List RawButton
    , id : String
    , index : Int
    , mapping : String
    , timestamp : Float
    }


type alias RawButton =
    { pressed : Bool
    , value : Float
    }


port onGamepadConnect : (RawGamepad -> msg) -> Sub msg


port onGamepadDisconnect : (RawGamepad -> msg) -> Sub msg


port onGamepadUpdate : (List RawGamepad -> msg) -> Sub msg



-- PUBLIC EXPOSED STUFF


type alias StandardGamepad =
    { id : String
    , index : Int
    , mapping : String
    , timestamp : Float
    , sticks :
        { left : Stick
        , right : Stick
        }
    , buttons :
        { a : Bool
        , b : Bool
        , x : Bool
        , y : Bool
        , start : Bool
        , select : Bool
        }
    , dpad :
        { up : Bool
        , down : Bool
        , left : Bool
        , right : Bool
        }
    , bumpers :
        { left : Bool
        , right : Bool
        }
    , triggers :
        { left : Float
        , right : Float
        }
    }


type alias Stick =
    { x : Float, y : Float, pressed : Bool }


onStandardGamepadConnect : (StandardGamepad -> msg) -> Sub msg
onStandardGamepadConnect handler =
    onGamepadConnect (\raw -> handler (toStandardGamepad raw))


toStandardGamepad : RawGamepad -> StandardGamepad
toStandardGamepad raw =
    let
        axes =
            Array.fromList raw.axes

        buttons =
            Array.fromList raw.buttons
    in
    { id = raw.id
    , index = raw.index
    , mapping = raw.mapping
    , timestamp = raw.timestamp
    , sticks =
        { left =
            { x = getAxis 0 axes
            , y = getAxis 1 axes
            , pressed = getButtonPressed 10 buttons
            }
        , right =
            { x = getAxis 2 axes
            , y = getAxis 3 axes
            , pressed = getButtonPressed 11 buttons
            }
        }
    , buttons =
        { a = getButtonPressed 0 buttons
        , b = getButtonPressed 1 buttons
        , x = getButtonPressed 2 buttons
        , y = getButtonPressed 3 buttons
        , select = getButtonPressed 8 buttons
        , start = getButtonPressed 9 buttons
        }
    , dpad =
        { up = getButtonPressed 12 buttons
        , down = getButtonPressed 13 buttons
        , left = getButtonPressed 14 buttons
        , right = getButtonPressed 15 buttons
        }
    , bumpers =
        { left = getButtonPressed 4 buttons
        , right = getButtonPressed 5 buttons
        }
    , triggers =
        { left = getTriggerValue 6 buttons
        , right = getTriggerValue 7 buttons
        }
    }


getAxis : Int -> Array Float -> Float
getAxis index axes =
    Array.get index axes
        |> Maybe.withDefault 0


getButtonPressed : Int -> Array RawButton -> Bool
getButtonPressed index buttons =
    Array.get index buttons
        |> Maybe.map .pressed
        |> Maybe.withDefault False


getTriggerValue : Int -> Array RawButton -> Float
getTriggerValue index buttons =
    Array.get index buttons
        |> Maybe.map .value
        |> Maybe.withDefault 0


onStandardGamepadDisconnect : (StandardGamepad -> msg) -> Sub msg
onStandardGamepadDisconnect handler =
    onGamepadDisconnect (\raw -> handler (toStandardGamepad raw))


onStandardGamepadUpdate : (List StandardGamepad -> msg) -> Sub msg
onStandardGamepadUpdate handler =
    onGamepadUpdate (\raws -> handler (List.map toStandardGamepad raws))


port registerGamepadListener : Int -> Cmd msg


port unregisterGamepadListener : Int -> Cmd msg
