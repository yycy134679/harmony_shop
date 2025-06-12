//202306110141 杨富涛

import { Product } from './Product';

/**
 * 硬编码的商品数据源 (静态数据)
 */
export class DataSource {
  /**
   * 获取所有商品数据
   */
  static getAllProducts(): Product[] {
    return [
      {
        id: 1,
        name: 'Apple iPhone 16 Pro Max 256GB',
        price: 7999,
        image: 'https://img10.360buyimg.com/n5/s720x720_jfs/t1/168145/19/47417/9061/66df731fF3d55d94e/ce6d11f80a757287.jpg',
        description: 'Apple iPhone 16 Pro Max，搭载A18 Pro芯片，256GB存储容量，支持5G网络，拥有强大的摄影系统和超长续航能力。'
      },
      {
        id: 2,
        name: '小米 15 白色',
        price: 4999,
        image: 'https://img10.360buyimg.com/n5/s720x720_jfs/t1/188918/24/49838/43069/67203b9aFea4cec24/563909f5ba6329ea.jpg',
        description: '小米15白色版本，搭载骁龙8 Gen3处理器，拥有出色的性能表现和优雅的外观设计，是性价比之选。'
      },
      {
        id: 3,
        name: '三星Samsung Galaxy S24 Ultra',
        price: 6466,
        image: 'https://img13.360buyimg.com/n5/s720x720_jfs/t1/196045/16/45365/38717/664d6022Fe03b017b/40444f6ba5878a5e.jpg',
        description: '三星Galaxy S24 Ultra，配备S Pen手写笔，200MP主摄像头，支持AI功能，是商务和创作的理想选择。'
      },
      {
        id: 4,
        name: 'HUAWEI Mate 70',
        price: 12999,
        image: 'https://img12.360buyimg.com/n5/s720x720_jfs/t1/242313/11/23691/25932/6747e3e8F41f778d7/294a54279bf82296.jpg',
        description: 'HUAWEI Mate 70，搭载麒麟芯片，拥有强大的影像系统和鸿蒙操作系统，展现华为的技术实力。'
      },
      {
        id: 5,
        name: '安踏（ANTA）男鞋板鞋',
        price: 149,
        image: 'https://img13.360buyimg.com/n5/s720x720_jfs/t1/257962/11/1272/79927/67668593F28507096/82e67149a95c0600.jpg',
        description: '安踏男士板鞋，采用优质材料制作，舒适透气，适合日常休闲穿着，简约时尚的设计风格。'
      },
      {
        id: 6,
        name: '李宁赤兔6Pro新款跑步鞋',
        price: 399,
        image: 'https://img11.360buyimg.com/n5/s720x720_jfs/t1/234541/28/7960/235110/65792a01Fe4787218/4a265d5a1ca4e488.jpg',
        description: '李宁赤兔6Pro跑步鞋，专业跑步装备，采用先进的缓震技术，为跑者提供舒适的运动体验。'
      },
      {
        id: 7,
        name: '回力（Warrior）夏季休闲鞋',
        price: 99,
        image: 'https://img11.360buyimg.com/n5/s720x720_jfs/t1/282321/26/7024/79106/67de5dcbF7f21af05/1fbd2ba6713b0f57.jpg',
        description: '回力夏季休闲鞋，经典国产品牌，透气舒适，适合夏季穿着，性价比极高的选择。'
      },
      {
        id: 8,
        name: '回力纯棉舒适T恤',
        price: 59,
        image: 'https://img12.360buyimg.com/n5/s720x720_jfs/t1/216377/40/39529/39335/6616830aFec86cb26/3def54baa7b784f1.jpg',
        description: '回力纯棉T恤，100%纯棉材质，柔软舒适，透气性好，是夏季必备的基础款服装。'
      },
      {
        id: 9,
        name: '真维斯白色卫衣男连帽',
        price: 99,
        image: 'https://img.alicdn.com/imgextra/i1/2217457947858/O1CN01E2MvxE27v1I1gddDg_!!2217457947858.jpg',
        description: '真维斯男士连帽卫衣，白色经典款，舒适保暖，适合春秋季节穿着，简约百搭的设计。'
      },
      {
        id: 10,
        name: 'WASSUP ERIKA潮牌男装轻熟西装外套',
        price: 199,
        image: 'https://img.alicdn.com/imgextra/i2/3270715789/O1CN01kSFnJ81sdPqHwKcds_!!3270715789.jpg',
        description: 'WASSUP ERIKA潮牌西装外套，轻熟风格设计，适合商务休闲场合，展现男士的成熟魅力。'
      }
    ];
  }

  /**
   * 根据ID获取商品
   */
  static getProductById(id: number): Product | undefined {
    return this.getAllProducts().find(product => product.id === id);
  }

  /**
   * 根据分类获取商品
   */
  static getProductsByCategory(category: string): Product[] {
    const categoryMap: Record<string, number[]> = {
      '手机': [1, 2, 3, 4],
      '鞋子': [5, 6, 7],
      '衣服': [8, 9, 10]
    };

    const productIds = categoryMap[category] || [];
    return this.getAllProducts().filter(product => productIds.includes(product.id));
  }
}
