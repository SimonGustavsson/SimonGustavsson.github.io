module Standard exposing (Model, Msg, init, update, view)

import Html exposing (Html, a, div, span, text)
import Html.Attributes exposing (class, href, id, style)


type alias Model =
    String


type Msg
    = NoOp


init : ( Model, Cmd Msg )
init =
    ( "Hello, World", Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        NoOp ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "flex-shrink" "0"
        , style "height" "100%"
        ]
        [ div [ class "switch-notice" ] [ span [] [ text "Can you show me" ], a [ href "#mud" ] [ text "that MUD thing again?" ] ]
        , div
            [ id "content"
            , style "height" "100%"
            , style "display" "flex"
            , style "flex-direction" "column"
            , style "overflow-x" "auto"
            , style "padding" "0 1em"
            ]
            [ text "Beep boop! Simon has not yet created any content here..." ]
        ]
