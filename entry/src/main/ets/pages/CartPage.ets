//202306110141 杨富涛
//购物车页面 - 用于展示用户添加的商品，管理商品数量，计算总价并进行结算

import { CartViewModel } from '../viewmodel/CartViewModel';
import { CartItem } from '../model/CartItem';
import { Constants } from '../common/Constants';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

/**
 * 购物车页面
 * 用于展示用户添加的商品，管理商品数量，计算总价并进行结算
 */
@Entry
@Component
struct CartPage {
  @StorageLink(Constants.SHOPPING_CART) cartItems: CartItem[] = []; // 购物车商品列表，通过StorageLink绑定
  private cartViewModel: CartViewModel = new CartViewModel(); // 购物车数据视图模型

  /**
   * 构建UI界面
   */
  build() {
    Column() {
      // 标题栏
      Row() {
        Button('返回')
          .onClick(() => {
            router.back(); // 返回上一页
          })
          .margin({ left: 16 })

        Text('购物车')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text(`共${this.cartItems.reduce((total, item) => total + item.quantity, 0)}件商品`) // 显示商品总数量
          .fontSize(14)
          .fontColor('#666')
          .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#f8f8f8')

      if (this.cartItems.length === 0) {
        // 空购物车状态 - 当购物车没有商品时显示
        Column() {
          Text('购物车是空的')
            .fontSize(16)
            .fontColor('#999')
          
          Button('去购物')
            .margin({ top: 20 })
            .onClick(() => {
              router.back(); // 返回上一页去购物
            })
        }
        .width('100%')
        .height('60%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 购物车列表 - 显示所有添加的商品
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

                // 商品信息 - 名称和价格
                Column() {
                  Text(item.product.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                  
                  Text(`¥${item.product.price.toFixed(2)}`) // 格式化价格显示
                    .fontSize(14)
                    .fontColor('#ff6b35')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                // 数量控制 - 减少、显示数量、增加
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
                      this.cartViewModel.decreaseQuantity(item.product.id); // 减少商品数量
                    })

                  Text(item.quantity.toString()) // 显示当前数量
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
                      this.cartViewModel.increaseQuantity(item.product.id); // 增加商品数量
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

        // 底部结算栏 - 显示总价和结算按钮
        Row() {
          Column() {
            Text(`总计: ${this.cartViewModel.formatPrice(this.cartItems.reduce((total, item) => total + (item.product.price * item.quantity), 0))}`) // 计算并显示总价
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
              // 验证购物车
              const validation = this.cartViewModel.canCheckout();
              if (!validation.canCheckout) {
                promptAction.showToast({
                  message: validation.message,
                  duration: 2000
                });
                return;
              }

              // 跳转到订单确认页面
              router.pushUrl({
                url: 'pages/OrderConfirmationPage'
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
