import { Product } from '../model/Product';

/**
 * 收藏列表项组件
 */
@Component
export struct FavoriteItem {
  @Prop product: Product;
  onRemoveFavorite?: (productId: number) => void;
  onViewDetail?: (productId: number) => void;

  build() {
    Row() {
      // 商品图片
      Image(this.product.image)
        .width(80)
        .height(80)
        .objectFit(ImageFit.Contain)
        .backgroundColor('#f9f9f9')
        .borderRadius(8)
        .margin({ right: 12 })

      // 商品信息
      Column() {
        Text(this.product.name)
          .fontSize(16)
          .fontColor('#333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 8 })
          .textAlign(TextAlign.Start)
          .width('100%')

        Text(`¥${this.product.price.toFixed(2)}`)
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
            .onClick(() => {
              if (this.onViewDetail) {
                this.onViewDetail(this.product.id);
              }
            })

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
                message: `确定要取消收藏"${this.product.name}"吗？`,
                primaryButton: {
                  value: '确定',
                  action: () => {
                    if (this.onRemoveFavorite) {
                      this.onRemoveFavorite(this.product.id);
                    }
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
    .onClick(() => {
      if (this.onViewDetail) {
        this.onViewDetail(this.product.id);
      }
    })
  }
}
