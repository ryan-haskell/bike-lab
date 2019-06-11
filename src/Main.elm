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
                2000
                "/public/bike-with-trainer.png"
                [ Tier "+3 Features"
                    2000
                    features
                , Tier "+5 Features"
                    2300
                    features
                , Tier "+7 Features"
                    2500
                    features
                ]
                premiumFeatures
                packages
        , right =
            Bike
                "Smart Bike"
                3000
                "/public/machine.png"
                [ Tier "+3 Features"
                    3000
                    features
                , Tier "+5 Features"
                    3300
                    features
                , Tier "+7 Features"
                    3500
                    features
                ]
                premiumFeatures
                packages
        }
    }


premiumFeatures =
    [ Bundle "Lever Braking"
        65
        "Feels like outdoor experience reflected in digital experience"
    , Bundle "Premium Theater Setup"
        500
        "27” HD touchscreen and soundbar for a more immersive experience"
    , Bundle "Realistic Steering"
        200
        "Feels like outdoor experience reflected in digital experience"
    , Bundle "Sensor Output"
        500
        "Advanced analytics and power symmetry data"
    , Bundle "Game-Enabled Haptics"
        100
        "Terrain, drafting, and competitor notification feedback"
    , Bundle "Lever Shifting"
        200
        "Feels like outdoor experience reflected in digital experience"
    ]


packages =
    [ Bundle "Training Package"
        3965
        "Chain drive, lever shifting, digital steering + braking, side-to-side rocking motion, advanced sensor output, biometric fan, LED lights, Bluetooth headset, interchangeable seat + pedals"
    , Bundle "Gaming Package"
        3230
        "Chain drive, lever shifting, digital steering + braking, side-to-side rocking motion, advanced sensor output, biometric fan, LED lights, Bluetooth headset, interchangeable seat + pedals"
    , Bundle "Real Road"
        3640
        "Chain drive, lever shifting, digital steering + braking, side-to-side rocking motion, advanced sensor output, biometric fan, LED lights, Bluetooth headset, interchangeable seat + pedals"
    ]


features =
    [ Feature "Digital braking" "ergonomic buttons reflected in  digital experience"
    , Feature "Handsfree headset" "Group chat capability"
    , Feature "Screen" "17” 1080p touchscreen"
    , Feature "Interchangeable seat and pedals" "ability to use standard outdoor bike options"
    , Feature "Digital steering" "ergonomic buttons reflected in digital experience"
    , Feature "Side to side motion" "to better simulate climbs and sprints"
    , Feature "LED lights" "reflect in-game interactions"
    , Feature "Incline" "simulated grade with resistance"
    , Feature "Biometric Fan" "fan that syncs with your bpm, power, or cadence"
    , Feature "Gaming buttons" "quick-hit buttons that power in-game actions"
    , Feature "Digital shifting" "ergonomic buttons reflected in  digital experience"
    ]


tieredFeatures =
    [ Tier "+3 Features"
        2600
        features
    , Tier "+5 Features"
        2800
        features
    , Tier "+7 Features"
        3100
        features
    ]


type alias Bike =
    { label : String
    , basePrice : Int
    , image : String
    , options : List Tier
    , premiumFeatures : List Bundle
    , packages : List Bundle
    }


type alias Tier =
    { label : String
    , price : Int
    , features : List Feature
    }


type alias Feature =
    { title : String
    , description : String
    }


type alias Model =
    { page : Page
    , color : String
    , panesVisible : Bool
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
    , price : Int
    , description : String
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
    | TogglePremiumFeature Direction (List Bundle) Bundle
    | SelectPackage Direction Bundle


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
    , delay 300 ShowPanes
    )



-- VIEW


bikeWith : Page -> Bike
bikeWith page =
    case page of
        Pane _ (Packages _) ->
            content.bikes.right

        _ ->
            content.bikes.left


