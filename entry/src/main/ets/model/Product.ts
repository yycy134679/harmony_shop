//202306110141 杨富涛

/**
 * 商品数据模型接口
 */
export interface Product {
  id: number;
  name: string;
  price: number;
  image: string;
  description?: string;
}
