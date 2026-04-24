/**
 * Watch-optimised error view with retry button.
 * Sized for a 466×466 round screen — content fits inside an inscribed square.
 */
@Component
export struct ErrorView {
  @Prop message: string = 'Something went wrong';
  @Prop showRetry: boolean = true;
  onRetry: () => void = () => {};

  build() {
    Column() {
      Text('⚠️')
        .fontSize(40)

      Text(this.message)
        .fontSize(14)
        .fontColor($r('app.color.watch_text_primary'))
        .textAlign(TextAlign.Center)
        .margin({ top: 12, left: 24, right: 24 })
        .maxLines(3)

      if (this.showRetry) {
        Button($r('app.string.retry'))
          .type(ButtonType.Capsule)
          .backgroundColor($r('app.color.watch_accent'))
          .fontColor(Color.Black)
          .fontSize(14)
          .height(36)
          .padding({ left: 20, right: 20 })
          .margin({ top: 16 })
          .onClick(() => this.onRetry())
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.watch_bg'))
  }
}
