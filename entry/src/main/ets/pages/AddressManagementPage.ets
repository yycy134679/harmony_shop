import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AddressViewModel } from '../viewmodel/AddressViewModel';
import { AddressItem } from '../view/AddressItem';
import { Address } from '../model/Address';
import common from '@ohos.app.ability.common';

/**
 * 地址管理页面
 */
@Entry
@Component
struct AddressManagementPage {
  @State addresses: Address[] = [];
  @State isLoading: boolean = true;
  private addressViewModel: AddressViewModel = new AddressViewModel();

  async aboutToAppear() {
    try {
      await this.addressViewModel.init(getContext(this) as common.UIAbilityContext);
      await this.loadAddresses();
    } catch (error) {
      console.error('Failed to initialize AddressManagementPage:', error);
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

  /**
   * 删除地址
   */
  private deleteAddress(address: Address): void {
    AlertDialog.show({
      title: '确认删除',
      message: `确定要删除地址"${address.fullAddress}"吗？`,
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#ff4444',
        action: async () => {
          try {
            const result = await this.addressViewModel.deleteAddress(address.id);
            if (result.success) {
              promptAction.showToast({
                message: result.message,
                duration: 2000
              });
              await this.loadAddresses(); // 重新加载列表
            } else {
              promptAction.showToast({
                message: result.message,
                duration: 2000
              });
            }
          } catch (error) {
            console.error('Failed to delete address:', error);
            promptAction.showToast({
              message: '删除失败，请重试',
              duration: 2000
            });
          }
        }
      }
    });
  }

  /**
   * 设置默认地址
   */
  private async setDefaultAddress(address: Address): Promise<void> {
    try {
      const result = await this.addressViewModel.setDefaultAddress(address.id);
      if (result.success) {
        promptAction.showToast({
          message: result.message,
          duration: 2000
        });
        await this.loadAddresses(); // 重新加载列表
      } else {
        promptAction.showToast({
          message: result.message,
          duration: 2000
        });
      }
    } catch (error) {
      console.error('Failed to set default address:', error);
      promptAction.showToast({
        message: '设置失败，请重试',
        duration: 2000
      });
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

        Text('地址管理')
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
              AddressItem({
                address: address,
                showActions: true,
                onEdit: (addr: Address) => this.editAddress(addr),
                onDelete: (addr: Address) => this.deleteAddress(addr),
                onSetDefault: (addr: Address) => this.setDefaultAddress(addr)
              })
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
