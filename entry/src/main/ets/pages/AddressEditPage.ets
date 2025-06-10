import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AddressViewModel } from '../viewmodel/AddressViewModel';
import { Address } from '../model/Address';
import common from '@ohos.app.ability.common';

interface AddressFormData {
  recipientName: string;
  phone: string;
  fullAddress: string;
  isDefault: boolean;
}

interface SaveResult {
  success: boolean;
  message: string;
}

/**
 * 地址编辑页面
 */
@Entry
@Component
struct AddressEditPage {
  @State recipientName: string = '';
  @State phone: string = '';
  @State fullAddress: string = '';
  @State isDefault: boolean = false;
  @State isLoading: boolean = false;
  @State isEditMode: boolean = false;
  @State addressId: string = '';
  private addressViewModel: AddressViewModel = new AddressViewModel();

  async aboutToAppear() {
    try {
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
   * 保存地址
   */
  private async saveAddress(): Promise<void> {
    if (this.isLoading) return;

    this.isLoading = true;
    try {
      let result: SaveResult;

      if (this.isEditMode) {
        // 编辑模式
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
        // 新增模式
        const newAddress: AddressFormData = {
          recipientName: this.recipientName.trim(),
          phone: this.phone.trim(),
          fullAddress: this.fullAddress.trim(),
          isDefault: this.isDefault
        };
        result = await this.addressViewModel.addAddress(newAddress);
      }

      if (result.success) {
        promptAction.showToast({
          message: result.message,
          duration: 2000
        });
        router.back();
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
        .backgroundColor('#f0f0f0')
        .borderRadius(20)
        .onClick(() => router.back())

        Text(this.isEditMode ? '编辑地址' : '新增地址')
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
            // 收件人姓名
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

              Divider().color('#f0f0f0')
            }

            // 联系电话
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
                  .type(InputType.PhoneNumber)
                  .onChange((value: string) => {
                    this.phone = value;
                  })
              }
              .width('100%')
              .height(56)
              .alignItems(VerticalAlign.Center)

              Divider().color('#f0f0f0')
            }

            // 详细地址
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

              Divider().color('#f0f0f0')
            }

            // 设为默认地址
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
            .enabled(!this.isLoading)
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
