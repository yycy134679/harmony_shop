//202306110141 杨富涛
//地址编辑页面 - 用于新增和编辑收货地址信息

import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AddressViewModel } from '../viewmodel/AddressViewModel';
import { Address } from '../model/Address';
import common from '@ohos.app.ability.common';

/**
 * 地址表单数据接口 - 定义地址表单所需的数据结构
 */
interface AddressFormData {
  recipientName: string; // 收件人姓名
  phone: string;         // 联系电话
  fullAddress: string;   // 详细地址
  isDefault: boolean;    // 是否为默认地址
}

/**
 * 保存结果接口 - 定义保存操作的返回结果
 */
interface SaveResult {
  success: boolean;      // 操作是否成功
  message: string;       // 操作结果消息
}

/**
 * 地址编辑页面组件
 * 支持新增地址和编辑已有地址两种模式
 */
@Entry
@Component
struct AddressEditPage {
  @State recipientName: string = '';  // 收件人姓名
  @State phone: string = '';          // 联系电话
  @State fullAddress: string = '';    // 详细地址
  @State isDefault: boolean = false;  // 是否为默认地址
  @State isLoading: boolean = false;  // 加载状态
  @State isEditMode: boolean = false; // 是否为编辑模式
  @State addressId: string = '';      // 地址ID，编辑模式下使用
  private addressViewModel: AddressViewModel = new AddressViewModel(); // 地址数据视图模型

  /**
   * 组件即将出现时的生命周期函数
   * 初始化视图模型并检查是否为编辑模式
   */
  async aboutToAppear() {
    try {
      // 初始化视图模型
      await this.addressViewModel.init(getContext(this) as common.UIAbilityContext);
      
      // 检查是否为编辑模式
      const params = router.getParams() as Record<string, Object>;
      if (params && params.address) {
        this.isEditMode = true;
        const address = params.address as Address;
        this.addressId = address.id;
        this.recipientName = address.recipientName;
        this.phone = address.phone;
        this.fullAddress = address.fullAddress;
        this.isDefault = address.isDefault;
      }
    } catch (error) {
      console.error('Failed to initialize AddressEditPage:', error);
    }
  }

  /**
   * 保存地址信息
   * 根据当前模式（新增/编辑）调用相应的方法保存地址
   */
  private async saveAddress(): Promise<void> {
    if (this.isLoading) return; // 防止重复提交

    this.isLoading = true;
    try {
      let result: SaveResult;

      if (this.isEditMode) {
        // 编辑模式 - 更新现有地址
        const updatedAddress: Address = {
          id: this.addressId,
          userId: '', // 会在ViewModel中设置
          recipientName: this.recipientName.trim(),
          phone: this.phone.trim(),
          fullAddress: this.fullAddress.trim(),
          isDefault: this.isDefault
        };
        result = await this.addressViewModel.updateAddress(updatedAddress);
      } else {
        // 新增模式 - 创建新地址
        const newAddress: AddressFormData = {
          recipientName: this.recipientName.trim(),
          phone: this.phone.trim(),
          fullAddress: this.fullAddress.trim(),
          isDefault: this.isDefault
        };
        result = await this.addressViewModel.addAddress(newAddress);
      }

      // 显示操作结果提示
      if (result.success) {
        promptAction.showToast({
          message: result.message,
          duration: 2000
        });
        router.back(); // 返回上一页
      } else {
        promptAction.showToast({
          message: result.message,
          duration: 2000
        });
      }
    } catch (error) {
      console.error('Failed to save address:', error);
      promptAction.showToast({
        message: '保存失败，请重试',
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

        Text(this.isEditMode ? '编辑地址' : '新增地址') // 根据模式显示不同标题
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
          // 表单内容
          Column() {
            // 收件人姓名输入区域
            Column() {
              Row() {
                Text('收件人')
                  .fontSize(16)
                  .fontColor('#333')
                  .width(80)

                TextInput({ placeholder: '请输入收件人姓名', text: this.recipientName })
                  .layoutWeight(1)
                  .backgroundColor('transparent')
                  .border({ width: 0 })
                  .onChange((value: string) => {
                    this.recipientName = value;
                  })
              }
              .width('100%')
              .height(56)
              .alignItems(VerticalAlign.Center)

              Divider().color('#f0f0f0') // 分隔线
            }

            // 联系电话输入区域
            Column() {
              Row() {
                Text('联系电话')
                  .fontSize(16)
                  .fontColor('#333')
                  .width(80)

                TextInput({ 
                  placeholder: '请输入手机号码', 
                  text: this.phone 
                })
                  .layoutWeight(1)
                  .backgroundColor('transparent')
                  .border({ width: 0 })
                  .type(InputType.PhoneNumber) // 设置为电话号码输入类型
                  .onChange((value: string) => {
                    this.phone = value;
                  })
              }
              .width('100%')
              .height(56)
              .alignItems(VerticalAlign.Center)

              Divider().color('#f0f0f0') // 分隔线
            }

            // 详细地址输入区域
            Column() {
              Row() {
                Text('详细地址')
                  .fontSize(16)
                  .fontColor('#333')
                  .width(80)
                  .alignSelf(ItemAlign.Start)
                  .margin({ top: 16 })

                TextArea({ 
                  placeholder: '请输入详细地址，如街道、门牌号等', 
                  text: this.fullAddress 
                })
                  .layoutWeight(1)
                  .backgroundColor('transparent')
                  .border({ width: 0 })
                  .height(80)
                  .onChange((value: string) => {
                    this.fullAddress = value;
                  })
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)

              Divider().color('#f0f0f0') // 分隔线
            }

            // 设为默认地址开关
            Row() {
              Text('设为默认地址')
                .fontSize(16)
                .fontColor('#333')
                .layoutWeight(1)

              Toggle({ type: ToggleType.Switch, isOn: this.isDefault })
                .onChange((isOn: boolean) => {
                  this.isDefault = isOn;
                })
            }
            .width('100%')
            .height(56)
            .alignItems(VerticalAlign.Center)
          }
          .backgroundColor('#fff')
          .margin({ top: 12, left: 16, right: 16 })
          .borderRadius(8)
          .padding({ left: 16, right: 16 })

          // 保存按钮
          Button(this.isLoading ? '保存中...' : '保存')
            .width('calc(100% - 32vp)')
            .height(48)
            .backgroundColor('#ff6b35')
            .fontColor('#fff')
            .fontSize(16)
            .borderRadius(8)
            .margin({ top: 32 })
            .enabled(!this.isLoading) // 加载中禁用按钮
            .onClick(() => this.saveAddress())
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
