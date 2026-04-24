/**
 * Watch-optimised loading indicator.
 * Centered on the black circular canvas with a short inline label.
 */
@Component
export struct LoadingView {
  @Prop message: string = 'Loading...';

  build() {
    Column() {
      LoadingProgress()
        .width(56)
        .height(56)
        .color($r('app.color.watch_accent'))

      Text(this.message)
        .fontSize(14)
        .fontColor($r('app.color.watch_text_secondary'))
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.watch_bg'))
  }
}
