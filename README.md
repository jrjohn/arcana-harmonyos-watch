# Arcana HarmonyOS Watch

<div align="center">

![HarmonyOS](.github/badges/harmonyos-next-5-0-blue-f9748eaa.svg)
![ArkTS](.github/badges/arkts-stage-model-3178c6-c514220b.svg)
![Device](.github/badges/devicetypes-wearable-green-801048e9.svg)
![Architecture](.github/badges/architecture-clean-mvi-purple-8ebae12a.svg)
![Grade](.github/badges/grade-b-yellow-537d83b8.svg)
![Tests](.github/badges/tests-0-pending-3c6d1120.svg)-lightgrey?style=for-the-badge)

**Wearable Reference Scaffold — Huawei Watch (HarmonyOS NEXT)**

*Clean Architecture | Two Real Keyless APIs | MVI ViewModel | Swiper Navigation*

[Features](#-key-features) | [Architecture](#-architecture-evaluation) | [Getting Started](#-getting-started) | [Documentation](#-documentation)

</div>

---

## Overview

**Arcana HarmonyOS Watch** is a wearable-form-factor derivative of [Arcana HarmonyOS](https://github.com/jrjohn/arcana-harmonyos), demonstrating how the phone/tablet app's Clean Architecture skeleton adapts to the constraints of a 466×466 round HarmonyOS wearable (Huawei Watch 4 / GT 4 / Watch Ultimate). Two glanceable features — **current weather** and **recent earthquakes** — are served by real, zero-key APIs so anyone can clone and run without credential setup.

This is deliberately a **learning / portfolio scaffold**, not a production app. The companion [Honest Assessment](#-honest-assessment) section spells out exactly what's solid and what's brittle.

### Three Pillars

| Pillar | Description |
|--------|-------------|
| **Clean Architecture (trimmed)** | Same four-layer separation (Presentation / Domain / Data / Core) as the phone project, with offline-first / DI / workers stripped as inappropriate for wearable |
| **Zero-Key APIs** | Open-Meteo (weather) + USGS Earthquake (quake feed) — no registration, no API keys, no rate-limit landmines on first launch |
| **Wearable-Correct UX** | `deviceTypes: ["wearable"]`, dark-first palette, inscribed-square layout, `Swiper` navigation, `List`-based crown scroll |

---

## Architecture Evaluation

### Overall Grade: B− (6.5/10)

<table>
<tr>
<td width="50%">

| Component | Grade | Score |
|-----------|-------|-------|
| Architecture Pattern | A | 9.0/10 |
| ArkTS / ArkUI Idiom Use | A− | 8.5/10 |
| MVI Implementation | A | 8.5/10 |
| Code Clarity | A | 8.5/10 |
| Feature Completeness | B | 7.0/10 |
| Educational Value | A | 9.0/10 |

</td>
<td width="50%">

| Component | Grade | Score |
|-----------|-------|-------|
| Compile Readiness | C | 5.0/10 |
| Device Readiness | C | 5.0/10 |
| Testing | F | 0.0/10 |
| Production Readiness | D | 3.5/10 |
| Attribution / Licensing | C | 5.0/10 |
| Documentation | B+ | 7.5/10 |

</td>
</tr>
</table>

### Comparison Metrics

| Metric | Arcana Watch | Phone Source (arcana-harmonyos) |
|--------|--------------|----------------------------------|
| Layer separation | 4 layers preserved | 4 layers |
| Backend(s) | 2 keyless public APIs | 1 test backend (reqres.in) |
| Offline support | None (stateless fetch) | Full offline-first + sync queue |
| DI framework | Hand-wired service locator (~50 LOC) | InversifyJS-style IoC container |
| Test coverage | 0% (no tests yet) | 100% business logic (555+ tests) |
| Icons | 11-byte placeholders | Production artwork |
| First-build risk | High (never compiled) | Low (shipped and tested) |

---

## Architecture Ranking

### Industry Comparison

<table>
<tr>
<td width="50%">

#### Overall Score: B− (6.5/10)

| Ranking Category | Position |
|------------------|----------|
| **vs. HarmonyOS Wearable Samples (hello-world tier)** | Above |
| **vs. HarmonyOS Wearable Samples (reference tier)** | Below — lacks tests & device verification |
| **vs. Phone-side Arcana HarmonyOS** | Subset (intentional) |
| **vs. Production Huawei Watch Apps** | Not comparable — this is a scaffold |

</td>
<td width="50%">

#### Maturity Model Level

| Level | Status |
|-------|--------|
| Level 1: Ad-hoc | Passed |
| Level 2: MVP Scaffold | **Current** |
| Level 3: Compile-green on device | Pending |
| Level 4: Test-backed | Pending |
| Level 5: Shippable (signed + icons + i18n) | Pending |

**Classification: MVP Learning Scaffold**

</td>
</tr>
</table>

### Detailed Component Scoring

<table>
<tr>
<td width="33%">

#### Architecture (9.0/10)
| Criterion | Score |
|-----------|-------|
| Layer Separation | 10/10 |
| Dependency Direction | 10/10 |
| Port / Adapter Shape | 9/10 |
| Scalability | 8/10 |
| Domain Independence | 9/10 |

</td>
<td width="33%">

#### Code Quality (8.5/10)
| Criterion | Score |
|-----------|-------|
| Error Handling (Result) | 9/10 |
| Type Safety | 8/10 |
| SOLID Principles | 9/10 |
| Memory Safety | 8/10 |
| Code Clarity | 9/10 |

</td>
<td width="34%">

#### Delivery Readiness (4.0/10)
| Criterion | Score |
|-----------|-------|
| Compiled on Device | 0/10 |
| Tests | 0/10 |
| Icons / Signing | 2/10 |
| Attribution UI | 2/10 |
| Caching / Battery | 4/10 |

</td>
</tr>
</table>

### Platform Comparison Matrix

| Aspect | Arcana Watch | Arcana HarmonyOS (Phone) | Arcana Android | Typical Watch Demos |
|--------|--------------|--------------------------|----------------|---------------------|
| **Architecture Grade** | A (9.0/10) | A+ (9.5/10) | A+ (9.5/10) | C (5/10) |
| **Form Factor** | Wearable 466×466 round | Phone / Tablet / 2-in-1 | Phone | Wearable |
| **Offline-First** | No (stateless) | Full LWW Sync | Full LWW Sync | No |
| **DI Framework** | Service Locator | IoC Container | Hilt | Manual |
| **Navigation** | Swiper (2 pages) | NavPathStack + Routes | Jetpack Navigation | Usually 1 page |
| **Error Handling** | Result&lt;T,E&gt; | Result&lt;T,E&gt; | Result&lt;T,E&gt; | try/catch |
| **Background Work** | None (foreground only) | WorkScheduler | WorkManager | None |
| **Features** | Weather + Earthquakes | User CRUD | User CRUD | One demo |

### Design Pattern Inventory

| Pattern | Implementation Quality | Usage |
|---------|-----------------------|-------|
| **MVI (Input / State / Effect)** | 9/10 | `BaseViewModel<I, S, E>` + typed inputs |
| **Repository / Port-Adapter** | 9/10 | Domain port + data-layer impl for both Weather and Earthquake |
| **Service Locator** | 7/10 | `WatchContainer` — tiny, hand-wired, explicit |
| **Builder** | 8/10 | `ApiClient.create(baseUrl).setTimeout(...).build()` |
| **Adapter (DTO → Domain)** | 8/10 | Open-Meteo + USGS DTOs mapped in repo impls |
| **Result&lt;T, E&gt;** | 9/10 | Railway-oriented error flow end-to-end |
| **Singleton (lazy)** | 7/10 | `WatchContainer.init / get` |
| **Unsubscribe token** | 9/10 | `StateUnsubscribe` prevents leaks on page disappear |

### Strengths Summary

| Category | Key Strength | Evidence |
|----------|-------------|----------|
| **Architecture** | Clean 4-layer separation preserved from phone project | Zero cross-layer imports; domain imports only Result/AppError |
| **API Choice** | Two keyless public backends | Clone → build → run, no credential setup |
| **Wearable Fit** | Correct manifest + UX primitives | `deviceTypes: ["wearable"]`, Swiper, dark palette |
| **Graceful Degradation** | Earthquake feature works without location | Falls back to newest-first sort if user denies |
| **Readability** | 27 files, ~3,900 LOC | Can be read end-to-end in ~1 hour |

### Known Limitations

| Limitation | Severity | Workaround Status |
|------------|----------|-------------------|
| Never compiled (first `hvigor build` will churn) | High | Pending — budget 1–2 rounds of fix-ups |
| No unit / integration tests | High | Pending — Hypium scaffolding to be re-added |
| 11-byte placeholder icons | Medium | Replace before ship |
| No Open-Meteo attribution in UI | Medium | CC-BY-4.0 requires visible credit |
| No in-memory cache (re-fetches on every tab switch) | Medium | Add TTL cache (~5 min / ~2 min) |
| Watch GT 4 BT-tether connectivity path untested | Medium | Needs real-device verification |
| English-only strings | Low | Re-add light i18n if shipping to TW / JP / CN |
| Not a real earthquake early warning (EEW) | Expected | Out of scope — EEW needs push channel + licensed backend |

---

## Architecture Pros and Cons

### Strengths

<table>
<tr>
<td width="50%">

#### Clean Architecture Benefits (preserved)
| Strength | Description |
|----------|-------------|
| **Strict Layer Separation** | Presentation → Domain ← Data ← Core, unidirectional |
| **Domain Independence** | Pure business logic — no `@kit.*` imports in `domain/` |
| **Testability** | Each layer can be unit-tested with mock repositories (tests not yet written) |
| **Port / Adapter Shape** | `WeatherRepository` / `EarthquakeRepository` interfaces; two adapters can coexist |

#### Wearable-Specific Decisions
| Strength | Description |
|----------|-------------|
| **Correct deviceTypes** | `["wearable"]` — Stage-model wearable, not legacy `liteWearable` |
| **Dark-First Palette** | Pure-black canvas maximises AMOLED burn-in safety and contrast |
| **Inscribed-Square Layout** | Content stays within ~330×330vp so round corners never clip text |
| **Swiper Navigation** | Horizontal swipe + dot indicator — idiomatic on round screens |
| **List-Based Crown Scroll** | `List` / `Scroll` consume crown rotation events by default |

</td>
<td width="50%">

#### Type Safety & Patterns
| Strength | Description |
|----------|-------------|
| **Result&lt;T, E&gt; Type** | Railway-oriented error handling, no thrown exceptions in hot path |
| **Input / State / Effect** | Clean MVI pattern with typed discriminated union actions |
| **Shared BaseViewModel** | Identical shape to phone project — cognitive parity |
| **Sealed Union Inputs** | Compile-time exhaustive pattern matching |

#### Infrastructure Quality
| Strength | Description |
|----------|-------------|
| **Declarative HTTP Client** | Retrofit-style `ApiClient.create(baseUrl).build()` (carried over) |
| **Two Clients, One Per Host** | Open-Meteo and USGS cleanly separated — no URL gymnastics |
| **One-Shot Location** | `getCurrentLocation` with runtime permission, no long-running listener |
| **Graceful Permission Degradation** | Earthquake page usable without location grant |

</td>
</tr>
</table>

### Limitations

<table>
<tr>
<td width="50%">

#### Delivery Gaps
| Limitation | Impact | Workaround |
|------------|--------|------------|
| **Never Compiled** | `hvigor build` hasn't run; expect API-shape fix-ups | Budget 1–2 rounds on first local build |
| **No Tests** | Hypium scaffolding dropped with Jest; 0% coverage | Re-add repository + VM unit tests before trusting distance / sort logic |
| **Placeholder Icons** | 11-byte PNGs from source — won't render properly | Swap `app_icon`, `startIcon`, `layered_image` assets |
| **No Signing Config** | First-time runners must set up signing | Use DevEco "Automatic Signing" for simulator |
| **No Caching** | Every tab-switch re-fetches GPS + HTTP | Add in-memory TTL cache |
| **No Attribution UI** | Open-Meteo CC-BY-4.0 requires visible credit | Small "Data: Open-Meteo / USGS" line in-app |

#### Wearable Constraints
| Limitation | Impact | Mitigation |
|------------|--------|------------|
| **GT 4 BT-Tether Path Untested** | HTTP over BT tether to paired phone not verified | Test against real GT 4 + paired phone scenario |
| **No Background Fetch** | Data refreshes only when app is opened | Add `workScheduler` 30-min cache warm-up |
| **Battery Cost Per Open** | Location fix + 2 HTTPS calls on every open | Cache first, re-fetch only if stale |

</td>
<td width="50%">

#### Scope Gaps
| Limitation | Impact | Future Improvement |
|------------|--------|-------------------|
| **English Only** | No i18n — poor fit for TW / JP / CN users | Re-add light `LocalizationManager` |
| **No Magnitude Filter** | M≥2.5 globally → noisy for users in quiet regions | Add quick filter button (M4+ / M5+) |
| **No City Name for Weather** | Shows coords, not a place name | Add Nominatim reverse-geocode |
| **No Tsunami Alert Escalation** | Tsunami flag only in subtitle | Could push to a full-screen alert view |

#### Not What This Is
| It's Not | Because |
|----------|---------|
| **A real EEW (earthquake early warning)** | Pull-every-few-minutes can't hit the "seconds before S-wave" bar — needs push channel + licensed backend (CWA / JMA) |
| **A production watch face** | No complication / always-on-display / tile integrations |
| **A replacement for the phone app** | Deliberately trimmed surface; phone side keeps offline-first + full user CRUD |

</td>
</tr>
</table>

### When to Use This Scaffold

| Goal | Recommendation |
|------|----------------|
| **Learning HarmonyOS wearable end-to-end** | Good fit — small, readable, real APIs |
| **Starting a single-purpose watch utility** | Good fit — swap either feature for your domain; skeleton reuses cleanly |
| **Comparing phone-side vs watch-side Clean Architecture** | Ideal — shares primitives with [arcana-harmonyos](https://github.com/jrjohn/arcana-harmonyos) |
| **Shipping to end users today** | Do not — needs compile verification + tests + icons + attribution UI + i18n + signing |
| **Real earthquake early warning** | Wrong architecture — use licensed CWA / JMA push backend instead |

---

## Key Features

### Architecture & Patterns
- **Clean Architecture** — Four distinct layers with unidirectional dependencies (same shape as phone project)
- **MVI Input / State / Effect** — Type-safe ViewModel pattern with sealed union actions
- **Service Locator** — Minimal hand-wired `WatchContainer` (full IoC container replaced; ~50 LOC)
- **Result&lt;T, E&gt; Types** — Railway-oriented programming for error handling

### Features on the Watch
- **Weather Page** — Current conditions + 6-hour forecast from Open-Meteo
- **Earthquake Page** — M≥2.5 past-24h from USGS, nearest-first when location granted
- **Swiper Navigation** — Horizontal page swipe with dot indicator
- **Graceful Location Degradation** — Earthquake page falls back to newest-first if denied

### Wearable Correctness
- **Stage-Model Wearable Manifest** — `deviceTypes: ["wearable"]`, API 12
- **Dark-First Palette** — AMOLED-safe, maximises contrast on round screen
- **Inscribed-Square Layout** — Content fits inside ~330×330vp, never clipped by round corners
- **Crown-Scrollable Lists** — `List` components consume digital crown rotation by default

---

## Technology Stack

<table>
<tr>
<td width="50%">

### Core Technologies
| Category | Technology |
|----------|------------|
| **Language** | ArkTS (TypeScript-based) |
| **UI Framework** | ArkUI (Declarative) |
| **Architecture** | Clean Architecture + MVI |
| **Model** | Stage Model |
| **deviceTypes** | `wearable` |
| **Target SDK** | API 12 (HarmonyOS 5.0.0) |

</td>
<td width="50%">

### Infrastructure
| Category | Technology |
|----------|------------|
| **Network** | `@kit.NetworkKit` (HTTP) |
| **Location** | `@kit.LocationKit` (`geoLocationManager`) |
| **Permissions** | `@kit.AbilityKit` (`abilityAccessCtrl`) |
| **Logging** | `@kit.PerformanceAnalysisKit` (hilog) |
| **Testing** | Pending (Hypium to be added) |

</td>
</tr>
</table>

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                              │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────────────────┐  │
│  │  MainPage   │  │   Features   │  │       ViewModels           │  │
│  │  (@Entry    │  │  Weather     │  │  (Input/State/Effect)      │  │
│  │   Swiper)   │  │  Earthquake  │  │  BaseViewModel<I, S, E>    │  │
│  └─────────────┘  └──────────────┘  └────────────────────────────┘  │
├─────────────────────────────────────────────────────────────────────┤
│                        DOMAIN LAYER                                  │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────────────────┐  │
│  │   Models    │  │  Services    │  │     Repository             │  │
│  │  Weather    │  │  Location    │  │    Interfaces (Ports)      │  │
│  │ Earthquake  │  │   Service    │  │ WeatherRepository          │  │
│  │  Result     │  │              │  │ EarthquakeRepository       │  │
│  │  AppError   │  │              │  │                            │  │
│  └─────────────┘  └──────────────┘  └────────────────────────────┘  │
├─────────────────────────────────────────────────────────────────────┤
│                         DATA LAYER                                   │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────────────────┐  │
│  │  DTOs       │  │ Repository   │  │   Repository Impls         │  │
│  │ OpenMeteo   │  │   Ports      │  │  OpenMeteoWeatherRepo      │  │
│  │ USGSGeoJSON │  │              │  │  UsgsEarthquakeRepo        │  │
│  └─────────────┘  └──────────────┘  └────────────────────────────┘  │
├─────────────────────────────────────────────────────────────────────┤
│                         CORE LAYER                                   │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌───────────┐ │
│  │ DI /     │ │ HTTP     │ │ Logging  │ │ Network  │              │ │
│  │ Watch    │ │ ApiClient│ │  Logger  │ │ Monitor  │              │ │
│  │Container │ │ Endpoint │ │          │ │          │              │ │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘              │ │
└─────────────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

| Layer | Purpose | Dependencies |
|-------|---------|--------------|
| **Presentation** | `MainPage` (Swiper root), two `@Component` features, ViewModels, shared components | Domain |
| **Domain** | Weather / Earthquake models, Result / AppError, LocationService, repository interfaces | None (Pure) |
| **Data** | Open-Meteo / USGS DTOs and repository implementations (HTTP → domain mapping) | Domain, Core |
| **Core** | `ApiClient`, Logger, NetworkMonitor, `WatchContainer` service locator | None |

---

## Project Structure

```
entry/src/main/ets/
├── entryability/
│   └── EntryAbility.ets                  # UIAbility — boots WatchContainer, loads MainPage
├── pages/
│   └── MainPage.ets                      # @Entry — Swiper(WeatherFeature, EarthquakeFeature)
├── presentation/
│   ├── features/                         # Per-page feature components
│   │   ├── WeatherFeature.ets            # @Component — hero temp + 6h forecast strip
│   │   └── EarthquakeFeature.ets         # @Component — magnitude-coloured list
│   ├── components/                       # Shared UI (dark watch theme)
│   │   ├── LoadingView.ets
│   │   ├── ErrorView.ets
│   │   └── EmptyView.ets
│   └── viewmodel/                        # MVI ViewModels
│       ├── BaseViewModel.ets             # Base<Input, State, Effect>
│       ├── WeatherViewModel.ets
│       └── EarthquakeViewModel.ets
├── domain/                               # Pure, framework-free
│   ├── models/
│   │   ├── Weather.ets                   # CurrentWeather, HourlyForecast, WMO code map
│   │   ├── Earthquake.ets                # EarthquakeEvent + haversine + colour band
│   │   ├── Result.ets                    # Success / Failure discriminated union
│   │   └── AppError.ets                  # Structured error codes (+ PERMISSION_DENIED)
│   ├── repository/                       # Ports
│   │   ├── WeatherRepository.ets
│   │   └── EarthquakeRepository.ets
│   └── services/
│       └── LocationService.ets           # LocationKit facade, runtime permission request
├── data/                                 # Adapters
│   ├── dto/
│   │   ├── WeatherDto.ets                # Open-Meteo response shape
│   │   └── EarthquakeDto.ets             # USGS GeoJSON shape
│   └── repository/
│       ├── WeatherRepositoryImpl.ets     # Open-Meteo adapter
│       └── EarthquakeRepositoryImpl.ets  # USGS adapter (with haversine sort)
└── core/                                 # Infrastructure
    ├── di/
    │   └── WatchContainer.ets            # Hand-wired service locator (2 ApiClients, 2 repos)
    ├── http/
    │   ├── ApiClient.ets                 # Retrofit-style declarative HTTP client
    │   └── ApiEndpoint.ets
    ├── logging/
    │   └── Logger.ets                    # hilog wrapper
    └── network/
        ├── NetworkMonitor.ets            # @kit.NetworkKit connection state
        └── HttpInterceptor.ets           # Request / response logging
```

### Code Statistics

| Metric | Value |
|--------|-------|
| Source Files | 27 ETS files |
| Source LOC | ~3,900 lines |
| Test Files | 0 |
| Test LOC | 0 |
| Test-to-Source Ratio | 0% |
| Avg File Size | ~145 LOC |

---

## MVI Input / State / Effect Pattern

Same MVI pattern as the phone project, carried over unchanged. Example from the weather feature:

```typescript
// Input — Type-safe user actions
export class LoadInput implements BaseInput {
  readonly kind: WeatherInputKind = WeatherInputKind.LOAD;
}
export class RefreshInput implements BaseInput {
  readonly kind: WeatherInputKind = WeatherInputKind.REFRESH;
}
export type WeatherInput = LoadInput | RefreshInput;

// State — Observable UI state (immutable updates)
export interface WeatherState extends BaseState {
  snapshot: WeatherSnapshot | undefined;
  isLoading: boolean;
  error: string | undefined;
  lastRefreshAt: number;
}

// Effect — One-time side effects (e.g. error toast)
export class ErrorToastEffect implements BaseEffect {
  readonly message: string;
  constructor(message: string) { this.message = message; }
}
export type WeatherEffect = ErrorToastEffect;
```

### ViewModel Usage

```typescript
export class WeatherViewModel extends BaseViewModel<WeatherInput, WeatherState, WeatherEffect> {
  constructor(
    private readonly repository: WeatherRepository,
    private readonly locationService: LocationService
  ) {
    super({ snapshot: undefined, isLoading: false, error: undefined, lastRefreshAt: 0 });
  }

  onEvent(input: WeatherInput): void {
    switch (input.kind) {
      case WeatherInputKind.LOAD:
      case WeatherInputKind.REFRESH:
        this.fetchWeather();
        break;
    }
  }
  // ...
}
```

---

## Service Locator (Watch-Sized DI)

The phone-side project uses a full InversifyJS-style IoC container with `@injectable` / `@inject` decorators. On a wearable with two services, that's overkill — a ~50-line hand-wired locator stays clearer:

```typescript
// 1. Initialise at UIAbility.onCreate
WatchContainer.init(this.context);

// 2. Read anywhere from pages / features
const container = WatchContainer.get();
this.viewModel = new WeatherViewModel(
  container.weatherRepository,
  container.locationService
);

// 3. Dispose at UIAbility.onDestroy (destroys both ApiClients)
WatchContainer.get().dispose();
```

### What's in the Container

| Service | Purpose |
|---------|---------|
| `weatherRepository` | `OpenMeteoWeatherRepository` — base URL `api.open-meteo.com` |
| `earthquakeRepository` | `UsgsEarthquakeRepository` — base URL `earthquake.usgs.gov` |
| `locationService` | Shared one-shot GPS fix + runtime permission handling |

---

## Testing

### Current Status

| Layer | Coverage | Files | Status |
|-------|----------|-------|--------|
| Domain Models | 0% | 0 | Not yet written |
| ViewModels | 0% | 0 | Not yet written |
| Repository | 0% | 0 | Not yet written |
| Integration | 0% | 0 | Not yet written |
| **Total** | **0%** | **0** | **Scaffolding pending** |

### Planned Test Harness

Hypium (`@ohos/hypium`) unit tests — same as phone project. First priorities once compile-green:
- `haversineKm` distance calculation (known-answer: London ↔ Paris ≈ 344 km)
- `weatherConditionFromWmoCode` mapping (WMO code table)
- `UsgsEarthquakeRepository.sortAndTrim` (with and without user location)
- `WeatherViewModel` and `EarthquakeViewModel` state transitions with mocked repositories

---

## Getting Started

### Prerequisites

- **DevEco Studio**: 5.0+ (with HarmonyOS SDK, `hvigor`, wearable simulator)
- **HarmonyOS SDK**: API 12 (5.0.0)
- **Device**: Huawei Watch 4 / GT 4 / Watch Ultimate on a developer profile, **or** DevEco Remote Emulator → Wearable

### Quick Start

```bash
# 1. Clone repository
git clone git@github.com:jrjohn/arcana-harmonyos-watch.git
cd arcana-harmonyos-watch

# 2. Open in DevEco Studio → let hvigor sync

# 3. Set up signing (DevEco → File → Project Structure → Signing Configs)
#    Automatic signing is fine for the wearable simulator.

# 4. Select a wearable run target and hit Run.
#    First launch asks for location permission on the watch.
```

### Build Output

```
entry/build/default/outputs/default/entry-default-signed.hap
```

### Expected First-Build Churn

Because this scaffold has never been compiled, expect a small number of API-shape
fixes on first build. Likely culprits (plan 1–2 hours):

- `Swiper.indicator(new DotIndicator()...)` — signature varies by SDK version
- `abilityAccessCtrl.requestPermissionsFromUser` — return shape (`authResults` vs `permissionGrantStatus`)
- `geoLocationManager.getCurrentLocation` — request object field names
- Strict-mode `| undefined` field declarations on `@State` — may require `?:` syntax

---

## Documentation

### Backend APIs

#### Open-Meteo (Weather)
Free, CC-BY-4.0, no API key, attribution required.

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/forecast` | GET | Current conditions + hourly forecast |

```
GET https://api.open-meteo.com/v1/forecast
  ?latitude=<lat>&longitude=<lon>
  &current=temperature_2m,apparent_temperature,relative_humidity_2m,
           wind_speed_10m,wind_direction_10m,weather_code,is_day
  &hourly=temperature_2m,weather_code,precipitation
  &wind_speed_unit=ms&timezone=auto&forecast_days=1
```

Weather codes: WMO 0–99. Mapping → domain enum in `domain/models/Weather.ets`.

#### USGS Earthquake (Quake feed)
Public domain, no API key.

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/earthquakes/feed/v1.0/summary/2.5_day.geojson` | GET | M≥2.5 past 24h, GeoJSON |

```
GET https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson
```

Alternate feeds if `2.5_day` is too sparse / noisy:
`all_hour.geojson`, `significant_week.geojson`, `4.5_day.geojson`, `2.5_week.geojson`.

### Screens

| Screen | Features |
|--------|----------|
| **Weather Page** | Hero temperature + condition glyph, feels-like / humidity / wind metrics, horizontally-scrollable 6-hour forecast, tap-to-refresh |
| **Earthquake Page** | Up to 10 recent events (M≥2.5), magnitude colour-coded, nearest-first (or newest-first if no location), tsunami flag, tap-to-refresh |
| **Navigation** | Swiper with dot indicator — swipe left/right to switch pages |

---

## Feature Comparison

| Feature | Arcana Watch | Arcana HarmonyOS (Phone) | Arcana Android |
|---------|--------------|--------------------------|----------------|
| Architecture | Clean Architecture (trimmed) | Clean Architecture | Clean Architecture |
| UI Framework | ArkUI (wearable) | ArkUI | Jetpack Compose |
| Language | ArkTS | ArkTS | Kotlin |
| ViewModel | Input/State/Effect | Input/State/Effect | Input/State/Effect |
| DI | Service Locator | InversifyJS-style IoC | Hilt |
| Database | None | RelationalStore | Room |
| Network | `@kit.NetworkKit` | `@kit.NetworkKit` | Ktorfit |
| Background | None | WorkScheduler | WorkManager |
| Caching | None | LruCache + RDB | StateFlow + LRU |
| Security | None (public APIs) | HUKS (AES-256-GCM) | EncryptedPrefs |
| Testing | Pending | Hypium (555+ tests) | JUnit + Mockito |
| Source Files | 27 | 65 | — |
| **Grade** | **B− (6.5/10)** | **A+ (9.2/10)** | **A+ (9.2/10)** |

---

## Recommendations

### Production Checklist (Ordered Roadmap)

To promote this from **MVP scaffold** → **shippable**, tackle roughly in order:

- [ ] **Compile green on device** — first `hvigor build`, fix API-shape issues
- [ ] **Flash to real Huawei Watch** — verify layout on 466×466, not just simulator
- [ ] **Test GT 4 BT-tether path** — HTTP over paired phone tether, with phone-out-of-range error handling
- [ ] **Replace placeholder icons** — real `app_icon` (1024×1024), `startIcon`, `layered_image` assets
- [ ] **Add in-memory cache** — 5-min TTL for weather, 2-min for quakes
- [ ] **Add attribution UI** — "Data: Open-Meteo / USGS" visible in-app (Open-Meteo CC-BY-4.0 requires this)
- [ ] **Re-add test harness** — Hypium unit tests for repositories + ViewModels + haversine
- [ ] **Re-add i18n** — light `LocalizationManager` for TW / JP / CN strings
- [ ] **Signing profile** — real HarmonyOS developer signing for device install
- [ ] **Magnitude filter UI** — M4+ / M5+ toggle on earthquake page
- [ ] **Background refresh** — `workScheduler` 30-min cache warm-up
- [ ] **Reverse geocoding** — Nominatim lookup so weather shows city name, not coords
- [ ] **Crash reporting** — hook HiAnalytics or similar

### Architecture Strengths (What Survived the Trim)

1. **Layer Separation** — Zero cross-layer imports; domain stays pure
2. **Port / Adapter** — Two different backends served by two separate adapters without changing UI
3. **Result&lt;T, E&gt;** — Error handling consistent across both features
4. **MVI ViewModel** — Same shape as phone project, enables shared reasoning
5. **Zero-Key APIs** — Ship-ready backends that don't require account setup

---

## License

```
Apache License 2.0

Copyright 2026 Arcana HarmonyOS Watch

Licensed under the Apache License, Version 2.0
```

---

## Credits

Based on [Arcana HarmonyOS](https://github.com/jrjohn/arcana-harmonyos) architecture, itself
derived from [Arcana Android](https://github.com/jrjohn/arcana-android).

Weather data: [Open-Meteo](https://open-meteo.com/) (CC-BY-4.0).
Earthquake data: [USGS Earthquake Hazards Program](https://earthquake.usgs.gov/) (public domain).

<div align="center">

**Clean Architecture principles, sized for a round HarmonyOS wearable.**

![Grade](.github/badges/overall-grade-b-yellow-35f1e4a3.svg)
![Status](.github/badges/status-mvp-scaffold-orange-f3303764.svg)
![Ready](.github/badges/ship-ready-no-red-4379942a.svg)

</div>
