//202306110141 杨富涛
//商品详情页 - 展示商品详细信息，支持收藏、加入购物车和立即购买

import { Product } from '../model/Product';
import { DataSource } from '../model/DataSource';
import { CartViewModel } from '../viewmodel/CartViewModel';
import { FavoriteViewModel } from '../viewmodel/FavoriteViewModel';
import { Constants } from '../common/Constants';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';

/**
 * 商品详情页
 * 展示商品图片、信息、价格、描述，支持收藏、加入购物车和立即购买
 */
@Entry
@Component
struct DetailsPage {
  @State product: Product | undefined = undefined; // 当前商品对象
  @State quantity: number = 1;                    // 购买数量
  @State isFavorite: boolean = false;             // 是否已收藏
  @StorageLink(Constants.IS_LOGGED_IN) isLoggedIn: boolean = false; // 登录状态
  private cartViewModel: CartViewModel = new CartViewModel();       // 购物车视图模型
  private favoriteViewModel: FavoriteViewModel = new FavoriteViewModel(); // 收藏视图模型

  /**
   * 生命周期 aboutToAppear
   * 初始化收藏视图模型，获取商品详情和收藏状态
   */
  async aboutToAppear() {
    try {
      await this.favoriteViewModel.init(getContext(this) as common.UIAbilityContext);

      // 获取路由参数
      const params = router.getParams() as Record<string, Object>;
      if (params && params.productId) {
        this.product = DataSource.getProductById(params.productId as number);

        // 检查收藏状态
        if (this.product && this.favoriteViewModel.isLoggedIn()) {
          this.isFavorite = await this.favoriteViewModel.checkFavoriteStatus(this.product.id);
        }
      }
    } catch (error) {
      console.error('Failed to initialize DetailsPage:', error);
    }
  }

  /**
   * 构建UI界面
   */
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button({ type: ButtonType.Circle }) {
          Text('←')
            .fontSize(20)
            .fontColor('#333')
        }
        .width(40)
        .height(40)
        .backgroundColor('#F5F5F5')
        .onClick(() => {
          router.back(); // 返回上一页
        })

        Blank()

        Text('商品详情')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')

        Blank()

