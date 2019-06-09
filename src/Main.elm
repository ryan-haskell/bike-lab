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
            Bike
                "Smart Bike"
                "/public/bike.png"
                [ Tier "3 Features"
                    1000
                    [ Feature "Digital braking —\u{00A0}ergonomic buttons reflected in digital experience" 50
                    , Feature "Handsfree headset and group chat capability" 100
                    , Feature "22” 1080p touchscreen" 250
                    ]
                , Tier "5 Features"
                    1500
                    [ Feature "Digital braking —\u{00A0}ergonomic buttons reflected in digital experience" 50
                    , Feature "GPS headset and group chat capability" 100
                    , Feature "22” 1080p touchscreen" 250
                    , Feature "Interchangeable seat and pedals — ability to use standard outdoor bike options" 150
                    , Feature "Digital steering — ergonomic buttons reflected in  digital experience" 500
                    ]
                , Tier "7 Features"
                    2000
                    [ Feature "Ultra braking —\u{00A0}ergonomic buttons reflected in digital experience" 150
                    , Feature "Bluetooth headset and group chat capability" 1000
                    , Feature "55” 1080p touchscreen" 250
                    , Feature "Interchangeable seat and pedals — ability to use standard outdoor bike options" 150
                    , Feature "Digital steering — ergonomic buttons reflected in  digital experience" 500
                    , Feature "Robotic Hamster" 400
                    , Feature "Game of Thrones Season 9" 5000
                    ]
                ]
        , right =
            Bike
                "Smart Trainer"
                "/public/machine.png"
                [ Tier "3 Features"
                    2600
                    [ Feature "Digital braking —\u{00A0}ergonomic buttons reflected in digital experience" 50
                    , Feature "Handsfree headset and group chat capability" 100
                    , Feature "22” 1080p touchscreen" 250
                    ]
                , Tier "5 Features"
                    2800
                    [ Feature "Digital braking —\u{00A0}ergonomic buttons reflected in digital experience" 50
                    , Feature "GPS headset and group chat capability" 100
                    , Feature "22” 1080p touchscreen" 250
                    , Feature "Interchangeable seat and pedals — ability to use standard outdoor bike options" 150
                    , Feature "Digital steering — ergonomic buttons reflected in  digital experience" 500
                    ]
                , Tier "7 Features"
                    3100
                    [ Feature "Ultra braking —\u{00A0}ergonomic buttons reflected in digital experience" 150
                    , Feature "Bluetooth headset and group chat capability" 1000
                    , Feature "55” 1080p touchscreen" 250
                    , Feature "Interchangeable seat and pedals — ability to use standard outdoor bike options" 150
                    , Feature "Digital steering — ergonomic buttons reflected in  digital experience" 500
                    , Feature "Robotic Hamster" 400
                    , Feature "Game of Thrones Season 9" 5000
                    ]
                ]
        }
    }


bikeOptions =
    [ Tier "3 Features"
        2600
        [ Feature "Digital braking —\u{00A0}ergonomic buttons reflected in digital experience" 50
        , Feature "Handsfree headset and group chat capability" 100
        , Feature "22” 1080p touchscreen" 250
        ]
    , Tier "5 Features"
        2800
        [ Feature "Digital braking —\u{00A0}ergonomic buttons reflected in digital experience" 50
        , Feature "GPS headset and group chat capability" 100
        , Feature "22” 1080p touchscreen" 250
        , Feature "Interchangeable seat and pedals — ability to use standard outdoor bike options" 150
        , Feature "Digital steering — ergonomic buttons reflected in  digital experience" 500
        ]
    , Tier "7 Features"
        3100
        [ Feature "Ultra braking —\u{00A0}ergonomic buttons reflected in digital experience" 150
        , Feature "Bluetooth headset and group chat capability" 1000
        , Feature "55” 1080p touchscreen" 250
        , Feature "Interchangeable seat and pedals — ability to use standard outdoor bike options" 150
        , Feature "Digital steering — ergonomic buttons reflected in  digital experience" 500
        , Feature "Robotic Hamster" 400
        , Feature "Game of Thrones Season 9" 5000
        ]
    ]


type alias Bike =
    { label : String
    , image : String
    , options : List Tier
    }


type alias Tier =
    { label : String
    , price : Int
    , features : List Feature
    }


