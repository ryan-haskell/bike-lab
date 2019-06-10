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
                "Smart Trainer"
                "/public/bike.png"
                bikeOptions
        , right =
            Bike
                "Smart Bike"
                "/public/machine.png"
                bikeOptions
        }
    }


bikeOptions =
    [ Tier "+3 Features"
        2600
        [ Feature "Digital braking — ergonomic buttons reflected in  digital experience" 50
        , Feature "Handsfree headset and group chat capability" 100
        , Feature "17” 1080p touchscreen" 250
        , Feature "Interchangeable seat and pedals — ability to use standard outdoor bike options" 200
        , Feature "Digital steering — ergonomic buttons reflected in  digital experience" 300
        , Feature "Side to side motion — to better simulate climbs and sprints" 150
        , Feature "LED lights — reflect in-game interactions" 200
        , Feature "Incline — simulated grade with resistance" 50
        , Feature "Biometric Fan — fan that syncs with your bpm, power, or cadence" 150
        , Feature "Gaming buttons — quick-hit buttons that power in-game actions" 200
        , Feature "Digital shifting — ergonomic buttons reflected in  digital experience" 300
        ]
    , Tier "+5 Features"
        2800
        [ Feature "Digital braking — ergonomic buttons reflected in  digital experience" 50
        , Feature "Handsfree headset and group chat capability" 100
        , Feature "17” 1080p touchscreen" 250
        , Feature "Interchangeable seat and pedals — ability to use standard outdoor bike options" 200
        , Feature "Digital steering — ergonomic buttons reflected in  digital experience" 300
        ]
    , Tier "+7 Features"
        3100
        [ Feature "Digital braking — ergonomic buttons reflected in  digital experience" 50
        , Feature "Handsfree headset and group chat capability" 100
        , Feature "17” 1080p touchscreen" 250
        , Feature "Interchangeable seat and pedals — ability to use standard outdoor bike options" 200
        , Feature "Digital steering — ergonomic buttons reflected in  digital experience" 300
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
    }


type alias Selection =
    { tier : Tier
    , features : List Feature
    }


type Page
    = Homepage
    | Pane Direction DetailPage


type DetailPage
    = Features Selection
    | PremiumFeatures (List Bundle)
    | Packages (Maybe Bundle)


type alias Bundle =
    { title : String
    , description : String
    , price : Int
    }


type Direction
    = Left
    | Right


type Msg
    = ShowPanes
    | ShowText
    | SelectPane Direction
    | GoHome
    | ShowFeatures
    | SelectTier Direction Tier
    | ToggleFeature Direction Selection Feature
    | ToPremiumFeatures Direction
    | ToPackages Direction


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
                , classList [ ( "panes__side--ready", model.panesVisible && isNotDirection Right model.page ) ]
                ]
                [ square "left" Left content.bikes.left model ]
            , div
                [ class "panes__side panes__side--right"
                , classList [ ( "panes__side--ready", model.panesVisible && isNotDirection Left model.page ) ]
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
                    [ ( "features__container--left", isDirection Left model.page )
                    ]
                ]
                (case model.page of
                    Pane dir detailPage ->
                        let
                            bike =
                                case dir of
                                    Left ->
                                        content.bikes.left

                                    Right ->
                                        content.bikes.right
                        in
                        case detailPage of
                            Features selection ->
                                viewDetailPage dir bike selection totalPrice viewFeaturesFor (Just ToPremiumFeatures)

                            PremiumFeatures selectedBundles ->
                                viewDetailPage dir bike selectedBundles premiumTotalPrice viewPremiumFeatures (Just ToPackages)

                            Packages selectedBundle ->
                                viewDetailPage dir bike selectedBundle packageTotalPrice viewPackages Nothing

                    Homepage ->
                        []
                )
            ]
        ]


isNotDirection : Direction -> Page -> Bool
isNotDirection dir page =
    case page of
        Homepage ->
            True

        Pane dir_ _ ->
            dir_ /= dir


isDirection : Direction -> Page -> Bool
isDirection dir page =
    case page of
        Homepage ->
            False

        Pane dir_ _ ->
            dir_ == dir


viewDetailPage :
    Direction
    -> Bike
    -> a
    -> (a -> String)
    -> (Direction -> Bike -> a -> Html Msg)
    -> Maybe (Direction -> Msg)
    -> List (Html Msg)
