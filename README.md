# 拼夕夕商店 - HarmonyOS购物应用

## 📱 项目概述

这是一个基于HarmonyOS开发的移动端购物应用，作为课程期末项目开发。应用采用现代化的UI设计和完整的购物流程，为用户提供从商品浏览到订单管理的全方位购物体验。

## ✨ 功能特性

### 🛍️ 核心购物功能
- **商品浏览**: 首页商品展示，支持分类筛选和关键词搜索
- **商品详情**: 详细的商品信息展示，包含图片轮播和描述
- **购物车管理**: 添加商品、数量调整、删除商品、清空购物车
- **订单流程**: 订单确认、支付方式选择、模拟支付、订单生成

### 👤 用户账户系统
- **用户注册**: 支持用户名、密码、手机号注册
- **用户登录**: 安全的登录验证机制
- **个人中心**: 用户信息展示和管理入口
- **个人信息编辑**: 修改昵称、手机号等个人信息

### 📍 地址管理
- **收货地址管理**: 添加、编辑、删除收货地址
- **默认地址设置**: 支持设置默认收货地址
- **地址选择**: 下单时可选择不同收货地址

### 📋 订单与收藏
- **订单管理**: 查看历史订单，订单详情展示
- **商品收藏**: 收藏喜欢的商品，管理收藏列表
- **订单状态跟踪**: 订单状态实时更新

## 🛠️ 技术栈

- **开发平台**: HarmonyOS NEXT
- **开发语言**: ArkTS (TypeScript)
- **UI框架**: ArkUI
- **架构模式**: MVVM (Model-View-ViewModel)
- **数据持久化**: @ohos.data.preferences
- **状态管理**: AppStorage + @State
- **开发工具**: DevEco Studio

## 📁 项目结构

```
harmony_shop/
├── entry/src/main/ets/
│   ├── common/                 # 公共常量和工具
│   │   └── Constants.ts
│   ├── model/                  # 数据模型定义
│   │   ├── Product.ts          # 商品模型
│   │   ├── User.ts             # 用户模型
│   │   ├── CartItem.ts         # 购物车项模型
│   │   ├── Address.ts          # 地址模型
│   │   ├── Order.ts            # 订单模型
│   │   ├── OrderItem.ts        # 订单项模型
│   │   └── DataSource.ts       # 商品数据源
│   ├── service/                # 数据服务层
│   │   ├── UserService.ts      # 用户服务
│   │   ├── AddressService.ts   # 地址服务
│   │   ├── OrderService.ts     # 订单服务
│   │   └── FavoriteService.ts  # 收藏服务
│   ├── viewmodel/              # 视图模型层
│   │   ├── UserViewModel.ts    # 用户视图模型
│   │   ├── CartViewModel.ts    # 购物车视图模型
│   │   ├── ProfileViewModel.ts # 个人中心视图模型
│   │   ├── AddressViewModel.ts # 地址管理视图模型
│   │   ├── OrderViewModel.ts   # 订单视图模型
│   │   └── FavoriteViewModel.ts# 收藏视图模型
│   ├── view/                   # 可复用UI组件
│   │   ├── BottomTabs.ets      # 底部导航栏
│   │   ├── IndexContent.ets    # 首页内容
│   │   ├── CartContent.ets     # 购物车内容
│   │   ├── ProfileContent.ets  # 个人中心内容
│   │   ├── AddressItem.ets     # 地址列表项
│   │   ├── OrderItem.ets       # 订单列表项
│   │   └── FavoriteItem.ets    # 收藏列表项
│   └── pages/                  # 页面文件
│       ├── Index.ets           # 首页
│       ├── CartPage.ets        # 购物车页面
│       ├── DetailsPage.ets     # 商品详情页
│       ├── LoginPage.ets       # 登录页面
│       ├── RegisterPage.ets    # 注册页面
│       ├── ProfilePage.ets     # 个人中心页面
│       ├── EditProfilePage.ets # 编辑个人信息页面
│       ├── AddressManagementPage.ets # 地址管理页面
│       ├── AddressEditPage.ets # 地址编辑页面
│       ├── AddressSelectionPage.ets # 地址选择页面
│       ├── OrderListPage.ets   # 订单列表页面
│       ├── OrderDetailPage.ets # 订单详情页面
│       ├── FavoriteListPage.ets# 收藏列表页面
│       ├── OrderConfirmationPage.ets # 订单确认页面
│       └── CheckoutSuccessPage.ets # 支付成功页面
├── docs/                       # 项目文档
│   ├── 需求分析.md
│   ├── 项目架构.md
│   └── 开发计划.md
└── README.md                   # 项目说明文档
```

## 🚀 安装和运行

### 开发环境要求

 - HarmonyOS SDK: 5.0.2
 - API版本: 14 

### 运行步骤

1. **克隆项目**
   ```bash
   git clone [项目地址]
   cd harmony_shop
   ```

2. **打开项目**
   - 启动 DevEco Studio
   - 选择 "Open" 打开项目文件夹
   - 等待项目索引完成

3. **配置SDK**
   - 确保已安装HarmonyOS SDK
   - 在 File > Settings > HarmonyOS SDK 中配置SDK路径

4. **运行项目**
   - 点击工具栏的预览按钮 (Preview)
   - 或使用快捷键 `Ctrl+Shift+P` (Windows/Linux) / `Cmd+Shift+P` (macOS)

## 🎯 HarmonyOS特色功能

本项目充分利用了HarmonyOS的特色功能：

- **ArkUI声明式开发**: 使用现代化的声明式UI开发范式
- **状态管理**: 利用@State、@Prop等装饰器实现响应式UI
- **数据持久化**: 使用@ohos.data.preferences实现本地数据存储
- **路由导航**: 基于HarmonyOS的页面路由系统
- **组件化开发**: 高度模块化的组件设计

## 📸 应用截图

*注：由于项目在预览器中运行，实际界面效果请在DevEco Studio预览器中查看*

## ⚠️ 注意事项

1. **预览器测试**: 本项目主要在DevEco Studio预览器中进行测试，因为开发环境无法运行模拟器
2. **数据持久化**: 使用preferences进行本地数据存储，支持多用户数据隔离
3. **购物车状态**: 购物车数据使用AppStorage管理，预览器刷新后会重置
4. **模拟支付**: 支付功能为模拟实现，仅用于演示完整购物流程

## 🔧 开发说明

### 数据管理策略

- **持久化数据**: 用户账户、订单、收藏、地址等使用preferences存储
- **运行时状态**: 登录状态、购物车内容等使用AppStorage管理
- **组件状态**: 表单输入、加载状态等使用@State管理

### 架构设计

项目采用MVVM架构模式：
- **Model**: 定义数据结构和业务实体
- **View**: 负责UI展示和用户交互
- **ViewModel**: 处理业务逻辑和状态管理
- **Service**: 封装数据访问和持久化操作

## 📝 开发计划

详细的开发计划和进度请参考 `docs/开发计划.md` 文件。

## 📄 许可证

本项目仅用于学习和课程作业目的。

---

**开发者**: [您的姓名]  
**课程**: HarmonyOS应用开发  
**学期**: [学期信息]  
**最后更新**: 2024年12月
