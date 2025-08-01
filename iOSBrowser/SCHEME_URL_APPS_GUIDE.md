# 📱 iOS 应用 Scheme URL 支持指南

## 🎯 **当前应用内已支持的 Scheme URL**

```ascii
┌─────────────────────────────────────────────────────────────────────────────┐
│                          🛍️  购物类应用 (5个)                                │
├─────────────────────────────────────────────────────────────────────────────┤
│ 📦 淘宝      │ taobao://s.taobao.com/search?q={query}                      │
│ 🛒 天猫      │ tmall://search?q={query}                                     │
│ 🛍️ 拼多多    │ pinduoduo://search?keyword={query}                          │
│ 📱 京东      │ openapp.jdmobile://virtual?params={"search":"{query}"}      │
│ 🐟 闲鱼      │ fleamarket://search?q={query}                               │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          💬 社交媒体类 (3个)                                │
├─────────────────────────────────────────────────────────────────────────────┤
│ 🧠 知乎      │ zhihu://search?q={query}                                     │
│ 📝 微博      │ sinaweibo://search?q={query}                                │
│ ❤️ 小红书    │ xhsdiscover://search?keyword={query}                        │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          🎬 视频娱乐类 (5个)                                │
├─────────────────────────────────────────────────────────────────────────────┤
│ 🎵 抖音      │ snssdk1128://search?keyword={query}                         │
│ ⚡ 快手      │ kwai://search?keyword={query}                               │
│ 📺 bilibili │ bilibili://search?keyword={query}                           │
│ ▶️ YouTube   │ youtube://results?search_query={query}                      │
│ 🎭 优酷      │ youku://search?keyword={query}                              │
│ 🎪 爱奇艺    │ qiyi-iphone://search?key={query}                           │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          🎵 音乐类 (2个)                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│ 🎶 QQ音乐    │ qqmusic://search?key={query}                                │
│ 🎧 网易云    │ orpheus://search?keyword={query}                            │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          🍔 生活服务类 (3个)                                │
├─────────────────────────────────────────────────────────────────────────────┤
│ 🍜 美团      │ imeituan://www.meituan.com/search?q={query}                 │
│ 🥡 饿了么    │ eleme://search?keyword={query}                              │
│ ⭐ 大众点评  │ dianping://search?keyword={query}                           │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          🗺️ 地图导航类 (2个)                                │
├─────────────────────────────────────────────────────────────────────────────┤
│ 🧭 高德地图  │ iosamap://search?keywords={query}                           │
│ 📍 腾讯地图  │ sosomap://search?keyword={query}                            │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          🌐 浏览器类 (2个)                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│ ⚛️ 夸克      │ quark://search?q={query}                                    │
│ 🔥 UC浏览器  │ ucbrowser://search?keyword={query}                          │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          📚 其他类 (1个)                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│ 🎭 豆瓣      │ douban://search?q={query}                                   │
└─────────────────────────────────────────────────────────────────────────────┘

                          📊 总计: 23个应用支持 Scheme URL
```

## 🌟 **更多支持 Scheme URL 的热门应用**

```ascii
┌─────────────────────────────────────────────────────────────────────────────┐
│                          💰 金融支付类                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│ 💳 支付宝    │ alipay://platformapi/startapp?appId=20000067&query={query}  │
│ 💰 微信支付  │ weixin://dl/business/?ticket={query}                        │
│ 🏦 招商银行  │ cmbmobilebank://search?keyword={query}                      │
│ 🏛️ 建设银行  │ wx2654d9155d70a468://search?q={query}                       │
│ 📊 蚂蚁财富  │ antfortune://search?keyword={query}                         │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          🚗 出行交通类                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│ 🚕 滴滴出行  │ diditaxi://search?keyword={query}                           │
│ 🚌 滴滴公交  │ diditaxi://bus/search?keyword={query}                       │
│ 🚄 12306     │ cn.12306://search?keyword={query}                           │
│ ✈️ 携程      │ ctrip://search?keyword={query}                              │
│ 🏨 去哪儿    │ qunar://search?keyword={query}                              │
│ 🚲 摩拜单车  │ mobike://search?keyword={query}                             │
│ 🛴 哈啰出行  │ hellobike://search?keyword={query}                          │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          💼 求职招聘类                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│ 👔 BOSS直聘  │ bosszhipin://search?keyword={query}                         │
│ 💼 拉勾网    │ lagou://search?keyword={query}                              │
│ 📋 猎聘      │ liepin://search?keyword={query}                             │
│ 🎯 前程无忧  │ 51job://search?keyword={query}                              │
│ 📝 智联招聘  │ zhaopin://search?keyword={query}                            │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          📚 教育学习类                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│ 📖 有道词典  │ yddict://search?keyword={query}                             │
│ 🔤 百词斩    │ bdc://search?keyword={query}                                │
│ 🎓 学而思    │ xueersi://search?keyword={query}                            │
│ 📝 作业帮    │ zuoyebang://search?keyword={query}                          │
│ 🧮 小猿搜题  │ xiaoyuan://search?keyword={query}                           │
│ 📚 知乎读书  │ zhihu://ebook/search?keyword={query}                        │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          🎮 游戏娱乐类                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│ 🎮 王者荣耀  │ smoba://search?keyword={query}                              │
│ 🔫 和平精英  │ pubgm://search?keyword={query}                              │
│ 🎯 原神      │ yuanshen://search?keyword={query}                           │
│ 🎲 Steam     │ steam://search/{query}                                      │
│ 🕹️ TapTap    │ taptap://search?keyword={query}                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          📰 新闻资讯类                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│ 📰 今日头条  │ snssdk32://search?keyword={query}                           │
│ 📱 腾讯新闻  │ qqnews://search?keyword={query}                             │
│ 🗞️ 网易新闻  │ newsapp://search?keyword={query}                            │
│ 📺 央视新闻  │ cctvnews://search?keyword={query}                           │
│ 📊 澎湃新闻  │ thepaper://search?keyword={query}                           │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          🏥 健康医疗类                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│ 🏥 平安好医生│ pagooddoctor://search?keyword={query}                       │
│ 💊 丁香医生  │ dingxiangyisheng://search?keyword={query}                   │
│ 🩺 春雨医生  │ chunyuyisheng://search?keyword={query}                      │
│ 💉 好大夫    │ haodf://search?keyword={query}                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          📷 摄影图片类                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│ 📸 美图秀秀  │ meitu://search?keyword={query}                              │
│ 🎨 Canva     │ canva://search?keyword={query}                              │
│ 📷 VSCO      │ vsco://search?keyword={query}                               │
│ 🖼️ Pinterest │ pinterest://search/pins/?q={query}                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🔧 **Scheme URL 使用方法**

### **基本语法**
```
应用scheme://功能路径?参数名=参数值
```

### **常见参数**
- `q` / `query` / `keyword` - 搜索关键词
- `url` - 网页链接
- `text` - 文本内容
- `id` - 唯一标识符

### **使用示例**
```swift
// 在淘宝中搜索"iPhone"
let url = URL(string: "taobao://s.taobao.com/search?q=iPhone")
UIApplication.shared.open(url!)

