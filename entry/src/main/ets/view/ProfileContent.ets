import router from '@ohos.router';
import { Constants } from '../common/Constants';
import { UserViewModel } from '../viewmodel/UserViewModel';

/**
 * 个人中心内容组件
 */
@Component
export struct ProfileContent {
  @StorageLink(Constants.IS_LOGGED_IN) isLoggedIn: boolean = false;
  @StorageLink(Constants.CURRENT_USER) currentUser: string = '';
  private userViewModel: UserViewModel = new UserViewModel();

  /**
   * 处理退出登录
   */
  private handleLogout(): void {
    this.userViewModel.logout();
    // 可以选择跳转到首页标签
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
        Image($r('sys.symbol.person'))
          .width(80)
          .height(80)
          .fillColor('#ff6b35')
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
      .margin({ bottom: 12 })

      // 功能菜单区域
      Column() {
        this.buildMenuItemText('我的订单', '订单', () => this.goToOrders())
        Divider().color('#f0f0f0')
        this.buildMenuItemText('我的收藏', '收藏', () => this.goToFavorites())
        Divider().color('#f0f0f0')
        this.buildMenuItemText('地址管理', '地址', () => this.goToAddressManagement())
        Divider().color('#f0f0f0')
        this.buildMenuItemText('修改信息', '编辑', () => this.goToEditProfile())
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
    .height('100%')
  }

  /**
   * 构建未登录状态的内容
   */
  @Builder
  buildNotLoggedInContent() {
    Column() {
      // 未登录提示区域
      Column() {
        Image($r('sys.symbol.person'))
          .width(80)
          .height(80)
          .fillColor('#ccc')
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
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 构建菜单项（文字版本）
   */
  @Builder
  buildMenuItemText(title: string, iconText: string, onClick: () => void) {
    Row() {
      Text(iconText)
        .width(32)
        .height(32)
        .fontSize(14)
        .fontColor('#ff6b35')
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .backgroundColor('#fff2f0')
        .borderRadius(16)
        .margin({ right: 12 })

      Text(title)
        .fontSize(16)
        .fontColor('#333')
        .layoutWeight(1)

      Text('>')
        .fontSize(16)
        .fontColor('#ccc')
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .onClick(onClick)
  }

  /**
   * 构建菜单项（原版本保留）
   */
  @Builder
  buildMenuItem(title: string, icon: Resource, onClick: () => void) {
    Row() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor('#666')
        .margin({ right: 12 })

      Text(title)
        .fontSize(16)
        .fontColor('#333')
        .layoutWeight(1)

      Text('>')
        .fontSize(16)
        .fontColor('#ccc')
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .onClick(onClick)
  }
}
