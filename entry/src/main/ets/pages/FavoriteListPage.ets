import router from '@ohos.router';
import { FavoriteViewModel } from '../viewmodel/FavoriteViewModel';
import { Product } from '../model/Product';
import promptAction from '@ohos.promptAction';

/**
 * 我的收藏页面
 */
@Entry
@Component
struct FavoriteListPage {
  @State favoriteProducts: Product[] = [];
  @State isLoading: boolean = true;
  private favoriteViewModel: FavoriteViewModel = new FavoriteViewModel();

  async aboutToAppear() {
    try {
      await this.favoriteViewModel.init(getContext(this) as Context);
      await this.loadFavoriteProducts();
    } catch (error) {
      console.error('Failed to initialize FavoriteListPage:', error);
    }
  }

  /**
   * 加载收藏商品列表
   */
  private async loadFavoriteProducts(): Promise<void> {
    this.isLoading = true;
    try {
      this.favoriteProducts = await this.favoriteViewModel.getFavoriteProducts();
    } catch (error) {
      console.error('Failed to load favorite products:', error);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 取消收藏
   */
  private async removeFavorite(productId: number): Promise<void> {
    try {
      const result = await this.favoriteViewModel.removeFavorite(productId);
      if (result.success) {
        promptAction.showToast({
          message: result.message,
          duration: 2000
        });
        // 重新加载收藏列表
        await this.loadFavoriteProducts();
      } else {
        promptAction.showToast({
          message: result.message,
          duration: 2000
        });
      }
    } catch (error) {
      console.error('Failed to remove favorite:', error);
      promptAction.showToast({
        message: '操作失败，请重试',
        duration: 2000
      });
    }
  }

  /**
   * 跳转到商品详情页
   */
  private goToProductDetail(productId: number): void {
    router.pushUrl({
      url: 'pages/DetailsPage',
      params: { productId: productId }
    });
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button() {
          Image($r('sys.symbol.chevron_left'))
            .width(24)
            .height(24)
            .fillColor('#333')
        }
        .width(40)
        .height(40)
        .backgroundColor('transparent')
        .onClick(() => router.back())

        Text('我的收藏')
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

      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#ff6b35')
          
          Text('加载中...')
            .fontSize(14)
            .fontColor('#666')
            .margin({ top: 12 })
        }
        .width('100%')
        .height('60%')
        .justifyContent(FlexAlign.Center)
      } else if (this.favoriteProducts.length === 0) {
        // 空状态
        Column() {
          Image($r('sys.symbol.heart'))
            .width(80)
            .height(80)
            .fillColor('#ddd')
            .margin({ bottom: 16 })

          Text('暂无收藏商品')
            .fontSize(16)
            .fontColor('#666')
            .margin({ bottom: 8 })

          Text('去首页看看有什么好商品吧')
            .fontSize(14)
            .fontColor('#999')
            .margin({ bottom: 24 })

          Button('去逛逛')
            .width(120)
            .height(40)
            .backgroundColor('#ff6b35')
            .fontColor('#fff')
            .fontSize(16)
            .borderRadius(20)
            .onClick(() => {
              router.back();
            })
        }
        .width('100%')
        .height('60%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 收藏商品列表
        List({ space: 12 }) {
          ForEach(this.favoriteProducts, (product: Product) => {
            ListItem() {
              this.buildFavoriteItem(product)
            }
          }, (product: Product) => product.id.toString())
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  /**
   * 构建收藏商品项
   */
  @Builder
  buildFavoriteItem(product: Product) {
    Row() {
      // 商品图片
      Image(product.image)
        .width(80)
        .height(80)
        .objectFit(ImageFit.Contain)
        .backgroundColor('#f9f9f9')
        .borderRadius(8)
        .margin({ right: 12 })

      // 商品信息
      Column() {
        Text(product.name)
          .fontSize(16)
          .fontColor('#333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 8 })
          .textAlign(TextAlign.Start)
          .width('100%')

        Text(`¥${product.price.toFixed(2)}`)
          .fontSize(18)
          .fontColor('#E41F19')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 8 })
          .textAlign(TextAlign.Start)
          .width('100%')

        Row() {
          Button('查看详情')
            .height(32)
            .backgroundColor('#ff6b35')
            .fontColor('#fff')
            .fontSize(14)
            .borderRadius(16)
            .padding({ left: 16, right: 16 })
            .onClick(() => this.goToProductDetail(product.id))

          Blank()

          Button('取消收藏')
            .height(32)
            .backgroundColor('transparent')
            .fontColor('#666')
            .fontSize(14)
            .border({ width: 1, color: '#ddd' })
            .borderRadius(16)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              AlertDialog.show({
                title: '确认取消收藏',
                message: `确定要取消收藏"${product.name}"吗？`,
                primaryButton: {
                  value: '确定',
                  action: () => {
                    this.removeFavorite(product.id);
                  }
                },
                secondaryButton: {
                  value: '取消',
                  action: () => {}
                }
              });
            })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(8)
    .onClick(() => this.goToProductDetail(product.id))
  }
}
