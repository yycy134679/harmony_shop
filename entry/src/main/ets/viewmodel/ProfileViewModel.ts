import { UserService } from '../service/UserService';
import { AddressService } from '../service/AddressService';
import { User } from '../model/User';
import { Address } from '../model/Address';
import { Constants } from '../common/Constants';
import common from '@ohos.app.ability.common';

/**
 * 个人中心视图模型 - 管理个人中心页面的业务逻辑和状态
 */
export class ProfileViewModel {
  private userService: UserService;
  private addressService: AddressService;

  constructor() {
    this.userService = UserService.getInstance();
    this.addressService = AddressService.getInstance();
  }

  /**
   * 初始化服务
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    await this.userService.init(context);
    await this.addressService.init(context);
  }

  /**
   * 获取当前用户信息
   */
  async getCurrentUserInfo(): Promise<User | null> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return null;
      }

      // 从UserService获取用户详细信息
      const userInfo = await this.userService.getUserByUsername(currentUser);
      if (userInfo) {
        // 不返回密码信息
        return {
          ...userInfo,
          password: ''
        };
      }
      return null;
    } catch (error) {
      console.error('Failed to get current user info:', error);
      return null;
    }
  }

  /**
   * 获取用户的默认地址
   */
  async getDefaultAddress(): Promise<Address | null> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return null;
      }

      return await this.addressService.getDefaultAddress(currentUser);
    } catch (error) {
      console.error('Failed to get default address:', error);
      return null;
    }
  }

  /**
   * 获取用户统计信息
   */
  async getUserStats(): Promise<{
    orderCount: number;
    favoriteCount: number;
    addressCount: number;
  }> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return { orderCount: 0, favoriteCount: 0, addressCount: 0 };
      }

      // 这里需要调用各个服务获取统计信息
      // 暂时返回占位数据
      return {
        orderCount: 0,
        favoriteCount: 0,
        addressCount: 0
      };
    } catch (error) {
      console.error('Failed to get user stats:', error);
      return { orderCount: 0, favoriteCount: 0, addressCount: 0 };
    }
  }

  /**
   * 检查用户是否已登录
   */
  isLoggedIn(): boolean {
    return AppStorage.get(Constants.IS_LOGGED_IN) as boolean || false;
  }

  /**
   * 获取当前用户名
   */
  getCurrentUsername(): string {
    return AppStorage.get(Constants.CURRENT_USER) as string || '';
  }

  /**
   * 退出登录
   */
  logout(): void {
    AppStorage.setOrCreate(Constants.IS_LOGGED_IN, false);
    AppStorage.setOrCreate(Constants.CURRENT_USER, '');
    // 清空购物车
    AppStorage.setOrCreate(Constants.SHOPPING_CART, []);
  }
}
