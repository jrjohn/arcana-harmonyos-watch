import { Result, ResultFactory, Success, Failure } from '../../domain/models/Result';
import { AppError, AppErrorFactory } from '../../domain/models/AppError';
import {
  CurrentWeather,
  HourlyForecast,
  WeatherSnapshot,
  weatherConditionFromWmoCode
} from '../../domain/models/Weather';
import { WeatherRepository } from '../../domain/repository/WeatherRepository';
import { ApiClient } from '../../core/http/ApiClient';
import { OpenMeteoResponse, OpenMeteoCurrent, OpenMeteoHourly } from '../dto/WeatherDto';
import { Logger } from '../../core/logging/Logger';

const TAG = 'WeatherRepositoryImpl';

/**
 * Open-Meteo backed implementation.
 *
 * Open-Meteo is a free, no-API-key, no-auth weather service ideal for
 * demoing a wearable app without credential management. Base host:
 * https://api.open-meteo.com
 */
export class OpenMeteoWeatherRepository implements WeatherRepository {
  private static readonly HOURS_AHEAD = 6;

  private readonly client: ApiClient;

  constructor(client: ApiClient) {
    this.client = client;
  }

  async getWeather(latitude: number, longitude: number): Promise<Result<WeatherSnapshot, AppError>> {
    const query = new Map<string, string>();
    query.set('latitude', latitude.toFixed(4));
    query.set('longitude', longitude.toFixed(4));
    query.set('current', 'temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,wind_direction_10m,weather_code,is_day');
    query.set('hourly', 'temperature_2m,weather_code,precipitation');
    query.set('forecast_days', '1');
    query.set('wind_speed_unit', 'ms');
    query.set('timezone', 'auto');

    const result = await this.client.get<OpenMeteoResponse>(
      '/v1/forecast',
      (raw) => raw as OpenMeteoResponse,
      query
    );

    if (result.isFailure) {
      const err = (result as Failure<AppError>).error;
      Logger.e(TAG, `Open-Meteo fetch failed: ${err.toLogString()}`);
      return ResultFactory.failure(err);
    }

    try {
      const response = (result as Success<OpenMeteoResponse>).value;
      const snapshot = this.mapToDomain(response, latitude, longitude);
      return ResultFactory.success(snapshot);
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      Logger.e(TAG, `Weather DTO mapping failed: ${msg}`);
      return ResultFactory.failure(AppErrorFactory.parseError(msg));
    }
  }

  private mapToDomain(response: OpenMeteoResponse, lat: number, lon: number): WeatherSnapshot {
    const current = this.mapCurrent(response.current);
    const hourly = this.mapUpcomingHours(response.hourly, current.observedAt, OpenMeteoWeatherRepository.HOURS_AHEAD);
    const label = `${lat.toFixed(2)}°, ${lon.toFixed(2)}°`;
    return new WeatherSnapshot(label, lat, lon, current, hourly, Date.now());
  }

  private mapCurrent(raw: OpenMeteoCurrent): CurrentWeather {
    return new CurrentWeather(
      raw.temperature_2m,
      raw.apparent_temperature,
      raw.relative_humidity_2m,
      raw.wind_speed_10m,
      raw.wind_direction_10m,
      weatherConditionFromWmoCode(raw.weather_code),
      raw.is_day === 1,
      Date.parse(raw.time)
    );
  }

  private mapUpcomingHours(hourly: OpenMeteoHourly, fromTimestamp: number, count: number): HourlyForecast[] {
    const out: HourlyForecast[] = [];
    const times = hourly.time;
    const temps = hourly.temperature_2m;
    const codes = hourly.weather_code;
    const precips = hourly.precipitation;

    let startIndex = 0;
    for (let i = 0; i < times.length; i++) {
      if (Date.parse(times[i]) > fromTimestamp) {
        startIndex = i;
        break;
      }
    }

    const end = Math.min(startIndex + count, times.length);
    for (let i = startIndex; i < end; i++) {
      out.push(new HourlyForecast(
        Date.parse(times[i]),
        temps[i],
        weatherConditionFromWmoCode(codes[i]),
        precips[i]
      ));
    }
    return out;
  }
}
