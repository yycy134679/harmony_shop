import { Address } from '../model/Address';

/**
 * 地址项组件
 */
@Component
export struct AddressItem {
  @Prop address: Address;
  @Prop showActions: boolean = true;
  onEdit?: (address: Address) => void;
  onDelete?: (address: Address) => void;
  onSetDefault?: (address: Address) => void;

  build() {
    Column() {
      Row() {
        Column() {
          // 收件人信息
          Row() {
            Text(this.address.recipientName)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
              .margin({ right: 12 })

            Text(this.address.phone)
              .fontSize(14)
              .fontColor('#666')

            if (this.address.isDefault) {
              Text('默认')
                .fontSize(12)
                .fontColor('#fff')
                .backgroundColor('#ff6b35')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .borderRadius(10)
                .margin({ left: 12 })
            }
          }
          .width('100%')
          .margin({ bottom: 8 })

          // 详细地址
          Text(this.address.fullAddress)
            .fontSize(14)
            .fontColor('#666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        if (this.showActions) {
          // 操作按钮
          Row() {
            Button('编辑')
              .fontSize(12)
              .fontColor('#ff6b35')
              .backgroundColor('transparent')
              .border({ width: 1, color: '#ff6b35' })
              .borderRadius(4)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .onClick(() => {
                if (this.onEdit) {
                  this.onEdit(this.address);
                }
              })

            Button('删除')
              .fontSize(12)
              .fontColor('#ff4444')
              .backgroundColor('transparent')
              .border({ width: 1, color: '#ff4444' })
              .borderRadius(4)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ left: 8 })
              .onClick(() => {
                if (this.onDelete) {
                  this.onDelete(this.address);
                }
              })
          }
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      if (this.showActions && !this.address.isDefault) {
        // 设为默认按钮
        Row() {
          Button('设为默认地址')
            .fontSize(14)
            .fontColor('#666')
            .backgroundColor('transparent')
            .border({ width: 1, color: '#ddd' })
            .borderRadius(4)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .margin({ top: 12 })
            .onClick(() => {
              if (this.onSetDefault) {
                this.onSetDefault(this.address);
              }
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#fff')
    .borderRadius(8)
    .margin({ bottom: 12 })
  }
}
