import { WeatherFeature } from '../presentation/features/WeatherFeature';
import { EarthquakeFeature } from '../presentation/features/EarthquakeFeature';

/**
 * Root @Entry page for the wearable app.
 *
 * A two-page Swiper:
 *   page 0 — WeatherFeature (current conditions + 6h forecast)
 *   page 1 — EarthquakeFeature (USGS 2.5_day feed, nearest first)
 *
 * Swiper is the idiomatic wearable gesture for "switch between glanceable
 * views" on a round screen (horizontal swipe + page indicator dots).
 * Indicator is kept minimal to avoid crowding the 466×466 canvas.
 */
@Entry
@Component
struct MainPage {
  @State private currentIndex: number = 0;

  build() {
    Swiper() {
      WeatherFeature()
      EarthquakeFeature()
    }
    .index(this.currentIndex)
    .loop(false)
    .autoPlay(false)
    .indicator(
      new DotIndicator()
        .color($r('app.color.watch_text_hint'))
        .selectedColor($r('app.color.watch_accent'))
        .itemWidth(5)
        .itemHeight(5)
        .selectedItemWidth(6)
        .selectedItemHeight(6)
    )
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.watch_bg'))
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }
}
