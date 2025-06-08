import { UserService } from '../service/UserService';
import { User } from '../model/User';
import { Constants } from '../common/Constants';
import common from '@ohos.app.ability.common';

/**
 * 用户视图模型 - 登录/注册页面的业务逻辑和状态管理
 */
export class UserViewModel {
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
   * 用户注册
   */
  async register(user: User): Promise<{ success: boolean; message: string }> {
    try {
      // 基本验证
      if (!user.username || !user.password) {
        return { success: false, message: '用户名和密码不能为空' };
      }

      if (user.username.length < 3) {
        return { success: false, message: '用户名至少需要3个字符' };
      }

      if (user.password.length < 6) {
        return { success: false, message: '密码至少需要6个字符' };
      }

      const success = await this.userService.registerUser(user);
      if (success) {
        return { success: true, message: '注册成功' };
      } else {
        return { success: false, message: '用户名已存在' };
      }
    } catch (error) {
      console.error('Registration error:', error);
      return { success: false, message: '注册失败，请重试' };
    }
  }

  /**
   * 用户登录
   */
  async login(username: string, password: string): Promise<{ success: boolean; message: string }> {
    try {
      // 基本验证
      if (!username || !password) {
        return { success: false, message: '用户名和密码不能为空' };
      }

      const success = await this.userService.login(username, password);
      if (success) {
        // 更新全局状态
        AppStorage.setOrCreate(Constants.IS_LOGGED_IN, true);
        AppStorage.setOrCreate(Constants.CURRENT_USER, username);
        return { success: true, message: '登录成功' };
      } else {
        return { success: false, message: '用户名或密码错误' };
      }
    } catch (error) {
      console.error('Login error:', error);
      return { success: false, message: '登录失败，请重试' };
    }
  }

  /**
   * 用户退出登录
   */
  logout(): void {
    AppStorage.setOrCreate(Constants.IS_LOGGED_IN, false);
    AppStorage.setOrCreate(Constants.CURRENT_USER, '');
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
  getCurrentUser(): string {
    return AppStorage.get(Constants.CURRENT_USER) as string || '';
  }
}
