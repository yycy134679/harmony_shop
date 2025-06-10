import preferences from '@ohos.data.preferences';
import { Constants } from '../common/Constants';
import common from '@ohos.app.ability.common';

/**
 * 收藏服务类 - 封装用户商品收藏的持久化操作
 */
export class FavoriteService {
  private static instance: FavoriteService;
  private preferencesStore: preferences.Preferences | null = null;

  private constructor() { }

  /**
   * 获取单例实例
   */
  static getInstance(): FavoriteService {
    if (!FavoriteService.instance) {
      FavoriteService.instance = new FavoriteService();
    }
    return FavoriteService.instance;
  }

  /**
   * 初始化 Preferences
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    try {
      this.preferencesStore = await preferences.getPreferences(context, Constants.FAVORITES_FILE);
    } catch (error) {
      console.error('Failed to initialize favorites preferences:', error);
      throw error;
    }
  }

  /**
   * 确保 Preferences 已初始化
   */
  private ensureInitialized(): void {
    if (!this.preferencesStore) {
      throw new Error('FavoriteService not initialized. Call init() first.');
    }
  }

  /**
   * 获取用户收藏列表的存储键
   */
  private getFavoritesKey(username: string): string {
    return `favorites_${username}`;
  }

  /**
   * 获取用户的收藏商品ID列表
   */
  async getFavorites(username: string): Promise<number[]> {
    try {
      this.ensureInitialized();
      const key = this.getFavoritesKey(username);
      const favoritesJson = await this.preferencesStore!.get(key, '[]') as string;
      return JSON.parse(favoritesJson) as number[];
    } catch (error) {
      console.error('Failed to get favorites:', error);
      return [];
    }
  }

  /**
   * 保存用户的收藏商品ID列表
   */
  private async saveFavorites(username: string, favorites: number[]): Promise<void> {
    try {
      this.ensureInitialized();
      const key = this.getFavoritesKey(username);
      await this.preferencesStore!.put(key, JSON.stringify(favorites));
      await this.preferencesStore!.flush();
    } catch (error) {
      console.error('Failed to save favorites:', error);
      throw error;
    }
  }

  /**
   * 添加商品到收藏
   */
  async addFavorite(username: string, productId: number): Promise<boolean> {
    try {
      const favorites = await this.getFavorites(username);
      
      // 检查是否已经收藏
      if (favorites.includes(productId)) {
        return false; // 已经收藏过了
      }

      favorites.push(productId);
      await this.saveFavorites(username, favorites);
      return true;
    } catch (error) {
      console.error('Failed to add favorite:', error);
      return false;
    }
  }

  /**
   * 从收藏中移除商品
   */
  async removeFavorite(username: string, productId: number): Promise<boolean> {
    try {
      const favorites = await this.getFavorites(username);
      const index = favorites.indexOf(productId);
      
      if (index === -1) {
        return false; // 商品不在收藏列表中
      }

      favorites.splice(index, 1);
      await this.saveFavorites(username, favorites);
      return true;
    } catch (error) {
      console.error('Failed to remove favorite:', error);
      return false;
    }
  }

  /**
   * 检查商品是否已收藏
   */
  async isFavorite(username: string, productId: number): Promise<boolean> {
    try {
      const favorites = await this.getFavorites(username);
      return favorites.includes(productId);
    } catch (error) {
      console.error('Failed to check favorite status:', error);
      return false;
    }
  }

  /**
   * 切换收藏状态
   */
  async toggleFavorite(username: string, productId: number): Promise<boolean> {
    try {
      const isCurrentlyFavorite = await this.isFavorite(username, productId);
      
      if (isCurrentlyFavorite) {
        await this.removeFavorite(username, productId);
        return false; // 返回新的收藏状态：false表示已取消收藏
      } else {
        await this.addFavorite(username, productId);
        return true; // 返回新的收藏状态：true表示已添加收藏
      }
    } catch (error) {
      console.error('Failed to toggle favorite:', error);
      return false;
    }
  }
}
