/**
 * Open-Meteo response DTOs.
 * Keep DTO shape loose — Open-Meteo returns ISO8601 strings and parallel arrays.
 * Domain mapping happens in WeatherRepositoryImpl.
 */

export interface OpenMeteoCurrent {
  time: string;
  interval?: number;
  temperature_2m: number;
  apparent_temperature: number;
  relative_humidity_2m: number;
  wind_speed_10m: number;
  wind_direction_10m: number;
  weather_code: number;
  is_day: number;
}

export interface OpenMeteoHourly {
  time: string[];
  temperature_2m: number[];
  weather_code: number[];
  precipitation: number[];
}

export interface OpenMeteoResponse {
  latitude: number;
  longitude: number;
  timezone: string;
  current: OpenMeteoCurrent;
  hourly: OpenMeteoHourly;
}
