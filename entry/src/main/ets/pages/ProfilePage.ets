import router from '@ohos.router';
import { Constants } from '../common/Constants';
import { UserViewModel } from '../viewmodel/UserViewModel';

/**
 * 个人中心页面
 */
@Entry
@Component
struct ProfilePage {
  @StorageLink(Constants.IS_LOGGED_IN) isLoggedIn: boolean = false;
  @StorageLink(Constants.CURRENT_USER) currentUser: string = '';
  private userViewModel: UserViewModel = new UserViewModel();

  /**
   * 处理退出登录
   */
  private handleLogout(): void {
    AlertDialog.show({
      title: '退出登录',
      message: '确定要退出登录吗？',
      primaryButton: {
        value: '确定',
        action: () => {
          this.userViewModel.logout();
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    });
  }

  /**
   * 跳转到登录页面
   */
  private goToLogin(): void {
    router.pushUrl({ url: 'pages/LoginPage' });
  }

  /**
   * 跳转到编辑个人信息页面
   */
  private goToEditProfile(): void {
    router.pushUrl({ url: 'pages/EditProfilePage' });
  }

  /**
   * 跳转到我的收藏页面
   */
  private goToFavorites(): void {
    router.pushUrl({ url: 'pages/FavoriteListPage' });
  }

  /**
   * 跳转到地址管理页面
   */
  private goToAddressManagement(): void {
    router.pushUrl({ url: 'pages/AddressManagementPage' });
  }

  /**
   * 跳转到我的订单页面
   */
  private goToOrders(): void {
    router.pushUrl({ url: 'pages/OrderListPage' });
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
        .onClick(() => {
          // 返回到首页（底部导航）
          router.replaceUrl({ url: 'view/BottomTabs' });
        })

        Text('个人中心')
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

      if (this.isLoggedIn) {
        // 已登录状态
        this.buildLoggedInContent()
      } else {
        // 未登录状态
        this.buildNotLoggedInContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  /**
   * 构建已登录状态的内容
   */
  @Builder
  buildLoggedInContent() {
    Column() {
      // 用户信息区域
      Column() {
        // 头像
        Text('👤')
          .fontSize(60)
          .margin({ bottom: 12 })

        // 用户名
        Text(this.currentUser)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .margin({ bottom: 8 })

        // 个人信息展示区域（暂时显示占位文本）
        Text('电话：138****8888')
          .fontSize(14)
          .fontColor('#666')
          .margin({ bottom: 4 })

        Text('默认地址：北京市朝阳区...')
          .fontSize(14)
          .fontColor('#666')
      }
      .width('100%')
      .padding(24)
      .backgroundColor('#fff')
      .margin({ top: 12, bottom: 12 })

      // 功能菜单区域
      Column() {
        this.buildMenuItem('我的订单', '📋', () => this.goToOrders())
        Divider().color('#f0f0f0')
        this.buildMenuItem('我的收藏', '❤️', () => this.goToFavorites())
        Divider().color('#f0f0f0')
        this.buildMenuItem('地址管理', '🏠', () => this.goToAddressManagement())
        Divider().color('#f0f0f0')
        this.buildMenuItem('修改信息', '👤', () => this.goToEditProfile())
      }
      .backgroundColor('#fff')
      .borderRadius(8)
      .margin({ left: 16, right: 16, bottom: 24 })

      // 退出登录按钮
      Button('退出登录')
        .width('calc(100% - 32vp)')
        .height(48)
        .backgroundColor('#ff4444')
        .fontColor('#fff')
        .fontSize(16)
        .borderRadius(8)
        .onClick(() => this.handleLogout())
    }
    .width('100%')
    .layoutWeight(1)
  }

  /**
   * 构建未登录状态的内容
   */
  @Builder
  buildNotLoggedInContent() {
    Column() {
      // 未登录提示区域
      Column() {
        Text('👤')
          .fontSize(60)
          .fontColor('#ccc')
          .margin({ bottom: 16 })

        Text('您还未登录')
          .fontSize(18)
          .fontColor('#666')
          .margin({ bottom: 8 })

        Text('登录后可享受更多服务')
          .fontSize(14)
          .fontColor('#999')
          .margin({ bottom: 24 })

        Button('立即登录')
          .width(120)
          .height(40)
          .backgroundColor('#ff6b35')
          .fontColor('#fff')
          .fontSize(16)
          .borderRadius(20)
          .onClick(() => this.goToLogin())
      }
      .width('100%')
      .padding(48)
      .backgroundColor('#fff')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 12 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 构建菜单项
   */
  @Builder
  buildMenuItem(title: string, icon: string, onClick: () => void) {
    Row() {
      Text(icon)
        .fontSize(20)
        .margin({ right: 12 })

      Text(title)
        .fontSize(16)
        .fontColor('#333')
        .layoutWeight(1)

      Text('→')
        .fontSize(14)
        .fontColor('#ccc')
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .onClick(onClick)
  }
}