viewDetailPage dir bike data priceFunction viewFunction nextMsg =
    let
        labelHtml =
            div [ class "labels" ]
                [ div [ class "labels__label" ] [ text bike.label ]
                , div [ class "labels__total" ] [ text (priceFunction data) ]
                ]

        nextButton =
            div
                ([ style "margin-top" "3rem"
                 , style "display" "flex"
                 , style "justify-content" "flex-end"
                 , style "position" "fixed"
                 , style "bottom" "2rem"
                 ]
                    ++ (case dir of
                            Left ->
                                [ style "left" "calc(50% + 2rem)" ]

                            Right ->
                                [ style "right" "calc(50% + 2rem)" ]
                       )
                )
                [ button
                    (case nextMsg of
                        Just msg_ ->
                            [ class "feature__tier", onClick (msg_ dir) ]

                        Nothing ->
                            [ class "feature__tier" ]
                    )
                    [ text "Next" ]
                ]
    in
    case dir of
        Left ->
            [ labelHtml
            , viewFunction dir bike data
            , nextButton
            ]

        Right ->
            [ viewFunction dir bike data
            , labelHtml
            , nextButton
            ]



-- VIEW: PREMIUM FEATURES


viewPremiumFeatures : Direction -> Bike -> List Bundle -> Html Msg
viewPremiumFeatures dir bike selectedBundles =
    text "Premium Features"


premiumTotalPrice : List Bundle -> String
premiumTotalPrice bundles =
    bundles
        |> List.map .price
        |> List.sum
        |> String.fromInt



-- VIEW: PACKAGES


viewPackages : Direction -> Bike -> Maybe Bundle -> Html Msg
viewPackages dir bike selectedBundle =
    text "Packages"


packageTotalPrice : Maybe Bundle -> String
packageTotalPrice bundle =
    bundle
        |> Maybe.map .price
        |> Maybe.withDefault 0
        |> String.fromInt



-- VIEW: FEATURES


totalPrice : Selection -> String
totalPrice selection =
    selection.tier.price
        + (selection.features |> List.map .price |> List.sum)
        |> String.fromInt
        |> (\price -> "$" ++ price)


viewFeaturesFor : Direction -> Bike -> Selection -> Html Msg
viewFeaturesFor dir bike selection =
    div [ class "feature" ]
        [ div [ class "feature__section-label" ] [ text "Choose your tier" ]
        , div [ class "feature__tiers" ]
            (List.map (viewTier dir selection) bike.options)
        , div [ class "feature__section-label" ] [ text "Choose your basic features" ]
        , div [ class "feature__features" ]
            (List.map (viewFeature dir selection) selection.tier.features)
        ]


viewTier : Direction -> Selection -> Tier -> Html Msg
viewTier dir selection tier =
    button
        [ class "feature__tier"
        , onClick (SelectTier dir tier)
        , classList
            [ ( "feature__tier--selected", selection.tier == tier )
            ]
        ]
        [ text (tier.label ++ " — $" ++ String.fromInt tier.price)
        ]


viewFeature : Direction -> Selection -> Feature -> Html Msg
viewFeature dir selection feature =
    div []
        [ button
            [ class "feature__feature"
            , onClick (ToggleFeature dir selection feature)
            , classList
                [ ( "feature__feature--selected", List.member feature selection.features )
                ]
            ]
            [ text (feature.label ++ " — $" ++ String.fromInt feature.price)
            ]
        ]



-- VIEW - HOMEPAGE


square : String -> Direction -> Bike -> Model -> Html Msg
square squareModifier dir bike model =
    div [ class "panes__square-wrapper", onClick (SelectPane dir) ]
        [ div
            [ class ("panes__square panes__square--" ++ squareModifier)
            , classList
                [ ( "panes__square--visible", model.imagesVisible )
                , ( "panes__square--zoomed", isDirection dir model.page )
                ]
            , style "background-image" ("url(" ++ bike.image ++ ")")
            ]
            []
        , div
            [ class "panes__square-text"
            , classList
                [ ( "panes__square-text--offscreen", isDirection dir model.page )
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



-- UPDATE


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
                | page = Pane dir (Features (optionsFor dir))
                , color =
                    if dir == Right then
                        "#000a53"

                    else
                        "#11b3ba"
              }
            , delay 300 ShowFeatures
            )

        GoHome ->
            ( { model
                | page = Homepage
                , areFeaturesVisible = False
              }
            , Cmd.none
            )

        ShowFeatures ->
            ( { model | areFeaturesVisible = True }
            , Cmd.none
            )

        SelectTier dir tier ->
            ( { model | page = Pane dir (Features (Selection tier [])) }
            , Cmd.none
            )

        ToggleFeature dir selection feature ->
            ( { model | page = Pane dir (Features { selection | features = toggleFeature feature selection.features }) }
            , Cmd.none
            )

        ToPremiumFeatures dir ->
            ( { model | page = Pane dir (PremiumFeatures []) }
            , Cmd.none
            )

        ToPackages dir ->
            ( { model | page = Pane dir (Packages Nothing) }
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