view : Model -> Html Msg
view model =
    div [ class "page" ]
        [ div
            [ class "panes"
            , style "background-color" model.color
            ]
            [ div
                [ class "panes__side panes__side--left"
                , classList
                    [ ( "panes__side--ready"
                      , model.panesVisible
                            && isNotDirection Right model.page
                            && notOnPackagesPage model.page
                      )
                    ]
                ]
                [ square "left" Left (bikeWith model.page) model ]
            , div
                [ class "panes__side panes__side--right"
                , classList
                    [ ( "panes__side--ready"
                      , model.panesVisible
                            && isNotDirection Left model.page
                            && notOnPackagesPage model.page
                      )
                    ]
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
            [ img
                [ src content.title
                , alt "Prototyping the Future of Cycling"
                ]
                []
            ]
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
                    [ ( "features__container--left"
                      , isDirection Left model.page
                      )
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
                                viewDetailPage
                                    dir
                                    bike
                                    selection
                                    totalPrice
                                    viewFeaturesFor
                                    (Just ToPremiumFeatures)
                                    (Just (always GoHome))

                            PremiumFeatures selectedBundles ->
                                viewDetailPage
                                    dir
                                    bike
                                    selectedBundles
                                    premiumTotalPrice
                                    viewPremiumFeatures
                                    (Just ToPackages)
                                    (Just SelectPane)

                            Packages _ ->
                                let
                                    tierPackages =
                                        [ Tier "Training Package"
                                            3965
                                            [ Feature "Chain" "sounds and feels like outdoor experience"
                                            , Feature "Lever Shifting" "feels like outdoor experience reflected in digital experience"
                                            , Feature "Digital steering" "ergonomic buttons reflected in digital experience"
                                            , Feature "Digital braking" "ergonomic buttons reflected in digital experience"
                                            , Feature "Side to side motion" "to better simulate climbs and sprints"
                                            , Feature "Sensor Output" "power symmetry and analytics"
                                            , Feature "Biometric Fan" "fan that syncs with your bpm, power, or cadence"
                                            , Feature "LED lights" "reflect in-game interactions"
                                            , Feature "Handsfree headset" "group chat capability"
                                            , Feature "Interchangeable seat and pedals" "ability to use standard outdoor bike options"
                                            ]
                                        , Tier "Gaming Package"
                                            3230
                                            [ Feature "Belt" "Secondary input buttons on handles (Ride On, boost, etc)"
                                            , Feature "Digital steering" "ergonomic buttons reflected in digital experience"
                                            , Feature "Digital braking" "ergonomic buttons reflected in digital experience"
                                            , Feature "Side to side motion" "to better simulate climbs and sprints"
                                            , Feature "LED lights" "reflect in-game interactions"
                                            , Feature "Handsfree headset" "group chat capability"
                                            , Feature "Gaming Theater Setup" "27 HD screen w/ soundbar"
                                            , Feature "Haptics" "reflect game activity (drafting, approaching player, etc.)"
                                            ]
                                        , Tier "Real Road Package"
                                            3640
                                            [ Feature "Chain" "sounds and feels like outdoor experience"
                                            , Feature "Lever Shifting" "feels like outdoor experience reflected in digital experience"
                                            , Feature "Realistic Steering" "feels like outdoor experience reflected in digital experience"
                                            , Feature "Lever Braking" "feels like outdoor experience reflected in digital experience"
                                            , Feature "Side to side motion" "to better simulate climbs and sprints"
                                            , Feature "Interchangeable seat and pedals" "ability to use standard outdoor bike options"
                                            , Feature "Incline" "simulated grade with resistance"
                                            ]
                                        ]

                                    viewPackageColumn package =
                                        div [ class "package__column", onClick GoHome ]
                                            [ div [ class "card__header package__header" ]
                                                [ div [ class "card__title" ] [ text package.label ]
                                                , div [ class "card__price" ] [ text "" ]
                                                ]
                                            , div [ class "package__include" ] [ text "Features include:" ]
                                            , div [ class "package__features" ] (List.map viewFeatureListing package.features)
                                            ]
                                in
                                [ div
                                    [ class "package"
                                    , classList [ ( "package--left", dir == Left ) ]
                                    ]
                                    [ div
                                        [ class "package__heading feature__section-label"
                                        , style "padding" "0 1.5rem"
                                        ]
                                        [ text "Choose your bundle:" ]
                                    , div [ class "package__columns" ]
                                        (List.map viewPackageColumn tierPackages)
                                    ]
                                ]

                    Homepage ->
                        []
                )
            ]
        ]


notOnPackagesPage : Page -> Bool
notOnPackagesPage page =
    case page of
        Pane _ (Packages _) ->
            False

        _ ->
            True


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
    -> (Bike -> a -> Maybe Int)
    -> (Direction -> Bike -> a -> Html Msg)
    -> Maybe (Direction -> Msg)
    -> Maybe (Direction -> Msg)
    -> List (Html Msg)
viewDetailPage dir bike data priceFunction viewFunction nextMsg prevMsg =
    let
        labelHtml =
            div [ class "labels" ]
                [ div [ class "labels__label" ] [ text bike.label ]
                , div [ class "labels__total" ]
                    [ text
                        (priceFunction bike data
                            |> Maybe.map String.fromInt
                            |> Maybe.map (\price -> "$" ++ price)
                            |> Maybe.withDefault ""
                        )
                    ]
                ]

        nextButton =
            div
                ([ style "margin-top" "3rem"
                 , style "display" "flex"
                 , style "justify-content" "flex-end"
                 , style "position" "fixed"
                 , style "bottom" "1rem"
                 ]
                    ++ (case dir of
                            Left ->
                                [ style "left" "calc(50% + 2rem)" ]

                            Right ->
                                [ style "right" "calc(50%)" ]
                       )
                )
                [ case prevMsg of
                    Just msg_ ->
                        button [ class "button", onClick (msg_ dir) ] [ text "Back" ]

                    Nothing ->
                        text ""
                , case nextMsg of
                    Just msg_ ->
                        button [ class "button", onClick (msg_ dir) ] [ text "Next" ]

                    Nothing ->
                        text ""
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


viewSectionLabel : String -> Html Msg
viewSectionLabel label =
    div [ class "feature__section-label" ] [ text label ]


viewCard : Bundle -> Bool -> (Bundle -> Msg) -> Html Msg
viewCard bundle isSelected clickMsg =
    div
        [ class "card"
        , classList [ ( "card--active", isSelected ) ]
        , onClick (clickMsg bundle)
        ]
        [ div [ class "card__header" ]
            [ div [ class "card__title" ]
                [ text bundle.title ]
            , div [ class "card__price" ]
                [ text ("$" ++ String.fromInt bundle.price) ]
            ]
        , div [ class "card__description" ] [ text bundle.description ]
        ]



-- VIEW: PREMIUM FEATURES


viewPremiumFeatures : Direction -> Bike -> List Bundle -> Html Msg
viewPremiumFeatures dir bike selectedPremiumFeatures =
    div [ class "feature" ]
        [ viewSectionLabel "Choose your premium features"
        , div [ class "card__list" ]
            (List.map
                (\bundle ->
                    viewCard
                        bundle
                        (List.member bundle selectedPremiumFeatures)
                        (TogglePremiumFeature dir selectedPremiumFeatures)
                )
                bike.premiumFeatures
            )
        ]


premiumTotalPrice : Bike -> List Bundle -> Maybe Int
premiumTotalPrice bike bundles =
    if List.isEmpty bundles then
        Just bike.basePrice

    else
        bundles
            |> List.map .price
            |> List.sum
            |> (+) bike.basePrice
            |> Just



-- VIEW: PACKAGES


viewPackages : Direction -> Bike -> Maybe Bundle -> Html Msg
viewPackages dir bike selectedPackage =
    div [ class "feature" ]
        [ viewSectionLabel "Choose your bundle"
        , div [ class "card__list" ]
            (List.map
                (\bundle ->
                    viewCard
                        bundle
                        (selectedPackage == Just bundle)
                        (SelectPackage dir)
                )
                bike.packages
            )
        ]


packageTotalPrice : Bike -> Maybe Bundle -> Maybe Int
packageTotalPrice bike bundle =
    bundle
        |> Maybe.map .price



-- VIEW: FEATURES


totalPrice : Bike -> Selection -> Maybe Int
totalPrice _ selection =
    Just <| selection.tier.price


viewFeaturesFor : Direction -> Bike -> Selection -> Html Msg
viewFeaturesFor dir bike selection =
    div [ class "feature" ]
        [ viewSectionLabel "Choose your tier"
        , div [ class "feature__tiers" ]
            (List.map (viewTier bike dir selection) bike.options)
        , div [ class "feature__section-label" ] [ text "Choose your basic features" ]
        , div [ class "feature__features" ]
            (List.map (viewFeature dir selection) selection.tier.features)
        ]


viewTier : Bike -> Direction -> Selection -> Tier -> Html Msg
viewTier bike dir selection tier =
    button
        [ class "feature__tier"
        , onClick (SelectTier dir tier)
        , classList
            [ ( "feature__tier--selected", selection.tier == tier )
            ]
        ]
        [ text (tier.label ++ " — $" ++ String.fromInt (tier.price - bike.basePrice))
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
            [ viewFeatureListing feature
            ]
        ]


viewFeatureListing feature =
    div [ style "max-width" "45ch" ]
        [ span [ style "font-weight" "bold" ] [ text feature.title ]
        , span [] [ text " — " ]
        , span [] [ text feature.description ]
        ]



-- VIEW - HOMEPAGE


square : String -> Direction -> Bike -> Model -> Html Msg
square squareModifier dir bike model =
    div [ class "panes__square-wrapper", onClick (SelectPane dir) ]
        [ div
            [ class ("panes__square panes__square--" ++ squareModifier)
            , classList
                [ ( "panes__square--zoomed", isDirection dir model.page )
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
            , text ("$" ++ String.fromInt bike.basePrice)
            , br [] []
            , span [ style "font-size" "18px" ] [ text "(includes 3 smart features)" ]
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

        TogglePremiumFeature dir selectedFeatures feature ->
            ( { model | page = Pane dir (PremiumFeatures (toggleFeature feature selectedFeatures)) }
            , Cmd.none
            )

        SelectPackage dir package ->
            ( { model | page = Pane dir (Packages (Just package)) }, Cmd.none )


toggleFeature : a -> List a -> List a
toggleFeature item items =
    let
        alreadyHasItem =
            List.member item items
    in
    case alreadyHasItem of
        True ->
            List.filter (\f -> f /= item) items

        False ->
            item :: items


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