        // 收藏按钮
        Button() {
          Text(this.isFavorite ? '已收藏' : '收藏')
            .fontSize(14)
            .fontColor(this.isFavorite ? '#E41F19' : '#666')
            .fontWeight(FontWeight.Medium)
        }
        .height(32)
        .padding({ left: 12, right: 12 })
        .backgroundColor('rgba(245, 245, 245, 0.8)')
        .border({ width: 1, color: this.isFavorite ? '#E41F19' : 'rgba(0, 0, 0, 0.1)' })
        .borderRadius(16)
        .onClick(async () => {
          if (!this.isLoggedIn) {
            promptAction.showToast({
              message: '请先登录后再收藏商品',
              duration: 2000
            });
            router.pushUrl({ url: 'pages/LoginPage' });
            return;
          }

          if (!this.product) {
            return;
          }

          // 实现收藏功能
          try {
            const result = await this.favoriteViewModel.toggleFavorite(this.product.id);
            if (result.success) {
              this.isFavorite = result.isFavorite;
              promptAction.showToast({
                message: result.message,
                duration: 2000
              });
            } else {
              promptAction.showToast({
                message: result.message,
                duration: 2000
              });
            }
          } catch (error) {
            console.error('Failed to toggle favorite:', error);
            promptAction.showToast({
              message: '操作失败，请重试',
              duration: 2000
            });
          }
        })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#fff')
      .shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.1)', offsetY: 2 })

      if (this.product) {
        Scroll() {
          Column() {
            // 商品图片
            Stack({ alignContent: Alignment.Center }) {
              Image(this.product.image)
                .width('100%')
                .height(300)
                .objectFit(ImageFit.Contain)
                .backgroundColor('#FFFFFF')
                .onError(() => {
                  console.error(`Failed to load image: ${this.product?.image}`);
                })
            }
            .width('100%')
            .height(300)
            .backgroundColor('#F9F9F9')
            .borderRadius(8)

            // 商品信息
            Column() {
              Text(this.product.name)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 12 })
                .textAlign(TextAlign.Start)
                .width('100%')

              Row() {
                Text(`¥${this.product.price.toFixed(2)}`)
                  .fontSize(28)
                  .fontColor('#E41F19')
                  .fontWeight(FontWeight.Bold)

                Blank()

                Text('现货')
                  .fontSize(12)
                  .fontColor('#4CAF50')
                  .backgroundColor('#E8F5E8')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(4)
              }
              .width('100%')
              .margin({ bottom: 16 })

              // 商品特色标签
              Row({ space: 8 }) {
                Text('正品保证')
                  .fontSize(10)
                  .fontColor('#E41F19')
                  .border({ width: 1, color: '#E41F19' })
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .borderRadius(2)

                Text('7天退换')
                  .fontSize(10)
                  .fontColor('#E41F19')
                  .border({ width: 1, color: '#E41F19' })
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .borderRadius(2)

                Text('全国包邮')
                  .fontSize(10)
                  .fontColor('#E41F19')
                  .border({ width: 1, color: '#E41F19' })
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .borderRadius(2)
              }
              .width('100%')
              .margin({ bottom: 20 })

              if (this.product.description) {
                Text('商品详情')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 8 })
                  .textAlign(TextAlign.Start)
                  .width('100%')

                Text(this.product.description)
                  .fontSize(14)
                  .fontColor('#666')
                  .lineHeight(22)
                  .textAlign(TextAlign.Start)
                  .width('100%')
              }
            }
            .width('100%')
            .padding(16)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor('#fff')
            .margin({ top: 8 })
            .borderRadius(8)

            // 数量选择和规格
            Column() {
              // 数量选择
              Row() {
                Text('数量:')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .margin({ right: 16 })

                Row() {
                  Text('-')
                    .width(36)
                    .height(36)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.Center)
                    .fontColor(this.quantity > 1 ? '#E41F19' : '#CCCCCC')
                    .border({ width: 1, color: this.quantity > 1 ? '#E41F19' : '#CCCCCC' })
                    .borderRadius(4)
                    .backgroundColor('#FFFFFF')
                    .onClick(() => {
                      if (this.quantity > 1) {
                        this.quantity--;
                      }
                    })

                  Text(this.quantity.toString())
                    .width(50)
                    .height(36)
                    .textAlign(TextAlign.Center)
                    .fontSize(16)
                    .margin({ left: 8, right: 8 })
                    .border({ width: 1, color: '#E0E0E0' })
                    .borderRadius(4)
                    .backgroundColor('#FFFFFF')

                  Text('+')
                    .width(36)
                    .height(36)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.Center)
                    .fontColor('#E41F19')
                    .border({ width: 1, color: '#E41F19' })
                    .borderRadius(4)
                    .backgroundColor('#FFFFFF')
                    .onClick(() => {
                      this.quantity++;
                    })
                }
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .margin({ bottom: 16 })
              .justifyContent(FlexAlign.Start)

              // 配送信息
              Row() {
                Text('配送:')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .margin({ right: 16 })

                Text('全国包邮 · 预计1-3天到达')
                  .fontSize(14)
                  .fontColor('#666')
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#fff')
            .margin({ top: 8 })
            .alignItems(HorizontalAlign.Start)
            .borderRadius(8)
          }
        }
        .layoutWeight(1)

        // 底部操作栏
        Row() {
          Button('加入购物车')
            .layoutWeight(1)
            .height(50)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#FFA500')
            .fontColor('#FFFFFF')
            .margin({ right: 8 })
            .borderRadius(25)
            .onClick(() => {
              if (!this.isLoggedIn) {
                promptAction.showToast({
                  message: '请先登录后再加入购物车',
                  duration: 2000
                });
                router.pushUrl({ url: 'pages/LoginPage' });
                return;
              }

              if (this.product) {
                this.cartViewModel.addToCart(this.product, this.quantity);
                promptAction.showToast({
                  message: `已将 ${this.product.name} 加入购物车`,
                  duration: 2000
                });
              }
            })

          Button('立即购买')
            .layoutWeight(1)
            .height(50)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#E41F19')
            .fontColor('#FFFFFF')
            .margin({ left: 8 })
            .borderRadius(25)
            .onClick(() => {
              if (!this.isLoggedIn) {
                promptAction.showToast({
                  message: '请先登录后再购买',
                  duration: 2000
                });
                router.pushUrl({ url: 'pages/LoginPage' });
                return;
              }

              if (this.product) {
                // 立即购买：先添加到购物车，然后直接跳转到订单确认页面
                this.cartViewModel.addToCart(this.product, this.quantity);
                router.pushUrl({
                  url: 'pages/OrderConfirmationPage'
                });
              }
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#fff')
        .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetY: -2 })
      } else {
        // 商品不存在时的提示
        Column() {
          Text('商品不存在')
            .fontSize(16)
            .fontColor('#999')
          
          Button('返回')
            .margin({ top: 20 })
            .onClick(() => {
              router.back();
            })
        }
        .width('100%')
        .height('60%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
