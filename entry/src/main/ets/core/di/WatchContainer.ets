/**
 * Minimal service locator for the watch build.
 *
 * The phone/tablet build used inversify-style DI with decorators (see
 * original arcana-harmonyos repo). For a wearable the surface is small
 * enough that a hand-wired locator stays clearer than a container.
 *
 * Two ApiClient instances — one per backing host — because ApiClient
 * composes `baseUrl + path` on every call and mixing hosts would defeat
 * its logging/interceptor setup.
 */

import { common } from '@kit.AbilityKit';
import { ApiClient } from '../http/ApiClient';

import { WeatherRepository } from '../../domain/repository/WeatherRepository';
import { OpenMeteoWeatherRepository } from '../../data/repository/WeatherRepositoryImpl';

import { EarthquakeRepository } from '../../domain/repository/EarthquakeRepository';
import { UsgsEarthquakeRepository } from '../../data/repository/EarthquakeRepositoryImpl';

import { LocationService } from '../../domain/services/LocationService';

const OPEN_METEO_BASE_URL = 'https://api.open-meteo.com';
const USGS_BASE_URL = 'https://earthquake.usgs.gov';

export class WatchContainer {
  private static instance: WatchContainer | undefined;

  readonly weatherRepository: WeatherRepository;
  readonly earthquakeRepository: EarthquakeRepository;
  readonly locationService: LocationService;

  private readonly weatherClient: ApiClient;
  private readonly earthquakeClient: ApiClient;

  private constructor(context: common.UIAbilityContext) {
    this.weatherClient = ApiClient.create(OPEN_METEO_BASE_URL)
      .setTimeout(10_000)
      .accept('application/json')
      .logging(true)
      .build();
    this.earthquakeClient = ApiClient.create(USGS_BASE_URL)
      .setTimeout(10_000)
      .accept('application/geo+json,application/json;q=0.9')
      .logging(true)
      .build();

    this.weatherRepository = new OpenMeteoWeatherRepository(this.weatherClient);
    this.earthquakeRepository = new UsgsEarthquakeRepository(this.earthquakeClient);
    this.locationService = new LocationService(context);
  }

  static init(context: common.UIAbilityContext): WatchContainer {
    if (!WatchContainer.instance) {
      WatchContainer.instance = new WatchContainer(context);
    }
    return WatchContainer.instance;
  }

  static get(): WatchContainer {
    if (!WatchContainer.instance) {
      throw new Error('WatchContainer not initialized; call WatchContainer.init(context) in EntryAbility');
    }
    return WatchContainer.instance;
  }

  dispose(): void {
    this.weatherClient.destroy();
    this.earthquakeClient.destroy();
    WatchContainer.instance = undefined;
  }
}
