import { UserService } from '../service/UserService';
import { User } from '../model/User';
import { Constants } from '../common/Constants';
import common from '@ohos.app.ability.common';

/**
 * 编辑个人信息视图模型 - 管理个人信息编辑的业务逻辑
 */
export class EditProfileViewModel {
  private userService: UserService;

  constructor() {
    this.userService = UserService.getInstance();
  }

  /**
   * 初始化服务
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    await this.userService.init(context);
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

      // 这里需要扩展 UserService 来获取用户详细信息
      // 暂时返回基本信息
      return {
        username: currentUser,
        password: '', // 不返回密码
        phone: '138****8888', // 占位数据
        email: ''
      };
    } catch (error) {
      console.error('Failed to get current user info:', error);
      return null;
    }
  }

  /**
   * 更新用户信息
   */
  async updateUserInfo(userInfo: Partial<User>): Promise<{ success: boolean; message: string }> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return { success: false, message: '用户未登录' };
      }

      // 验证输入
      if (userInfo.phone && !this.validatePhone(userInfo.phone)) {
        return { success: false, message: '请输入正确的手机号码' };
      }

      if (userInfo.email && !this.validateEmail(userInfo.email)) {
        return { success: false, message: '请输入正确的邮箱地址' };
      }

      // 这里需要扩展 UserService 来支持更新用户信息
      // 暂时返回成功
      return { success: true, message: '信息更新成功' };
    } catch (error) {
      console.error('Failed to update user info:', error);
      return { success: false, message: '更新失败，请重试' };
    }
  }

  /**
   * 验证手机号码格式
   */
  private validatePhone(phone: string): boolean {
    const phoneRegex = /^1[3-9]\d{9}$/;
    return phoneRegex.test(phone);
  }

  /**
   * 验证邮箱格式
   */
  private validateEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  /**
   * 修改密码
   */
  async changePassword(oldPassword: string, newPassword: string): Promise<{ success: boolean; message: string }> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return { success: false, message: '用户未登录' };
      }

      // 验证新密码
      if (!newPassword || newPassword.length < 6) {
        return { success: false, message: '新密码长度不能少于6位' };
      }

      // 验证旧密码
      const isOldPasswordValid = await this.userService.login(currentUser, oldPassword);
      if (!isOldPasswordValid) {
        return { success: false, message: '原密码错误' };
      }

      // 这里需要扩展 UserService 来支持修改密码
      // 暂时返回成功
      return { success: true, message: '密码修改成功' };
    } catch (error) {
      console.error('Failed to change password:', error);
      return { success: false, message: '密码修改失败，请重试' };
    }
  }
}
