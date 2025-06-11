import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { OrderViewModel } from '../viewmodel/OrderViewModel';
import { OrderItem } from '../view/OrderItem';
import { Order } from '../model/Order';
import common from '@ohos.app.ability.common';

interface OrderStats {
  total: number;
  paid: number;
  completed: number;
}

/**
 * 我的订单页面
 */
@Entry
@Component
struct OrderListPage {
  @State orders: Order[] = [];
  @State isLoading: boolean = true;
  @State orderStats: OrderStats = { total: 0, paid: 0, completed: 0 };
  private orderViewModel: OrderViewModel = new OrderViewModel();

  async aboutToAppear() {
    try {
      await this.orderViewModel.init(getContext(this) as common.UIAbilityContext);
      await this.loadOrders();
      await this.loadOrderStats();
    } catch (error) {
      console.error('Failed to initialize OrderListPage:', error);
      this.isLoading = false;
    }
  }

  /**
   * 页面显示时刷新数据
   */
  async onPageShow() {
    // 页面显示时刷新订单数据
    await this.refreshOrders();
  }

  /**
   * 加载订单列表
   */
  private async loadOrders(): Promise<void> {
    try {
      this.isLoading = true;
      this.orders = await this.orderViewModel.getOrders();
      // 按创建时间倒序排列
      this.orders.sort((a, b) => b.createTime - a.createTime);
    } catch (error) {
      console.error('Failed to load orders:', error);
      promptAction.showToast({
        message: '加载订单失败',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 加载订单统计信息
   */
  private async loadOrderStats(): Promise<void> {
    try {
      this.orderStats = await this.orderViewModel.getOrderStats();
    } catch (error) {
      console.error('Failed to load order stats:', error);
    }
  }

  /**
   * 查看订单详情
   */
  private viewOrderDetail(order: Order): void {
    router.pushUrl({
      url: 'pages/OrderDetailPage',
      params: { order: order }
    });
  }

  /**
   * 刷新订单列表
   */
  private async refreshOrders(): Promise<void> {
    await this.loadOrders();
    await this.loadOrderStats();
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button() {
          Text('←')
            .fontSize(20)
            .fontColor('#333')
            .fontWeight(FontWeight.Bold)
        }
        .width(40)
        .height(40)
        .backgroundColor('#f0f0f0')
        .borderRadius(20)
        .onClick(() => router.back())

        Text('我的订单')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 刷新按钮
        Button() {
          Text('刷新')
            .fontSize(12)
            .fontColor('#666')
        }
        .height(32)
        .padding({ left: 8, right: 8 })
        .backgroundColor('#f0f0f0')
        .borderRadius(16)
        .onClick(() => this.refreshOrders())
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#fff')

      // 订单统计卡片
      if (!this.isLoading) {
        Row() {
          Column() {
            Text(this.orderStats.total.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .margin({ bottom: 4 })

            Text('全部订单')
              .fontSize(12)
              .fontColor('#666')
          }
          .layoutWeight(1)

          Column() {
            Text(this.orderStats.paid.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#ff6b35')
              .margin({ bottom: 4 })

            Text('已支付')
              .fontSize(12)
              .fontColor('#666')
          }
          .layoutWeight(1)

          Column() {
            Text(this.orderStats.completed.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4CAF50')
              .margin({ bottom: 4 })

            Text('已完成')
              .fontSize(12)
              .fontColor('#666')
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#fff')
        .margin({ top: 0, left: 16, right: 16, bottom: 0 })
        .borderRadius(8)
      }

      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .margin({ bottom: 16 })

          Text('加载中...')
            .fontSize(14)
            .fontColor('#666')
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ top: 60 })
        .justifyContent(FlexAlign.Start)
      } else if (this.orders.length === 0) {
        // 空状态
        Column() {
          Text('📋')
            .fontSize(60)
            .margin({ bottom: 16 })

          Text('暂无订单')
            .fontSize(16)
            .fontColor('#666')
            .margin({ bottom: 8 })

          Text('快去购买您喜欢的商品吧')
            .fontSize(14)
            .fontColor('#999')
            .margin({ bottom: 24 })

          Button('去购物')
            .width(120)
            .height(40)
            .backgroundColor('#ff6b35')
            .fontColor('#fff')
            .fontSize(16)
            .borderRadius(20)
            .onClick(() => {
              router.clear();
              router.pushUrl({ url: 'view/BottomTabs' });
            })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ top: 60 })
        .justifyContent(FlexAlign.Start)
      } else {
        // 订单列表
        Scroll() {
          Column() {
            ForEach(this.orders, (order: Order) => {
              OrderItem({
                order: order,
                onViewDetail: (order: Order) => this.viewOrderDetail(order)
              })
            }, (order: Order) => order.orderId)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Start)
          .padding({ left: 16, right: 16, top: 8, bottom: 16 })
        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)
        .align(Alignment.TopStart)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }
}
