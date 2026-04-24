/**
 * Minimal service locator for the watch build.
 *
 * The phone/tablet build used inversify-style DI with decorators (see
 * original arcana-harmonyos repo). For a wearable with two services
 * (WeatherRepository, LocationService) a full container is overkill —
 * this file stays ~30 lines and can grow if needed.
 */

import { common } from '@kit.AbilityKit';
import { ApiClient } from '../http/ApiClient';
import { WeatherRepository } from '../../domain/repository/WeatherRepository';
import { OpenMeteoWeatherRepository } from '../../data/repository/WeatherRepositoryImpl';
import { LocationService } from '../../domain/services/LocationService';

const OPEN_METEO_BASE_URL = 'https://api.open-meteo.com';

export class WatchContainer {
  private static instance: WatchContainer | undefined;

  readonly weatherRepository: WeatherRepository;
  readonly locationService: LocationService;

  private readonly apiClient: ApiClient;

  private constructor(context: common.UIAbilityContext) {
    this.apiClient = ApiClient.create(OPEN_METEO_BASE_URL)
      .setTimeout(10_000)
      .accept('application/json')
      .logging(true)
      .build();
    this.weatherRepository = new OpenMeteoWeatherRepository(this.apiClient);
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
    this.apiClient.destroy();
    WatchContainer.instance = undefined;
  }
}
