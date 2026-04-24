import { Result } from '../models/Result';
import { AppError } from '../models/AppError';
import { WeatherSnapshot } from '../models/Weather';

/**
 * Domain-layer port. Presentation depends on this interface, never on HTTP/DTO details.
 */
export interface WeatherRepository {
  /** Fetches current weather + short forecast for the given coordinates. */
  getWeather(latitude: number, longitude: number): Promise<Result<WeatherSnapshot, AppError>>;
}
