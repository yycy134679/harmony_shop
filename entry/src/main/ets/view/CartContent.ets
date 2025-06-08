// 购物车内容组件
import { CartViewModel } from '../viewmodel/CartViewModel';
import { CartItem } from '../model/CartItem';
import { Constants } from '../common/Constants';
import router from '@ohos.router';

@Component
export struct CartContent {
  @StorageLink(Constants.SHOPPING_CART) cartItems: CartItem[] = [];
  private cartViewModel: CartViewModel = new CartViewModel();

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('购物车')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
        
        Blank()
        
        Text(`共${this.cartItems.reduce((total, item) => total + item.quantity, 0)}件商品`)
          .fontSize(14)
          .fontColor('#666')
          .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#f8f8f8')

      if (this.cartItems.length === 0) {
        // 空购物车状态
        Column() {
          Text('购物车是空的')
            .fontSize(16)
            .fontColor('#999')
          
          Text('去首页看看吧')
            .fontSize(14)
            .fontColor('#666')
            .margin({ top: 10 })
        }
        .width('100%')
        .height('60%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 购物车列表
        List() {
          ForEach(this.cartItems, (item: CartItem) => {
            ListItem() {
              Row() {
                // 商品图片
                Stack({ alignContent: Alignment.Center }) {
                  Image(item.product.image)
                    .width(60)
                    .height(60)
                    .objectFit(ImageFit.Contain)
                    .backgroundColor('#FFFFFF')
                    .onError(() => {
                      console.error(`Failed to load image: ${item.product.image}`);
                    })
                }
                .width(60)
                .height(60)
                .backgroundColor('#F9F9F9')
                .borderRadius(8)
                .margin({ right: 12 })

                Column() {
                  Text(item.product.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                  
                  Text(`¥${item.product.price.toFixed(2)}`)
                    .fontSize(14)
                    .fontColor('#ff6b35')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                // 数量控制
                Row() {
                  Text('-')
                    .width(32)
                    .height(32)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.Center)
                    .fontColor('#E41F19')
                    .border({ width: 1, color: '#E41F19' })
                    .borderRadius(4)
                    .backgroundColor('#FFFFFF')
                    .onClick(() => {
                      this.cartViewModel.decreaseQuantity(item.product.id);
                    })

                  Text(item.quantity.toString())
                    .width(40)
                    .height(32)
                    .textAlign(TextAlign.Center)
                    .fontSize(16)
                    .margin({ left: 8, right: 8 })
                    .border({ width: 1, color: '#E0E0E0' })
                    .borderRadius(4)
                    .backgroundColor('#FFFFFF')

                  Text('+')
                    .width(32)
                    .height(32)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.Center)
                    .fontColor('#E41F19')
                    .border({ width: 1, color: '#E41F19' })
                    .borderRadius(4)
                    .backgroundColor('#FFFFFF')
                    .onClick(() => {
                      this.cartViewModel.increaseQuantity(item.product.id);
                    })
                }
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .padding(16)
            }
          })
        }
        .layoutWeight(1)

        // 底部结算栏
        Row() {
          Column() {
            Text(`总计: ${this.cartViewModel.formatPrice(this.cartItems.reduce((total, item) => total + (item.product.price * item.quantity), 0))}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#ff6b35')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button('结算')
            .width(100)
            .height(40)
            .backgroundColor('#ff6b35')
            .onClick(() => {
              // 清空购物车
              this.cartViewModel.clearCart();
              // 跳转到结算成功页面
              router.pushUrl({
                url: 'pages/CheckoutSuccessPage'
              });
            })
        }
        .width('100%')
        .height(80)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#fff')
        .border({ width: { top: 1 }, color: '#e0e0e0' })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
