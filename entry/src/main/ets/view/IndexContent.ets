// 202506120141 杨富涛
// 首页内容组件，用于显示商品列表和搜索功能

import { router } from '@kit.ArkUI';
import { Constants } from '../common/Constants';
import { CartViewModel } from '../viewmodel/CartViewModel';
import { UserViewModel } from '../viewmodel/UserViewModel';
import { FavoriteViewModel } from '../viewmodel/FavoriteViewModel';
import { Product } from '../model/Product';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';

interface IndexProduct {
  id: number;
  name: string;
  imageUrl: string;
  price: string;
  category: string;
}

@Component
export struct IndexContent {
  // 登录状态管理
  @StorageLink(Constants.IS_LOGGED_IN) isLoggedIn: boolean = false;
  @StorageLink(Constants.CURRENT_USER) currentUser: string = '';

  // 监听登录状态变化
  @Watch('onLoginStatusChanged') @StorageLink(Constants.IS_LOGGED_IN) watchIsLoggedIn: boolean = false;
  
  // State for the selected category
  @State selectedCategory: string = '手机'; // Default selected category
  // List of categories
  private categories: string[] = ['手机', '鞋子', '衣服'];
  // 购物车视图模型
  private cartViewModel: CartViewModel = new CartViewModel();
  // 用户视图模型
  private userViewModel: UserViewModel = new UserViewModel();
  // 收藏视图模型
  private favoriteViewModel: FavoriteViewModel = new FavoriteViewModel();
  
  // All products data (replace with your actual data source)
  @State allProducts: IndexProduct[] = [
    {
      id: 1,
      name: 'Apple iPhone 16 Pro Max 256GB',
      imageUrl: 'https://img10.360buyimg.com/n5/s720x720_jfs/t1/168145/19/47417/9061/66df731fF3d55d94e/ce6d11f80a757287.jpg',
      price: '¥7999',
      category: '手机'
    },
    {
      id: 2,
      name: '小米 15 白色',
      imageUrl: 'https://img10.360buyimg.com/n5/s720x720_jfs/t1/188918/24/49838/43069/67203b9aFea4cec24/563909f5ba6329ea.jpg',
      price: '¥4999',
      category: '手机'
    },
    {
      id: 3,
      name: '三星Samsung Galaxy S24 Ultra',
      imageUrl: 'https://img13.360buyimg.com/n5/s720x720_jfs/t1/196045/16/45365/38717/664d6022Fe03b017b/40444f6ba5878a5e.jpg',
      price: '¥6466',
      category: '手机'
    },
    {
      id: 4,
      name: 'HUAWEI Mate 70',
      imageUrl: 'https://img12.360buyimg.com/n5/s720x720_jfs/t1/242313/11/23691/25932/6747e3e8F41f778d7/294a54279bf82296.jpg',
      price: '¥12999',
      category: '手机'
    },
    {
      id: 5,
      name: '安踏（ANTA）男鞋板鞋',
      imageUrl: 'https://img13.360buyimg.com/n5/s720x720_jfs/t1/257962/11/1272/79927/67668593F28507096/82e67149a95c0600.jpg',
      price: '¥149',
      category: '鞋子'
    },
    {
      id: 6,
      name: '李宁赤兔6Pro新款跑步鞋',
      imageUrl: 'https://img11.360buyimg.com/n5/s720x720_jfs/t1/234541/28/7960/235110/65792a01Fe4787218/4a265d5a1ca4e488.jpg',
      price: '¥399',
      category: '鞋子'
    },
    {
      id: 7,
      name: '回力（Warrior）夏季休闲鞋',
      imageUrl: 'https://img11.360buyimg.com/n5/s720x720_jfs/t1/282321/26/7024/79106/67de5dcbF7f21af05/1fbd2ba6713b0f57.jpg',
      price: '¥99',
      category: '鞋子'
    },
    {
      id: 8,
      name: '回力纯棉舒适T恤',
      imageUrl: 'https://img12.360buyimg.com/n5/s720x720_jfs/t1/216377/40/39529/39335/6616830aFec86cb26/3def54baa7b784f1.jpg',
      price: '¥59',
      category: '衣服'
    },
    {
      id: 9,
      name: '真维斯白色卫衣男连帽',
      imageUrl: 'https://img.alicdn.com/imgextra/i1/2217457947858/O1CN01E2MvxE27v1I1gddDg_!!2217457947858.jpg',
      price: '¥99',
      category: '衣服'
    },
    {
      id: 10,
      name: 'WASSUP ERIKA潮牌男装轻熟西装外套',
      imageUrl: 'https://img.alicdn.com/imgextra/i2/3270715789/O1CN01kSFnJ81sdPqHwKcds_!!3270715789.jpg',
      price: '¥199',
      category: '衣服'
    },
  ];
  // Filtered products based on selected category
  @State filteredProducts: IndexProduct[] = [];
  // 搜索关键词
  @State searchKeyword: string = '';
  // 商品收藏状态映射
  @State favoriteStatusMap: Map<number, boolean> = new Map();

