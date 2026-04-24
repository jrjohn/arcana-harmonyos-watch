import { Result, ResultFactory, Success, Failure } from '../../domain/models/Result';
import { AppError, AppErrorFactory } from '../../domain/models/AppError';
import { EarthquakeEvent, haversineKm } from '../../domain/models/Earthquake';
import { EarthquakeRepository } from '../../domain/repository/EarthquakeRepository';
import { ApiClient } from '../../core/http/ApiClient';
import { UsgsEarthquakeFeed, UsgsEarthquakeFeature } from '../dto/EarthquakeDto';
import { Logger } from '../../core/logging/Logger';

const TAG = 'EarthquakeRepositoryImpl';

/**
 * USGS-backed implementation. Feed used: `2.5_day` (M≥2.5 in last 24h)
 * — a reasonable balance for a watch glance (typically 50–200 events/day,
 * enough to always have something nearby to show).
 *
 * ApiClient is passed in with baseUrl = https://earthquake.usgs.gov.
 */
export class UsgsEarthquakeRepository implements EarthquakeRepository {
  private static readonly PATH = '/earthquakes/feed/v1.0/summary/2.5_day.geojson';

  private readonly client: ApiClient;

  constructor(client: ApiClient) {
    this.client = client;
  }

  async getRecentEarthquakes(
    userLatitude: number | undefined,
    userLongitude: number | undefined,
    maxResults: number
  ): Promise<Result<EarthquakeEvent[], AppError>> {
    const result = await this.client.get<UsgsEarthquakeFeed>(
      UsgsEarthquakeRepository.PATH,
      (raw) => raw as UsgsEarthquakeFeed
    );

    if (result.isFailure) {
      const err = (result as Failure<AppError>).error;
      Logger.e(TAG, `USGS fetch failed: ${err.toLogString()}`);
      return ResultFactory.failure(err);
    }

    try {
      const feed = (result as Success<UsgsEarthquakeFeed>).value;
      const events = this.mapFeatures(feed.features, userLatitude, userLongitude);
      const sorted = this.sortAndTrim(events, userLatitude !== undefined, maxResults);
      return ResultFactory.success(sorted);
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      Logger.e(TAG, `Earthquake DTO mapping failed: ${msg}`);
      return ResultFactory.failure(AppErrorFactory.parseError(msg));
    }
  }

  private mapFeatures(
    features: UsgsEarthquakeFeature[],
    userLat: number | undefined,
    userLon: number | undefined
  ): EarthquakeEvent[] {
    const out: EarthquakeEvent[] = [];
    for (const f of features) {
      const coords = f.geometry.coordinates;
      if (!coords || coords.length < 2) continue;

      const lon = coords[0];
      const lat = coords[1];
      const depth = coords.length > 2 ? coords[2] : 0;
      const mag = f.properties.mag ?? 0;
      const place = f.properties.place ?? 'Unknown location';
      const distanceKm = (userLat !== undefined && userLon !== undefined)
        ? haversineKm(userLat, userLon, lat, lon)
        : undefined;

      out.push(new EarthquakeEvent(
        f.id,
        mag,
        place,
        f.properties.time,
        lat,
        lon,
        depth,
        f.properties.tsunami === 1,
        f.properties.url,
        distanceKm
      ));
    }
    return out;
  }

  private sortAndTrim(events: EarthquakeEvent[], haveUserLocation: boolean, max: number): EarthquakeEvent[] {
    const sorted = events.slice();
    if (haveUserLocation) {
      sorted.sort((a, b) => (a.distanceKm ?? Infinity) - (b.distanceKm ?? Infinity));
    } else {
      sorted.sort((a, b) => b.occurredAt - a.occurredAt);
    }
    return sorted.slice(0, max);
  }
}
