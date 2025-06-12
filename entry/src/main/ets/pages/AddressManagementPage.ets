//202306110141 杨富涛
//地址管理页面 - 用于管理用户的收货地址，支持添加、编辑、删除和设置默认地址

import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AddressViewModel } from '../viewmodel/AddressViewModel';
import { AddressItem } from '../view/AddressItem';
import { Address } from '../model/Address';
import common from '@ohos.app.ability.common';

/**
 * 地址管理页面
 * 用于展示、添加、编辑、删除和设置默认地址
 */
@Entry
@Component
struct AddressManagementPage {
  @State addresses: Address[] = [];    // 地址列表
  @State isLoading: boolean = true;    // 加载状态
  private addressViewModel: AddressViewModel = new AddressViewModel(); // 地址数据视图模型

  /**
   * 组件即将出现时的生命周期函数
   * 初始化视图模型并加载地址列表
   */
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
   * 从视图模型中获取用户的所有地址
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
   * 跳转到地址编辑页面
   */
  private addAddress(): void {
    router.pushUrl({ url: 'pages/AddressEditPage' });
  }

  /**
   * 编辑地址
   * 跳转到地址编辑页面并传递地址信息
   * @param address 需要编辑的地址对象
   */
  private editAddress(address: Address): void {
    router.pushUrl({
      url: 'pages/AddressEditPage',
      params: { address: address }
    });
  }

  /**
   * 删除地址
   * 显示确认对话框，确认后删除地址
   * @param address 需要删除的地址对象
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
   * @param address 需要设置为默认的地址对象
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

  /**
   * 构建UI界面
   */
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
        .onClick(() => router.back()) // 返回上一页

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
        .onClick(() => this.addAddress()) // 点击添加新地址
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#fff')

      if (this.isLoading) {
        // 加载状态 - 显示加载进度指示器
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
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 100 })
      } else if (this.addresses.length === 0) {
        // 空状态 - 没有地址时显示
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
            .onClick(() => this.addAddress()) // 点击添加新地址
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 100 })
      } else {
        // 地址列表 - 显示所有地址
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
            }, (address: Address) => address.id) // 使用地址ID作为唯一键
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(16)
        }
        .layoutWeight(1)
        .align(Alignment.TopStart)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