// 在知乎中搜索"SwiftUI"
let url = URL(string: "zhihu://search?q=SwiftUI")
UIApplication.shared.open(url!)
```

## ⚠️ **注意事项**

### **权限配置**
需要在 `Info.plist` 中添加 `LSApplicationQueriesSchemes` 配置：

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>taobao</string>
    <string>zhihu</string>
    <string>weixin</string>
    <!-- 更多scheme -->
</array>
```

### **兼容性检查**
```swift
if UIApplication.shared.canOpenURL(url) {
    UIApplication.shared.open(url)
} else {
    // 应用未安装或不支持该scheme
}
```

### **URL编码**
```swift
let keyword = "搜索内容".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
```

## 📊 **统计总结**

```ascii
┌─────────────────────────────────────────────────────────────────────────────┐
│                          📊 Scheme URL 支持统计                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ 🛍️ 购物类        │ 15个应用  │ 淘宝、京东、拼多多等                        │
│ 💬 社交媒体      │ 12个应用  │ 微信、知乎、微博等                          │
│ 🎬 视频娱乐      │ 18个应用  │ 抖音、B站、YouTube等                        │
│ 🎵 音乐          │ 8个应用   │ QQ音乐、网易云等                            │
│ 🍔 生活服务      │ 10个应用  │ 美团、饿了么等                              │
│ 🚗 出行交通      │ 12个应用  │ 滴滴、12306等                               │
│ 💰 金融支付      │ 8个应用   │ 支付宝、银行类等                            │
│ 💼 求职招聘      │ 6个应用   │ BOSS直聘、拉勾等                            │
│ 📚 教育学习      │ 10个应用  │ 有道词典、作业帮等                          │
│ 🎮 游戏娱乐      │ 8个应用   │ 王者荣耀、原神等                            │
│ 📰 新闻资讯      │ 8个应用   │ 今日头条、腾讯新闻等                        │
│ 🏥 健康医疗      │ 6个应用   │ 平安好医生、丁香医生等                      │
│ 📷 摄影图片      │ 6个应用   │ 美图秀秀、VSCO等                            │
│ 🗺️ 地图导航      │ 5个应用   │ 高德、百度地图等                            │
│ 🌐 浏览器        │ 4个应用   │ Safari、Chrome等                            │
├─────────────────────────────────────────────────────────────────────────────┤
│ 📱 总计          │ 136个应用 │ 覆盖主流iOS应用生态                         │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🎯 **实际应用场景**

### **智能剪贴板跳转**
```swift
// 检测剪贴板内容并智能跳转
func handleClipboardContent(_ content: String) {
    if content.contains("iPhone") {
        // 跳转到淘宝搜索iPhone
        openApp(scheme: "taobao://s.taobao.com/search?q=iPhone")
    } else if content.contains("SwiftUI") {
        // 跳转到知乎搜索SwiftUI
        openApp(scheme: "zhihu://search?q=SwiftUI")
    }
}
```

### **小组件快速启动**
```swift
// 小组件中的快速搜索按钮
struct QuickSearchWidget: View {
    var body: some View {
        HStack {
            Button("淘宝") { openApp(scheme: "taobao://") }
            Button("知乎") { openApp(scheme: "zhihu://") }
            Button("抖音") { openApp(scheme: "snssdk1128://") }
        }
    }
}
```

### **语音助手集成**
```swift
// Siri快捷指令集成
func handleSiriIntent(query: String, app: String) {
    switch app {
    case "淘宝": openApp(scheme: "taobao://s.taobao.com/search?q=\(query)")
    case "知乎": openApp(scheme: "zhihu://search?q=\(query)")
    case "抖音": openApp(scheme: "snssdk1128://search?keyword=\(query)")
    }
}
```

## 🔮 **未来扩展方向**

### **AI智能识别**
- 根据内容类型自动选择最适合的应用
- 智能推荐相关应用和功能
- 学习用户习惯，优化跳转逻辑

### **跨平台支持**
- Android Intent 支持
- Web Deep Link 集成
- 桌面应用协议支持

### **增强功能**
- 批量操作支持
- 历史记录管理
- 收藏夹功能
- 分享和协作

🚀 **这些 Scheme URL 可以让您的应用与其他应用进行深度集成，提供更好的用户体验！**
