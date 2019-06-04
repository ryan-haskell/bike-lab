module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Process
import Task exposing (Task)


type alias Flags =
    ()


content =
    { logoUrl = "/public/bike-logo.png"
    , title = "Prototyping the Future of Cycling"
    , bikes =
        { left =
            { name = "Smart Trainer"
            , price = "$1050"
            , image = "/public/bike.png"
            }
        , right =
            { name = "Smart Bike"
            , price = "$2200"
            , image = "/public/machine.png"
            }
        }
    , features =
        { options =
            [ "3 Features – $2600"
            , "5 Features – $2800"
            , "7 Features – $3100"
            ]
        , list = List.map (always "Feature 1") (List.range 1 20)
        }
    }


type alias Model =
    { page : Page
    , panesVisible : Bool
    , imagesVisible : Bool
    , textVisible : Bool
    }


type Page
    = Homepage
    | Left (Maybe Int)
    | Right (Maybe Int)


type Msg
    = ShowPanes
    | ShowText


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( Model
        Homepage
        False
        False
        False
    , delay 300 ShowPanes
    )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "page" ]
        [ div
            [ class "panes"
            , classList [ ( "panes--ready", model.panesVisible ) ]
            ]
            [ div [ class "panes__side panes__side--left" ] [ square content.bikes.left model ]
            , div [ class "panes__side panes__side--right" ] [ square content.bikes.right model ]
            ]
        , div
            [ class "page__title"
            , classList [ ( "page__title--visible", model.textVisible ) ]
            ]
            [ span [ class "page__title-span" ] [ text content.title ] ]
        , div
            [ class "nav"
            , classList [ ( "nav--visible", model.textVisible ) ]
            ]
            [ a [ href "#home" ] [ img [ src content.logoUrl, alt "Bike Lab" ] [] ]
            , a [ href "#menu" ] [ img [ src "/public/menu.png", alt "Bike Lab" ] [] ]
            ]
        ]


type alias Bike =
    { name : String
    , price : String
    , image : String
    }


square : Bike -> Model -> Html msg
square bike model =
    div [ class "panes__square-wrapper" ]
        [ div
            [ class "panes__square"
            , classList [ ( "panes__square--visible", model.imagesVisible ) ]
            , style "background-image" ("url(" ++ bike.image ++ ")")
            ]
            []
        , div [ class "panes__square-text" ]
            [ p [] [ text bike.name ]
            , p [] [ text bike.price ]
            ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowPanes ->
            ( { model | panesVisible = True }
            , delay 400 ShowText
            )

        ShowText ->
            ( { model | textVisible = True }
            , Cmd.none
            )


send : msg -> Cmd msg
send msg =
    Task.succeed ()
        |> Task.perform (\_ -> msg)


delay : Float -> msg -> Cmd msg
delay ms msg =
    Process.sleep ms
        |> Task.perform (\_ -> msg)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
