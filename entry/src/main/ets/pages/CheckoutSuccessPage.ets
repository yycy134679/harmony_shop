//202306110141 杨富涛
//结算成功页面 - 用于展示订单支付成功后的提示和操作

import { CartViewModel } from '../viewmodel/CartViewModel';
import router from '@ohos.router';

/**
 * 结算成功页面
 * 展示订单支付成功信息，并提供继续购物和查看订单的操作
 */
@Entry
@Component
struct CheckoutSuccessPage {
  @State orderId: string = '';         // 当前订单号
  @State totalPrice: number = 0;      // 支付总金额
  private cartViewModel: CartViewModel = new CartViewModel(); // 购物车视图模型

  /**
   * 生命周期 aboutToAppear
   * 获取路由参数中的订单信息
   */
  aboutToAppear() {
    // 获取传入的订单信息
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      this.orderId = (params.orderId as string) || '';
      this.totalPrice = (params.totalPrice as number) || 0;
    }
  }

  /**
   * 构建UI界面
   */
  build() {
    Column() {
      // 成功图标和文字区域
      Column() {
        Text('✅')
          .fontSize(60)
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

      // 操作按钮区域
      Column() {
        Button('继续购物')
          .width('80%')
          .height(50)
          .backgroundColor('#ff6b35')
          .margin({ bottom: 16 })
          .onClick(() => {
            router.clear(); // 清空页面栈
            router.pushUrl({
              url: 'view/BottomTabs' // 跳转到首页
            });
          })

        Button('查看订单')
          .width('80%')
          .height(50)
          .backgroundColor('#fff')
          .fontColor('#ff6b35')
          .border({ width: 1, color: '#ff6b35' })
          .onClick(() => {
            router.clear(); // 清空页面栈
            router.pushUrl({ url: 'pages/OrderListPage' }); // 跳转到订单列表
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
