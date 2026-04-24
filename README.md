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

## Honest assessment

Written down so anyone forking this knows exactly what they're getting.

### What's solid (pros)

- **Clean Architecture carries over correctly.** Domain knows nothing about HTTP; ports
  (`WeatherRepository`, `EarthquakeRepository`) sit in `domain/`, adapters in `data/`.
  A second adapter (e.g. CWA for Taiwan EEW) can drop in without touching the UI.
- **Two real, zero-key APIs.** Anyone can clone and run — no credential setup, no vendor
  lock-in, no API-key rate-limit landmine on first launch.
- **Wearable-correct manifest and UX primitives.** `deviceTypes: ["wearable"]`, dark palette,
  466×466-aware inscribed-square layout, `Swiper` navigation, `List` for crown scroll — all
  grounded against HarmonyOS dev docs at the time of writing.
- **Graceful location degradation.** Earthquake page works without location (falls back to
  newest-first); user isn't held hostage by a permission prompt to see useful data.
- **Focused surface.** 27 ArkTS files, ~3,900 lines total. Small enough to read end-to-end
  in ~1 hour.
- **Sharable primitives.** `Result` / `AppError` / `BaseViewModel` / `ApiClient` are the same
  shapes as the phone-side project — cognitive parity across form factors.

### What's brittle (cons / risks)

- **Never compiled.** All code is written against ArkTS conventions from the source repo plus
  researched doc excerpts; `hvigor build` has **not** run against this tree. Expect a handful
  of fix-up rounds on first build — likely culprits: `Swiper.indicator()` API shape on your
  exact SDK, `abilityAccessCtrl.requestPermissionsFromUser` return shape, strict-mode `| undefined`
  field declarations, `@Builder` parameter typing.
- **No tests.** The source project's Jest scaffolding was dropped; no `ohosTest` either.
  Adding at least repository-level unit tests before trusting the distance/sort logic is wise.
- **Icons are 11-byte placeholders** (`media/*.png` inherited from source). Real launch icon,
  startWindow icon, and layered adaptive icon set need swapping before a real install.
- **No caching.** Every time a page appears it re-fetches GPS + HTTP. Fine for a demo,
  aggressive on watch battery. A simple in-memory TTL cache (~5 min for weather, ~2 min for
  quakes) is the obvious next step.
- **No attribution UI.** Open-Meteo's CC-BY-4.0 license requires visible attribution. Currently
  only in README — needs a small "Data: Open-Meteo / USGS" line somewhere in-app before ship.
- **No background / push.** The earthquake page **is not a real "速報" (EEW)** — it's a
  pull-every-time-you-look feed. Real earthquake early warning (CWA in Taiwan, JMA in Japan)
  needs push channels + licensed backend; this scaffold cannot replace that.
- **Watch connectivity assumption.** HTTP requires the watch to reach the internet. Huawei
  Watch 4 / Ultimate / Watch 5 have independent Wi-Fi / LTE; **Watch GT 4 piggybacks on the
  paired phone via BT tether** — if the user walks away from their phone, GT 4 calls will fail.
  Not currently handled with a graceful "paired phone unreachable" error.
- **Strings are English-only.** `LocalizationManager` was dropped; if the target market is
  Taiwan / Japan / CN, a light i18n layer needs adding back.
- **No filter UI.** M≥2.5 returns ~50–200 events per day globally; a user in a quiet region
  mostly sees events on the far side of Earth. A magnitude / distance filter button would help.
- **Permissions prompt happens twice.** Both features call `requestPermissionsFromUser`
  independently. Idempotent but noisy to read in logs — `LocationService` should cache grant
  state.

### Rank

| Axis | Grade | Reasoning |
|---|---|---|
| Architecture | **A** | Clean layers, ports + adapters, shared primitives with phone project |
| ArkTS / ArkUI idiom use | **A−** | Correct wearable manifest, `Swiper`/`List` choice, dark-first palette |
| Feature completeness (MVP) | **B** | 2 features work; no caching, no filter, no background, no i18n |
| Compile readiness | **C** | Written but never built — expect first-compile churn |
| Device readiness | **C** | Never flashed to real watch or simulator; GT 4 tether path untested |
| Production readiness | **D** | No tests, placeholder icons, no signing, no attribution UI, no telemetry |
| Educational value | **A** | Small enough to read; demonstrates port/adapter cleanly with two real backends |

**Overall: B− — a solid learning / portfolio scaffold.** Good shape, not shippable.
Before it becomes shippable: compile green → device test → icons → caching → attribution UI →
tests → i18n → signing profile. That's the ordered roadmap.

### What this is good for

- Learning HarmonyOS wearable ArkTS end-to-end from a real (not hello-world) example.
- Starting point for your own single-purpose watch utility (swap either feature for your own
  domain — the skeleton reuses cleanly).
- Comparing how Clean Architecture adapts when you move from phone → watch (large UI /
  feature surface shrinks, core primitives survive).

### What this is NOT good for

- Shipping to end users as-is.
- Real earthquake early warning (EEW) — fundamentally wrong transport for that use case.
- Learning background-task / push / notification patterns — this scaffold deliberately avoids
  them.

## License

Apache-2.0 (inherited from the source project).
