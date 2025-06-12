// 202506120141 杨富涛
// 订单服务，用于管理用户订单列表

import preferences from '@ohos.data.preferences';
import { Order } from '../model/Order';
import { Constants } from '../common/Constants';
import common from '@ohos.app.ability.common';

/**
 * 订单服务类 - 封装用户订单的持久化操作
 */
export class OrderService {
  private static instance: OrderService;
  private preferencesStore: preferences.Preferences | null = null;

  private constructor() { }

  /**
   * 获取单例实例
   */
  static getInstance(): OrderService {
    if (!OrderService.instance) {
      OrderService.instance = new OrderService();
    }
    return OrderService.instance;
  }

  /**
   * 初始化 Preferences
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    try {
      this.preferencesStore = await preferences.getPreferences(context, Constants.ORDERS_FILE);
    } catch (error) {
      console.error('Failed to initialize orders preferences:', error);
      throw error;
    }
  }

  /**
   * 确保 Preferences 已初始化
   */
  private ensureInitialized(): void {
    if (!this.preferencesStore) {
      throw new Error('OrderService not initialized. Call init() first.');
    }
  }

  /**
   * 获取用户订单列表的存储键
   */
  private getOrdersKey(username: string): string {
    return `orders_${username}`;
  }

  /**
   * 生成订单ID
   */
  private generateOrderId(): string {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 1000);
    return `ORDER_${timestamp}_${random}`;
  }

  /**
   * 获取用户的所有订单
   */
  async getOrders(username: string): Promise<Order[]> {
    try {
      this.ensureInitialized();
      const key = this.getOrdersKey(username);
      const ordersJson = await this.preferencesStore!.get(key, '[]') as string;
      return JSON.parse(ordersJson) as Order[];
    } catch (error) {
      console.error('Failed to get orders:', error);
      return [];
    }
  }

  /**
   * 保存用户的订单列表
   */
  private async saveOrders(username: string, orders: Order[]): Promise<void> {
    try {
      this.ensureInitialized();
      const key = this.getOrdersKey(username);
      await this.preferencesStore!.put(key, JSON.stringify(orders));
      await this.preferencesStore!.flush();
    } catch (error) {
      console.error('Failed to save orders:', error);
      throw error;
    }
  }

  /**
   * 创建新订单
   */
  async createOrder(order: Omit<Order, 'orderId' | 'createTime'>): Promise<string | null> {
    try {
      const newOrder: Order = {
        ...order,
        orderId: this.generateOrderId(),
        createTime: Date.now()
      };

      const orders = await this.getOrders(order.userId);
      orders.push(newOrder);
      await this.saveOrders(order.userId, orders);

      return newOrder.orderId;
    } catch (error) {
      console.error('Failed to create order:', error);
      return null;
    }
  }

  /**
   * 根据订单ID获取订单
   */
  async getOrderById(username: string, orderId: string): Promise<Order | null> {
    try {
      const orders = await this.getOrders(username);
      return orders.find(order => order.orderId === orderId) || null;
    } catch (error) {
      console.error('Failed to get order by id:', error);
      return null;
    }
  }

  /**
   * 更新订单状态
   */
  async updateOrderStatus(username: string, orderId: string, status: Order['status']): Promise<boolean> {
    try {
      const orders = await this.getOrders(username);
      const orderIndex = orders.findIndex(order => order.orderId === orderId);

      if (orderIndex === -1) {
        return false; // 订单不存在
      }

      orders[orderIndex].status = status;
      await this.saveOrders(username, orders);
      return true;
    } catch (error) {
      console.error('Failed to update order status:', error);
      return false;
    }
  }

  /**
   * 获取用户订单统计信息
   */
  async getOrderStats(username: string): Promise<{ total: number; paid: number; completed: number }> {
    try {
      const orders = await this.getOrders(username);
      const stats = {
        total: orders.length,
        paid: orders.filter(order => order.status === '已支付').length,
        completed: orders.filter(order => order.status === '已完成').length
      };
      return stats;
    } catch (error) {
      console.error('Failed to get order stats:', error);
      return { total: 0, paid: 0, completed: 0 };
    }
  }
}
