// 202506120141 杨富涛
// 底部导航栏容器组件，用于显示应用的主导航容器

import { Constants } from '../common/Constants';
import { CartItem } from '../model/CartItem';
import { IndexContent } from './IndexContent';
import { CartContent } from './CartContent';
import { ProfileContent } from './ProfileContent';
import router from '@ohos.router';

/**
 * 底部导航栏容器组件 - 应用的主导航容器
 */
@Entry
@Component
struct BottomTabs {
  @StorageLink(Constants.SHOPPING_CART) cartItems: CartItem[] = [];
  @State currentIndex: number = 0;

  /**
   * 计算购物车中商品总数量
   */
  private getCartTotalQuantity(): number {
    return this.cartItems.reduce((total, item) => total + item.quantity, 0);
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      // 首页标签
      TabContent() {
        IndexContent()
      }
      .tabBar(this.TabBuilder('首页', 0, null))

      // 购物车标签
      TabContent() {
        CartContent()
      }
      .tabBar(this.TabBuilder('购物车', 1, null, this.getCartTotalQuantity()))

      // 我的标签
      TabContent() {
        ProfileContent()
      }
      .tabBar(this.TabBuilder('我的', 2, null))
    }
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }

  /**
   * 构建标签栏项
   */
  @Builder
  TabBuilder(title: string, targetIndex: number, icon: Resource | null, badgeCount?: number) {
    Column() {
      Stack() {
        // 使用文字图标替代系统图标
        Text(this.getTabIcon(title))
          .fontSize(20)
          .fontColor(this.currentIndex === targetIndex ? '#ff6b35' : '#999')

        // 购物车徽章
        if (badgeCount && badgeCount > 0) {
          Text(badgeCount > 99 ? '99+' : badgeCount.toString())
            .fontSize(10)
            .fontColor('#fff')
            .backgroundColor('#E41F19')
            .borderRadius(10)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .position({ x: 14, y: -6 })
            .width(20)
            .textAlign(TextAlign.Center)
        }
      }
      .margin({ bottom: 4 })

      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === targetIndex ? '#ff6b35' : '#999')
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 获取标签页图标
   */
  private getTabIcon(title: string): string {
    switch (title) {
      case '首页':
        return '🏠';
      case '购物车':
        return '🛒';
      case '我的':
        return '👤';
      default:
        return '•';
    }
  }
}
