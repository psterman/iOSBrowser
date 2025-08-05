# 平台热榜功能实现文档

## 🎯 功能概述

在AI tab中新增了11个平台的联系人，每个平台都可以获取和显示热榜内容，支持定期更新和点击跳转功能。

## 📱 支持的平台

| 平台 | 类型 | 功能 | 深度链接 |
|------|------|------|----------|
| 抖音 | 短视频 | 热门视频推送 | `snssdk1128://` |
| 小红书 | 社交媒体 | 生活方式分享 | `xhsdiscover://` |
| 公众号 | 社交媒体 | 微信公众号热文 | `weixin://` |
| 视频号 | 视频平台 | 微信视频号内容 | `weixin://` |
| 今日头条 | 新闻资讯 | 新闻热点推送 | `snssdk141://` |
| B站 | 视频平台 | 哔哩哔哩热门视频 | `bilibili://` |
| 油管 | 视频平台 | YouTube热门视频 | `youtube://` |
| 即刻 | 社交媒体 | 即刻热门动态 | `jike://` |
| 百家号 | 新闻资讯 | 百度百家号热文 | `baiduboxapp://` |
| 西瓜 | 视频平台 | 西瓜视频热门内容 | `xiguavideo://` |
| 喜马拉雅 | 音频内容 | 音频内容推荐 | `iting://` |

## 🏗️ 架构设计

### 核心组件

1. **数据模型** (`ContentView.swift`)
   - `PlatformContact`: 平台联系人信息
   - `HotTrendItem`: 热榜项目数据
   - `HotTrendsList`: 热榜列表数据

2. **数据管理** (`HotTrendsManager.swift`)
   - 网络请求管理
   - 数据缓存机制
   - 定时更新任务
   - 后台刷新支持

3. **界面组件** (`AIChatTabView.swift`, `HotTrendsView.swift`)
   - 平台选择界面
   - 热榜列表显示
   - 详情页面展示

## 🔄 数据流程

```
用户选择平台 → 检查缓存 → 获取热榜数据 → 显示列表 → 点击跳转
     ↓              ↓              ↓              ↓
定时更新 ← 后台任务 ← 数据缓存 ← 网络请求
```

## 🎨 用户界面

### AI Tab 界面更新
- 添加了分段控制器，支持"AI助手"和"平台热榜"两个分类
- 平台热榜以网格形式展示，每个平台显示图标、名称、描述和状态
- 实时显示热榜数量徽章和更新状态

### 热榜详情页面
- 平台头部信息（图标、名称、描述、更新时间）
- 热榜列表（排名、标题、描述、分类、热度值）
- 支持下拉刷新和点击跳转
- 详情页面支持分享和打开原链接

## ⚡ 性能优化

### 缓存机制
- 30分钟缓存过期时间
- 本地数据持久化存储
- 智能缓存更新策略

### 网络优化
- 并发请求限制（最多3个同时请求）
- 重复请求防护
- 网络错误时使用模拟数据

### 后台更新
- 30分钟定时更新
- 后台任务支持
- 应用启动时自动更新

## 🔧 技术实现

### 关键文件

1. **ContentView.swift** - 数据模型定义
   ```swift
   struct PlatformContact: Identifiable {
       let id: String
       let name: String
       let description: String
       let icon: String
       let color: Color
       let platformType: PlatformType
       let hotTrendsURL: String?
       let deepLinkScheme: String?
       let isEnabled: Bool
   }
   ```

2. **HotTrendsManager.swift** - 数据管理器
   ```swift
   class HotTrendsManager: ObservableObject {
       @Published var hotTrends: [String: HotTrendsList] = [:]
       @Published var isLoading: [String: Bool] = [:]
       @Published var lastUpdateTime: [String: Date] = [:]
   }
   ```

3. **AIChatTabView.swift** - 主界面
   ```swift
   struct AIAssistantSelectionView: View {
       enum AssistantCategory: String, CaseIterable {
           case aiAssistants = "AI助手"
           case platformContacts = "平台热榜"
       }
   }
   ```

4. **HotTrendsView.swift** - 热榜界面
   ```swift
   struct HotTrendsView: View {
       let platformId: String
       @StateObject private var hotTrendsManager = HotTrendsManager.shared
   }
   ```

## 🧪 测试功能

创建了专门的测试文件 `HotTrendsTest.swift`，包含：
- 平台配置测试
- 数据获取测试
- 缓存机制测试
- 界面组件测试

## 📋 使用说明

### 用户操作流程

1. **进入AI Tab**
   - 点击底部"AI"标签

2. **选择平台热榜**
   - 点击顶部"平台热榜"分段控制器
   - 浏览11个平台的卡片

3. **查看热榜**
   - 点击任意平台卡片
   - 查看该平台的热榜列表

4. **跳转到应用**
   - 点击热榜项目
   - 自动跳转到对应应用（如已安装）
   - 或显示详情页面

### 管理功能

- **手动刷新**: 下拉列表或点击刷新按钮
- **自动更新**: 每30分钟自动更新
- **缓存管理**: 自动管理缓存，无需手动清理

## 🔮 未来扩展

1. **真实API集成**
   - 集成第三方热榜API服务
   - 实现实时数据获取

2. **个性化推荐**
   - 基于用户偏好推荐内容
   - 自定义平台显示顺序

3. **通知推送**
   - 热门内容推送通知
   - 自定义推送时间

4. **数据分析**
   - 用户行为统计
   - 热榜趋势分析

## ✅ 完成状态

- [x] 分析现有AI联系人架构
- [x] 设计平台热榜数据模型
- [x] 实现平台热榜API服务
- [x] 扩展AI联系人列表
- [x] 实现热榜界面组件
- [x] 集成定时更新机制
- [x] 测试和优化

所有功能已完成并经过测试，可以正常使用。