  // Lifecycle method: Called when the component is about to appear
  async aboutToAppear() {
    try {
      await this.favoriteViewModel.init(getContext(this) as common.UIAbilityContext);
      // 初始化收藏状态
      await this.initializeFavoriteStatus();
    } catch (error) {
      console.error('Failed to initialize FavoriteViewModel:', error);
    }
    this.updateFilteredProducts();
  }

  // 初始化所有商品的收藏状态
  private async initializeFavoriteStatus() {
    if (!this.isLoggedIn) {
      // 如果未登录，清空收藏状态
      this.favoriteStatusMap.clear();
      return;
    }

    try {
      for (const product of this.allProducts) {
        const isFavorite = await this.favoriteViewModel.checkFavoriteStatus(product.id);
        this.favoriteStatusMap.set(product.id, isFavorite);
      }
    } catch (error) {
      console.error('Failed to initialize favorite status:', error);
    }
  }

  // 监听登录状态变化
  private async onLoginStatusChanged() {
    await this.initializeFavoriteStatus();
  }

  // Method to update the filtered products list
  updateFilteredProducts() {
    // 如果有搜索关键词，搜索所有商品，不受类别限制
    if (this.searchKeyword.trim()) {
      this.filteredProducts = this.allProducts.filter(product =>
        product.name.toLowerCase().includes(this.searchKeyword.toLowerCase())
      );
    } else {
      // 没有搜索关键词时，按类别过滤
      this.filteredProducts = this.allProducts.filter(product => product.category === this.selectedCategory);
    }
  }

  // 处理搜索输入变化
  onSearchChange(value: string) {
    this.searchKeyword = value;
    this.updateFilteredProducts();
  }

  build() {
    Column() {
      // 1. Top Title Bar with modern design
      Row() {
        Text('拼夕夕商店')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E41F19')
      }
      .width('100%')
      .height(44)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 6, color: 'rgba(0, 0, 0, 0.08)', offsetY: 1 })
      .justifyContent(FlexAlign.Center)

      // 2. 搜索框
      Row() {
        TextInput({ placeholder: '搜索商品...', text: this.searchKeyword })
          .layoutWeight(1)
          .height(36)
          .backgroundColor('#f5f5f5')
          .borderRadius(18)
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => this.onSearchChange(value))

