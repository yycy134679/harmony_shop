import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AddressViewModel } from '../viewmodel/AddressViewModel';
import { AddressItem } from '../view/AddressItem';
import { Address } from '../model/Address';
import common from '@ohos.app.ability.common';

/**
 * 地址选择页面
 */
@Entry
@Component
struct AddressSelectionPage {
  @State addresses: Address[] = [];
  @State isLoading: boolean = true;
  @State selectedAddressId: string = '';
  private addressViewModel: AddressViewModel = new AddressViewModel();

  async aboutToAppear() {
    try {
      await this.addressViewModel.init(getContext(this) as common.UIAbilityContext);
      
      // 获取传入的已选择地址ID
      const params = router.getParams() as Record<string, Object>;
      if (params && params.selectedAddressId) {
        this.selectedAddressId = params.selectedAddressId as string;
      }
      
      await this.loadAddresses();
    } catch (error) {
      console.error('Failed to initialize AddressSelectionPage:', error);
      this.isLoading = false;
    }
  }

  /**
   * 加载地址列表
   */
  private async loadAddresses(): Promise<void> {
    try {
      this.isLoading = true;
      this.addresses = await this.addressViewModel.getAddresses();
    } catch (error) {
      console.error('Failed to load addresses:', error);
      promptAction.showToast({
        message: '加载地址失败',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 选择地址
   */
  private selectAddress(address: Address): void {
    router.back({
      url: 'pages/OrderConfirmationPage',
      params: {
        selectedAddress: address
      }
    });
  }

  /**
   * 新增地址
   */
  private addAddress(): void {
    router.pushUrl({ url: 'pages/AddressEditPage' });
  }

  /**
   * 编辑地址
   */
  private editAddress(address: Address): void {
    router.pushUrl({ 
      url: 'pages/AddressEditPage',
      params: { address: address }
    });
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

        Text('选择收货地址')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 新增按钮
        Button() {
          Text('+')
            .fontSize(20)
            .fontColor('#ff6b35')
            .fontWeight(FontWeight.Bold)
        }
        .width(40)
        .height(40)
        .backgroundColor('#f0f0f0')
        .borderRadius(20)
        .onClick(() => this.addAddress())
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
            .margin({ bottom: 16 })

          Text('加载中...')
            .fontSize(14)
            .fontColor('#666')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.addresses.length === 0) {
        // 空状态
        Column() {
          Text('🏠')
            .fontSize(60)
            .fontColor('#ddd')
            .margin({ bottom: 16 })

          Text('暂无收货地址')
            .fontSize(16)
            .fontColor('#666')
            .margin({ bottom: 8 })

          Text('点击右上角"+"添加新地址')
            .fontSize(14)
            .fontColor('#999')
            .margin({ bottom: 24 })

          Button('添加地址')
            .width(120)
            .height(40)
            .backgroundColor('#ff6b35')
            .fontColor('#fff')
            .fontSize(16)
            .borderRadius(20)
            .onClick(() => this.addAddress())
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 地址列表
        Scroll() {
          Column() {
            ForEach(this.addresses, (address: Address) => {
              Column() {
                Row() {
                  // 选择状态指示器
                  Row() {
                    if (this.selectedAddressId === address.id || address.isDefault) {
                      Text('✓')
                        .fontSize(16)
                        .fontColor('#ff6b35')
                        .fontWeight(FontWeight.Bold)
                    } else {
                      Text('○')
                        .fontSize(16)
                        .fontColor('#ddd')
                    }
                  }
                  .width(40)
                  .justifyContent(FlexAlign.Center)

                  // 地址信息
                  Column() {
                    Row() {
                      Text(address.recipientName)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333')
                        .margin({ right: 12 })

                      Text(address.phone)
                        .fontSize(14)
                        .fontColor('#666')

                      if (address.isDefault) {
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

                    Text(address.fullAddress)
                      .fontSize(14)
                      .fontColor('#666')
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  // 编辑按钮
                  Button('编辑')
                    .fontSize(12)
                    .fontColor('#ff6b35')
                    .backgroundColor('transparent')
                    .border({ width: 1, color: '#ff6b35' })
                    .borderRadius(4)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .onClick(() => this.editAddress(address))
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#fff')
                .borderRadius(8)
                .margin({ bottom: 12 })
                .onClick(() => this.selectAddress(address))
              }
            }, (address: Address) => address.id)
          }
          .padding(16)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
