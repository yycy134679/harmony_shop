// 202506120141 杨富涛
// 订单列表项组件，用于显示订单信息

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
            .fontSize(13)
            .fontColor('#333')
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 2 })

          Text(this.orderViewModel.formatOrderTime(this.order.createTime))
            .fontSize(11)
            .fontColor('#999')
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(this.orderViewModel.getStatusDisplayText(this.order.status))
          .fontSize(13)
          .fontColor(this.orderViewModel.getStatusColor(this.order.status))
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .margin({ bottom: 6 })

      // 商品信息（显示第一个商品和总数量）
      Row() {
        // 商品图片（使用真实商品图片）
        Stack({ alignContent: Alignment.Center }) {
          Image(this.orderViewModel.getMainProductImageUrl(this.order))
            .width(45)
            .height(45)
            .objectFit(ImageFit.Contain)
            .backgroundColor('#FFFFFF')
            .onError(() => {
              console.error(`Failed to load order product image`);
            })
        }
        .width(45)
        .height(45)
        .backgroundColor('#f9f9f9')
        .borderRadius(6)
        .margin({ right: 10 })

        Column() {
          Text(this.orderViewModel.getMainProductName(this.order))
            .fontSize(13)
            .fontColor('#333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .margin({ bottom: 2 })

          Row() {
            Text(`共${this.orderViewModel.calculateTotalQuantity(this.order)}件商品`)
              .fontSize(11)
              .fontColor('#666')

            Blank()

            Text(`¥${this.order.totalPrice.toFixed(2)}`)
              .fontSize(15)
              .fontColor('#E41F19')
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')

          Row() {
            Text(`📍 ${this.order.shippingAddress.recipientName} ${this.order.shippingAddress.phone}`)
              .fontSize(11)
              .fontColor('#666')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
              .margin({ top: 2 })

            Button('查看详情')
              .fontSize(11)
              .fontColor('#ff6b35')
              .backgroundColor('transparent')
              .border({ width: 1, color: '#ff6b35' })
              .borderRadius(3)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .onClick(() => {
                if (this.onViewDetail) {
                  this.onViewDetail(this.order);
                }
              })
          }
          .width('100%')
          .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#fff')
    .borderRadius(6)
    .margin({ bottom: 6 })
  }
}
