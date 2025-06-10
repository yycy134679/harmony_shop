import { CartItem } from '../model/CartItem';
import { Product } from '../model/Product';
import { Constants } from '../common/Constants';
import { OrderViewModel } from './OrderViewModel';
import { AddressViewModel } from './AddressViewModel';
import { Address } from '../model/Address';
import common from '@ohos.app.ability.common';

/**
 * 购物车视图模型 - 购物车的业务逻辑和状态管理
 */
export class CartViewModel {
  private orderViewModel: OrderViewModel;
  private addressViewModel: AddressViewModel;

  constructor() {
    // 初始化购物车状态
    this.initializeCart();
    this.orderViewModel = new OrderViewModel();
    this.addressViewModel = new AddressViewModel();
  }

  /**
   * 初始化服务
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    await this.orderViewModel.init(context);
    await this.addressViewModel.init(context);
  }

  /**
   * 初始化购物车
   */
  private initializeCart(): void {
    const existingCart = AppStorage.get(Constants.SHOPPING_CART);
    if (!existingCart) {
      AppStorage.setOrCreate(Constants.SHOPPING_CART, [] as CartItem[]);
    }
  }

  /**
   * 获取购物车中的所有商品
   */
  getCartItems(): CartItem[] {
    return AppStorage.get(Constants.SHOPPING_CART) as CartItem[] || [];
  }

  /**
   * 添加商品到购物车
   */
  addToCart(product: Product, quantity: number = 1): void {
    const cartItems = [...this.getCartItems()]; // 创建新数组以触发状态更新
    const existingItemIndex = cartItems.findIndex(item => item.product.id === product.id);

    if (existingItemIndex >= 0) {
      // 如果商品已存在，增加数量
      cartItems[existingItemIndex] = {
        ...cartItems[existingItemIndex],
        quantity: cartItems[existingItemIndex].quantity + quantity
      };
    } else {
      // 如果商品不存在，添加新项
      cartItems.push({ product, quantity });
    }

    // 使用 set 方法确保状态更新被正确触发
    AppStorage.set(Constants.SHOPPING_CART, cartItems);
  }

  /**
   * 从购物车中移除商品
   */
  removeFromCart(productId: number): void {
    const cartItems = this.getCartItems();
    const updatedItems = cartItems.filter(item => item.product.id !== productId);
    AppStorage.set(Constants.SHOPPING_CART, updatedItems);
  }

  /**
   * 更新购物车中商品的数量
   */
  updateQuantity(productId: number, quantity: number): void {
    if (quantity <= 0) {
      this.removeFromCart(productId);
      return;
    }

    const cartItems = [...this.getCartItems()]; // 创建新数组以触发状态更新
    const itemIndex = cartItems.findIndex(item => item.product.id === productId);

    if (itemIndex >= 0) {
      cartItems[itemIndex] = {
        ...cartItems[itemIndex],
        quantity: quantity
      };
      AppStorage.set(Constants.SHOPPING_CART, cartItems);
    }
  }

  /**
   * 增加商品数量
   */
  increaseQuantity(productId: number): void {
    const currentQuantity = this.getProductQuantity(productId);
    this.updateQuantity(productId, currentQuantity + 1);
  }

  /**
   * 减少商品数量
   */
  decreaseQuantity(productId: number): void {
    const currentQuantity = this.getProductQuantity(productId);
    if (currentQuantity > 1) {
      this.updateQuantity(productId, currentQuantity - 1);
    } else {
      this.removeFromCart(productId);
    }
  }

  /**
   * 清空购物车
   */
  clearCart(): void {
    AppStorage.set(Constants.SHOPPING_CART, [] as CartItem[]);
  }

  /**
   * 获取购物车中商品的总数量
   */
  getTotalQuantity(): number {
    const cartItems = this.getCartItems();
    return cartItems.reduce((total, item) => total + item.quantity, 0);
  }

  /**
   * 获取购物车总价
   */
  getTotalPrice(): number {
    const cartItems = this.getCartItems();
    return cartItems.reduce((total, item) => total + (item.product.price * item.quantity), 0);
  }

  /**
   * 检查购物车是否为空
   */
  isEmpty(): boolean {
    return this.getCartItems().length === 0;
  }

  /**
   * 获取购物车中商品的数量（按商品ID）
   */
  getProductQuantity(productId: number): number {
    const cartItems = this.getCartItems();
    const item = cartItems.find(item => item.product.id === productId);
    return item ? item.quantity : 0;
  }

  /**
   * 格式化价格显示
   */
  formatPrice(price: number): string {
    return `¥${price.toFixed(2)}`;
  }

  /**
   * 获取默认收货地址
   */
  async getDefaultAddress(): Promise<Address | null> {
    try {
      return await this.addressViewModel.getDefaultAddress();
    } catch (error) {
      console.error('Failed to get default address:', error);
      return null;
    }
  }

  /**
   * 获取所有收货地址
   */
  async getAllAddresses(): Promise<Address[]> {
    try {
      return await this.addressViewModel.getAddresses();
    } catch (error) {
      console.error('Failed to get addresses:', error);
      return [];
    }
  }

  /**
   * 创建订单并清空购物车
   */
  async createOrderAndClearCart(
    shippingAddress: Address,
    paymentMethod: '微信支付' | '支付宝' | '云闪付'
  ): Promise<{ success: boolean; orderId?: string; message: string }> {
    try {
      const cartItems = this.getCartItems();
      if (cartItems.length === 0) {
        return { success: false, message: '购物车为空' };
      }

      // 创建订单
      const result = await this.orderViewModel.createOrder(cartItems, shippingAddress, paymentMethod);

      if (result.success) {
        // 订单创建成功，清空购物车
        this.clearCart();
      }

      return result;
    } catch (error) {
      console.error('Failed to create order and clear cart:', error);
      return { success: false, message: '创建订单失败，请重试' };
    }
  }

  /**
   * 验证购物车是否可以结算
   */
  canCheckout(): { canCheckout: boolean; message: string } {
    const cartItems = this.getCartItems();

    if (cartItems.length === 0) {
      return { canCheckout: false, message: '购物车为空' };
    }

    // 检查是否有无效商品（价格为0或负数）
    const invalidItems = cartItems.filter(item => item.product.price <= 0);
    if (invalidItems.length > 0) {
      return { canCheckout: false, message: '购物车中存在无效商品' };
    }

    return { canCheckout: true, message: '' };
  }

  /**
   * 获取购物车摘要信息
   */
  getCartSummary(): {
    totalItems: number;
    totalQuantity: number;
    totalPrice: number;
    formattedTotalPrice: string;
  } {
    const cartItems = this.getCartItems();
    const totalItems = cartItems.length;
    const totalQuantity = this.getTotalQuantity();
    const totalPrice = this.getTotalPrice();

    return {
      totalItems,
      totalQuantity,
      totalPrice,
      formattedTotalPrice: this.formatPrice(totalPrice)
    };
  }
}
