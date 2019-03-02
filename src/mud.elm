module Mud exposing (Message(..), Model, Room, init, update, view)

import Browser exposing (Document)
import Browser.Dom
import Html exposing (Html, a, div, form, input, pre, span, text)
import Html.Attributes exposing (class, href, id, name, placeholder, style, type_, value)
import Html.Events exposing (onInput, onSubmit)
import List.Extra exposing (find)
import String exposing (toUpper)
import Task


type Direction
    = Left
    | Right
    | Up
    | Down


type Command
    = StringCommand String


type alias Item =
    { id : String
    , name : String
    }


type RoomId
    = Home
    | Basement
    | Kitchen


type alias Room =
    { id : RoomId
    , description : String
    , navigation : List NavigationTarget
    , commands : List Command
    , items : List Item
    }


type alias NavigationTarget =
    { direction : Direction
    , roomId : RoomId
    }


type Color
    = Red
    | Green
    | LightGreen


type HistoryEntryPart
    = PlainText String
    | ColoredText ( Color, String )


type HistoryEntry
    = HistoryEntry (List HistoryEntryPart)


type alias Model =
    { initialRoom : Room
    , currentRoom : Room
    , items : List Item
    , allRooms : List Room
    , commandText : String
    , history : List HistoryEntry
    }


type Message
    = NoOp
    | NewCommand
    | CommandTextChanged String


pencil : Item
pencil =
    Item "pencil" "Pencil"


inventoryCommand : Command
inventoryCommand =
    StringCommand "inventory"


dropCommand : Command
dropCommand =
    StringCommand "drop"


lookCommand : Command
lookCommand =
    StringCommand "look"


takeCommand : Command
takeCommand =
    StringCommand "take"


timeCommand : Command
timeCommand =
    StringCommand "time"


helpCommand : Command
helpCommand =
    StringCommand "help"


alwaysAvailableCommands : List Command
alwaysAvailableCommands =
    [ timeCommand, inventoryCommand, takeCommand, dropCommand, helpCommand, lookCommand ]


init : () -> ( Model, Cmd Message )
init _ =
    let
        home =
            Room Home "You find yourself in the woods. There's a big suspicious looking hole in the ground." [ NavigationTarget Down Basement ] [] [ pencil ]

        basement =
            Room Basement "You've entered a basement. You immediately spot a strange corner to the left..." [ NavigationTarget Up Home, NavigationTarget Left Kitchen ] [] []

        kitchen =
            Room Kitchen "You go left through a rickety door and find yourself in a dingy old kitchen." [ NavigationTarget Right Basement ] [] []

        initialModel =
            Model home home [] [ home, basement, kitchen ] "" []
                |> addHistory welcomeText
                |> addHistory ""
                |> showNavigated
    in
    ( initialModel, Cmd.none )


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NewCommand ->
            let
                modelAfterCommand =
                    model
                        |> addColoredHistory Green ("> " ++ model.commandText)
                        |> handleCommand model.commandText

                scrollCommand =
                    Browser.Dom.getViewportOf "room"
                        |> Task.andThen (\info -> Browser.Dom.setViewportOf "room" 0 info.scene.height)
                        |> Task.attempt (\_ -> NoOp)
            in
            ( { modelAfterCommand | commandText = "" }, scrollCommand )

        CommandTextChanged newText ->
            ( { model | commandText = newText }, Cmd.none )


handleCommand : String -> Model -> Model
handleCommand rawCommandString model =
    let
        availableCommands =
            List.append alwaysAvailableCommands model.currentRoom.commands
    in
    case stringToDirection rawCommandString of
        Just direction ->
            navigate model direction

        Nothing ->
            case parseCommand rawCommandString availableCommands of
                Just ( command, args ) ->
                    executeCommand model command args

                Nothing ->
                    addHistory "I'm sorry, Dave. I'm afraid I can't do that." model


view : Model -> List (Html Message)
view model =
    [ div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "flex-shrink" "0"
        , style "background" "#000"
        , style "color" "#02f100"
        , style "height" "100%"
        ]
        [ div [ class "switch-notice" ] [ span [] [ text "MUDs are sooo 1980's." ], a [ href "#standard" ] [ text "Take me to the real site" ] ]
        , div
            [ id "room"
            , style "height" "100%"
            , style "display" "flex"
            , style "font-family" "'Courier New', Courier, monospace"
            , style "flex-direction" "column"
            , style "overflow-x" "auto"
            , style "padding" "0 1em"
            ]
            (viewHistory model.history)
        , viewInput model
        ]
    ]


