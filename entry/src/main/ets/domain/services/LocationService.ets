import { geoLocationManager } from '@kit.LocationKit';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { Result, ResultFactory } from '../models/Result';
import { AppError, AppErrorFactory, ErrorCode } from '../models/AppError';
import { Logger } from '../../core/logging/Logger';

const TAG = 'LocationService';

export class Coordinates {
  readonly latitude: number;
  readonly longitude: number;
  readonly accuracyMeters: number;

  constructor(latitude: number, longitude: number, accuracyMeters: number) {
    this.latitude = latitude;
    this.longitude = longitude;
    this.accuracyMeters = accuracyMeters;
  }
}

/**
 * Thin facade over @kit.LocationKit. Requests runtime permission and
 * resolves to a single coordinate fix. Weather UX doesn't need continuous
 * updates, so we deliberately use one-shot `getCurrentLocation`.
 */
export class LocationService {
  private static readonly PERMISSIONS: Permissions[] = [
    'ohos.permission.APPROXIMATELY_LOCATION',
    'ohos.permission.LOCATION'
  ];

  private readonly context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  async getCurrentCoordinates(): Promise<Result<Coordinates, AppError>> {
    const granted = await this.ensurePermissions();
    if (!granted) {
      return ResultFactory.failure(
        new AppError(ErrorCode.PERMISSION_DENIED, 'Location permission denied')
      );
    }

    try {
      const request: geoLocationManager.CurrentLocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        scenario: geoLocationManager.LocationRequestScenario.UNSET,
        maxAccuracy: 0
      };
      const loc = await geoLocationManager.getCurrentLocation(request);
      Logger.d(TAG, `Location fix: ${loc.latitude.toFixed(4)}, ${loc.longitude.toFixed(4)} (±${loc.accuracy}m)`);
      return ResultFactory.success(new Coordinates(loc.latitude, loc.longitude, loc.accuracy));
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      Logger.e(TAG, `Location fetch failed: ${msg}`);
      return ResultFactory.failure(AppErrorFactory.networkError(msg));
    }
  }

  private async ensurePermissions(): Promise<boolean> {
    const atManager = abilityAccessCtrl.createAtManager();
    try {
      const res = await atManager.requestPermissionsFromUser(this.context, LocationService.PERMISSIONS);
      const grantStatuses = res.authResults;
      const granted = grantStatuses.some((code) => code === 0);
      if (!granted) {
        Logger.w(TAG, `Permission not granted; statuses=${JSON.stringify(grantStatuses)}`);
      }
      return granted;
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      Logger.e(TAG, `requestPermissionsFromUser failed: ${msg}`);
      return false;
    }
  }
}
