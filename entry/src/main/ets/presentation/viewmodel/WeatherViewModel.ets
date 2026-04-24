import { BaseInput, BaseOutput, BaseState, BaseEffect, BaseViewModel } from './BaseViewModel';
import { WeatherSnapshot } from '../../domain/models/Weather';
import { AppError } from '../../domain/models/AppError';
import { WeatherRepository } from '../../domain/repository/WeatherRepository';
import { Coordinates, LocationService } from '../../domain/services/LocationService';
import { Success, Failure } from '../../domain/models/Result';
import { Logger } from '../../core/logging/Logger';

const TAG = 'WeatherViewModel';

// ===== I/O types =====

export enum WeatherInputKind {
  LOAD = 'load',
  REFRESH = 'refresh'
}

export class LoadInput implements BaseInput {
  readonly kind: WeatherInputKind = WeatherInputKind.LOAD;
}

export class RefreshInput implements BaseInput {
  readonly kind: WeatherInputKind = WeatherInputKind.REFRESH;
}

export type WeatherInput = LoadInput | RefreshInput;

export interface WeatherState extends BaseState {
  snapshot: WeatherSnapshot | undefined;
  isLoading: boolean;
  error: string | undefined;
  lastRefreshAt: number;
}

export interface WeatherOutput extends BaseOutput {
  state: WeatherState;
}

export enum WeatherEffectKind {
  SHOWED_ERROR_TOAST = 'showed_error_toast'
}

export class ErrorToastEffect implements BaseEffect {
  readonly kind: WeatherEffectKind = WeatherEffectKind.SHOWED_ERROR_TOAST;
  readonly message: string;

  constructor(message: string) {
    this.message = message;
  }
}

export type WeatherEffect = ErrorToastEffect;

// ===== ViewModel =====

export class WeatherViewModel extends BaseViewModel<WeatherInput, WeatherState, WeatherEffect> {
  private readonly repository: WeatherRepository;
  private readonly locationService: LocationService;

  constructor(repository: WeatherRepository, locationService: LocationService) {
    super({
      snapshot: undefined,
      isLoading: false,
      error: undefined,
      lastRefreshAt: 0
    });
    this.repository = repository;
    this.locationService = locationService;
  }

  onEvent(input: WeatherInput): void {
    switch (input.kind) {
      case WeatherInputKind.LOAD:
      case WeatherInputKind.REFRESH:
        this.fetchWeather();
        break;
    }
  }

  protected updateState(state: WeatherState): void {
    this.setStateDirectly(state);
  }

  protected setLoading(isLoading: boolean): void {
    this.setStateDirectly({
      snapshot: this._state.snapshot,
      isLoading: isLoading,
      error: this._state.error,
      lastRefreshAt: this._state.lastRefreshAt
    });
  }

  protected setError(error: string | undefined): void {
    this.setStateDirectly({
      snapshot: this._state.snapshot,
      isLoading: false,
      error: error,
      lastRefreshAt: this._state.lastRefreshAt
    });
  }

  protected clearError(): void {
    this.setError(undefined);
  }

  private async fetchWeather(): Promise<void> {
    this.setLoading(true);
    this.clearError();

    const locationResult = await this.locationService.getCurrentCoordinates();
    if (locationResult.isFailure) {
      const err = (locationResult as Failure<AppError>).error;
      Logger.e(TAG, `Location error: ${err.toLogString()}`);
      this.setError(err.userMessage);
      this.emitEffect(new ErrorToastEffect(err.userMessage));
      return;
    }

    const coords: Coordinates = (locationResult as Success<Coordinates>).value;
    const weatherResult = await this.repository.getWeather(coords.latitude, coords.longitude);
    if (weatherResult.isFailure) {
      const err = (weatherResult as Failure<AppError>).error;
      Logger.e(TAG, `Weather error: ${err.toLogString()}`);
      this.setError(err.userMessage);
      this.emitEffect(new ErrorToastEffect(err.userMessage));
      return;
    }

    const snapshot: WeatherSnapshot = (weatherResult as Success<WeatherSnapshot>).value;
    this.setStateDirectly({
      snapshot: snapshot,
      isLoading: false,
      error: undefined,
      lastRefreshAt: Date.now()
    });
  }
}