viewHistory : List HistoryEntry -> List (Html Message)
viewHistory history =
    history
        |> List.reverse
        |> List.map viewEntry
        |> List.concat


viewEntry : HistoryEntry -> List (Html Message)
viewEntry (HistoryEntry parts) =
    let
        coreEntryStyle =
            [ style "margin" "0"
            , style "white-space" "pre-wrap"
            , style "font-family" "'Courier New', Courier, monospace"
            ]

        viewCoreEntry coreEntry =
            case coreEntry of
                PlainText str ->
                    [ pre coreEntryStyle [ text str ] ]

                ColoredText ( color, str ) ->
                    let
                        colorAttribute =
                            case color of
                                Red ->
                                    style "color" "red"

                                Green ->
                                    style "color" "green"

                                LightGreen ->
                                    style "color" "rgb(159, 232, 158)"
                    in
                    [ pre (colorAttribute :: coreEntryStyle) [ text str ] ]
    in
    [ div [ style "display" "flex", style "flex-shrink" "0" ] (List.map viewCoreEntry parts |> List.concat) ]


viewInput : Model -> Html Message
viewInput model =
    div
        [ id "input" ]
        [ form [ onSubmit NewCommand ]
            [ input
                [ type_ "text"
                , onInput CommandTextChanged
                , name "commandText"
                , placeholder "Type your next command here. Try 'help' to see what you can do!"
                , value model.commandText
                , style "width" "100%"
                , style "outline" "none"
                , style "margin" "0"
                , style "font-size" "1em"
                , style "font-family" "'Courier New', Courier, monospace"
                , style "background" "#000"
                , style "color" "#02f100"
                , style "box-sizing" "border-box"
                ]
                []
            ]
        ]


executeCommand : Model -> Command -> List String -> Model
executeCommand model command args =
    case command of
        StringCommand commandName ->
            case commandName of
                "help" ->
                    showHelp model

                "inventory" ->
                    showInventory model

                "take" ->
                    case args of
                        firstArg :: _ ->
                            pickupItemFromRoom model firstArg

                        _ ->
                            addHistory "Take what exactly?" model

                "drop" ->
                    case args of
                        firstArg :: _ ->
                            dropItemInRoom model firstArg

                        _ ->
                            addHistory "What do you want to drop?" model

                "look" ->
                    showNavigated model

                "time" ->
                    showTime model

                _ ->
                    addHistory "I don't know what that is (yet?)." model


showTime : Model -> Model
showTime model =
    addHistory "Time in Elm is tricky, watch this space.." model


showInventory : Model -> Model
showInventory model =
    let
        showCore remaining m =
            case remaining of
                nextItem :: newRemaining ->
                    showCore newRemaining (addHistory ("* " ++ nextItem.name) m)

                [] ->
                    m
    in
    case model.items of
        _ :: _ ->
            addHistory "You are carrying: " model
                |> showCore model.items

        _ ->
            addHistory "You're not carrying anything." model


findItemInRoom : Room -> String -> Maybe Item
findItemInRoom room itemName =
    find (\item -> String.toUpper item.name == String.toUpper itemName) room.items


dropItemInRoom : Model -> String -> Model
dropItemInRoom model itemName =
    case find (\item -> String.toUpper item.name == String.toUpper itemName) model.items of
        Just itemToDrop ->
            let
                newInventory =
                    List.filter (\item -> item.id /= itemToDrop.id) model.items

                currentWithItem =
                    addItemToRoom model.currentRoom itemToDrop

                allRoomWithoutRoom =
                    List.filter (\room -> room.id /= model.currentRoom.id) model.allRooms

                allRoomsWithItem =
                    currentWithItem :: allRoomWithoutRoom
            in
            { model | items = newInventory, currentRoom = currentWithItem, allRooms = allRoomsWithItem }
                |> addHistory ("You throw a " ++ itemToDrop.name ++ " on the ground.")

        Nothing ->
            addHistory "You're not carrying an item with that name" model


pickupItemFromRoom : Model -> String -> Model
pickupItemFromRoom model itemName =
    case model.currentRoom.items of
        [] ->
            addHistory "There's nothing to take in this room!" model

        _ ->
            case findItemInRoom model.currentRoom itemName of
                Just item ->
                    let
                        roomWithoutItem =
                            removeItemFromRoom model.currentRoom item

                        allRoomsWithoutRoom =
                            List.filter (\room -> room.id /= model.currentRoom.id) model.allRooms

                        allRoomsWithoutItem =
                            roomWithoutItem :: allRoomsWithoutRoom
                    in
                    { model | items = item :: model.items, currentRoom = roomWithoutItem, allRooms = allRoomsWithoutItem }
                        |> addHistory "You picked up an item!"

                Nothing ->
                    addHistory ("There's no item '" ++ itemName ++ "' here.") model


