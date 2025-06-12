// 202506120141 杨富涛
// 用户服务，用于管理用户注册和登录验证

import preferences from '@ohos.data.preferences';
import { User } from '../model/User';
import { Constants } from '../common/Constants';
import common from '@ohos.app.ability.common';

/**
 * 用户服务类 - 封装 Preferences 操作，负责用户注册和登录验证的底层服务
 */
export class UserService {
  private static instance: UserService;
  private preferencesStore: preferences.Preferences | null = null;

  private constructor() { }

  /**
   * 获取单例实例
   */
  static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService();
    }
    return UserService.instance;
  }

  /**
   * 初始化 Preferences
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    try {
      this.preferencesStore = await preferences.getPreferences(context, Constants.USER_ACCOUNTS_FILE);
    } catch (error) {
      console.error('Failed to initialize preferences:', error);
      throw error;
    }
  }

  /**
   * 获取所有用户
   */
  private async getAllUsers(): Promise<User[]> {
    if (!this.preferencesStore) {
      throw new Error('Preferences not initialized');
    }

    try {
      const usersJson = await this.preferencesStore.get(Constants.USER_ACCOUNTS_KEY, '[]') as string;
      return JSON.parse(usersJson) as User[];
    } catch (error) {
      console.error('Failed to get users:', error);
      return [];
    }
  }

  /**
   * 保存所有用户
   */
  private async saveAllUsers(users: User[]): Promise<void> {
    if (!this.preferencesStore) {
      throw new Error('Preferences not initialized');
    }

    try {
      await this.preferencesStore.put(Constants.USER_ACCOUNTS_KEY, JSON.stringify(users));
      await this.preferencesStore.flush();
    } catch (error) {
      console.error('Failed to save users:', error);
      throw error;
    }
  }

  /**
   * 用户注册
   */
  async registerUser(user: User): Promise<boolean> {
    try {
      const users = await this.getAllUsers();

      // 检查用户名是否已存在
      if (users.some(u => u.username === user.username)) {
        return false; // 用户名已存在
      }

      users.push(user);
      await this.saveAllUsers(users);
      return true;
    } catch (error) {
      console.error('Failed to register user:', error);
      return false;
    }
  }

  /**
   * 用户登录验证
   */
  async login(username: string, password: string): Promise<boolean> {
    try {
      const users = await this.getAllUsers();
      return users.some(user => user.username === username && user.password === password);
    } catch (error) {
      console.error('Failed to login:', error);
      return false;
    }
  }

  /**
   * 检查用户名是否存在
   */
  async userExists(username: string): Promise<boolean> {
    try {
      const users = await this.getAllUsers();
      return users.some(user => user.username === username);
    } catch (error) {
      console.error('Failed to check user existence:', error);
      return false;
    }
  }

  /**
   * 根据用户名获取用户信息
   */
  async getUserByUsername(username: string): Promise<User | null> {
    try {
      const users = await this.getAllUsers();
      return users.find(user => user.username === username) || null;
    } catch (error) {
      console.error('Failed to get user by username:', error);
      return null;
    }
  }

  /**
   * 更新用户信息
   */
  async updateUser(username: string, updatedInfo: Partial<User>): Promise<boolean> {
    try {
      const users = await this.getAllUsers();
      const userIndex = users.findIndex(user => user.username === username);

      if (userIndex === -1) {
        return false; // 用户不存在
      }

      // 更新用户信息，但不允许修改用户名
      users[userIndex] = {
        ...users[userIndex],
        ...updatedInfo,
        username: users[userIndex].username // 保持用户名不变
      };

      await this.saveAllUsers(users);
      return true;
    } catch (error) {
      console.error('Failed to update user:', error);
      return false;
    }
  }

  /**
   * 修改用户密码
   */
  async changePassword(username: string, oldPassword: string, newPassword: string): Promise<boolean> {
    try {
      const users = await this.getAllUsers();
      const userIndex = users.findIndex(user => user.username === username);

      if (userIndex === -1) {
        return false; // 用户不存在
      }

      // 验证旧密码
      if (users[userIndex].password !== oldPassword) {
        return false; // 旧密码错误
      }

      // 更新密码
      users[userIndex].password = newPassword;
      await this.saveAllUsers(users);
      return true;
    } catch (error) {
      console.error('Failed to change password:', error);
      return false;
    }
  }
}
