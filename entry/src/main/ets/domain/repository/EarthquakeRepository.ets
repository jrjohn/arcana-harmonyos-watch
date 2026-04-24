import { Result } from '../models/Result';
import { AppError } from '../models/AppError';
import { EarthquakeEvent } from '../models/Earthquake';

/**
 * Domain port. Implementations fetch a recent earthquake feed and may
 * annotate each event with distance from an optional user location.
 */
export interface EarthquakeRepository {
  /**
   * Fetches recent earthquakes.
   * @param userLatitude if provided, events are annotated with distance and sorted by distance ascending
   * @param userLongitude matching longitude
   * @param maxResults cap on returned events (defaults to 10)
   */
  getRecentEarthquakes(
    userLatitude: number | undefined,
    userLongitude: number | undefined,
    maxResults: number
  ): Promise<Result<EarthquakeEvent[], AppError>>;
}
