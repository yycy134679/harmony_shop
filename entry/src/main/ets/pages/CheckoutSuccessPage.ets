import { CartViewModel } from '../viewmodel/CartViewModel';
import router from '@ohos.router';

/**
 * 结算成功页面
 */
@Entry
@Component
struct CheckoutSuccessPage {
  @State orderId: string = '';
  @State totalPrice: number = 0;
  private cartViewModel: CartViewModel = new CartViewModel();

  aboutToAppear() {
    // 获取传入的订单信息
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      this.orderId = (params.orderId as string) || '';
      this.totalPrice = (params.totalPrice as number) || 0;
    }
  }

  build() {
    Column() {
      // 成功图标和文字
      Column() {
        Image($r('sys.symbol.checkmark_circle_fill'))
          .width(80)
          .height(80)
          .fillColor('#4CAF50')
          .margin({ bottom: 20 })

        Text('支付成功！')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .margin({ bottom: 8 })

        if (this.orderId) {
          Text(`订单号：${this.orderId}`)
            .fontSize(14)
            .fontColor('#666')
            .margin({ bottom: 4 })
        }

        if (this.totalPrice > 0) {
          Text(`支付金额：¥${this.totalPrice.toFixed(2)}`)
            .fontSize(16)
            .fontColor('#E41F19')
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
        }

        Text('您的订单已提交，我们会尽快为您处理')
          .fontSize(14)
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
            router.clear();
            router.pushUrl({ url: 'pages/OrderListPage' });
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
