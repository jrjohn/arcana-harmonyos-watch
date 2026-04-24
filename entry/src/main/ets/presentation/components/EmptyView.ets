/**
 * Watch-optimised empty state (pre-fetch or no-data).
 */
@Component
export struct EmptyView {
  @Prop title: string = '';
  @Prop message: string = '';

  build() {
    Column() {
      Text('📡')
        .fontSize(40)

      if (this.title.length > 0) {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.watch_text_primary'))
          .margin({ top: 12 })
      }

      if (this.message.length > 0) {
        Text(this.message)
          .fontSize(13)
          .fontColor($r('app.color.watch_text_secondary'))
          .textAlign(TextAlign.Center)
          .margin({ top: 6, left: 24, right: 24 })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.watch_bg'))
  }
}
