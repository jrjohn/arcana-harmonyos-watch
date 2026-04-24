/**
 * Weather domain model — framework-free.
 *
 * Represents current conditions plus a short-range forecast window.
 * Units: temperature °C, wind m/s, precipitation mm, humidity %.
 */

export enum WeatherCondition {
  CLEAR = 'clear',
  PARTLY_CLOUDY = 'partly_cloudy',
  CLOUDY = 'cloudy',
  FOG = 'fog',
  DRIZZLE = 'drizzle',
  RAIN = 'rain',
  SNOW = 'snow',
  THUNDERSTORM = 'thunderstorm',
  UNKNOWN = 'unknown'
}

export class HourlyForecast {
  readonly timestamp: number;
  readonly temperatureC: number;
  readonly condition: WeatherCondition;
  readonly precipitationMm: number;

  constructor(timestamp: number, temperatureC: number, condition: WeatherCondition, precipitationMm: number) {
    this.timestamp = timestamp;
    this.temperatureC = temperatureC;
    this.condition = condition;
    this.precipitationMm = precipitationMm;
  }
}

export class CurrentWeather {
  readonly temperatureC: number;
  readonly apparentTemperatureC: number;
  readonly humidityPct: number;
  readonly windSpeedMs: number;
  readonly windDirectionDeg: number;
  readonly condition: WeatherCondition;
  readonly isDay: boolean;
  readonly observedAt: number;

  constructor(
    temperatureC: number,
    apparentTemperatureC: number,
    humidityPct: number,
    windSpeedMs: number,
    windDirectionDeg: number,
    condition: WeatherCondition,
    isDay: boolean,
    observedAt: number
  ) {
    this.temperatureC = temperatureC;
    this.apparentTemperatureC = apparentTemperatureC;
    this.humidityPct = humidityPct;
    this.windSpeedMs = windSpeedMs;
    this.windDirectionDeg = windDirectionDeg;
    this.condition = condition;
    this.isDay = isDay;
    this.observedAt = observedAt;
  }
}

export class WeatherSnapshot {
  readonly locationLabel: string;
  readonly latitude: number;
  readonly longitude: number;
  readonly current: CurrentWeather;
  readonly next6Hours: HourlyForecast[];
  readonly fetchedAt: number;

  constructor(
    locationLabel: string,
    latitude: number,
    longitude: number,
    current: CurrentWeather,
    next6Hours: HourlyForecast[],
    fetchedAt: number
  ) {
    this.locationLabel = locationLabel;
    this.latitude = latitude;
    this.longitude = longitude;
    this.current = current;
    this.next6Hours = next6Hours;
    this.fetchedAt = fetchedAt;
  }
}

/**
 * Maps an Open-Meteo / WMO weather code to our domain enum.
 * Reference: https://open-meteo.com/en/docs#api_form (WMO codes 0-99).
 */
export function weatherConditionFromWmoCode(code: number): WeatherCondition {
  if (code === 0) return WeatherCondition.CLEAR;
  if (code === 1 || code === 2) return WeatherCondition.PARTLY_CLOUDY;
  if (code === 3) return WeatherCondition.CLOUDY;
  if (code === 45 || code === 48) return WeatherCondition.FOG;
  if (code >= 51 && code <= 57) return WeatherCondition.DRIZZLE;
  if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) return WeatherCondition.RAIN;
  if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) return WeatherCondition.SNOW;
  if (code >= 95 && code <= 99) return WeatherCondition.THUNDERSTORM;
  return WeatherCondition.UNKNOWN;
}

export function weatherConditionLabel(condition: WeatherCondition): string {
  switch (condition) {
    case WeatherCondition.CLEAR: return 'Clear';
    case WeatherCondition.PARTLY_CLOUDY: return 'Partly cloudy';
    case WeatherCondition.CLOUDY: return 'Cloudy';
    case WeatherCondition.FOG: return 'Fog';
    case WeatherCondition.DRIZZLE: return 'Drizzle';
    case WeatherCondition.RAIN: return 'Rain';
    case WeatherCondition.SNOW: return 'Snow';
    case WeatherCondition.THUNDERSTORM: return 'Thunder';
    default: return '—';
  }
}

export function weatherConditionGlyph(condition: WeatherCondition, isDay: boolean): string {
  switch (condition) {
    case WeatherCondition.CLEAR: return isDay ? '☀️' : '🌙';
    case WeatherCondition.PARTLY_CLOUDY: return isDay ? '⛅' : '☁️';
    case WeatherCondition.CLOUDY: return '☁️';
    case WeatherCondition.FOG: return '🌫️';
    case WeatherCondition.DRIZZLE: return '🌦️';
    case WeatherCondition.RAIN: return '🌧️';
    case WeatherCondition.SNOW: return '❄️';
    case WeatherCondition.THUNDERSTORM: return '⛈️';
    default: return '—';
  }
}
