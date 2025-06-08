// 202306110141 杨富涛

import { router } from '@kit.ArkUI';
import { UserViewModel } from '../viewmodel/UserViewModel';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  private viewModel: UserViewModel = new UserViewModel();
  private context = getContext(this) as common.UIAbilityContext;

  async aboutToAppear() {
    // 初始化 UserViewModel
    await this.viewModel.init(this.context);
  }

  @Builder
  LoginPageContent() {
    Column() {
      Image('https://image2.135editor.com/cache/remote/aHR0cHM6Ly9tbWJpei5xbG9nby5jbi9tbWJpel9qcGcvQUlKZ00zYmt3OG03SGhtb3IxRzdYMzZEVkFjMThpYVhHaWFUaWJPaENVSGpsd3JYVmdMU1pRSWFYTEloZmhZYXByVXJnTVAxV2pFb1I2aWNmRXRwd25jb0N3LzY0MC5qcGVn')
        .width(100)
        .height(100)
        .borderRadius(20)
        .margin({ top: 100, bottom: 50 })

      TextInput({ placeholder: '用户名' })
        .width('80%')
        .height(50)
        .margin(10)
        .backgroundColor(Color.White)
        .onChange((value) => {
          this.username = value;
        })

      TextInput({ placeholder: '密码' })
        .type(InputType.Password)
        .width('80%')
        .height(50)
        .margin(10)
        .backgroundColor(Color.White)
        .onChange((value) => {
          this.password = value;
        })

      Button('登录')
        .width('60%')
        .height(50)
        .margin(30)
        .onClick(async () => {
          const result = await this.viewModel.login(this.username, this.password);
          if (result.success) {
            promptAction.showToast({ message: result.message });
            router.replaceUrl({ url: 'view/BottomTabs' });
          } else {
            promptAction.showToast({ message: result.message });
          }
        })

      Row() {
        Text('还没有账号？').fontColor(Color.Black)
        Text('去注册')
          .decoration({ type: TextDecorationType.Underline, color: Color.Blue })
          .fontColor(Color.Blue)
          .onClick(() => {
            router.replaceUrl({ url: 'pages/RegisterPage' });
          })
      }
      .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F1F3F5')
  }

  build() {
    Column() {
      this.LoginPageContent();
    }
  }
}
