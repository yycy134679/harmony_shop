import router from '@ohos.router';

/**
 * 我的订单页面（占位页面）
 */
@Entry
@Component
struct OrderListPage {
  build() {
    Column() {
      // 标题栏
      Row() {
        Button() {
          Image($r('sys.symbol.chevron_left'))
            .width(24)
            .height(24)
            .fillColor('#333')
        }
        .width(40)
        .height(40)
        .backgroundColor('transparent')
        .onClick(() => router.back())

        Text('我的订单')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位，保持标题居中
        Row().width(40).height(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#fff')

      // 占位内容
      Column() {
        Image($r('sys.symbol.list_bullet'))
          .width(80)
          .height(80)
          .fillColor('#ddd')
          .margin({ bottom: 16 })

        Text('订单管理功能')
          .fontSize(18)
          .fontColor('#333')
          .margin({ bottom: 8 })

        Text('此功能将在后续阶段开发')
          .fontSize(14)
          .fontColor('#666')
          .margin({ bottom: 24 })

        Button('返回')
          .width(120)
          .height(40)
          .backgroundColor('#ff6b35')
          .fontColor('#fff')
          .fontSize(16)
          .borderRadius(20)
          .onClick(() => {
            router.back();
          })
      }
      .width('100%')
      .height('80%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