        if (this.searchKeyword.trim()) {
          Button('清空')
            .height(28)
            .backgroundColor('transparent')
            .fontColor('#666')
            .fontSize(13)
            .margin({ left: 6 })
            .onClick(() => this.onSearchChange(''))
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#fff')

      // 3. Welcome and Login Area
      Row() {
        Text('商品列表')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)

        Button({ type: ButtonType.Capsule }) {
          Text(this.isLoggedIn ? `欢迎您, ${this.currentUser}` : '欢迎您, 请登录')
            .fontSize(13)
            .fontColor('#FFFFFF')
        }
        .height(32)
        .backgroundColor('#E41F19')
        .onClick(() => {
          if (!this.isLoggedIn) {
            router.pushUrl({ url: 'pages/LoginPage' });
          } else {
            // 显示退出登录确认对话框
            AlertDialog.show({
              title: '退出登录',
              message: '确定要退出登录吗？',
              primaryButton: {
                value: '确定',
                action: () => {
                  this.userViewModel.logout();
                  promptAction.showToast({
                    message: '已退出登录',
                    duration: 2000
                  });
                }
              },
              secondaryButton: {
                value: '取消',
                action: () => {}
              }
            });
          }
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })

      // 4. Category Navigation Bar with pill design
      Scroll() {
        Row({ space: 10 }) {
          ForEach(this.categories, (category: string) => {
            Button({ type: ButtonType.Capsule }) {
              Text(category)
                .fontSize(14)
                .fontColor(this.selectedCategory === category ? '#FFFFFF' : '#333333')
            }
            .height(34)
            .padding({ left: 16, right: 16 })
            .backgroundColor(this.selectedCategory === category ? '#E41F19' : '#F5F5F5')
            .onClick(() => {
              this.selectedCategory = category;
              this.updateFilteredProducts();
            })
          }, (item: string) => item)
        }
        .padding({ left: 16, right: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .width('100%')
      .height(50)
      .margin({ bottom: 6 })

      // 5. Product List with card design
      List({ space: 12 }) {
        ForEach(this.filteredProducts, (product: IndexProduct) => {
          ListItem() {
            Column() {
              // Product Image with better container
              Stack({ alignContent: Alignment.Center }) {
                Image(product.imageUrl)
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Contain)
                  .backgroundColor('#FFFFFF')
                  .onError(() => {
                    console.error(`Failed to load image: ${product.imageUrl}`);
                  })

                // 收藏按钮
                Button({ type: ButtonType.Capsule }) {
                  Text(this.favoriteStatusMap.get(product.id) ? '已收藏' : '收藏')
                    .fontSize(12)
                    .fontColor(this.favoriteStatusMap.get(product.id) ? '#FFFFFF' : '#666666')
                    .fontWeight(FontWeight.Medium)
                }
                .height(28)
                .padding({ left: 12, right: 12 })
                .backgroundColor(this.favoriteStatusMap.get(product.id) ? '#E41F19' : 'rgba(255, 255, 255, 0.9)')
                .border({
                  width: 1,
                  color: this.favoriteStatusMap.get(product.id) ? '#E41F19' : '#E0E0E0'
                })
                .position({ x: '75%', y: 8 })
                .onClick(async () => {
                  // 检查登录状态
                  if (!this.isLoggedIn) {
                    promptAction.showToast({
                      message: '请先登录后再收藏商品',
                      duration: 2000
                    });
                    router.pushUrl({ url: 'pages/LoginPage' });
                    return;
                  }

                  // 实现收藏功能
                  try {
                    const result = await this.favoriteViewModel.toggleFavorite(product.id);
                    if (result.success) {
                      // 更新本地收藏状态
                      this.favoriteStatusMap.set(product.id, result.isFavorite);
                      promptAction.showToast({
                        message: result.message,
                        duration: 2000
                      });
                    } else {
                      promptAction.showToast({
                        message: result.message,
                        duration: 2000
                      });
                    }
                  } catch (error) {
                    console.error('Failed to toggle favorite:', error);
                    promptAction.showToast({
                      message: '操作失败，请重试',
                      duration: 2000
                    });
                  }
                })
              }
              .width('100%')
              .height(200)
              .backgroundColor('#F9F9F9')

              // Product Details with better spacing and typography
              Column() {
                Text(product.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ bottom: 4 })
                  .padding({ top: 5 })

                // 在搜索时显示商品类别
                if (this.searchKeyword.trim()) {
                  Text(product.category)
                    .fontSize(12)
                    .fontColor('#666')
                    .backgroundColor('#f0f0f0')
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .borderRadius(10)
                    .margin({ bottom: 8 })
                } else {
                  // 非搜索状态下保持原有间距
                  Blank().height(8)
                }

                Row() {
                  Text(product.price)
                    .fontSize(20)
                    .fontColor('#E41F19')
                    .fontWeight(FontWeight.Bold)

                  Blank()

                  Button({ type: ButtonType.Circle, stateEffect: true }) {
                    Text('+')
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FFFFFF')
                  }
                  .width(36)
                  .height(36)
                  .backgroundColor('#E41F19')
                  .onClick(() => {
                    // 检查登录状态
                    if (!this.isLoggedIn) {
                      promptAction.showToast({
                        message: '请先登录后再加入购物车',
                        duration: 2000
                      });
                      router.pushUrl({ url: 'pages/LoginPage' });
                      return;
                    }

                    // 将商品添加到购物车
                    const productToAdd: Product = {
                      id: product.id,
                      name: product.name,
                      price: parseFloat(product.price.replace('¥', '')),
                      image: product.imageUrl,
                      description: `${product.category}商品`
                    };
                    this.cartViewModel.addToCart(productToAdd, 1);
                    promptAction.showToast({
                      message: `已将 ${product.name} 加入购物车`,
                      duration: 2000
                    });
                  })
                }
                .width('100%')
              }
              .width('100%')
              .padding({ left: 15, right: 15, bottom: 15, top: 5 })
              .alignItems(HorizontalAlign.Start)
            }
            .backgroundColor(Color.White)
            .borderRadius(12)
            .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.05)', offsetY: 2 })
            .onClick(() => {
              // 跳转到商品详情页
              router.pushUrl({
                url: 'pages/DetailsPage',
                params: { productId: product.id }
              });
            })
          }
          .width('100%')
        }, (item: IndexProduct) => item.id.toString())
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16, bottom: 12 })
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
