# Arcana HarmonyOS Watch

A practical two-glance app for **Huawei smart watches** running HarmonyOS NEXT (API 12) —
**current weather** + **recent earthquakes** — scaffolded on top of the Clean Architecture
skeleton from [arcana-harmonyos](https://github.com/jrjohn/arcana-harmonyos) and trimmed
down for a wearable form factor.

![HarmonyOS](https://img.shields.io/badge/HarmonyOS-NEXT%20API%2012-blue?style=flat-square&logo=huawei&logoColor=white)
![Device](https://img.shields.io/badge/deviceTypes-wearable-green?style=flat-square)
![Language](https://img.shields.io/badge/ArkTS-Stage%20Model-purple?style=flat-square)

---

## What it does

Swipe between two pages on the watch:

| Page | Source | What you see |
|---|---|---|
| **Weather** | [Open-Meteo](https://open-meteo.com/) (free, no key) | Big temperature + condition glyph, feels-like / RH / wind, horizontally-scrollable 6-hour forecast |
| **Earthquakes** | [USGS M2.5+ past day](https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson) (free, no key) | Up to 10 events, sorted nearest-first when location granted, otherwise newest-first. Magnitude colour-coded; tsunami flag shown |

Both pages share the user's GPS fix (one permission prompt) and both have a tap-to-refresh
footer.

## Target devices

Design target: **Huawei Watch 4 / GT 4 / Ultimate** (466×466 round AMOLED, HarmonyOS NEXT).
`module.json5` declares `deviceTypes: ["wearable"]` — Stage-model wearable, not the legacy
`liteWearable` / FA-model used on older OpenHarmony LiteOS devices.

## Architecture

```
entry/src/main/ets/
├── entryability/EntryAbility.ets             # UIAbility — boots WatchContainer, loads MainPage
├── pages/MainPage.ets                        # @Entry — Swiper(WeatherFeature, EarthquakeFeature)
├── presentation/
│   ├── features/
│   │   ├── WeatherFeature.ets                # @Component — hero temp + forecast strip
│   │   └── EarthquakeFeature.ets             # @Component — magnitude-coloured list
│   ├── components/                           # LoadingView, ErrorView, EmptyView (dark watch theme)
│   └── viewmodel/
│       ├── BaseViewModel.ets                 # MVI-style Input/State/Effect
│       ├── WeatherViewModel.ets
│       └── EarthquakeViewModel.ets
├── domain/
│   ├── models/
│   │   ├── Weather.ets                       # CurrentWeather, HourlyForecast, WMO code map
│   │   ├── Earthquake.ets                    # EarthquakeEvent, haversineKm, magnitudeColor
│   │   ├── Result.ets                        # Success / Failure discriminated union
│   │   └── AppError.ets                      # structured error codes (+ PERMISSION_DENIED)
│   ├── repository/
│   │   ├── WeatherRepository.ets             # port
│   │   └── EarthquakeRepository.ets          # port
│   └── services/LocationService.ets          # LocationKit facade, runtime permission handling
├── data/
│   ├── dto/
│   │   ├── WeatherDto.ets                    # Open-Meteo response shape
│   │   └── EarthquakeDto.ets                 # USGS GeoJSON shape
│   └── repository/
│       ├── WeatherRepositoryImpl.ets         # adapter → Open-Meteo
│       └── EarthquakeRepositoryImpl.ets      # adapter → USGS (with haversine sort)
└── core/
    ├── http/ApiClient.ets                    # Retrofit-style declarative HTTP client
    ├── http/ApiEndpoint.ets
    ├── network/NetworkMonitor.ets            # @kit.NetworkKit connection state
    ├── network/HttpInterceptor.ets           # request/response logging
    ├── logging/Logger.ets                    # hilog wrapper
    └── di/WatchContainer.ets                 # hand-wired service locator (2 ApiClients, 2 repos)
```

### What was dropped vs. the phone/tablet source
- User management (domain / data / pages / viewmodels).
- Offline-first machinery: local RDB, sync manager, conflict resolver, work scheduler.
- The full inversify-style DI container (replaced with `WatchContainer`).
- i18n `LocalizationManager`, deep-link router, multi-tab `HomePage`/`UserListPage`.
- Jest + Jenkins + Sonar + Docker CI scaffolding.

### What was added
- Weather feature: domain model, Open-Meteo adapter, ViewModel, `WeatherFeature` component.
- Earthquake feature: domain model + haversine helper, USGS adapter, ViewModel,
  `EarthquakeFeature` component.
- `LocationService` — one-shot GPS with runtime permission request.
- `MainPage` — Swiper root combining the two features with a dot indicator.
- `WatchContainer` — minimal service locator holding two `ApiClient`s (one per backend host).

## Permissions

Declared in `entry/src/main/module.json5`:

| Permission | Grant type | Reason |
|---|---|---|
| `ohos.permission.INTERNET` | system | HTTPS calls to `api.open-meteo.com` and `earthquake.usgs.gov` |
| `ohos.permission.GET_NETWORK_INFO` | system | Connectivity check before fetch |
| `ohos.permission.APPROXIMATELY_LOCATION` | user | ~5 km fuzzy location, sufficient for city-level weather and nearest-quake sort |
| `ohos.permission.LOCATION` | user | Fine GPS when user approves |

`LocationService` calls `abilityAccessCtrl.requestPermissionsFromUser` the first time a
feature loads; the Earthquake feature degrades gracefully if the user denies (falls back
to newest-first sort).

## Build & run

Prerequisites:
- **DevEco Studio 5.0+** (includes HarmonyOS SDK, `hvigor`, wearable simulator).
- A Huawei Watch 4 / GT 4 / Watch Ultimate on a developer profile **or** the DevEco
  **Remote Emulator → Wearable** image.

Steps:
1. `git clone git@github.com:jrjohn/arcana-harmonyos-watch.git`
2. Open in DevEco Studio — let it run `hvigor sync`.
3. Sign the app (File → Project Structure → Signing Configs — automatic is fine for
   the simulator; a real device needs a HarmonyOS developer profile).
4. Select a **wearable** run target and hit Run.

First launch asks for location permission on the watch; once granted both pages
populate within a couple of seconds.

## Data sources

- **Open-Meteo** — CC-BY 4.0, no key, attribution required.
  ```
  GET https://api.open-meteo.com/v1/forecast
    ?latitude=<lat>&longitude=<lon>
    &current=temperature_2m,apparent_temperature,relative_humidity_2m,
             wind_speed_10m,wind_direction_10m,weather_code,is_day
    &hourly=temperature_2m,weather_code,precipitation
    &wind_speed_unit=ms&timezone=auto&forecast_days=1
  ```
- **USGS Earthquake Hazards Program** — public domain, no key.
  ```
  GET https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson
  ```

## Known limitations / next steps

- The `media/*.png` icons carried over from the source are 11-byte placeholders — replace
  with real artwork before shipping.
- Pull-to-refresh is disabled on both pages; tap-to-refresh is used instead (circular
  `Refresh` behaves inconsistently on round screens in current SDKs).
- No background fetch: both pages refresh on `aboutToAppear`. A `workScheduler` task every
  30 min for a quiet background cache warm-up is a reasonable next step.
- `onDigitalCrown` (rotation input) is not explicitly wired; the earthquake `List` and
  forecast `List` already scroll via the crown because `Scroll`/`List` consume crown events
  by default on API ≥15.
- Reverse-geocoding `lat/lon → city name` is punted for weather; USGS already returns a
  human-readable `place` string so the earthquake list is self-explanatory.
- Earthquake feed tab could add a magnitude filter (M4+ / M5+) for users in regions where
  M2.5 noise is too frequent.

## License

Apache-2.0 (inherited from the source project).
