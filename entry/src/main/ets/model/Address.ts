//202306110141 杨富涛

/**
 * 收货地址数据模型接口
 */
export interface Address {
  id: string; // 地址唯一ID, 可用UUID或时间戳生成
  userId: string; // 关联的用户
  recipientName: string; // 收件人姓名
  phone: string; // 联系电话
  fullAddress: string; // 详细地址
  isDefault: boolean; // 是否为默认地址
}
