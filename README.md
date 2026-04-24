# Arcana HarmonyOS Watch

A practical weather app for **Huawei smart watches** running HarmonyOS NEXT (API 12),
scaffolded on top of the Clean Architecture skeleton from
[arcana-harmonyos](https://github.com/jrjohn/arcana-harmonyos) and trimmed down for a
wearable form factor.

![HarmonyOS](https://img.shields.io/badge/HarmonyOS-NEXT%20API%2012-blue?style=flat-square&logo=huawei&logoColor=white)
![Device](https://img.shields.io/badge/deviceTypes-wearable-green?style=flat-square)
![Language](https://img.shields.io/badge/ArkTS-Stage%20Model-purple?style=flat-square)

---

## What it does

- Reads the watch's current GPS coordinates (one-shot fix via `@kit.LocationKit`).
- Fetches current conditions + next-6-hour forecast from **[Open-Meteo](https://open-meteo.com/)**
  (free, no API key, WMO weather codes).
- Renders a glanceable UI on the 466×466 round display: big temperature, condition glyph,
  feels-like / humidity / wind metrics, and a horizontally-scrollable hourly strip.
- Tap anywhere on the footer to refresh.

## Target devices

Tested design target: **Huawei Watch 4 / GT 4 / Ultimate** (466×466 round AMOLED, HarmonyOS NEXT).
`module.json5` declares `deviceTypes: ["wearable"]` — this is the Stage-model wearable target
(not the legacy `liteWearable` / FA-model used on older OpenHarmony LiteOS devices).

## Architecture

Clean Architecture carried over from `arcana-harmonyos`, with non-wearable modules stripped:

```
entry/src/main/ets/
├── entryability/EntryAbility.ets        # UIAbility — loads WeatherPage
├── pages/WeatherPage.ets                # single-page ArkUI, Stack + Column + List
├── presentation/
│   ├── components/                      # LoadingView, ErrorView, EmptyView (dark watch theme)
│   └── viewmodel/
│       ├── BaseViewModel.ets            # carried over (MVI-style Input/State/Effect)
│       └── WeatherViewModel.ets         # LoadInput / RefreshInput → WeatherState
├── domain/
│   ├── models/
│   │   ├── Weather.ets                  # CurrentWeather, HourlyForecast, WeatherCondition
│   │   ├── Result.ets                   # Success / Failure discriminated union
│   │   └── AppError.ets                 # structured error codes (+ PERMISSION_DENIED)
│   ├── repository/WeatherRepository.ets # port (interface)
│   └── services/LocationService.ets     # LocationKit facade, runtime permission handling
├── data/
│   ├── dto/WeatherDto.ets               # Open-Meteo response shape
│   └── repository/WeatherRepositoryImpl.ets # adapter — HTTP + DTO → domain
└── core/
    ├── http/ApiClient.ets               # Retrofit-style declarative HTTP client
    ├── http/ApiEndpoint.ets
    ├── network/NetworkMonitor.ets       # @kit.NetworkKit connection state
    ├── network/HttpInterceptor.ets      # request/response logging
    ├── logging/Logger.ets               # hilog wrapper
    └── di/WatchContainer.ets            # 30-line service locator (full DI was overkill)
```

### What was dropped vs. the phone/tablet source
- User management (domain / data / pages / viewmodels).
- Offline-first machinery: local RDB, sync manager, conflict resolver, work scheduler.
- The full inversify-style DI container (replaced with `WatchContainer`).
- i18n `LocalizationManager`, deep-link router, multi-tab `MainPage`.
- Jest + Jenkins + Sonar + Docker CI scaffolding.

### What was added
- `domain/models/Weather.ets` — domain entities + WMO code mapping.
- `domain/services/LocationService.ets` — one-shot GPS with runtime permission request.
- `domain/repository/WeatherRepository.ets` + `data/repository/WeatherRepositoryImpl.ets`.
- `core/di/WatchContainer.ets` — minimal service locator keyed on `UIAbilityContext`.
- `pages/WeatherPage.ets` — circular-layout UI.

## Permissions

Declared in `entry/src/main/module.json5`:

| Permission | Grant type | Reason |
|---|---|---|
| `ohos.permission.INTERNET` | system | HTTPS call to `api.open-meteo.com` |
| `ohos.permission.GET_NETWORK_INFO` | system | Connectivity check before fetch |
| `ohos.permission.APPROXIMATELY_LOCATION` | user | ~5 km fuzzy location, sufficient for city-level weather |
| `ohos.permission.LOCATION` | user | Fine GPS when user approves |

`LocationService` calls `abilityAccessCtrl.requestPermissionsFromUser` the first time the page
loads; the user gets the system consent dialog on the watch.

## Build & run

Prerequisites:
- **DevEco Studio 5.0+** (includes HarmonyOS SDK, `hvigor`, wearable simulator).
- Access to a Huawei Watch 4 / GT 4 / Watch Ultimate paired through the developer profile,
  **or** the DevEco **Remote Emulator → Wearable** image.

Steps:
1. `git clone git@github.com:jrjohn/arcana-harmonyos-watch.git`
2. Open the folder in DevEco Studio — let it run `hvigor sync`.
3. Sign the app (DevEco → File → Project Structure → Signing Configs — automatic signing is fine
   for the wearable simulator; a real device needs a HarmonyOS developer profile).
4. Select a **wearable** run target and hit Run.

First launch asks for location permission on the watch; once granted the app fetches and
renders current conditions within a couple of seconds.

## Known limitations / next steps

- The `media/*.png` icons carried over from the source are 11-byte placeholders — replace with
  real 1024×1024 round-friendly artwork before shipping.
- Pull-to-refresh is deliberately disabled; the circular `Refresh` component behaves
  inconsistently on round screens in current SDKs. Tap-to-refresh is used instead.
- No background fetch: `workScheduler` is the standard wearable hook but Huawei keeps that
  budget tight. A 30-minute cron via `workScheduler` is a reasonable next iteration.
- `onDigitalCrown` (rotation input) is not yet wired; the forecast `List` already scrolls via
  the crown because `Scroll`/`List` consume crown events by default on API ≥15.
- Reverse-geocoding of `lat/lon → city name` is punted (label shows coordinates); adding
  a small OSM Nominatim lookup is straightforward.

## Data source

Weather data: **[Open-Meteo](https://open-meteo.com/)** forecast endpoint,
CC-BY 4.0 licensed, free for non-commercial and commercial use with attribution.
No API key required. Endpoint template:

```
GET https://api.open-meteo.com/v1/forecast
  ?latitude=<lat>&longitude=<lon>
  &current=temperature_2m,apparent_temperature,relative_humidity_2m,
           wind_speed_10m,wind_direction_10m,weather_code,is_day
  &hourly=temperature_2m,weather_code,precipitation
  &wind_speed_unit=ms&timezone=auto&forecast_days=1
```

## License

Apache-2.0 (inherited from the source project).
