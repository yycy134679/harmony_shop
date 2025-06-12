//202306110141 杨富涛
//编辑个人信息页面 - 用于修改用户的手机号和邮箱信息

import router from '@ohos.router';
import { EditProfileViewModel } from '../viewmodel/EditProfileViewModel';
import { User } from '../model/User';
import common from '@ohos.app.ability.common';

/**
 * 编辑个人信息页面
 * 支持用户修改手机号和邮箱，用户名只读
 */
@Entry
@Component
struct EditProfilePage {
  @State username: string = '';           // 用户名（只读）
  @State phone: string = '';              // 手机号
  @State email: string = '';              // 邮箱
  @State isLoading: boolean = false;      // 加载/保存状态
  private editProfileViewModel: EditProfileViewModel = new EditProfileViewModel(); // 视图模型

  /**
   * 生命周期 aboutToAppear
   * 初始化视图模型并加载当前用户信息
   */
  async aboutToAppear() {
    try {
      await this.editProfileViewModel.init(getContext(this) as common.UIAbilityContext);
      await this.loadUserInfo();
    } catch (error) {
      console.error('Failed to initialize EditProfilePage:', error);
    }
  }

  /**
   * 加载用户信息
   * 从视图模型获取当前用户信息并赋值到状态变量
   */
  private async loadUserInfo(): Promise<void> {
    try {
      const userInfo = await this.editProfileViewModel.getCurrentUserInfo();
      if (userInfo) {
        this.username = userInfo.username;
        this.phone = userInfo.phone || '';
        this.email = userInfo.email || '';
      }
    } catch (error) {
      console.error('Failed to load user info:', error);
    }
  }

  /**
   * 保存用户信息
   * 调用视图模型方法更新手机号和邮箱
   */
  private async saveUserInfo(): Promise<void> {
    if (this.isLoading) return;

    this.isLoading = true;
    try {
      const result = await this.editProfileViewModel.updateUserInfo({
        phone: this.phone,
        email: this.email
      });

      if (result.success) {
        // 显示成功提示
        AlertDialog.show({
          title: '提示',
          message: result.message,
          confirm: {
            value: '确定',
            action: () => {
              router.back(); // 返回上一页
            }
          }
        });
      } else {
        // 显示错误提示
        AlertDialog.show({
          title: '错误',
          message: result.message,
          confirm: {
            value: '确定',
            action: () => {}
          }
        });
      }
    } catch (error) {
      console.error('Failed to save user info:', error);
      AlertDialog.show({
        title: '错误',
        message: '保存失败，请重试',
        confirm: {
          value: '确定',
          action: () => {}
        }
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

        Text('编辑个人信息')
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

      // 表单内容
      Column() {
        // 用户名（只读）
        Column() {
          Row() {
            Text('用户名')
              .fontSize(16)
              .fontColor('#333')
              .width(80)

            Text(this.username)
              .fontSize(16)
              .fontColor('#666')
              .layoutWeight(1)
          }
          .width('100%')
          .height(56)
          .alignItems(VerticalAlign.Center)

          Divider().color('#f0f0f0')
        }

        // 手机号
        Column() {
          Row() {
            Text('手机号')
              .fontSize(16)
              .fontColor('#333')
              .width(80)

            TextInput({ placeholder: '请输入手机号', text: this.phone })
              .layoutWeight(1)
              .backgroundColor('transparent')
              .border({ width: 0 })
              .onChange((value: string) => {
                this.phone = value;
              })
          }
          .width('100%')
          .height(56)
          .alignItems(VerticalAlign.Center)

          Divider().color('#f0f0f0')
        }

        // 邮箱
        Column() {
          Row() {
            Text('邮箱')
              .fontSize(16)
              .fontColor('#333')
              .width(80)

            TextInput({ placeholder: '请输入邮箱地址', text: this.email })
              .layoutWeight(1)
              .backgroundColor('transparent')
              .border({ width: 0 })
              .onChange((value: string) => {
                this.email = value;
              })
          }
          .width('100%')
          .height(56)
          .alignItems(VerticalAlign.Center)

          Divider().color('#f0f0f0')
        }
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
        .onClick(() => this.saveUserInfo())

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
