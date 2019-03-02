module MainTests exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Main exposing (Message(..), Model, Room)
import Test exposing (..)


initModel : () -> Model
initModel _ =
    let
        ( model, _ ) =
            Main.init ()
    in
    model


updateDiscardCmd : Message -> Model -> Model
updateDiscardCmd message model =
    let
        ( newModel, _ ) =
            Main.update message model
    in
    newModel


emptyRoom : Room
emptyRoom =
    Room "Empty" "Nothing to see here" [] [] []


emptyModel : Model
emptyModel =
    Model emptyRoom emptyRoom [] [ emptyRoom ] "" []


suite : Test
suite =
    describe "Commands"
        [ test "Init works" <|
            \_ ->
                let
                    model =
                        initModel ()
                in
                Expect.notEqual model.history []
        , describe "Pick"
            [ test "Can't 'take' in empty empty" <|
                \_ ->
                    let
                        model =
                            emptyModel
                                |> updateDiscardCmd (CommandTextChanged "take whatever")
                                |> updateDiscardCmd NewCommand
                    in
                    Expect.all
                        [ \m -> Expect.equal (List.length m.items) 0
                        , \m -> Expect.notEqual (List.length m.history) 0
                        ]
                        model
            , test "Can pickup item in room 1" <|
                \_ ->
                    let
                        model =
                            initModel ()
                                |> updateDiscardCmd (CommandTextChanged "take pencil")
                                |> updateDiscardCmd NewCommand
                    in
                    Expect.equal (List.length model.items) 1
            , test "Cannot pick twice" <|
                \_ ->
                    let
                        model =
                            initModel ()
                                |> updateDiscardCmd (CommandTextChanged "take pencil")
                                |> updateDiscardCmd NewCommand
                                |> updateDiscardCmd (CommandTextChanged "take pencil")
                                |> updateDiscardCmd NewCommand
                    in
                    Expect.equal (List.length model.items) 1
            ]
        ]
