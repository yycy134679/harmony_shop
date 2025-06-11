import router from '@ohos.router';
import { Constants } from '../common/Constants';
import { UserViewModel } from '../viewmodel/UserViewModel';
import { ProfileViewModel } from '../viewmodel/ProfileViewModel';
import { User } from '../model/User';
import { Address } from '../model/Address';
import common from '@ohos.app.ability.common';

/**
 * 个人中心内容组件
 */
@Component
export struct ProfileContent {
  @StorageLink(Constants.IS_LOGGED_IN) isLoggedIn: boolean = false;
  @StorageLink(Constants.CURRENT_USER) currentUser: string = '';
  @State userInfo: User | null = null;
  @State defaultAddress: Address | null = null;
  @State isLoading: boolean = false;
  private userViewModel: UserViewModel = new UserViewModel();
  private profileViewModel: ProfileViewModel = new ProfileViewModel();

  async aboutToAppear() {
    try {
      await this.profileViewModel.init(getContext(this) as common.UIAbilityContext);
      if (this.isLoggedIn) {
        await this.loadUserData();
      }
    } catch (error) {
      console.error('Failed to initialize ProfileContent:', error);
    }
  }

  /**
   * 加载用户数据
   */
  private async loadUserData(): Promise<void> {
    if (this.isLoading) return;

    this.isLoading = true;
    try {
      // 获取用户信息
      this.userInfo = await this.profileViewModel.getCurrentUserInfo();
      // 获取默认地址
      this.defaultAddress = await this.profileViewModel.getDefaultAddress();
    } catch (error) {
      console.error('Failed to load user data:', error);
    } finally {
      this.isLoading = false;
    }
  }

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
    .onAppear(() => {
      // 当组件显示时，如果已登录则加载用户数据
      if (this.isLoggedIn) {
        this.loadUserData();
      }
    })
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

        // 个人信息展示区域
        if (this.userInfo?.phone) {
          Text(`电话：${this.userInfo.phone}`)
            .fontSize(14)
            .fontColor('#666')
            .margin({ bottom: 4 })
        } else {
          Text('电话：未设置')
            .fontSize(14)
            .fontColor('#999')
            .margin({ bottom: 4 })
        }

        if (this.defaultAddress) {
          Text(`默认地址：${this.defaultAddress.fullAddress}`)
            .fontSize(14)
            .fontColor('#666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        } else {
          Text('默认地址：未设置')
            .fontSize(14)
            .fontColor('#999')
        }
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
