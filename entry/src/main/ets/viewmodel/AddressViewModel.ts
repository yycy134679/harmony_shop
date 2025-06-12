// 202506120141 杨富涛
// 地址管理视图模型，用于管理地址相关的业务逻辑

import { AddressService } from '../service/AddressService';
import { Address } from '../model/Address';
import { Constants } from '../common/Constants';
import common from '@ohos.app.ability.common';

/**
 * 地址管理视图模型 - 管理地址相关的业务逻辑
 */
export class AddressViewModel {
  private addressService: AddressService;

  constructor() {
    this.addressService = AddressService.getInstance();
  }

  /**
   * 初始化服务
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    await this.addressService.init(context);
  }

  /**
   * 获取当前用户的所有地址
   */
  async getAddresses(): Promise<Address[]> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return [];
      }

      return await this.addressService.getAddresses(currentUser);
    } catch (error) {
      console.error('Failed to get addresses:', error);
      return [];
    }
  }

  /**
   * 添加新地址
   */
  async addAddress(address: Omit<Address, 'id' | 'userId'>): Promise<{ success: boolean; message: string }> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return { success: false, message: '用户未登录' };
      }

      // 验证地址信息
      const validation = this.validateAddress(address);
      if (!validation.isValid) {
        return { success: false, message: validation.message };
      }

      // 生成地址ID
      const newAddress: Address = {
        ...address,
        id: this.generateAddressId(),
        userId: currentUser
      };

      const success = await this.addressService.addAddress(currentUser, newAddress);
      if (success) {
        return { success: true, message: '地址添加成功' };
      } else {
        return { success: false, message: '地址添加失败' };
      }
    } catch (error) {
      console.error('Failed to add address:', error);
      return { success: false, message: '添加失败，请重试' };
    }
  }

  /**
   * 更新地址
   */
  async updateAddress(address: Address): Promise<{ success: boolean; message: string }> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return { success: false, message: '用户未登录' };
      }

      // 验证地址信息
      const validation = this.validateAddress(address);
      if (!validation.isValid) {
        return { success: false, message: validation.message };
      }

      const success = await this.addressService.updateAddress(currentUser, address);
      if (success) {
        return { success: true, message: '地址更新成功' };
      } else {
        return { success: false, message: '地址不存在或更新失败' };
      }
    } catch (error) {
      console.error('Failed to update address:', error);
      return { success: false, message: '更新失败，请重试' };
    }
  }

  /**
   * 删除地址
   */
  async deleteAddress(addressId: string): Promise<{ success: boolean; message: string }> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return { success: false, message: '用户未登录' };
      }

      const success = await this.addressService.deleteAddress(currentUser, addressId);
      if (success) {
        return { success: true, message: '地址删除成功' };
      } else {
        return { success: false, message: '地址不存在或删除失败' };
      }
    } catch (error) {
      console.error('Failed to delete address:', error);
      return { success: false, message: '删除失败，请重试' };
    }
  }

  /**
   * 获取默认地址
   */
  async getDefaultAddress(): Promise<Address | null> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return null;
      }

      return await this.addressService.getDefaultAddress(currentUser);
    } catch (error) {
      console.error('Failed to get default address:', error);
      return null;
    }
  }

  /**
   * 设置默认地址
   */
  async setDefaultAddress(addressId: string): Promise<{ success: boolean; message: string }> {
    try {
      const currentUser = AppStorage.get(Constants.CURRENT_USER) as string;
      if (!currentUser) {
        return { success: false, message: '用户未登录' };
      }

      // 获取所有地址
      const addresses = await this.addressService.getAddresses(currentUser);
      const targetAddress = addresses.find(addr => addr.id === addressId);

      if (!targetAddress) {
        return { success: false, message: '地址不存在' };
      }

      // 设置为默认地址
      targetAddress.isDefault = true;
      const success = await this.addressService.updateAddress(currentUser, targetAddress);

      if (success) {
        return { success: true, message: '默认地址设置成功' };
      } else {
        return { success: false, message: '设置失败' };
      }
    } catch (error) {
      console.error('Failed to set default address:', error);
      return { success: false, message: '设置失败，请重试' };
    }
  }

  /**
   * 验证地址信息
   */
  private validateAddress(address: Partial<Address>): { isValid: boolean; message: string } {
    if (!address.recipientName || address.recipientName.trim().length === 0) {
      return { isValid: false, message: '请输入收件人姓名' };
    }

    if (!address.phone || !this.validatePhone(address.phone)) {
      return { isValid: false, message: '请输入正确的手机号码' };
    }

    if (!address.fullAddress || address.fullAddress.trim().length === 0) {
      return { isValid: false, message: '请输入详细地址' };
    }

    if (address.fullAddress.trim().length < 5) {
      return { isValid: false, message: '详细地址不能少于5个字符' };
    }

    return { isValid: true, message: '' };
  }

  /**
   * 验证手机号码格式
   */
  private validatePhone(phone: string): boolean {
    const phoneRegex = /^1[3-9]\d{9}$/;
    return phoneRegex.test(phone);
  }

  /**
   * 生成地址ID
   */
  private generateAddressId(): string {
    return `addr_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}
