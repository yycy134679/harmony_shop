// 202306110141 杨富涛
// 订单确认页面 - 展示购物车商品、收货地址、价格明细，支持选择支付方式和下单

import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { CartViewModel } from '../viewmodel/CartViewModel';
import { CartItem } from '../model/CartItem';
import { Address } from '../model/Address';
import common from '@ohos.app.ability.common';

/**
 * 订单确认页面
 * 展示购物车商品、收货地址、价格明细，支持选择支付方式和下单
 */
@Entry
@Component
struct OrderConfirmationPage {
  @State cartItems: CartItem[] = []; // 购物车商品列表
  @State selectedAddress: Address | null = null; // 当前选中的收货地址
  @State totalPrice: number = 0; // 总价
  @State isLoading: boolean = false; // 支付中状态
  @State paymentMethod: '微信支付' | '支付宝' | '云闪付' = '微信支付'; // 支付方式
  @State showPaymentDialog: boolean = false; // 是否显示支付方式弹窗
  private cartViewModel: CartViewModel = new CartViewModel(); // 购物车视图模型

  /**
   * 生命周期 aboutToAppear
   * 初始化购物车视图模型，加载购物车商品、默认地址、校验购物车
   */
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
   * 跳转选择收货地址页面
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
  private openPaymentDialog(): void {
    if (!this.selectedAddress) {
      promptAction.showToast({
        message: '请先选择收货地址',
        duration: 2000
      });
      return;
    }
    this.showPaymentDialog = true;
  }

  /**
   * 关闭支付方式选择对话框
   */
  private closePaymentDialog(): void {
    this.showPaymentDialog = false;
  }

  /**
   * 选择支付方式
   */
  private selectPaymentMethod(method: '微信支付' | '支付宝' | '云闪付'): void {
    this.paymentMethod = method;
  }

  /**
   * 处理支付
   * 校验收货地址，模拟支付，创建订单并跳转到支付成功页面
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

  /**
   * 构建UI界面
   */
  build() {
    Stack() {
      // 主要内容
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
          .onClick(() => this.openPaymentDialog())
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

      // 支付方式选择弹窗
      if (this.showPaymentDialog) {
        this.buildPaymentDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 构建支付方式选择弹窗
   */
  @Builder
  buildPaymentDialog() {
    Stack() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => this.closePaymentDialog())

      // 弹窗内容
      Column() {
        // 弹窗顶部装饰条
        Row()
          .width(40)
          .height(4)
          .backgroundColor('#e0e0e0')
          .borderRadius(2)
          .margin({ top: 12, bottom: 16 })

        // 弹窗标题
        Row() {
          Column() {
            Text('选择支付方式')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .margin({ bottom: 4 })

            Text('请选择您的支付方式')
              .fontSize(14)
              .fontColor('#666')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Button() {
            Text('×')
              .fontSize(18)
              .fontColor('#999')
          }
          .width(36)
          .height(36)
          .backgroundColor('#f5f5f5')
          .borderRadius(18)
          .onClick(() => this.closePaymentDialog())
        }
        .width('100%')
        .padding({ left: 24, right: 24, bottom: 24 })

        // 支付方式列表
        Column() {
          this.buildPaymentOption('微信支付', '💚', '微信支付', '#1AAD19', false)
          this.buildPaymentOption('支付宝', '', '支付宝', '#1677FF', true, 'https://bed.djxs.xyz/file/BQACAgUAAyEGAASVl6k_AAIE-2hJi_yPv17fizJwZ0qf7q4hTImPAAK4GAACTEFQViSAqI-IBgaXNgQ.png')
          this.buildPaymentOption('云闪付', '🔴', '云闪付', '#E6002D', false)
        }
        .padding({ left: 24, right: 24 })
        .margin({ bottom: 32 })

        // 支付金额区域
        Column() {
          Row() {
            Text('支付金额')
              .fontSize(14)
              .fontColor('#666')
              .layoutWeight(1)

            Text(`¥${this.totalPrice.toFixed(2)}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#E41F19')
          }
          .width('100%')
          .padding({ left: 24, right: 24, top: 20, bottom: 20 })
        }
        .width('100%')
        .backgroundColor('#fafafa')
        .margin({ bottom: 24 })

        // 按钮区域
        Row() {
          Button('取消')
            .width('calc(50% - 32vp)')
            .height(48)
            .backgroundColor('#f5f5f5')
            .fontColor('#666')
            .fontSize(16)
            .borderRadius(24)
            .onClick(() => this.closePaymentDialog())

          Button('确认支付')
            .width('calc(50% - 32vp)')
            .height(48)
            .backgroundColor('#E41F19')
            .fontColor('#fff')
            .fontSize(16)
            .borderRadius(24)
            .onClick(() => {
              this.closePaymentDialog();
              this.processPayment();
            })
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('92%')
      .constraintSize({ maxWidth: 400 })
      .backgroundColor('#fff')
      .borderRadius(20)
      .shadow({ radius: 30, color: 'rgba(0, 0, 0, 0.15)', offsetY: 8 })
      .padding({ bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }

  /**
   * 构建支付方式选项
   */
  @Builder
  buildPaymentOption(title: string, icon: string, method: '微信支付' | '支付宝' | '云闪付', brandColor: string, useImageIcon: boolean = false, imageUrl?: string) {
    Row() {
      // 支付方式图标容器
      Row() {
        if (useImageIcon && imageUrl) {
          Image(imageUrl)
            .width(24)
            .height(24)
            .objectFit(ImageFit.Contain)
            .onError(() => {
              console.error(`Failed to load payment icon: ${imageUrl}`);
            })
        } else {
          Text(icon)
            .fontSize(20)
            .fontColor('#fff')
        }
      }
      .width(40)
      .height(40)
      .backgroundColor(brandColor)
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 16 })

      // 支付方式信息
      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
          .margin({ bottom: 2 })

        Text('安全快捷支付')
          .fontSize(12)
          .fontColor('#999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 选中状态
      Row() {
        if (this.paymentMethod === method) {
          Text('✓')
            .fontSize(16)
            .fontColor('#fff')
            .fontWeight(FontWeight.Bold)
        }
      }
      .width(24)
      .height(24)
      .backgroundColor(this.paymentMethod === method ? '#E41F19' : '#f0f0f0')
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(72)
    .padding({ left: 20, right: 20, top: 8, bottom: 8 })
    .backgroundColor(this.paymentMethod === method ? '#fff5f5' : '#fff')
    .border({
      width: this.paymentMethod === method ? 1 : 0,
      color: this.paymentMethod === method ? '#E41F19' : 'transparent'
    })
    .borderRadius(8)
    .margin({ bottom: 8 })
    .onClick(() => this.selectPaymentMethod(method))
  }
}
