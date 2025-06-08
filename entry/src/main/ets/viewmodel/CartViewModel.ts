import { CartItem } from '../model/CartItem';
import { Product } from '../model/Product';
import { Constants } from '../common/Constants';

/**
 * 购物车视图模型 - 购物车的业务逻辑和状态管理
 */
export class CartViewModel {
  constructor() {
    // 初始化购物车状态
    this.initializeCart();
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
}
