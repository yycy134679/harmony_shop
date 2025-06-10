import { Order } from '../model/Order';
import { OrderViewModel } from '../viewmodel/OrderViewModel';

/**
 * 订单列表项组件
 */
@Component
export struct OrderItem {
  @Prop order: Order;
  onViewDetail?: (order: Order) => void;
  private orderViewModel: OrderViewModel = new OrderViewModel();

  build() {
    Column() {
      // 订单头部信息
      Row() {
        Column() {
          Text(`订单号：${this.order.orderId}`)
            .fontSize(14)
            .fontColor('#333')
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 4 })

          Text(this.orderViewModel.formatOrderTime(this.order.createTime))
            .fontSize(12)
            .fontColor('#999')
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(this.orderViewModel.getStatusDisplayText(this.order.status))
          .fontSize(14)
          .fontColor(this.orderViewModel.getStatusColor(this.order.status))
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 商品信息（显示第一个商品和总数量）
      Row() {
        // 商品图片（使用第一个商品的图片，这里需要从DataSource获取）
        Image($r('sys.symbol.bag'))
          .width(60)
          .height(60)
          .fillColor('#ddd')
          .backgroundColor('#f9f9f9')
          .borderRadius(8)
          .margin({ right: 12 })

        Column() {
          Text(this.orderViewModel.getMainProductName(this.order))
            .fontSize(14)
            .fontColor('#333')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .margin({ bottom: 4 })

          Row() {
            Text(`共${this.orderViewModel.calculateTotalQuantity(this.order)}件商品`)
              .fontSize(12)
              .fontColor('#666')

            Blank()

            Text(`¥${this.order.totalPrice.toFixed(2)}`)
              .fontSize(16)
              .fontColor('#E41F19')
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 收货地址信息
      Row() {
        Image($r('sys.symbol.house'))
          .width(16)
          .height(16)
          .fillColor('#666')
          .margin({ right: 6 })

        Text(`${this.order.shippingAddress.recipientName} ${this.order.shippingAddress.phone}`)
          .fontSize(12)
          .fontColor('#666')
          .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 操作按钮区域
      Row() {
        Text(`支付方式：${this.order.paymentMethod}`)
          .fontSize(12)
          .fontColor('#666')

        Blank()

        Button('查看详情')
          .fontSize(12)
          .fontColor('#ff6b35')
          .backgroundColor('transparent')
          .border({ width: 1, color: '#ff6b35' })
          .borderRadius(4)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .onClick(() => {
            if (this.onViewDetail) {
              this.onViewDetail(this.order);
            }
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(8)
    .margin({ bottom: 12 })
  }
}
