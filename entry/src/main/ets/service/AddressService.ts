//202306110141 杨富涛
//地址服务，用于管理用户地址列表

import preferences from '@ohos.data.preferences';
import { Address } from '../model/Address';
import { Constants } from '../common/Constants';
import common from '@ohos.app.ability.common';

export class AddressService {
  private static instance: AddressService;
  private preferencesStore: preferences.Preferences | null = null;

  private constructor() { }

  /**
   * 获取单例实例
   */
  static getInstance(): AddressService {
    if (!AddressService.instance) {
      AddressService.instance = new AddressService();
    }
    return AddressService.instance;
  }

  /**
   * 初始化 Preferences
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    try {
      this.preferencesStore = await preferences.getPreferences(context, Constants.ADDRESSES_FILE);
    } catch (error) {
      console.error('Failed to initialize addresses preferences:', error);
      throw error;
    }
  }

  /**
   * 确保 Preferences 已初始化
   */
  private ensureInitialized(): void {
    if (!this.preferencesStore) {
      throw new Error('AddressService not initialized. Call init() first.');
    }
  }

  /**
   * 获取用户地址列表的存储键
   */
  private getAddressesKey(username: string): string {
    return `addresses_${username}`;
  }

  /**
   * 获取用户的所有地址
   */
  async getAddresses(username: string): Promise<Address[]> {
    try {
      this.ensureInitialized();
      const key = this.getAddressesKey(username);
      const addressesJson = await this.preferencesStore!.get(key, '[]') as string;
      return JSON.parse(addressesJson) as Address[];
    } catch (error) {
      console.error('Failed to get addresses:', error);
      return [];
    }
  }

  /**
   * 保存用户的地址列表
   */
  private async saveAddresses(username: string, addresses: Address[]): Promise<void> {
    try {
      this.ensureInitialized();
      const key = this.getAddressesKey(username);
      await this.preferencesStore!.put(key, JSON.stringify(addresses));
      await this.preferencesStore!.flush();
    } catch (error) {
      console.error('Failed to save addresses:', error);
      throw error;
    }
  }

  /**
   * 添加新地址
   */
  async addAddress(username: string, address: Address): Promise<boolean> {
    try {
      const addresses = await this.getAddresses(username);

      // 如果是默认地址，先取消其他地址的默认状态
      if (address.isDefault) {
        addresses.forEach(addr => addr.isDefault = false);
      }

      addresses.push(address);
      await this.saveAddresses(username, addresses);
      return true;
    } catch (error) {
      console.error('Failed to add address:', error);
      return false;
    }
  }

  /**
   * 更新地址
   */
  async updateAddress(username: string, updatedAddress: Address): Promise<boolean> {
    try {
      const addresses = await this.getAddresses(username);
      const index = addresses.findIndex(addr => addr.id === updatedAddress.id);

      if (index === -1) {
        return false; // 地址不存在
      }

      // 如果是设置为默认地址，先取消其他地址的默认状态
      if (updatedAddress.isDefault) {
        addresses.forEach(addr => addr.isDefault = false);
      }

      addresses[index] = updatedAddress;
      await this.saveAddresses(username, addresses);
      return true;
    } catch (error) {
      console.error('Failed to update address:', error);
      return false;
    }
  }

  /**
   * 删除地址
   */
  async deleteAddress(username: string, addressId: string): Promise<boolean> {
    try {
      const addresses = await this.getAddresses(username);
      const index = addresses.findIndex(addr => addr.id === addressId);

      if (index === -1) {
        return false; // 地址不存在
      }

      addresses.splice(index, 1);
      await this.saveAddresses(username, addresses);
      return true;
    } catch (error) {
      console.error('Failed to delete address:', error);
      return false;
    }
  }

  /**
   * 获取默认地址
   */
  async getDefaultAddress(username: string): Promise<Address | null> {
    try {
      const addresses = await this.getAddresses(username);
      return addresses.find(addr => addr.isDefault) || null;
    } catch (error) {
      console.error('Failed to get default address:', error);
      return null;
    }
  }

  /**
   * 设置默认地址
   */
  async setDefaultAddress(username: string, addressId: string): Promise<boolean> {
    try {
      const addresses = await this.getAddresses(username);

      // 取消所有地址的默认状态
      addresses.forEach(addr => addr.isDefault = false);

      // 设置指定地址为默认
      const targetAddress = addresses.find(addr => addr.id === addressId);
      if (!targetAddress) {
        return false; // 地址不存在
      }

      targetAddress.isDefault = true;
      await this.saveAddresses(username, addresses);
      return true;
    } catch (error) {
      console.error('Failed to set default address:', error);
      return false;
    }
  }
}
