import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { CartViewModel } from '../viewmodel/CartViewModel';
import { CartItem } from '../model/CartItem';
import { Address } from '../model/Address';
import common from '@ohos.app.ability.common';

/**
 * 订单确认页面
 */
@Entry
@Component
struct OrderConfirmationPage {
  @State cartItems: CartItem[] = [];
  @State selectedAddress: Address | null = null;
  @State totalPrice: number = 0;
  @State isLoading: boolean = false;
  @State paymentMethod: '微信支付' | '支付宝' | '云闪付' = '微信支付';
  private cartViewModel: CartViewModel = new CartViewModel();

  async aboutToAppear() {
    try {
      await this.cartViewModel.init(getContext(this) as common.UIAbilityContext);

      // 获取购物车商品
      this.cartItems = this.cartViewModel.getCartItems();
      this.totalPrice = this.cartViewModel.getTotalPrice();

      // 检查是否有传入的选中地址
      const params = router.getParams() as Record<string, Object>;
      if (params && params.selectedAddress) {
        this.selectedAddress = params.selectedAddress as Address;
      } else {
        // 获取默认地址
        this.selectedAddress = await this.cartViewModel.getDefaultAddress();
      }

      // 验证购物车
      const validation = this.cartViewModel.canCheckout();
      if (!validation.canCheckout) {
        promptAction.showToast({
          message: validation.message,
          duration: 2000
        });
        router.back();
      }
    } catch (error) {
      console.error('Failed to initialize OrderConfirmationPage:', error);
      promptAction.showToast({
        message: '页面初始化失败',
        duration: 2000
      });
      router.back();
    }
  }

  /**
   * 选择收货地址
   */
  private selectAddress(): void {
    router.pushUrl({
      url: 'pages/AddressSelectionPage',
      params: {
        selectedAddressId: this.selectedAddress?.id || ''
      }
    });
  }

  /**
   * 显示支付方式选择对话框
   */
  private showPaymentDialog(): void {
    if (!this.selectedAddress) {
      promptAction.showToast({
        message: '请先选择收货地址',
        duration: 2000
      });
      return;
    }

    ActionSheet.show({
      title: '选择支付方式',
      message: '请选择您的支付方式',
      sheets: [
        {
          title: '微信支付',
          action: () => {
            this.paymentMethod = '微信支付';
            this.processPayment();
          }
        },
        {
          title: '支付宝',
          action: () => {
            this.paymentMethod = '支付宝';
            this.processPayment();
          }
        },
        {
          title: '云闪付',
          action: () => {
            this.paymentMethod = '云闪付';
            this.processPayment();
          }
        }
      ]
    });
  }

  /**
   * 处理支付
   */
  private async processPayment(): Promise<void> {
    if (this.isLoading) return;

    if (!this.selectedAddress) {
      promptAction.showToast({
        message: '请先选择收货地址',
        duration: 2000
      });
      return;
    }

    this.isLoading = true;
    try {
      // 模拟支付延迟
      await new Promise<void>(resolve => setTimeout(resolve, 1500));

      // 创建订单
      const result = await this.cartViewModel.createOrderAndClearCart(
        this.selectedAddress,
        this.paymentMethod
      );

      if (result.success) {
        // 支付成功，跳转到成功页面
        router.replaceUrl({
          url: 'pages/CheckoutSuccessPage',
          params: {
            orderId: result.orderId,
            totalPrice: this.totalPrice
          }
        });
      } else {
        promptAction.showToast({
          message: result.message,
          duration: 2000
        });
      }
    } catch (error) {
      console.error('Payment failed:', error);
      promptAction.showToast({
        message: '支付失败，请重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
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
        .backgroundColor('transparent')
        .onClick(() => router.back())

        Text('确认订单')
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

      Scroll() {
        Column() {
          // 收货地址区域
          Column() {
            Row() {
              Text('🏠')
                .fontSize(16)
                .margin({ right: 8 })

              Text('收货地址')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333')
                .layoutWeight(1)

              Text('→')
                .fontSize(14)
                .fontColor('#ccc')
            }
            .width('100%')
            .margin({ bottom: 12 })

            if (this.selectedAddress) {
              Column() {
                Row() {
                  Text(this.selectedAddress.recipientName)
                    .fontSize(16)
                    .fontColor('#333')
                    .margin({ right: 12 })

                  Text(this.selectedAddress.phone)
                    .fontSize(14)
                    .fontColor('#666')
                }
                .width('100%')
                .margin({ bottom: 8 })

                Text(this.selectedAddress.fullAddress)
                  .fontSize(14)
                  .fontColor('#666')
                  .width('100%')
                  .textAlign(TextAlign.Start)
              }
              .alignItems(HorizontalAlign.Start)
            } else {
              Text('请选择收货地址')
                .fontSize(14)
                .fontColor('#999')
                .width('100%')
                .textAlign(TextAlign.Start)
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#fff')
          .borderRadius(8)
          .margin({ top: 12, left: 16, right: 16, bottom: 12 })
          .onClick(() => this.selectAddress())

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

            ForEach(this.cartItems, (item: CartItem) => {
              Row() {
                Image(item.product.image)
                  .width(60)
                  .height(60)
                  .objectFit(ImageFit.Contain)
                  .backgroundColor('#f9f9f9')
                  .borderRadius(8)
                  .margin({ right: 12 })

                Column() {
                  Text(item.product.name)
                    .fontSize(14)
                    .fontColor('#333')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                    .margin({ bottom: 4 })

                  Row() {
                    Text(`¥${item.product.price.toFixed(2)}`)
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
            }, (item: CartItem) => `${item.product.id}`)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#fff')
          .borderRadius(8)
          .margin({ left: 16, right: 16, bottom: 12 })

          // 价格明细
          Column() {
            Row() {
              Text('商品总价')
                .fontSize(14)
                .fontColor('#666')

              Blank()

              Text(`¥${this.totalPrice.toFixed(2)}`)
                .fontSize(14)
                .fontColor('#333')
            }
            .width('100%')
            .margin({ bottom: 8 })

            Row() {
              Text('运费')
                .fontSize(14)
                .fontColor('#666')

              Blank()

              Text('免运费')
                .fontSize(14)
                .fontColor('#4CAF50')
            }
            .width('100%')
            .margin({ bottom: 12 })

            Divider().color('#f0f0f0').margin({ bottom: 12 })

            Row() {
              Text('实付款')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333')

              Blank()

              Text(`¥${this.totalPrice.toFixed(2)}`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#E41F19')
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#fff')
          .borderRadius(8)
          .margin({ left: 16, right: 16, bottom: 80 })
        }
      }
      .layoutWeight(1)

      // 底部支付栏
      Row() {
        Column() {
          Text('实付款')
            .fontSize(12)
            .fontColor('#666')

          Text(`¥${this.totalPrice.toFixed(2)}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E41F19')
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Button(this.isLoading ? '支付中...' : '确认支付')
          .width(120)
          .height(44)
          .backgroundColor('#E41F19')
          .fontColor('#fff')
          .fontSize(16)
          .borderRadius(22)
          .enabled(!this.isLoading)
          .onClick(() => this.showPaymentDialog())
      }
      .width('100%')
      .height(80)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#fff')
      .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetY: -2 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
