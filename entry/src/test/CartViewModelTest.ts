import { CartViewModel } from '../main/ets/viewmodel/CartViewModel';
import { Product } from '../main/ets/model/Product';
import { Constants } from '../main/ets/common/Constants';

/**
 * 购物车视图模型测试
 * 用于验证购物车功能的正确性
 */
export class CartViewModelTest {
  private cartViewModel: CartViewModel;

  constructor() {
    this.cartViewModel = new CartViewModel();
  }

  /**
   * 运行所有测试
   */
  runAllTests(): boolean {
    console.log('开始运行购物车测试...');
    
    let allTestsPassed = true;
    
    try {
      // 清空购物车以确保测试环境干净
      this.cartViewModel.clearCart();
      
      allTestsPassed = this.testAddToCart() && allTestsPassed;
      allTestsPassed = this.testUpdateQuantity() && allTestsPassed;
      allTestsPassed = this.testRemoveFromCart() && allTestsPassed;
      allTestsPassed = this.testTotalCalculations() && allTestsPassed;
      allTestsPassed = this.testQuantityOperations() && allTestsPassed;
      
      if (allTestsPassed) {
        console.log('✅ 所有购物车测试通过！');
      } else {
        console.log('❌ 部分购物车测试失败！');
      }
      
    } catch (error) {
      console.error('测试过程中发生错误:', error);
      allTestsPassed = false;
    }
    
    return allTestsPassed;
  }

  /**
   * 测试添加商品到购物车
   */
  private testAddToCart(): boolean {
    console.log('测试添加商品到购物车...');
    
    const testProduct: Product = {
      id: 1,
      name: '测试商品',
      price: 100,
      image: 'test.jpg',
      description: '测试商品描述'
    };

    // 添加商品
    this.cartViewModel.addToCart(testProduct, 2);
    
    const cartItems = this.cartViewModel.getCartItems();
    const productQuantity = this.cartViewModel.getProductQuantity(1);
    
    if (cartItems.length === 1 && productQuantity === 2) {
      console.log('✅ 添加商品测试通过');
      return true;
    } else {
      console.log('❌ 添加商品测试失败');
      return false;
    }
  }

  /**
   * 测试更新商品数量
   */
  private testUpdateQuantity(): boolean {
    console.log('测试更新商品数量...');
    
    // 更新数量
    this.cartViewModel.updateQuantity(1, 5);
    const quantity = this.cartViewModel.getProductQuantity(1);
    
    if (quantity === 5) {
      console.log('✅ 更新数量测试通过');
      return true;
    } else {
      console.log('❌ 更新数量测试失败');
      return false;
    }
  }

  /**
   * 测试移除商品
   */
  private testRemoveFromCart(): boolean {
    console.log('测试移除商品...');
    
    // 移除商品
    this.cartViewModel.removeFromCart(1);
    const cartItems = this.cartViewModel.getCartItems();
    const quantity = this.cartViewModel.getProductQuantity(1);
    
    if (cartItems.length === 0 && quantity === 0) {
      console.log('✅ 移除商品测试通过');
      return true;
    } else {
      console.log('❌ 移除商品测试失败');
      return false;
    }
  }

  /**
   * 测试总数和总价计算
   */
  private testTotalCalculations(): boolean {
    console.log('测试总数和总价计算...');
    
    const product1: Product = { id: 1, name: '商品1', price: 100, image: 'test1.jpg' };
    const product2: Product = { id: 2, name: '商品2', price: 200, image: 'test2.jpg' };
    
    this.cartViewModel.addToCart(product1, 2);
    this.cartViewModel.addToCart(product2, 3);
    
    const totalQuantity = this.cartViewModel.getTotalQuantity();
    const totalPrice = this.cartViewModel.getTotalPrice();
    
    // 预期：2 + 3 = 5 件商品，100*2 + 200*3 = 800 元
    if (totalQuantity === 5 && totalPrice === 800) {
      console.log('✅ 总数和总价计算测试通过');
      return true;
    } else {
      console.log(`❌ 总数和总价计算测试失败 - 总数: ${totalQuantity}, 总价: ${totalPrice}`);
      return false;
    }
  }

  /**
   * 测试数量增减操作
   */
  private testQuantityOperations(): boolean {
    console.log('测试数量增减操作...');
    
    // 清空购物车
    this.cartViewModel.clearCart();
    
    const testProduct: Product = {
      id: 3,
      name: '测试商品3',
      price: 50,
      image: 'test3.jpg'
    };
    
    this.cartViewModel.addToCart(testProduct, 1);
    
    // 测试增加数量
    this.cartViewModel.increaseQuantity(3);
    let quantity = this.cartViewModel.getProductQuantity(3);
    
    if (quantity !== 2) {
      console.log('❌ 增加数量测试失败');
      return false;
    }
    
    // 测试减少数量
    this.cartViewModel.decreaseQuantity(3);
    quantity = this.cartViewModel.getProductQuantity(3);
    
    if (quantity !== 1) {
      console.log('❌ 减少数量测试失败');
      return false;
    }
    
    // 测试减少到0时移除商品
    this.cartViewModel.decreaseQuantity(3);
    quantity = this.cartViewModel.getProductQuantity(3);
    const isEmpty = this.cartViewModel.isEmpty();
    
    if (quantity === 0 && isEmpty) {
      console.log('✅ 数量增减操作测试通过');
      return true;
    } else {
      console.log('❌ 减少到0时移除商品测试失败');
      return false;
    }
  }
}
