module Main exposing (Model, main)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (text)
import Mud
import Standard
import Url exposing (Url)


type alias Model =
    { activeApp : Application
    , key : Nav.Key
    , mudData : Mud.Model
    , standardData : Standard.Model
    }


type Application
    = MUD Mud.Model
    | Standard Standard.Model


type ApplicationTarget
    = MudTarget
    | StandardTarget


type Msg
    = ClickedUrl UrlRequest
    | SwitchApplication ApplicationTarget
    | MudMessage Mud.Message
    | StandardMessage Standard.Msg


main : Platform.Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = ClickedUrl
        , onUrlChange = handleUrlChange
        }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    let
        ( mudData, mudCmd ) =
            Mud.init ()

        ( standardData, standardCmd ) =
            Standard.init

        initCmd =
            Cmd.batch
                [ Cmd.map MudMessage mudCmd
                , Cmd.map StandardMessage standardCmd
                ]

        initialModel =
            { activeApp = MUD mudData
            , key = navKey
            , mudData = mudData
            , standardData = standardData
            }

        appType =
            case url.fragment of
                Just "standard" ->
                    Standard initialModel.standardData

                _ ->
                    MUD initialModel.mudData
    in
    ( { initialModel | activeApp = appType }, initCmd )


handleUrlChange : Url -> Msg
handleUrlChange url =
    case url.fragment of
        Just "" ->
            SwitchApplication MudTarget

        Just "mud" ->
            SwitchApplication MudTarget

        Just "standard" ->
            SwitchApplication StandardTarget

        _ ->
            SwitchApplication MudTarget


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        StandardMessage m ->
            let
                ( newStandardModel, standardCommand ) =
                    Standard.update m model.standardData
            in
            case model.activeApp of
                Standard _ ->
                    ( { model | activeApp = Standard newStandardModel, standardData = newStandardModel }, Cmd.map StandardMessage standardCommand )

                _ ->
                    ( { model | standardData = newStandardModel }, Cmd.map StandardMessage standardCommand )

        MudMessage m ->
            let
                ( newMudModel, mudCommand ) =
                    Mud.update m model.mudData
            in
            case model.activeApp of
                MUD mudModel ->
                    ( { model | activeApp = MUD newMudModel, mudData = newMudModel }, Cmd.map MudMessage mudCommand )

                _ ->
                    ( { model | mudData = newMudModel }, Cmd.map MudMessage mudCommand )

        SwitchApplication target ->
            case target of
                MudTarget ->
                    ( { model | activeApp = MUD model.mudData }, Cmd.none )

                StandardTarget ->
                    ( { model | activeApp = Standard model.standardData }, Cmd.none )

        ClickedUrl request ->
            case request of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )


view : Model -> Document Msg
view model =
    let
        body =
            case model.activeApp of
                MUD mudModel ->
                    Mud.view mudModel
                        |> Html.map MudMessage

                Standard standardModel ->
                    Standard.view standardModel
                        |> Html.map StandardMessage
    in
    { title = "Simon Gustavsson"
    , body = [ body ]
    }
