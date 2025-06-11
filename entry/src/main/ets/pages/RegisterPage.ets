import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { UserViewModel } from '../viewmodel/UserViewModel';
import { User } from '../model/User';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct RegisterPage {
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State phone: string = '';
  private viewModel: UserViewModel = new UserViewModel();
  private context = getContext(this) as common.UIAbilityContext;

  build() {
    Column({ space: 20 }) {
      Text("用户注册")
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 80, bottom: 40 })

      TextInput({ placeholder: '请输入用户名' })
        .width('80%')
        .onChange((value) => {
          this.username = value;
        })

      TextInput({ placeholder: '请输入手机号' })
        .width('80%')
        .type(InputType.PhoneNumber)
        .onChange((value) => {
          this.phone = value;
        })

      TextInput({ placeholder: '请设置密码' })
        .type(InputType.Password)
        .width('80%')
        .onChange((value) => {
          this.password = value;
        })

      TextInput({ placeholder: '请再次输入密码' })
        .type(InputType.Password)
        .width('80%')
        .onChange((value) => {
          this.confirmPassword = value;
        })

      Button('注册')
        .width('80%')
        .margin({ top: 20 })
        .onClick(async () => {
          // 基本验证
          if (!this.username.trim()) {
            promptAction.showToast({ message: '请输入用户名' });
            return;
          }
          if (!this.phone.trim()) {
            promptAction.showToast({ message: '请输入手机号' });
            return;
          }
          if (!this.password.trim()) {
            promptAction.showToast({ message: '请输入密码' });
            return;
          }
          if (this.password !== this.confirmPassword) {
            promptAction.showToast({ message: '两次输入的密码不一致' });
            return;
          }

          // 验证手机号格式
          const phoneRegex = /^\d{11}$/;
          if (!phoneRegex.test(this.phone)) {
            promptAction.showToast({ message: '请输入正确的11位手机号' });
            return;
          }

          const user: User = {
            username: this.username,
            password: this.password,
            phone: this.phone
          };
          await this.viewModel.init(this.context);
          const result = await this.viewModel.register(user);
          if (result.success) {
            promptAction.showToast({ message: result.message });
            router.replaceUrl({ url: 'pages/LoginPage' });
          } else {
            promptAction.showToast({ message: result.message });
          }
        })

      Row({ space: 10 }) {
        Text("已有账号？")
        Text("去登录")
          .fontColor(Color.Blue)
          .onClick(() => {
            router.replaceUrl({ url: 'pages/LoginPage' });
          })
      }
      .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F1F3F5')
  }
}