addItemToRoom : Room -> Item -> Room
addItemToRoom room item =
    { room | items = item :: room.items }


removeItemFromRoom : Room -> Item -> Room
removeItemFromRoom room itemToRemove =
    let
        itemsWithoutItem =
            List.filter (\item -> item.id /= itemToRemove.id) room.items
    in
    { room | items = itemsWithoutItem }


showItem : Item -> String
showItem item =
    "There is a " ++ item.name ++ " on the ground."


directionToString : Direction -> String
directionToString direction =
    case direction of
        Left ->
            "left"

        Right ->
            "right"

        Up ->
            "up"

        Down ->
            "down"


stringToDirection : String -> Maybe Direction
stringToDirection string =
    case string of
        "left" ->
            Just Left

        "right" ->
            Just Right

        "up" ->
            Just Up

        "down" ->
            Just Down

        _ ->
            Nothing


navigate : Model -> Direction -> Model
navigate model direction =
    let
        directionString =
            directionToString direction
    in
    case find (\nav -> nav.direction == direction) model.currentRoom.navigation of
        Just targetRoom ->
            case find (\room -> room.id == targetRoom.roomId) model.allRooms of
                Just room ->
                    { model | currentRoom = room }
                        |> showNavigated

                Nothing ->
                    addHistory "Hmm, can't seem to be able to reach that room..." model

        Nothing ->
            addHistory ("You cannot go " ++ directionString) model


showNavigated : Model -> Model
showNavigated model =
    model
        |> addHistory model.currentRoom.description
        |> addItemsToHistory model.currentRoom.items
        |> addLinksToHistory


addItemsToHistory : List Item -> Model -> Model
addItemsToHistory items model =
    case items of
        [] ->
            model

        h :: t ->
            let
                newModel =
                    addItemTohistory model h
            in
            addItemsToHistory t newModel


addItemTohistory : Model -> Item -> Model
addItemTohistory model item =
    addColoredHistory LightGreen (showItem item) model


addHistory : String -> Model -> Model
addHistory entry model =
    { model | history = HistoryEntry [ PlainText entry ] :: model.history }


addColoredHistory : Color -> String -> Model -> Model
addColoredHistory color text model =
    { model | history = HistoryEntry [ ColoredText ( color, text ) ] :: model.history }


addLinksToHistory : Model -> Model
addLinksToHistory model =
    let
        entry =
            case model.currentRoom.navigation of
                _ :: _ ->
                    List.map (\dir -> ColoredText ( Red, directionToString dir.direction )) model.currentRoom.navigation
                        |> List.intersperse (PlainText ", ")
                        |> List.append [ PlainText "You can go " ]
                        |> HistoryEntry

                [] ->
                    HistoryEntry [ PlainText "There's nowhere to go" ]
    in
    { model | history = entry :: model.history }


parseCommand : String -> List Command -> Maybe ( Command, List String )
parseCommand string availableCommands =
    let
        split =
            String.split " " string
    in
    case split of
        h :: args ->
            case
                find
                    (\command ->
                        case command of
                            StringCommand commandAlias ->
                                toUpper commandAlias == toUpper h
                    )
                    availableCommands
            of
                Just command ->
                    Just ( command, args )

                Nothing ->
                    Nothing

        [] ->
            Nothing


showHelp : Model -> Model
showHelp model =
    addHistory """
*******************************************************************
Welcome traveler 3468.
--------------------------------
help               - Shows this help
up/down/left/right - Navigate around in the world.
take {item}        - Picks up an item you find in a room, e.g. 'take pencil'.
drop {item}        - Drops an item in the current room.
inventory          - Shows all items you're currently carrying.
time               - Shows the current time and the last time the world went through a magic shift.
look               - Look around the room.

Protocol 5 until further notice.
*******************************************************************
    """ model


welcomeText : String
welcomeText =
    """
*******************************************************************
Welcome to Simon Gustavsson's website.
--------------------------------------
Here you can interactively navigate around the mysterious mind that is Simon's,
and get a better idea of who he is, and what he's been up to.
*******************************************************************
"""
