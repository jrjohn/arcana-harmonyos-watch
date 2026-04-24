import { LoadingView } from '../components/LoadingView';
import { ErrorView } from '../components/ErrorView';
import {
  WeatherViewModel,
  WeatherState,
  LoadInput,
  RefreshInput
} from '../viewmodel/WeatherViewModel';
import { StateUnsubscribe } from '../viewmodel/BaseViewModel';
import {
  WeatherSnapshot,
  HourlyForecast,
  weatherConditionGlyph,
  weatherConditionLabel
} from '../../domain/models/Weather';
import { WatchContainer } from '../../core/di/WatchContainer';
import { Logger } from '../../core/logging/Logger';

const TAG = 'WeatherFeature';

/**
 * Weather feature view — meant to live inside a Swiper page on the
 * watch's root MainPage. Layout sized for a 466×466 round display,
 * content constrained to the inscribed square.
 */
@Component
export struct WeatherFeature {
  @State private viewState: WeatherState = {
    snapshot: undefined,
    isLoading: false,
    error: undefined,
    lastRefreshAt: 0
  };

  private viewModel: WeatherViewModel | undefined;
  private unsubscribe: StateUnsubscribe<WeatherState> | undefined;

  aboutToAppear(): void {
    Logger.d(TAG, 'aboutToAppear');
    const container = WatchContainer.get();
    this.viewModel = new WeatherViewModel(container.weatherRepository, container.locationService);
    this.unsubscribe = this.viewModel.subscribeToState((state) => {
      this.viewState = state;
    });
    this.viewModel.onEvent(new LoadInput());
  }

  aboutToDisappear(): void {
    Logger.d(TAG, 'aboutToDisappear');
    this.unsubscribe?.unsubscribe();
    this.viewModel?.destroy();
  }

  private onRefresh(): void {
    this.viewModel?.onEvent(new RefreshInput());
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.watch_bg'))

      if (this.viewState.isLoading && !this.viewState.snapshot) {
        LoadingView({ message: 'Fetching weather...' })
      } else if (this.viewState.error && !this.viewState.snapshot) {
        ErrorView({
          message: this.viewState.error,
          showRetry: true,
          onRetry: () => this.onRefresh()
        })
      } else if (this.viewState.snapshot) {
        this.buildContent(this.viewState.snapshot)
      } else {
        LoadingView({ message: 'Starting...' })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildContent(snapshot: WeatherSnapshot) {
    Column() {
      Row() {
        Text(weatherConditionGlyph(snapshot.current.condition, snapshot.current.isDay))
          .fontSize(48)

        Column() {
          Text(`${Math.round(snapshot.current.temperatureC)}°`)
            .fontSize(52)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.watch_text_primary'))
          Text(weatherConditionLabel(snapshot.current.condition))
            .fontSize(13)
            .fontColor($r('app.color.watch_text_secondary'))
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 8 })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .width('100%')

      Row() {
        this.buildMetric(`${Math.round(snapshot.current.apparentTemperatureC)}°`, 'Feels')
        Divider()
          .vertical(true)
          .height(18)
          .color($r('app.color.watch_divider'))
          .margin({ left: 10, right: 10 })
        this.buildMetric(`${Math.round(snapshot.current.humidityPct)}%`, 'RH')
        Divider()
          .vertical(true)
          .height(18)
          .color($r('app.color.watch_divider'))
          .margin({ left: 10, right: 10 })
        this.buildMetric(`${snapshot.current.windSpeedMs.toFixed(1)}`, 'm/s')
      }
      .margin({ top: 14 })
      .justifyContent(FlexAlign.Center)

      List({ space: 10 }) {
        ForEach(snapshot.next6Hours, (hour: HourlyForecast, index: number) => {
          ListItem() {
            this.buildHourCell(hour)
          }
        }, (hour: HourlyForecast) => `${hour.timestamp}`)
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .width('86%')
      .height(70)
      .margin({ top: 16 })
      .padding({ left: 8, right: 8 })

      Row() {
        Text(this.viewState.isLoading ? 'Refreshing…' : 'Tap to refresh')
          .fontSize(11)
          .fontColor($r('app.color.watch_text_hint'))
      }
      .margin({ top: 8 })
      .onClick(() => this.onRefresh())
    }
    .width('100%')
    .height('100%')
    .padding({ top: 60, bottom: 60, left: 20, right: 20 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildMetric(value: string, label: string) {
    Column() {
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.watch_text_primary'))
      Text(label)
        .fontSize(10)
        .fontColor($r('app.color.watch_text_hint'))
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildHourCell(hour: HourlyForecast) {
    Column() {
      Text(this.formatHour(hour.timestamp))
        .fontSize(10)
        .fontColor($r('app.color.watch_text_hint'))
      Text(weatherConditionGlyph(hour.condition, true))
        .fontSize(18)
        .margin({ top: 2 })
      Text(`${Math.round(hour.temperatureC)}°`)
        .fontSize(12)
        .fontColor($r('app.color.watch_text_primary'))
        .margin({ top: 2 })
    }
    .width(44)
    .alignItems(HorizontalAlign.Center)
  }

  private formatHour(ts: number): string {
    const d = new Date(ts);
    const h = d.getHours();
    return `${h.toString().padStart(2, '0')}h`;
  }
}
