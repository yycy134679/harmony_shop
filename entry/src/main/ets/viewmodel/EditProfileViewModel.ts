// 202506120141 杨富涛
// 编辑个人信息视图模型，用于管理个人信息编辑的业务逻辑

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

      // 调用UserService更新用户信息
      const success = await this.userService.updateUser(currentUser, userInfo);
      if (success) {
        return { success: true, message: '信息更新成功' };
      } else {
        return { success: false, message: '更新失败，用户不存在' };
      }
    } catch (error) {
      console.error('Failed to update user info:', error);
      return { success: false, message: '更新失败，请重试' };
    }
  }

  /**
   * 验证手机号码格式 - 只验证11位数字
   */
  private validatePhone(phone: string): boolean {
    // 只验证是否为11位数字
    const phoneRegex = /^\d{11}$/;
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

      // 调用UserService修改密码
      const success = await this.userService.changePassword(currentUser, oldPassword, newPassword);
      if (success) {
        return { success: true, message: '密码修改成功' };
      } else {
        return { success: false, message: '原密码错误或用户不存在' };
      }
    } catch (error) {
      console.error('Failed to change password:', error);
      return { success: false, message: '密码修改失败，请重试' };
    }
  }
}
