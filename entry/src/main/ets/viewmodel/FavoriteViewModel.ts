import { FavoriteService } from '../service/FavoriteService';
import { Product } from '../model/Product';
import { DataSource } from '../model/DataSource';
import { Constants } from '../common/Constants';
import common from '@ohos.app.ability.common';

/**
 * 收藏视图模型 - 管理商品收藏的业务逻辑和状态
 */
export class FavoriteViewModel {
  private favoriteService: FavoriteService;

  constructor() {
    this.favoriteService = FavoriteService.getInstance();
  }

  /**
   * 初始化服务
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    await this.favoriteService.init(context);
  }

  /**
   * 切换商品收藏状态
   */
  async toggleFavorite(productId: number): Promise<{ success: boolean; isFavorite: boolean; message: string }> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return { success: false, isFavorite: false, message: '用户未登录' };
      }

      const newFavoriteStatus = await this.favoriteService.toggleFavorite(currentUser, productId);
      const message = newFavoriteStatus ? '已添加到收藏' : '已取消收藏';
      
      return { success: true, isFavorite: newFavoriteStatus, message };
    } catch (error) {
      console.error('Failed to toggle favorite:', error);
      return { success: false, isFavorite: false, message: '操作失败，请重试' };
    }
  }

  /**
   * 检查商品是否已收藏
   */
  async checkFavoriteStatus(productId: number): Promise<boolean> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return false;
      }

      return await this.favoriteService.isFavorite(currentUser, productId);
    } catch (error) {
      console.error('Failed to check favorite status:', error);
      return false;
    }
  }

  /**
   * 获取用户收藏的商品列表
   */
  async getFavoriteProducts(): Promise<Product[]> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return [];
      }

      const favoriteIds = await this.favoriteService.getFavorites(currentUser);
      const favoriteProducts: Product[] = [];

      // 根据收藏的商品ID获取完整的商品信息
      for (const productId of favoriteIds) {
        const product = DataSource.getProductById(productId);
        if (product) {
          favoriteProducts.push(product);
        }
      }

      return favoriteProducts;
    } catch (error) {
      console.error('Failed to get favorite products:', error);
      return [];
    }
  }

  /**
   * 取消收藏商品
   */
  async removeFavorite(productId: number): Promise<{ success: boolean; message: string }> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return { success: false, message: '用户未登录' };
      }

      const success = await this.favoriteService.removeFavorite(currentUser, productId);
      if (success) {
        return { success: true, message: '已取消收藏' };
      } else {
        return { success: false, message: '商品不在收藏列表中' };
      }
    } catch (error) {
      console.error('Failed to remove favorite:', error);
      return { success: false, message: '取消收藏失败，请重试' };
    }
  }

  /**
   * 获取收藏数量
   */
  async getFavoriteCount(): Promise<number> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return 0;
      }

      const favorites = await this.favoriteService.getFavorites(currentUser);
      return favorites.length;
    } catch (error) {
      console.error('Failed to get favorite count:', error);
      return 0;
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
}
