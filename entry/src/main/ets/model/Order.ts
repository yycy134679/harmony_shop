import { OrderItem } from './OrderItem';
import { Address } from './Address';

/**
 * 订单模型接口
 */
export interface Order {
  orderId: string; // 可用时间戳+随机数生成
  userId: string;
  items: OrderItem[]; // 订单内的商品项
  totalPrice: number;
  shippingAddress: Address; // 订单使用的收货地址
  paymentMethod: '微信支付' | '支付宝' | '云闪付'; // 支付方式
  createTime: number; // 时间戳
  status: '已支付' | '已完成'; // 订单状态
}
