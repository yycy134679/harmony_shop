//202306110141 杨富涛

import { Product } from './Product';

/**
 * 购物车项模型接口
 */
export interface CartItem {
  product: Product;
  quantity: number;
}
