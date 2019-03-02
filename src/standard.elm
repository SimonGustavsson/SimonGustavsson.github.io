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


view : Model -> List (Html Msg)
view model =
    [ viewFirstSection model
    , viewSecondSection model
    ]


viewSecondSection : Model -> Html Msg
viewSecondSection _ =
    div
        [ id "aboutme"
        , style "height" "100%"
        , style "color" "#FFF"
        ]
        [ text "Im a second page" ]


viewFirstSection : Model -> Html Msg
viewFirstSection _ =
    div
        [ id "home"
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "flex-shrink" "0"
        , style "height" "100%"
        , style "font-family" "merriweather, serif"
        , style "font-feature-settings" "kern"
        , style "color" "#FFF"
        ]
        [ div [ class "switch-notice" ] [ span [] [ text "Can you show me" ], a [ href "?page=mud" ] [ text "that MUD thing again?" ] ]
        , viewMenu
        , div
            [ id "welcome-page"
            , style "display" "flex"
            , style "flex-grow" "1"
            , style "justify-content" "center"
            , style "align-items" "center"
            , style "flex-direction" "column"
            ]
            [ div [ style "font-size" "4em" ] [ text "Hello" ]
            , div [ style "font-size" "4em" ] [ text "I'm Simon" ]
            ]
        ]


viewMenu : Html Msg
viewMenu =
    let
        menuItemBaseStyle target =
            [ style "display" "flex"
            , style "justify-content" "center"
            , style "min-width" "125px"
            , style "padding" "1em 0"
            , style "text-decoration" "none"
            , style "color" "#fff"
            , href target
            ]
    in
    div
        [ id "menu-bar"
        , style "display" "flex"
        , style "padding" "0 1em"
        , style "font-family" "promixa-nova"
        , style "font-size" "1.2em"
        , style "justify-content" "flex-end"
        ]
        [ div [ style "display" "flex", style "justify-content" "space-between", style "width" "20%", style "font-size" "1.3em", style "padding" "0.5em 0" ]
            [ a (menuItemBaseStyle "#home") [ div [] [ text "home" ] ]
            , a (menuItemBaseStyle "#aboutme") [ div [] [ text "about" ] ]
            , a (style "border" "#fff 1px solid" :: menuItemBaseStyle "contact") [ div [] [ text "contact" ] ]
            ]
        ]
