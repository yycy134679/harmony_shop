import router from '@ohos.router';
import { Order } from '../model/Order';
import { OrderItem as OrderItemModel } from '../model/OrderItem';
import { OrderViewModel } from '../viewmodel/OrderViewModel';

/**
 * 订单详情页面
 */
@Entry
@Component
struct OrderDetailPage {
  @State order: Order | null = null;
  private orderViewModel: OrderViewModel = new OrderViewModel();

  aboutToAppear() {
    // 获取传入的订单信息
    const params = router.getParams() as Record<string, Object>;
    if (params && params.order) {
      this.order = params.order as Order;
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button() {
          Text('←')
            .fontSize(20)
            .fontColor('#333')
            .fontWeight(FontWeight.Bold)
        }
        .width(40)
        .height(40)
        .backgroundColor('#f0f0f0')
        .borderRadius(20)
        .onClick(() => router.back())

        Text('订单详情')
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

      if (this.order) {
        Scroll() {
          Column() {
            // 订单状态
            Column() {
              Row() {
                Text('✓')
                  .fontSize(20)
                  .fontColor(this.orderViewModel.getStatusColor(this.order.status))
                  .fontWeight(FontWeight.Bold)
                  .margin({ right: 12 })

                Column() {
                  Text(this.orderViewModel.getStatusDisplayText(this.order.status))
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333')
                    .width('100%')
                    .textAlign(TextAlign.Start)
                    .margin({ bottom: 4 })

                  Text(this.orderViewModel.formatOrderTime(this.order.createTime))
                    .fontSize(14)
                    .fontColor('#666')
                    .width('100%')
                    .textAlign(TextAlign.Start)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#fff')
            .margin({ top: 12, left: 16, right: 16 })
            .borderRadius(8)

            // 收货地址
            Column() {
              Row() {
                Text('🏠')
                  .fontSize(16)
                  .margin({ right: 8 })

                Text('收货地址')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333')
              }
              .width('100%')
              .margin({ bottom: 12 })

              Column() {
                Row() {
                  Text(this.order.shippingAddress.recipientName)
                    .fontSize(16)
                    .fontColor('#333')
                    .margin({ right: 12 })

                  Text(this.order.shippingAddress.phone)
                    .fontSize(14)
                    .fontColor('#666')
                }
                .width('100%')
                .margin({ bottom: 8 })

                Text(this.order.shippingAddress.fullAddress)
                  .fontSize(14)
                  .fontColor('#666')
                  .width('100%')
                  .textAlign(TextAlign.Start)
              }
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#fff')
            .margin({ top: 12, left: 16, right: 16 })
            .borderRadius(8)

            // 商品列表
            Column() {
              Row() {
                Text('🛍️')
                  .fontSize(16)
                  .margin({ right: 8 })

                Text('商品清单')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333')
              }
              .width('100%')
              .margin({ bottom: 12 })

              ForEach(this.order.items, (item: OrderItemModel) => {
                Row() {
                  Stack({ alignContent: Alignment.Center }) {
                    Image(this.orderViewModel.getProductImageUrl(item.productId))
                      .width(60)
                      .height(60)
                      .objectFit(ImageFit.Contain)
                      .backgroundColor('#FFFFFF')
                      .onError(() => {
                        console.error(`Failed to load product image for ID: ${item.productId}`);
                      })
                  }
                  .width(60)
                  .height(60)
                  .backgroundColor('#f9f9f9')
                  .borderRadius(8)
                  .margin({ right: 12 })

                  Column() {
                    Text(item.name)
                      .fontSize(14)
                      .fontColor('#333')
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('100%')
                      .margin({ bottom: 4 })

                    Row() {
                      Text(`¥${item.price.toFixed(2)}`)
                        .fontSize(16)
                        .fontColor('#E41F19')
                        .fontWeight(FontWeight.Medium)

                      Blank()

                      Text(`x${item.quantity}`)
                        .fontSize(14)
                        .fontColor('#666')
                    }
                    .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .padding({ top: 12, bottom: 12 })
                .border({ width: { bottom: 1 }, color: '#f0f0f0' })
              }, (item: OrderItemModel) => `${item.productId}`)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#fff')
            .margin({ top: 12, left: 16, right: 16 })
            .borderRadius(8)

            // 订单信息
            Column() {
              Row() {
                Text('订单号')
                  .fontSize(14)
                  .fontColor('#666')
                  .width(80)

                Text(this.order.orderId)
                  .fontSize(14)
                  .fontColor('#333')
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 12 })

              Row() {
                Text('支付方式')
                  .fontSize(14)
                  .fontColor('#666')
                  .width(80)

                Text(this.order.paymentMethod)
                  .fontSize(14)
                  .fontColor('#333')
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 12 })

              Row() {
                Text('商品总价')
                  .fontSize(14)
                  .fontColor('#666')
                  .width(80)

                Text(`¥${this.order.totalPrice.toFixed(2)}`)
                  .fontSize(14)
                  .fontColor('#333')
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 12 })

              Row() {
                Text('运费')
                  .fontSize(14)
                  .fontColor('#666')
                  .width(80)

                Text('免运费')
                  .fontSize(14)
                  .fontColor('#4CAF50')
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 12 })

              Divider().color('#f0f0f0').margin({ bottom: 12 })

              Row() {
                Text('实付款')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333')
                  .width(80)

                Text(`¥${this.order.totalPrice.toFixed(2)}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#E41F19')
                  .layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#fff')
            .margin({ top: 12, left: 16, right: 16, bottom: 20 })
            .borderRadius(8)
          }
        }
        .layoutWeight(1)
      } else {
        // 订单不存在
        Column() {
          Text('订单不存在')
            .fontSize(16)
            .fontColor('#999')
          
          Button('返回')
            .margin({ top: 20 })
            .onClick(() => {
              router.back();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
