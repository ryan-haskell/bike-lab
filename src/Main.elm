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
    { logoUrl = "/public/bike-logo.svg"
    , title = "/public/prototyping-the-future.svg"
    , bikes =
        { left =
            { src = "/public/smart-bike.png"
            , alt = "Smart Bike"
            , image = "/public/bike.png"
            }
        , right =
            { src = "/public/smart-trainer.png"
            , alt = "Smart Trainer"
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
    , color : String
    , panesVisible : Bool
    , imagesVisible : Bool
    , textVisible : Bool
    , selectedOption : Int
    }


type Page
    = Homepage
    | Pane Direction


type Direction
    = Left
    | Right


type Msg
    = ShowPanes
    | ShowText
    | SelectPane Direction
    | GoHome


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
        "#11b3ba"
        False
        False
        False
        0
    , delay 300 ShowPanes
    )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "page" ]
        [ div
            [ class "panes"
            , style "background-color" model.color
            ]
            [ div
                [ class "panes__side panes__side--left"
                , classList [ ( "panes__side--ready", model.panesVisible && model.page /= Pane Right ) ]
                ]
                [ square "left" Left content.bikes.left model ]
            , div
                [ class "panes__side panes__side--right"
                , classList [ ( "panes__side--ready", model.panesVisible && model.page /= Pane Left ) ]
                ]
                [ square "right" Right content.bikes.right model ]
            ]
        , div
            [ class "page__title"
            , classList
                [ ( "page__title--visible", model.textVisible )
                , ( "page__title--offscreen", model.page /= Homepage )
                ]
            ]
            [ img [ src content.title, alt "Prototyping the Future of Cycling" ] [] ]
        , div
            [ class "nav"
            , classList [ ( "nav--visible", model.textVisible ) ]
            ]
            [ a [ onClick GoHome ]
                [ img [ src content.logoUrl, alt "Bike Lab" ] [] ]
            , a [ href "#menu" ]
                [ img [ src "/public/menu.svg", alt "Menu" ] [] ]
            ]
        ]


type alias Bike =
    { src : String
    , alt : String
    , image : String
    }


square : String -> Direction -> Bike -> Model -> Html Msg
square squareModifier dir bike model =
    div [ class "panes__square-wrapper", onClick (SelectPane dir) ]
        [ div
            [ class ("panes__square panes__square--" ++ squareModifier)
            , classList
                [ ( "panes__square--visible", model.imagesVisible )
                , ( "panes__square--zoomed", model.page == Pane dir )
                ]
            , style "background-image" ("url(" ++ bike.image ++ ")")
            ]
            []
        , div
            [ class "panes__square-text"
            , classList
                [ ( "panes__square-text--offscreen", model.page == Pane dir )
                ]
            ]
            [ img [ src bike.src, alt bike.alt ] []
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

        SelectPane dir ->
            ( { model
                | page = Pane dir
                , color =
                    if dir == Right then
                        "#000a53"

                    else
                        "#11b3ba"
              }
            , Cmd.none
            )

        GoHome ->
            ( { model | page = Homepage }
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
