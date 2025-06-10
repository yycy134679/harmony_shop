import { OrderService } from '../service/OrderService';
import { Order } from '../model/Order';
import { OrderItem } from '../model/OrderItem';
import { Address } from '../model/Address';
import { CartItem } from '../model/CartItem';
import { Constants } from '../common/Constants';
import common from '@ohos.app.ability.common';

/**
 * 订单管理视图模型 - 管理订单相关的业务逻辑
 */
export class OrderViewModel {
  private orderService: OrderService;

  constructor() {
    this.orderService = OrderService.getInstance();
  }

  /**
   * 初始化服务
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    await this.orderService.init(context);
  }

  /**
   * 获取当前用户的所有订单
   */
  async getOrders(): Promise<Order[]> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return [];
      }

      return await this.orderService.getOrders(currentUser);
    } catch (error) {
      console.error('Failed to get orders:', error);
      return [];
    }
  }

  /**
   * 根据订单ID获取订单详情
   */
  async getOrderById(orderId: string): Promise<Order | null> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return null;
      }

      return await this.orderService.getOrderById(currentUser, orderId);
    } catch (error) {
      console.error('Failed to get order by id:', error);
      return null;
    }
  }

  /**
   * 创建新订单
   */
  async createOrder(
    cartItems: CartItem[],
    shippingAddress: Address,
    paymentMethod: '微信支付' | '支付宝' | '云闪付'
  ): Promise<{ success: boolean; orderId?: string; message: string }> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return { success: false, message: '用户未登录' };
      }

      if (!cartItems || cartItems.length === 0) {
        return { success: false, message: '购物车为空' };
      }

      if (!shippingAddress) {
        return { success: false, message: '请选择收货地址' };
      }

      // 转换购物车项为订单项
      const orderItems: OrderItem[] = cartItems.map(cartItem => ({
        productId: cartItem.product.id,
        name: cartItem.product.name,
        price: cartItem.product.price,
        quantity: cartItem.quantity
      }));

      // 计算总价
      const totalPrice = cartItems.reduce((total, item) => {
        return total + (item.product.price * item.quantity);
      }, 0);

      // 创建订单对象
      const orderData: Omit<Order, 'orderId' | 'createTime'> = {
        userId: currentUser,
        items: orderItems,
        totalPrice: totalPrice,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        status: '已支付'
      };

      // 调用服务创建订单
      const orderId = await this.orderService.createOrder(orderData);
      if (orderId) {
        return { success: true, orderId: orderId, message: '订单创建成功' };
      } else {
        return { success: false, message: '订单创建失败' };
      }
    } catch (error) {
      console.error('Failed to create order:', error);
      return { success: false, message: '创建订单失败，请重试' };
    }
  }

  /**
   * 更新订单状态
   */
  async updateOrderStatus(orderId: string, status: Order['status']): Promise<{ success: boolean; message: string }> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return { success: false, message: '用户未登录' };
      }

      const success = await this.orderService.updateOrderStatus(currentUser, orderId, status);
      if (success) {
        return { success: true, message: '订单状态更新成功' };
      } else {
        return { success: false, message: '订单不存在或更新失败' };
      }
    } catch (error) {
      console.error('Failed to update order status:', error);
      return { success: false, message: '更新失败，请重试' };
    }
  }

  /**
   * 获取订单统计信息
   */
  async getOrderStats(): Promise<{ total: number; paid: number; completed: number }> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return { total: 0, paid: 0, completed: 0 };
      }

      return await this.orderService.getOrderStats(currentUser);
    } catch (error) {
      console.error('Failed to get order stats:', error);
      return { total: 0, paid: 0, completed: 0 };
    }
  }

  /**
   * 格式化订单创建时间
   */
  formatOrderTime(createTime: number): string {
    const date = new Date(createTime);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    
    return `${year}-${month}-${day} ${hours}:${minutes}`;
  }

  /**
   * 格式化订单状态显示文本
   */
  getStatusDisplayText(status: Order['status']): string {
    switch (status) {
      case '已支付':
        return '已支付';
      case '已完成':
        return '已完成';
      default:
        return status;
    }
  }

  /**
   * 获取订单状态对应的颜色
   */
  getStatusColor(status: Order['status']): string {
    switch (status) {
      case '已支付':
        return '#ff6b35';
      case '已完成':
        return '#4CAF50';
      default:
        return '#666';
    }
  }

  /**
   * 计算订单商品总数量
   */
  calculateTotalQuantity(order: Order): number {
    return order.items.reduce((total, item) => total + item.quantity, 0);
  }

  /**
   * 获取订单的主要商品名称（用于列表显示）
   */
  getMainProductName(order: Order): string {
    if (order.items.length === 0) {
      return '无商品';
    }
    
    if (order.items.length === 1) {
      return order.items[0].name;
    }
    
    return `${order.items[0].name} 等${order.items.length}件商品`;
  }
}