type alias Feature =
    { label : String
    , price : Int
    }


type alias Model =
    { page : Page
    , color : String
    , panesVisible : Bool
    , imagesVisible : Bool
    , textVisible : Bool
    , areFeaturesVisible : Bool
    , selectedOption : Maybe Selection
    }


type alias Selection =
    { tier : Tier
    , features : List Feature
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
    | ShowFeatures
    | SelectTier Tier
    | ToggleFeature Selection Feature


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
        False
        Nothing
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
        , div
            [ class "features"
            , classList
                [ ( "features--visible", model.areFeaturesVisible )
                ]
            ]
            [ div
                [ class "features__container"
                , classList
                    [ ( "features__container--left", model.page == Pane Left )
                    ]
                ]
                (case model.selectedOption of
                    Just option ->
                        case model.page of
                            Pane pane ->
                                case pane of
                                    Left ->
                                        [ div [ class "labels" ]
                                            [ div [ class "labels__label" ] [ text content.bikes.left.label ]
                                            , div [ class "labels__total" ] [ text (totalPrice option) ]
                                            ]
                                        , viewFeaturesFor option content.bikes.left
                                        ]

                                    Right ->
                                        [ viewFeaturesFor option content.bikes.right
                                        , div [ class "labels" ]
                                            [ div [ class "labels__label" ] [ text content.bikes.right.label ]
                                            , div [ class "labels__total" ] [ text (totalPrice option) ]
                                            ]
                                        ]

                            Homepage ->
                                []

                    Nothing ->
                        []
                )
            ]
        ]


totalPrice : Selection -> String
totalPrice selection =
    selection.tier.price
        + (selection.features |> List.map .price |> List.sum)
        |> String.fromInt
        |> (\price -> "$" ++ price)


viewFeaturesFor : Selection -> Bike -> Html Msg
viewFeaturesFor selection bike =
    div [ class "feature" ]
        [ div [ class "feature__tiers" ]
            (List.map (viewTier selection) bike.options)
        , div [ class "feature__features" ]
            (List.map (viewFeature selection) selection.tier.features)
        ]


viewTier : Selection -> Tier -> Html Msg
viewTier selection tier =
    button
        [ class "feature__tier"
        , onClick (SelectTier tier)
        , classList
            [ ( "feature__tier--selected", selection.tier == tier )
            ]
        ]
        [ text (tier.label ++ " — $" ++ String.fromInt tier.price)
        ]


viewFeature : Selection -> Feature -> Html Msg
viewFeature selection feature =
    div []
        [ button
            [ class "feature__feature"
            , onClick (ToggleFeature selection feature)
            , classList
                [ ( "feature__feature--selected", List.member feature selection.features )
                ]
            ]
            [ text (feature.label ++ " — $" ++ String.fromInt feature.price)
            ]
        ]


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
            [ text bike.label
            , br [] []
            , List.head bike.options
                |> Maybe.map .price
                |> Maybe.withDefault 1000
                |> String.fromInt
                |> (\price -> "$" ++ price)
                |> text
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
                , selectedOption = Just (optionsFor dir)
              }
            , delay 300 ShowFeatures
            )

        GoHome ->
            ( { model
                | page = Homepage
                , areFeaturesVisible = False
                , selectedOption = Nothing
              }
            , Cmd.none
            )

        ShowFeatures ->
            ( { model | areFeaturesVisible = True }
            , Cmd.none
            )

        SelectTier tier ->
            ( { model | selectedOption = Just (Selection tier []) }
            , Cmd.none
            )

        ToggleFeature selection feature ->
            ( { model | selectedOption = Just { selection | features = toggleFeature feature selection.features } }
            , Cmd.none
            )


toggleFeature : Feature -> List Feature -> List Feature
toggleFeature feature features =
    let
        alreadyHasFeature =
            List.member feature features
    in
    case alreadyHasFeature of
        True ->
            List.filter (\f -> f /= feature) features

        False ->
            feature :: features


optionsFor : Direction -> Selection
optionsFor dir =
    let
        bike =
            case dir of
                Left ->
                    content.bikes.left

                Right ->
                    content.bikes.right

        fallbackTier =
            Tier "Missing Tier" 0 []
    in
    Selection
        (List.head bike.options
            |> Maybe.withDefault fallbackTier
        )
        []


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
