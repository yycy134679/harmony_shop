import { CartViewModel } from '../viewmodel/CartViewModel';
import router from '@ohos.router';

/**
 * 结算成功页面
 */
@Entry
@Component
struct CheckoutSuccessPage {
  private cartViewModel: CartViewModel = new CartViewModel();

  aboutToAppear() {
    // 页面初始化
  }

  build() {
    Column() {
      // 成功图标和文字
      Column() {
        Text('✓')
          .fontSize(80)
          .fontColor('#4CAF50')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })

        Text('支付成功！')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 8 })

        Text('您的订单已提交，我们会尽快为您处理')
          .fontSize(16)
          .fontColor('#666')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 40 })
      }
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)

      // 操作按钮
      Column() {
        Button('继续购物')
          .width('80%')
          .height(50)
          .backgroundColor('#ff6b35')
          .margin({ bottom: 16 })
          .onClick(() => {
            router.clear();
            router.pushUrl({
              url: 'view/BottomTabs'
            });
          })

        Button('查看订单')
          .width('80%')
          .height(50)
          .backgroundColor('#fff')
          .fontColor('#ff6b35')
          .border({ width: 1, color: '#ff6b35' })
          .onClick(() => {
            // TODO: 跳转到订单页面
            console.log('查看订单功能待实现');
          })
      }
      .width('100%')
      .padding({ bottom: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
    .justifyContent(FlexAlign.Center)
  }
}
