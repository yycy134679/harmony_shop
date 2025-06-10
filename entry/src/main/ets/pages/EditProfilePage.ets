import router from '@ohos.router';
import { EditProfileViewModel } from '../viewmodel/EditProfileViewModel';
import { User } from '../model/User';

/**
 * 编辑个人信息页面
 */
@Entry
@Component
struct EditProfilePage {
  @State username: string = '';
  @State phone: string = '';
  @State email: string = '';
  @State isLoading: boolean = false;
  private editProfileViewModel: EditProfileViewModel = new EditProfileViewModel();

  async aboutToAppear() {
    try {
      await this.editProfileViewModel.init(getContext(this) as Context);
      await this.loadUserInfo();
    } catch (error) {
      console.error('Failed to initialize EditProfilePage:', error);
    }
  }

  /**
   * 加载用户信息
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
              router.back();
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
