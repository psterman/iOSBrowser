//
//  ContentView.swift
//  iOSBrowser
//
//  Created by LZH on 2025/7/13.
//

import SwiftUI
import UIKit
import Foundation
import WidgetKit
#if canImport(WidgetKit)
import WidgetKit
#endif

// MARK: - 绿色主题色值标准
extension Color {
    // 主绿色 - 与Tab一致的标准绿色
    static let themeGreen = Color(red: 0.2, green: 0.7, blue: 0.3)

    // 深绿色 - 用于强调和重要元素
    static let themeDarkGreen = Color(red: 0.15, green: 0.6, blue: 0.25)

    // 浅绿色 - 用于背景和次要元素
    static let themeLightGreen = Color(red: 0.3, green: 0.8, blue: 0.4)

    // 极浅绿色 - 用于背景和透明效果
    static let themeVeryLightGreen = Color(red: 0.9, green: 0.98, blue: 0.92)

    // 成功绿色 - 用于成功状态
    static let themeSuccessGreen = Color(red: 0.2, green: 0.8, blue: 0.3)

    // 错误红色 - 保留用于错误状态（不改为绿色）
    static let themeErrorRed = Color(red: 0.9, green: 0.2, blue: 0.2)
}

// MARK: - 确保所有视图类型可见
// 注意：DataSyncCenter在DataSyncCenter.swift中定义

// MARK: - 临时DataSyncCenter引用（确保编译器能找到）
class DataSyncCenter: ObservableObject {
    static let shared = DataSyncCenter()

    @Published var allApps: [UnifiedAppData] = []
    @Published var allAIAssistants: [UnifiedAIData] = []
    @Published var availableAIAssistants: [UnifiedAIData] = []

    @Published var selectedSearchEngines: [String] = {
        print("🔥🔥🔥 @Published初始化开始: selectedSearchEngines")
        let defaults = UserDefaults.standard
        defaults.synchronize()

        let saved = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
        print("🔥🔥🔥 @Published读取UserDefaults: iosbrowser_engines = \(saved)")

        if !saved.isEmpty {
            print("🔥🔥🔥 @Published初始化: 加载用户搜索引擎 \(saved)")
            return saved
        } else {
            print("🔥🔥🔥 @Published初始化: 使用默认搜索引擎 [baidu, google]")
            let defaultEngines = ["baidu", "google"]

            // 🔥🔥🔥 关键修复：立即保存默认值到UserDefaults
            defaults.set(defaultEngines, forKey: "iosbrowser_engines")
            defaults.synchronize()
            print("🔥🔥🔥 @Published初始化: 已保存默认搜索引擎到UserDefaults")

            return defaultEngines
        }
    }()

    @Published var selectedApps: [String] = {
        let defaults = UserDefaults.standard
        if let saved = defaults.stringArray(forKey: "iosbrowser_apps"), !saved.isEmpty {
            print("🔥🔥🔥 @Published初始化: 加载应用 \(saved)")
            return saved
        }
        print("🔥🔥🔥 @Published初始化: 使用默认应用")
        let defaultApps = ["taobao", "zhihu", "douyin"]

        // 🔥🔥🔥 关键修复：立即保存默认值到UserDefaults
        defaults.set(defaultApps, forKey: "iosbrowser_apps")
        defaults.synchronize()
        print("🔥🔥🔥 @Published初始化: 已保存默认应用到UserDefaults")

        return defaultApps
    }()

    @Published var selectedAIAssistants: [String] = {
        let defaults = UserDefaults.standard
        if let saved = defaults.stringArray(forKey: "iosbrowser_ai"), !saved.isEmpty {
            print("🔥🔥🔥 @Published初始化: 加载AI助手 \(saved)")
            return saved
        }
        print("🔥🔥🔥 @Published初始化: 使用默认AI助手")
        let defaultAI = ["deepseek", "qwen"]

        // 🔥🔥🔥 关键修复：立即保存默认值到UserDefaults
        defaults.set(defaultAI, forKey: "iosbrowser_ai")
        defaults.synchronize()
        print("🔥🔥🔥 @Published初始化: 已保存默认AI助手到UserDefaults")

        return defaultAI
    }()

    @Published var selectedQuickActions: [String] = {
        let defaults = UserDefaults.standard
        if let saved = defaults.stringArray(forKey: "iosbrowser_actions"), !saved.isEmpty {
            print("🔥🔥🔥 @Published初始化: 加载快捷操作 \(saved)")
            return saved
        }
        print("🔥🔥🔥 @Published初始化: 使用默认快捷操作")
        let defaultActions = ["search", "bookmark"]

        // 🔥🔥🔥 关键修复：立即保存默认值到UserDefaults
        defaults.set(defaultActions, forKey: "iosbrowser_actions")
        defaults.synchronize()
        print("🔥🔥🔥 @Published初始化: 已保存默认快捷操作到UserDefaults")

        return defaultActions
    }()

    private init() {
        print("🔥🔥🔥 DataSyncCenter: 开始初始化...")
        print("🔥🔥🔥 初始化时间: \(Date())")

        print("🔥🔥🔥 加载基础数据...")
        loadAllData()

        print("🔥🔥🔥 加载用户选择...")
        loadUserSelections() // 加载用户之前的选择

        print("🔥🔥🔥 DataSyncCenter: 初始化完成")
    }

    func loadAllData() {
        loadAppsFromSearchTab()
        loadAIFromContactsTab()
        loadSearchEngines()
        loadQuickActions()
        print("🔄 DataSyncCenter: 所有数据加载完成")
    }

    // MARK: - 从存储中加载用户选择（数据持久化）
    private func loadUserSelections() {
        print("🔥🔥🔥 DataSyncCenter: 开始加载用户之前的选择...")
        print("🔥🔥🔥 当前时间: \(Date())")

        let defaults = UserDefaults.standard
        let syncResult = defaults.synchronize()
        print("🔥🔥🔥 UserDefaults同步结果: \(syncResult)")

        // 先读取所有数据进行诊断
        let savedApps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []
        let savedAI = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
        let savedEngines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
        let savedActions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []
        let lastUpdate = defaults.double(forKey: "iosbrowser_last_update")

        print("🔥🔥🔥 UserDefaults中读取的原始数据:")
        print("   应用: \(savedApps)")
        print("   AI助手: \(savedAI)")
        print("   搜索引擎: \(savedEngines)")
        print("   快捷操作: \(savedActions)")
        print("   最后更新: \(Date(timeIntervalSince1970: lastUpdate))")

        print("🔥🔥🔥 当前内存中的默认值:")
        print("   应用: \(selectedApps)")
        print("   AI助手: \(selectedAIAssistants)")
        print("   搜索引擎: \(selectedSearchEngines)")
        print("   快捷操作: \(selectedQuickActions)")

        // 应用选择已在@Published初始化时加载，跳过重复加载
        print("🔥🔥🔥 应用已在@Published初始化时加载: \(selectedApps)")
        print("🔥🔥🔥 跳过loadUserSelections中的应用加载，避免覆盖")

        // AI助手选择已在@Published初始化时加载，跳过重复加载
        print("🔥🔥🔥 AI助手已在@Published初始化时加载: \(selectedAIAssistants)")
        print("🔥🔥🔥 跳过loadUserSelections中的AI助手加载，避免覆盖")

        // 搜索引擎选择已在@Published初始化时加载，跳过重复加载
        print("🔥🔥🔥 搜索引擎已在@Published初始化时加载: \(selectedSearchEngines)")
        print("🔥🔥🔥 跳过loadUserSelections中的搜索引擎加载，避免覆盖")

        // 快捷操作选择已在@Published初始化时加载，跳过重复加载
        print("🔥🔥🔥 快捷操作已在@Published初始化时加载: \(selectedQuickActions)")
        print("🔥🔥🔥 跳过loadUserSelections中的快捷操作加载，避免覆盖")

        print("🔥🔥🔥 最终加载结果:")
        print("   应用: \(selectedApps)")
        print("   AI助手: \(selectedAIAssistants)")
        print("   搜索引擎: \(selectedSearchEngines)")
        print("   快捷操作: \(selectedQuickActions)")

        // 强制触发UI更新
        DispatchQueue.main.async {
            self.objectWillChange.send()
            print("🔥🔥🔥 已发送UI更新通知")
        }

        print("🔥🔥🔥 DataSyncCenter: 用户选择加载完成")
    }

    // MARK: - 从搜索tab加载应用数据
    private func loadAppsFromSearchTab() {
        allApps = [
            // 购物类 - 统一绿色系
            UnifiedAppData(id: "taobao", name: "淘宝", icon: "bag.fill", color: .themeGreen, category: "购物"),
            UnifiedAppData(id: "tmall", name: "天猫", icon: "bag.fill", color: .themeLightGreen, category: "购物"),
            UnifiedAppData(id: "pinduoduo", name: "拼多多", icon: "cart.fill", color: .themeGreen, category: "购物"),
            UnifiedAppData(id: "jd", name: "京东", icon: "shippingbox.fill", color: .themeDarkGreen, category: "购物"),
            UnifiedAppData(id: "xianyu", name: "闲鱼", icon: "fish.fill", color: .themeLightGreen, category: "购物"),

            // 社交媒体 - 统一绿色系
            UnifiedAppData(id: "zhihu", name: "知乎", icon: "bubble.left.and.bubble.right.fill", color: .themeGreen, category: "社交"),
            UnifiedAppData(id: "weibo", name: "微博", icon: "at", color: .themeLightGreen, category: "社交"),
            UnifiedAppData(id: "xiaohongshu", name: "小红书", icon: "heart.fill", color: .themeDarkGreen, category: "社交"),
            UnifiedAppData(id: "wechat", name: "微信", icon: "message.circle.fill", color: .themeSuccessGreen, category: "社交"),

            // 视频娱乐 - 统一绿色系
            UnifiedAppData(id: "douyin", name: "抖音", icon: "music.note", color: .themeDarkGreen, category: "视频"),
            UnifiedAppData(id: "kuaishou", name: "快手", icon: "video.circle.fill", color: .themeGreen, category: "视频"),
            UnifiedAppData(id: "bilibili", name: "bilibili", icon: "tv.fill", color: .themeLightGreen, category: "视频"),
            UnifiedAppData(id: "youtube", name: "YouTube", icon: "play.rectangle.fill", color: .themeDarkGreen, category: "视频"),
            UnifiedAppData(id: "youku", name: "优酷", icon: "play.rectangle.fill", color: .themeGreen, category: "视频"),
            UnifiedAppData(id: "iqiyi", name: "爱奇艺", icon: "tv.fill", color: .themeSuccessGreen, category: "视频"),

            // 音乐 - 统一绿色系
            UnifiedAppData(id: "qqmusic", name: "QQ音乐", icon: "music.quarternote.3", color: .themeSuccessGreen, category: "音乐"),
            UnifiedAppData(id: "netease_music", name: "网易云音乐", icon: "music.note.list", color: .themeLightGreen, category: "音乐"),

            // 生活服务 - 统一绿色系
            UnifiedAppData(id: "meituan", name: "美团", icon: "fork.knife", color: .themeGreen, category: "生活"),
            UnifiedAppData(id: "eleme", name: "饿了么", icon: "takeoutbag.and.cup.and.straw.fill", color: .themeLightGreen, category: "生活"),
            UnifiedAppData(id: "dianping", name: "大众点评", icon: "star.circle.fill", color: .themeDarkGreen, category: "生活"),
            UnifiedAppData(id: "alipay", name: "支付宝", icon: "creditcard.circle.fill", color: .themeSuccessGreen, category: "生活"),

            // 地图导航 - 保持绿色系
            UnifiedAppData(id: "gaode", name: "高德地图", icon: "map.circle.fill", color: .themeSuccessGreen, category: "地图"),
            UnifiedAppData(id: "tencent_map", name: "腾讯地图", icon: "location.circle.fill", color: .themeGreen, category: "地图"),

            // 浏览器 - 统一绿色系
            UnifiedAppData(id: "quark", name: "夸克", icon: "globe.circle.fill", color: .themeGreen, category: "浏览器"),
            UnifiedAppData(id: "uc", name: "UC浏览器", icon: "safari.fill", color: .themeLightGreen, category: "浏览器"),

            // 生活服务中的豆瓣 - 保持绿色系
            UnifiedAppData(id: "douban", name: "豆瓣", icon: "book.fill", color: .themeSuccessGreen, category: "生活")
        ]

        print("📱 从搜索tab加载应用数据: \(allApps.count) 个应用")
        saveToSharedStorage()
    }

    // MARK: - 从AI tab加载AI助手数据
    private func loadAIFromContactsTab() {
        allAIAssistants = [
            // 🇨🇳 国内主流AI服务商 - 统一绿色系
            UnifiedAIData(id: "deepseek", name: "DeepSeek", icon: "brain.head.profile", color: .themeGreen, description: "专业编程助手", apiEndpoint: "https://api.deepseek.com"),
            UnifiedAIData(id: "qwen", name: "通义千问", icon: "cloud.fill", color: .themeLightGreen, description: "阿里云AI", apiEndpoint: "https://dashscope.aliyuncs.com"),
            UnifiedAIData(id: "chatglm", name: "智谱清言", icon: "lightbulb.fill", color: .themeDarkGreen, description: "清华智谱AI", apiEndpoint: "https://open.bigmodel.cn"),
            UnifiedAIData(id: "moonshot", name: "Kimi", icon: "moon.stars.fill", color: .themeGreen, description: "月之暗面", apiEndpoint: "https://api.moonshot.cn"),
            UnifiedAIData(id: "doubao", name: "豆包", icon: "bubble.left.and.bubble.right", color: .themeLightGreen, description: "字节跳动AI", apiEndpoint: "https://ark.cn-beijing.volces.com"),
            UnifiedAIData(id: "wenxin", name: "文心一言", icon: "w.circle.fill", color: .themeDarkGreen, description: "百度AI", apiEndpoint: "https://aip.baidubce.com"),
            UnifiedAIData(id: "spark", name: "讯飞星火", icon: "sparkles", color: .themeGreen, description: "科大讯飞AI", apiEndpoint: "https://spark-api.xf-yun.com"),
            UnifiedAIData(id: "baichuan", name: "百川智能", icon: "b.circle.fill", color: .themeSuccessGreen, description: "百川智能AI", apiEndpoint: "https://api.baichuan-ai.com"),
            UnifiedAIData(id: "minimax", name: "MiniMax", icon: "m.circle.fill", color: .themeLightGreen, description: "MiniMax AI", apiEndpoint: "https://api.minimax.chat"),

            // 硅基流动 - 统一绿色系
            UnifiedAIData(id: "siliconflow-qwen", name: "千问-硅基流动", icon: "cpu.fill", color: .themeDarkGreen, description: "硅基流动API", apiEndpoint: "https://api.siliconflow.cn"),

            // 🌍 国际主流AI服务商 - 统一绿色系
            UnifiedAIData(id: "openai", name: "ChatGPT", icon: "bubble.left.and.bubble.right.fill", color: .themeSuccessGreen, description: "OpenAI GPT-4", apiEndpoint: "https://api.openai.com"),
            UnifiedAIData(id: "claude", name: "Claude", icon: "c.circle.fill", color: .themeGreen, description: "Anthropic Claude", apiEndpoint: "https://api.anthropic.com"),
            UnifiedAIData(id: "gemini", name: "Gemini", icon: "diamond.fill", color: .themeLightGreen, description: "Google Gemini", apiEndpoint: "https://generativelanguage.googleapis.com"),

            // ⚡ 高性能推理 - 统一绿色系
            UnifiedAIData(id: "groq", name: "Groq", icon: "bolt.circle.fill", color: .themeGreen, description: "超快推理", apiEndpoint: "https://api.groq.com"),
            UnifiedAIData(id: "together", name: "Together AI", icon: "link.circle.fill", color: .themeDarkGreen, description: "开源模型", apiEndpoint: "https://api.together.xyz"),
            UnifiedAIData(id: "perplexity", name: "Perplexity", icon: "questionmark.diamond.fill", color: .themeLightGreen, description: "搜索增强", apiEndpoint: "https://api.perplexity.ai"),

            // 🎨 专业工具 - 统一绿色系
            UnifiedAIData(id: "dalle", name: "DALL-E", icon: "photo.circle.fill", color: .themeGreen, description: "AI绘画", apiEndpoint: "https://api.openai.com"),
            UnifiedAIData(id: "stablediffusion", name: "Stable Diffusion", icon: "camera.macro.circle.fill", color: .themeLightGreen, description: "开源绘画", apiEndpoint: "https://api.stability.ai"),
            UnifiedAIData(id: "elevenlabs", name: "ElevenLabs", icon: "speaker.wave.3.fill", color: .themeDarkGreen, description: "AI语音", apiEndpoint: "https://api.elevenlabs.io"),
            UnifiedAIData(id: "whisper", name: "Whisper", icon: "mic.circle.fill", color: .themeGreen, description: "语音识别", apiEndpoint: "https://api.openai.com"),

            // 本地部署 - 统一绿色系
            UnifiedAIData(id: "ollama", name: "Ollama", icon: "server.rack", color: .themeDarkGreen, description: "本地部署", apiEndpoint: "http://localhost:11434")
        ]

        // 基于API配置过滤可用的AI助手
        updateAvailableAIAssistants()

        print("🤖 从AI联系人tab加载AI数据: \(allAIAssistants.count) 个")
        saveToSharedStorage()
    }

    // MARK: - 加载搜索引擎数据
    private func loadSearchEngines() {
        // 搜索引擎数据已在配置视图中定义
        print("🔍 搜索引擎数据加载完成")
    }

    // MARK: - 加载快捷操作数据
    private func loadQuickActions() {
        // 快捷操作数据已在配置视图中定义
        print("⚡ 快捷操作数据加载完成")
    }

    // MARK: - 更新可用的AI助手（基于API配置）
    private func updateAvailableAIAssistants() {
        availableAIAssistants = allAIAssistants.filter { ai in
            APIConfigManager.shared.hasAPIKey(for: ai.id)
        }
        print("🤖 可用AI助手: \(availableAIAssistants.count) 个")
    }

    // MARK: - 保存到共享存储（无需App Groups方案）
    private func saveToSharedStorage() {
        print("🔥 DataSyncCenter.saveToSharedStorage 开始")

        // 方案1: 尝试App Groups（如果可用）
        let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")
        if sharedDefaults != nil {
            print("🔥 App Groups可用，保存到App Groups")
            // 保存应用数据
            if let appsData = try? JSONEncoder().encode(allApps) {
                sharedDefaults?.set(appsData, forKey: "unified_apps_data")
            }

            // 保存AI数据
            if let aiData = try? JSONEncoder().encode(allAIAssistants) {
                sharedDefaults?.set(aiData, forKey: "unified_ai_data")
            }

            // 保存用户选择
            sharedDefaults?.set(selectedSearchEngines, forKey: "widget_search_engines")
            sharedDefaults?.set(selectedApps, forKey: "widget_apps")
            sharedDefaults?.set(selectedAIAssistants, forKey: "widget_ai_assistants")
            sharedDefaults?.set(selectedQuickActions, forKey: "widget_quick_actions")
        } else {
            print("⚠️ App Groups不可用")
        }

        // 方案2: 无需App Groups的多重保存方案
        print("🔥 开始无需App Groups的多重保存")
        saveToWidgetAccessibleLocationFromDataSyncCenter()

        print("💾 数据已保存到共享存储")

        // 强制刷新小组件
        reloadAllWidgets()
    }

    // MARK: - 从DataSyncCenter调用无需App Groups方案
    private func saveToWidgetAccessibleLocationFromDataSyncCenter() {
        print("🔥 DataSyncCenter无需App Groups方案开始")

        // 使用UserDefaults.standard，这是最可靠的跨进程通信方式
        let defaults = UserDefaults.standard

        print("🔥 准备保存数据:")
        print("🔥   selectedApps: \(selectedApps)")
        print("🔥   selectedAIAssistants: \(selectedAIAssistants)")
        print("🔥   selectedSearchEngines: \(selectedSearchEngines)")
        print("🔥   selectedQuickActions: \(selectedQuickActions)")

        // 保存所有数据到多个键，增加成功率
        defaults.set(selectedApps, forKey: "widget_apps_v2")
        defaults.set(selectedApps, forKey: "widget_apps_v3")
        defaults.set(selectedApps, forKey: "iosbrowser_apps")

        defaults.set(selectedAIAssistants, forKey: "widget_ai_assistants_v2")
        defaults.set(selectedAIAssistants, forKey: "widget_ai_assistants_v3")
        defaults.set(selectedAIAssistants, forKey: "iosbrowser_ai")

        defaults.set(selectedSearchEngines, forKey: "widget_search_engines_v2")
        defaults.set(selectedSearchEngines, forKey: "widget_search_engines_v3")
        defaults.set(selectedSearchEngines, forKey: "iosbrowser_engines")

        defaults.set(selectedQuickActions, forKey: "widget_quick_actions_v2")
        defaults.set(selectedQuickActions, forKey: "widget_quick_actions_v3")
        defaults.set(selectedQuickActions, forKey: "iosbrowser_actions")

        defaults.set(Date().timeIntervalSince1970, forKey: "widget_last_update")
        defaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

        print("🔥 数据已设置到UserDefaults，开始同步...")

        // 强制同步
        let syncResult = defaults.synchronize()
        print("🔥 UserDefaults同步结果: \(syncResult)")

        // 🔥🔥🔥 关键修复：同时保存到App Groups
        print("🔥🔥🔥 开始保存到App Groups...")
        if let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared") {
            sharedDefaults.set(selectedSearchEngines, forKey: "widget_search_engines")
            sharedDefaults.set(selectedApps, forKey: "widget_apps")
            sharedDefaults.set(selectedAIAssistants, forKey: "widget_ai_assistants")
            sharedDefaults.set(selectedQuickActions, forKey: "widget_quick_actions")
            sharedDefaults.set(Date().timeIntervalSince1970, forKey: "widget_last_update")

            let sharedSyncResult = sharedDefaults.synchronize()
            print("🔥🔥🔥 App Groups同步结果: \(sharedSyncResult)")

            // 验证App Groups保存结果
            let sharedEngines = sharedDefaults.stringArray(forKey: "widget_search_engines") ?? []
            let sharedApps = sharedDefaults.stringArray(forKey: "widget_apps") ?? []
            let sharedAI = sharedDefaults.stringArray(forKey: "widget_ai_assistants") ?? []
            let sharedActions = sharedDefaults.stringArray(forKey: "widget_quick_actions") ?? []

            print("🔥🔥🔥 App Groups保存验证:")
            print("   搜索引擎: \(sharedEngines)")
            print("   应用: \(sharedApps)")
            print("   AI助手: \(sharedAI)")
            print("   快捷操作: \(sharedActions)")
        } else {
            print("❌ App Groups不可用")
        }

        // 立即验证保存结果（所有数据类型）
        let savedApps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []
        let savedAI = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
        let savedEngines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
        let savedActions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []
        let lastUpdate = defaults.double(forKey: "iosbrowser_last_update")

        print("✅ DataSyncCenter强制同步到UserDefaults完成")
        print("📱 完整验证保存结果:")
        print("📱   应用 (iosbrowser_apps): \(savedApps)")
        print("📱   AI助手 (iosbrowser_ai): \(savedAI)")
        print("📱   搜索引擎 (iosbrowser_engines): \(savedEngines)")
        print("📱   快捷操作 (iosbrowser_actions): \(savedActions)")
        print("📱   最后更新时间: \(Date(timeIntervalSince1970: lastUpdate))")

        // 检查数据一致性
        let appsMatch = selectedApps == savedApps
        let aiMatch = selectedAIAssistants == savedAI
        let enginesMatch = selectedSearchEngines == savedEngines
        let actionsMatch = selectedQuickActions == savedActions

        print("🔍 数据一致性验证:")
        print("📱   应用: \(appsMatch ? "✅" : "❌") (内存:\(selectedApps) vs 存储:\(savedApps))")
        print("📱   AI助手: \(aiMatch ? "✅" : "❌") (内存:\(selectedAIAssistants) vs 存储:\(savedAI))")
        print("📱   搜索引擎: \(enginesMatch ? "✅" : "❌") (内存:\(selectedSearchEngines) vs 存储:\(savedEngines))")
        print("📱   快捷操作: \(actionsMatch ? "✅" : "❌") (内存:\(selectedQuickActions) vs 存储:\(savedActions))")

        print("🔥🔥🔥 DataSyncCenter双重保存方案完成")
    }

    // MARK: - 立即同步方法（用于用户操作后的即时同步）
    func immediateSyncToWidgets() {
        print("🔥🔥🔥 立即同步到小组件开始...")
        print("🔥🔥🔥 当前数据状态:")
        print("   搜索引擎: \(selectedSearchEngines)")
        print("   应用: \(selectedApps)")
        print("   AI助手: \(selectedAIAssistants)")
        print("   快捷操作: \(selectedQuickActions)")

        // 立即保存到UserDefaults
        saveToWidgetAccessibleLocationFromDataSyncCenter()

        // 🔥🔥🔥 增强的实时刷新策略
        print("🔥🔥🔥 开始增强的实时刷新策略...")

        // 1. 立即刷新（多次调用确保生效）
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                print("🔥🔥🔥 第\(i+1)次立即刷新...")
                self.reloadAllWidgets()
            }
        }

        // 2. 强制通知系统更新
        DispatchQueue.main.async {
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
                print("🔥🔥🔥 已通知系统立即更新所有小组件")

                // 额外刷新特定小组件
                let widgetKinds = ["SimpleSearchEngineWidget", "SimpleAppWidget", "SimpleAIWidget", "SimpleQuickActionWidget"]
                for kind in widgetKinds {
                    WidgetCenter.shared.reloadTimelines(ofKind: kind)
                    print("🔥🔥🔥 已刷新特定小组件: \(kind)")
                }
            }
        }

        // 3. 延迟验证和再次刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("🔥🔥🔥 延迟1秒验证和刷新...")
            self.validateDataSync()
            self.reloadAllWidgets()
        }

        // 4. 最终确保刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            print("🔥🔥🔥 延迟3秒最终刷新...")
            self.reloadAllWidgets()
        }

        print("🔥🔥🔥 增强的立即同步完成")
    }

    // MARK: - 强制UI刷新方法
    func forceUIRefresh() {
        print("🔥🔥🔥 强制UI刷新开始...")

        // 确保在主线程上立即执行UI更新
        if Thread.isMainThread {
            self.objectWillChange.send()
            print("🔥🔥🔥 主线程立即发送UI更新通知")
        } else {
            DispatchQueue.main.sync {
                self.objectWillChange.send()
                print("🔥🔥🔥 切换到主线程发送UI更新通知")
            }
        }

        print("🔥🔥🔥 强制UI刷新完成")
    }

    // MARK: - 强制刷新所有小组件（增强版）
    func reloadAllWidgets() {
        #if canImport(WidgetKit)
        if #available(iOS 14.0, *) {
            print("🔄🔄🔄 开始强制刷新所有小组件...")

            // 1. 强制刷新所有小组件
            WidgetKit.WidgetCenter.shared.reloadAllTimelines()
            print("🔄 已请求刷新所有小组件")

            // 2. 额外刷新特定小组件（多次调用确保生效）
            let widgetKinds = [
                "UserConfigurableSearchWidget",
                "UserConfigurableAppWidget",
                "UserConfigurableAIWidget",
                "UserConfigurableQuickActionWidget"
            ]

            for kind in widgetKinds {
                WidgetKit.WidgetCenter.shared.reloadTimelines(ofKind: kind)
                print("🔄 已请求刷新小组件: \(kind)")
            }

            // 3. 延迟再次刷新（对抗系统缓存）
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("🔄🔄🔄 延迟1秒再次刷新小组件...")
                WidgetKit.WidgetCenter.shared.reloadAllTimelines()
                for kind in widgetKinds {
                    WidgetKit.WidgetCenter.shared.reloadTimelines(ofKind: kind)
                }
            }

            // 4. 最终刷新（确保更新）
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                print("🔄🔄🔄 延迟3秒最终刷新小组件...")
                WidgetKit.WidgetCenter.shared.reloadAllTimelines()
            }

            print("🔄🔄🔄 小组件刷新请求已发送")
        }
        #endif
    }

    func refreshAllData() {
        loadAllData()
        loadUserSelections() // 同时刷新用户选择
        print("🔄 DataSyncCenter: 数据已刷新")
    }

    // MARK: - 手动刷新用户选择（用于调试和强制刷新）
    func refreshUserSelections() {
        print("🔄 手动刷新用户选择...")
        loadUserSelections()
    }

    // MARK: - 数据同步验证方法
    func validateDataSync() {
        print("🔥🔥🔥 开始数据同步验证...")

        let defaults = UserDefaults.standard
        defaults.synchronize()

        // 验证所有数据是否正确保存
        let savedApps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []
        let savedAI = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
        let savedEngines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
        let savedActions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []

        print("📱 当前内存中的数据:")
        print("   应用: \(selectedApps)")
        print("   AI助手: \(selectedAIAssistants)")
        print("   搜索引擎: \(selectedSearchEngines)")
        print("   快捷操作: \(selectedQuickActions)")

        print("💾 UserDefaults中保存的数据:")
        print("   应用: \(savedApps)")
        print("   AI助手: \(savedAI)")
        print("   搜索引擎: \(savedEngines)")
        print("   快捷操作: \(savedActions)")

        // 检查数据一致性
        let appsMatch = selectedApps == savedApps
        let aiMatch = selectedAIAssistants == savedAI
        let enginesMatch = selectedSearchEngines == savedEngines
        let actionsMatch = selectedQuickActions == savedActions

        print("🔍 数据一致性检查:")
        print("   应用: \(appsMatch ? "✅" : "❌")")
        print("   AI助手: \(aiMatch ? "✅" : "❌")")
        print("   搜索引擎: \(enginesMatch ? "✅" : "❌")")
        print("   快捷操作: \(actionsMatch ? "✅" : "❌")")

        if appsMatch && aiMatch && enginesMatch && actionsMatch {
            print("🎉 数据同步验证通过！")
        } else {
            print("⚠️ 数据同步存在问题，需要修复")
        }
    }

    // MARK: - 实时数据验证（针对特定数据类型）
    func validateDataSyncRealtime(dataType: String, expectedData: [String], key: String) {
        print("🔍🔍🔍 实时验证\(dataType)数据同步...")

        let defaults = UserDefaults.standard
        defaults.synchronize()

        let savedData = defaults.stringArray(forKey: key) ?? []
        let isMatch = expectedData == savedData

        print("🔍 \(dataType)数据验证:")
        print("   期望数据: \(expectedData)")
        print("   保存数据: \(savedData)")
        print("   验证结果: \(isMatch ? "✅" : "❌")")

        if isMatch {
            print("🎉 \(dataType)数据同步成功！小组件应该会显示: \(expectedData)")
        } else {
            print("❌ \(dataType)数据同步失败！正在重新保存...")

            // 重新保存数据
            defaults.set(expectedData, forKey: key)
            let syncResult = defaults.synchronize()
            print("🔧 重新保存\(dataType)数据，同步结果: \(syncResult)")

            // 强制刷新小组件
            reloadAllWidgets()
        }
    }

    func updateAppSelection(_ apps: [String]) {
        print("🔥🔥🔥 DataSyncCenter.updateAppSelection 被调用: \(apps)")
        print("🔥🔥🔥 当前selectedApps: \(selectedApps)")

        selectedApps = apps
        print("🔥🔥🔥 selectedApps已更新为: \(selectedApps)")

        // 立即强制UI刷新（确保UI立即响应）
        forceUIRefresh()

        print("🔥🔥🔥 开始立即同步到小组件")
        immediateSyncToWidgets()
        print("🔥🔥🔥 立即同步完成")

        print("📱📱📱 应用选择已更新: \(apps)")

        // 🔥🔥🔥 增强的实时验证
        validateDataSyncRealtime(dataType: "应用", expectedData: apps, key: "iosbrowser_apps")

        // 额外延迟验证确保数据持久化
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("🔄🔄🔄 延迟验证应用数据同步...")
            self.validateDataSyncRealtime(dataType: "应用", expectedData: apps, key: "iosbrowser_apps")
        }

        // 最终验证
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            print("🔄🔄🔄 最终验证应用数据同步...")
            self.validateDataSyncRealtime(dataType: "应用", expectedData: apps, key: "iosbrowser_apps")
        }
    }

    func updateAISelection(_ assistants: [String]) {
        print("🔥🔥🔥 DataSyncCenter.updateAISelection 被调用: \(assistants)")
        print("🔥🔥🔥 当前selectedAIAssistants: \(selectedAIAssistants)")

        selectedAIAssistants = assistants
        print("🔥🔥🔥 selectedAIAssistants已更新为: \(selectedAIAssistants)")

        // 立即强制UI刷新（确保UI立即响应）
        forceUIRefresh()

        print("🔥🔥🔥 开始立即同步到小组件 (AI)")
        immediateSyncToWidgets()
        print("🔥🔥🔥 立即同步完成 (AI)")

        print("🤖🤖🤖 AI选择已更新: \(assistants)")

        // 🔥🔥🔥 增强的实时验证
        validateDataSyncRealtime(dataType: "AI助手", expectedData: assistants, key: "iosbrowser_ai")

        // 额外延迟验证确保数据持久化
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("🔄🔄🔄 延迟验证AI助手数据同步...")
            self.validateDataSyncRealtime(dataType: "AI助手", expectedData: assistants, key: "iosbrowser_ai")
        }

        // 最终验证
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            print("🔄🔄🔄 最终验证AI助手数据同步...")
            self.validateDataSyncRealtime(dataType: "AI助手", expectedData: assistants, key: "iosbrowser_ai")
        }
    }

    func updateSearchEngineSelection(_ engines: [String]) {
        print("🔥 DataSyncCenter.updateSearchEngineSelection 被调用: \(engines)")
        print("🔥 当前selectedSearchEngines: \(selectedSearchEngines)")

        selectedSearchEngines = engines
        print("🔥 selectedSearchEngines已更新为: \(selectedSearchEngines)")

        // 立即强制UI刷新（确保UI立即响应）
        forceUIRefresh()

        print("🔥 开始立即同步到小组件 (搜索引擎)")
        immediateSyncToWidgets()
        print("🔥 立即同步完成 (搜索引擎)")

        print("🔍 搜索引擎选择已更新: \(engines)")

        // 立即验证数据同步
        validateDataSync()

        // 额外延迟验证确保数据持久化
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("🔄 延迟验证数据同步 (搜索引擎)...")
            self.validateDataSync()
        }
    }

    func updateQuickActionSelection(_ actions: [String]) {
        print("🔥 DataSyncCenter.updateQuickActionSelection 被调用: \(actions)")
        print("🔥 当前selectedQuickActions: \(selectedQuickActions)")

        selectedQuickActions = actions
        print("🔥 selectedQuickActions已更新为: \(selectedQuickActions)")

        // 立即强制UI刷新（确保UI立即响应）
        forceUIRefresh()

        print("🔥 开始立即同步到小组件 (快捷操作)")
        immediateSyncToWidgets()
        print("🔥 立即同步完成 (快捷操作)")

        print("⚡ 快捷操作选择已更新: \(actions)")

        // 立即验证数据同步
        validateDataSync()

        // 额外延迟验证确保数据持久化
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("🔄 延迟验证数据同步 (快捷操作)...")
            self.validateDataSync()
        }
    }
}

// MARK: - 数据结构
struct UnifiedAppData: Codable, Identifiable {
    let id: String
    let name: String
    let icon: String
    let colorName: String // 用字符串存储颜色名称
    let category: String

    // 计算属性，用于UI显示
    var color: Color {
        switch colorName {
        case "orange": return .themeLightGreen
        case "red": return .themeDarkGreen
        case "blue": return .themeGreen
        case "green": return .themeSuccessGreen
        case "yellow": return .themeLightGreen
        case "pink": return .themeLightGreen
        case "purple": return .themeGreen
        case "cyan": return .themeLightGreen
        case "gray": return .themeDarkGreen
        case "black": return .themeDarkGreen
        default: return .themeGreen
        }
    }

    init(id: String, name: String, icon: String, color: Color, category: String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.category = category

        // 将Color转换为字符串
        switch color {
        case .orange: self.colorName = "orange"
        case .red: self.colorName = "red"
        case .blue: self.colorName = "blue"
        case .green: self.colorName = "green"
        case .yellow: self.colorName = "yellow"
        case .pink: self.colorName = "pink"
        case .purple: self.colorName = "purple"
        case .cyan: self.colorName = "cyan"
        case .gray: self.colorName = "gray"
        case .black: self.colorName = "black"
        default: self.colorName = "blue"
        }
    }
}

struct UnifiedAIData: Codable, Identifiable {
    let id: String
    let name: String
    let icon: String
    let colorName: String // 用字符串存储颜色名称
    let description: String
    let apiEndpoint: String

    // 计算属性，用于UI显示
    var color: Color {
        switch colorName {
        case "orange": return .themeLightGreen
        case "red": return .themeDarkGreen
        case "blue": return .themeGreen
        case "green": return .themeSuccessGreen
        case "yellow": return .themeLightGreen
        case "pink": return .themeLightGreen
        case "purple": return .themeGreen
        case "cyan": return .themeLightGreen
        case "gray": return .themeDarkGreen
        case "indigo": return .themeGreen
        default: return .themeGreen
        }
    }

    init(id: String, name: String, icon: String, color: Color, description: String, apiEndpoint: String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.description = description
        self.apiEndpoint = apiEndpoint

        // 将Color转换为字符串
        switch color {
        case .orange: self.colorName = "orange"
        case .red: self.colorName = "red"
        case .blue: self.colorName = "blue"
        case .green: self.colorName = "green"
        case .yellow: self.colorName = "yellow"
        case .pink: self.colorName = "pink"
        case .purple: self.colorName = "purple"
        case .cyan: self.colorName = "cyan"
        case .gray: self.colorName = "gray"
        case .indigo: self.colorName = "indigo"
        default: self.colorName = "blue"
        }
    }
}

// MARK: - 临时WidgetConfigView引用（确保编译器能找到）
struct WidgetConfigView: View {
    @ObservedObject private var dataSyncCenter = DataSyncCenter.shared
    @State private var selectedTab = 0
    @State private var showingWidgetGuide = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部标题栏
                HStack {
                    Text("小组件配置")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Spacer()

                    // 同步小组件按钮 - 合并了刷新和保存功能
                    Button(action: {
                        print("🚨🚨🚨 同步小组件按钮被点击！")
                        // 保存当前配置并立即同步到小组件
                        saveAllConfigurations()
                        forceRefreshWidgets()
                        print("🚨🚨🚨 同步小组件按钮处理完成！")
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("同步小组件")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.themeGreen)
                        .cornerRadius(8)
                    }

                    // 重置按钮 - 保留，用于恢复默认设置
                    Button(action: {
                        resetToDefaults()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("重置")
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.themeLightGreen)
                        .cornerRadius(6)
                    }

                    Button(action: {
                        showingWidgetGuide = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.title2)
                            .foregroundColor(.themeGreen)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                // Tab选择器
                HStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { index in
                        Button(action: {
                            selectedTab = index
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: getTabIcon(index))
                                    .font(.system(size: 16))
                                Text(getTabTitle(index))
                                    .font(.caption)
                            }
                            .foregroundColor(selectedTab == index ? .themeGreen : .secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .background(Color(.systemGray6))

                // 内容区域
                TabView(selection: $selectedTab) {
                    SearchEngineConfigView()
                        .tag(0)

                    UnifiedAppConfigView()
                        .tag(1)

                    UnifiedAIConfigView()
                        .tag(2)

                    QuickActionConfigView()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingWidgetGuide) {
                WidgetGuideView()
            }
        }
        .onAppear {
            print("🔥🔥🔥 WidgetConfigView: 开始强制加载数据...")

            // 🔥🔥🔥 关键修复：强制检查和初始化UserDefaults数据
            forceInitializeUserDefaults()

            // 1. 强制刷新所有基础数据
            dataSyncCenter.refreshAllData()

            // 2. 强制重新加载用户选择
            dataSyncCenter.refreshUserSelections()

            // 3. 强制UI更新
            dataSyncCenter.forceUIRefresh()

            // 4. 延迟再次刷新确保数据同步
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("🔥🔥🔥 WidgetConfigView: 延迟刷新数据...")
                self.dataSyncCenter.refreshUserSelections()
                self.dataSyncCenter.forceUIRefresh()

                print("🔥🔥🔥 WidgetConfigView: 最终数据状态:")
                print("   应用: \(self.dataSyncCenter.selectedApps)")
                print("   AI助手: \(self.dataSyncCenter.selectedAIAssistants)")
                print("   搜索引擎: \(self.dataSyncCenter.selectedSearchEngines)")
                print("   快捷操作: \(self.dataSyncCenter.selectedQuickActions)")
            }

            print("🔥🔥🔥 WidgetConfigView: 强制加载完成")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            print("🔥🔥🔥 应用进入前台，强制刷新数据...")
            dataSyncCenter.refreshUserSelections()
            dataSyncCenter.forceUIRefresh()
        }
    }

    // MARK: - 保存所有配置
    private func saveAllConfigurations() {
        print("🔥🔥🔥 手动保存所有配置开始...")

        // 🔥🔥🔥 关键修复：保存用户当前选择
        saveUserSelectionsToStorage()

        // 立即同步到小组件
        dataSyncCenter.immediateSyncToWidgets()

        // 强制UI刷新
        dataSyncCenter.forceUIRefresh()

        // 验证数据同步
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dataSyncCenter.validateDataSync()
        }

        print("🔥🔥🔥 手动保存所有配置完成")

        // 显示保存成功提示
        showSaveSuccessAlert()
    }

    // MARK: - 保存用户选择到存储
    private func saveUserSelectionsToStorage() {
        print("🔥🔥🔥 开始保存用户选择到存储...")

        let defaults = UserDefaults.standard
        let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

        // 获取当前UI状态中的用户选择
        let currentEngines = dataSyncCenter.selectedSearchEngines
        let currentApps = dataSyncCenter.selectedApps
        let currentAI = dataSyncCenter.selectedAIAssistants
        let currentActions = dataSyncCenter.selectedQuickActions

        print("🔥🔥🔥 当前用户选择状态:")
        print("   搜索引擎: \(currentEngines)")
        print("   应用: \(currentApps)")
        print("   AI助手: \(currentAI)")
        print("   快捷操作: \(currentActions)")

        // 保存到UserDefaults.standard
        defaults.set(currentEngines, forKey: "iosbrowser_engines")
        defaults.set(currentApps, forKey: "iosbrowser_apps")
        defaults.set(currentAI, forKey: "iosbrowser_ai")
        defaults.set(currentActions, forKey: "iosbrowser_actions")
        defaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

        let stdSync = defaults.synchronize()
        print("🔥🔥🔥 UserDefaults保存同步: \(stdSync)")

        // 保存到App Groups
        if let shared = sharedDefaults {
            shared.set(currentEngines, forKey: "widget_search_engines")
            shared.set(currentApps, forKey: "widget_apps")
            shared.set(currentAI, forKey: "widget_ai_assistants")
            shared.set(currentActions, forKey: "widget_quick_actions")
            shared.set(Date().timeIntervalSince1970, forKey: "widget_last_update")

            let sharedSync = shared.synchronize()
            print("🔥🔥🔥 App Groups保存同步: \(sharedSync)")

            // 验证App Groups保存结果
            let verifyEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
            let verifyApps = shared.stringArray(forKey: "widget_apps") ?? []
            let verifyAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
            let verifyActions = shared.stringArray(forKey: "widget_quick_actions") ?? []

            print("🔥🔥🔥 App Groups保存验证:")
            print("   搜索引擎: \(verifyEngines)")
            print("   应用: \(verifyApps)")
            print("   AI助手: \(verifyAI)")
            print("   快捷操作: \(verifyActions)")

            let success = verifyEngines == currentEngines &&
                         verifyApps == currentApps &&
                         verifyAI == currentAI &&
                         verifyActions == currentActions

            if success {
                print("✅ App Groups保存验证成功")
            } else {
                print("❌ App Groups保存验证失败")
            }
        } else {
            print("❌ App Groups不可用")
        }

        print("🔥🔥🔥 用户选择保存到存储完成")
    }

    private func showSaveSuccessAlert() {
        // 这里可以添加一个成功提示，比如HUD或者Toast
        print("✅ 配置已保存成功！")
    }

    // MARK: - 测试数据保存和加载（不修改用户数据）
    private func testDataSaveAndLoad() {
        print("🧪🧪🧪 开始测试数据保存和加载验证...")

        // 1. 显示当前内存中的数据
        print("📱 当前内存数据:")
        print("   搜索引擎: \(dataSyncCenter.selectedSearchEngines)")
        print("   AI助手: \(dataSyncCenter.selectedAIAssistants)")
        print("   应用: \(dataSyncCenter.selectedApps)")
        print("   快捷操作: \(dataSyncCenter.selectedQuickActions)")

        // 2. 验证当前数据是否已保存到UserDefaults
        print("🔍 验证当前数据保存状态...")
        let defaults = UserDefaults.standard
        defaults.synchronize()

        let savedEngines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
        let savedAI = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
        let savedApps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []
        let savedActions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []
        let lastUpdate = defaults.double(forKey: "iosbrowser_last_update")

        print("💾 UserDefaults中保存的数据:")
        print("   搜索引擎: \(savedEngines)")
        print("   AI助手: \(savedAI)")
        print("   应用: \(savedApps)")
        print("   快捷操作: \(savedActions)")
        print("   最后更新: \(Date(timeIntervalSince1970: lastUpdate))")

        // 3. 检查数据一致性
        let enginesMatch = dataSyncCenter.selectedSearchEngines == savedEngines
        let aiMatch = dataSyncCenter.selectedAIAssistants == savedAI
        let appsMatch = dataSyncCenter.selectedApps == savedApps
        let actionsMatch = dataSyncCenter.selectedQuickActions == savedActions

        print("🔍 数据一致性检查:")
        print("   搜索引擎: \(enginesMatch ? "✅ 一致" : "❌ 不一致")")
        print("   AI助手: \(aiMatch ? "✅ 一致" : "❌ 不一致")")
        print("   应用: \(appsMatch ? "✅ 一致" : "❌ 不一致")")
        print("   快捷操作: \(actionsMatch ? "✅ 一致" : "❌ 不一致")")

        // 4. 总结测试结果
        let allMatch = enginesMatch && aiMatch && appsMatch && actionsMatch
        if allMatch {
            print("🎉 测试通过！所有数据已正确保存")
        } else {
            print("⚠️ 测试发现问题！部分数据未正确保存")
            print("💡 建议：点击'保存'按钮手动保存数据")
        }

        print("🧪🧪🧪 测试验证完成！")
    }

    // MARK: - 重置到默认设置
    private func resetToDefaults() {
        print("🔄🔄🔄 开始重置到默认设置...")

        // 重置到默认值
        dataSyncCenter.selectedSearchEngines = ["baidu", "google"]
        dataSyncCenter.selectedAIAssistants = ["deepseek", "qwen"]
        dataSyncCenter.selectedApps = ["taobao", "zhihu", "douyin"]
        dataSyncCenter.selectedQuickActions = ["search", "bookmark"]

        print("📱 已重置到默认值:")
        print("   搜索引擎: \(dataSyncCenter.selectedSearchEngines)")
        print("   AI助手: \(dataSyncCenter.selectedAIAssistants)")
        print("   应用: \(dataSyncCenter.selectedApps)")
        print("   快捷操作: \(dataSyncCenter.selectedQuickActions)")

        // 强制UI刷新
        dataSyncCenter.forceUIRefresh()

        // 立即保存
        dataSyncCenter.immediateSyncToWidgets()

        // 验证重置结果
        dataSyncCenter.validateDataSync()

        print("🔄🔄🔄 重置完成！")
    }

    // MARK: - 强制刷新小组件
    private func forceRefreshWidgets() {
        print("🔄🔄🔄 用户手动强制刷新小组件...")

        // 1. 立即保存当前数据
        dataSyncCenter.immediateSyncToWidgets()

        // 2. 多次强制刷新
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                print("🔄🔄🔄 第\(i+1)次强制刷新小组件...")
                self.dataSyncCenter.reloadAllWidgets()
            }
        }

        // 3. 显示提示信息
        print("🔄🔄🔄 已发送多次刷新请求，请等待5-10秒查看小组件更新")

        // 4. 验证当前数据
        let defaults = UserDefaults.standard
        let engines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
        print("🔄🔄🔄 当前UserDefaults中的搜索引擎: \(engines)")
        print("🔄🔄🔄 小组件应该显示: \(engines.joined(separator: ", "))")
    }

    // MARK: - 强制初始化UserDefaults数据
    private func forceInitializeUserDefaults() {
        print("🔥🔥🔥 开始强制初始化UserDefaults数据...")

        let defaults = UserDefaults.standard

        // 检查并初始化搜索引擎数据
        if defaults.stringArray(forKey: "iosbrowser_engines")?.isEmpty != false {
            let defaultEngines = ["baidu", "google"]
            defaults.set(defaultEngines, forKey: "iosbrowser_engines")
            print("🔥🔥🔥 强制初始化: 保存默认搜索引擎 \(defaultEngines)")
        }

        // 检查并初始化应用数据
        if defaults.stringArray(forKey: "iosbrowser_apps")?.isEmpty != false {
            let defaultApps = ["taobao", "zhihu", "douyin"]
            defaults.set(defaultApps, forKey: "iosbrowser_apps")
            print("🔥🔥🔥 强制初始化: 保存默认应用 \(defaultApps)")
        }

        // 检查并初始化AI助手数据
        if defaults.stringArray(forKey: "iosbrowser_ai")?.isEmpty != false {
            let defaultAI = ["deepseek", "qwen"]
            defaults.set(defaultAI, forKey: "iosbrowser_ai")
            print("🔥🔥🔥 强制初始化: 保存默认AI助手 \(defaultAI)")
        }

        // 检查并初始化快捷操作数据
        if defaults.stringArray(forKey: "iosbrowser_actions")?.isEmpty != false {
            let defaultActions = ["search", "bookmark"]
            defaults.set(defaultActions, forKey: "iosbrowser_actions")
            print("🔥🔥🔥 强制初始化: 保存默认快捷操作 \(defaultActions)")
        }

        // 强制同步
        let syncResult = defaults.synchronize()
        print("🔥🔥🔥 强制初始化: UserDefaults同步结果 \(syncResult)")

        // 立即刷新小组件
        dataSyncCenter.reloadAllWidgets()
        print("🔥🔥🔥 强制初始化: 已触发小组件刷新")

        print("🔥🔥🔥 强制初始化UserDefaults数据完成")
    }

    // MARK: - 测试数据联动
    private func testDataSync() {
        print("🧪🧪🧪 开始测试数据联动...")

        // 测试数据
        let testApps = ["wechat", "alipay", "taobao", "jd"]
        let testAI = ["chatgpt", "deepseek", "claude"]
        let testEngines = ["google", "bing", "duckduckgo"]
        let testActions = ["search", "bookmark", "translate"]

        print("🧪 测试应用数据联动...")
        dataSyncCenter.updateAppSelection(testApps)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("🧪 测试AI助手数据联动...")
            self.dataSyncCenter.updateAISelection(testAI)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("🧪 测试搜索引擎数据联动...")
            self.dataSyncCenter.updateSearchEngineSelection(testEngines)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            print("🧪 测试快捷操作数据联动...")
            self.dataSyncCenter.updateQuickActionSelection(testActions)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            print("🧪🧪🧪 数据联动测试完成！")
            print("🧪 请检查小组件是否显示以下数据:")
            print("   应用: \(testApps)")
            print("   AI助手: \(testAI)")
            print("   搜索引擎: \(testEngines)")
            print("   快捷操作: \(testActions)")
        }
    }

    private func getTabIcon(_ index: Int) -> String {
        switch index {
        case 0: return "magnifyingglass"
        case 1: return "app.badge"
        case 2: return "brain.head.profile"
        case 3: return "bolt.circle"
        default: return "questionmark"
        }
    }

    private func getTabTitle(_ index: Int) -> String {
        switch index {
        case 0: return "搜索引擎"
        case 1: return "应用选择"
        case 2: return "AI助手"
        case 3: return "快捷操作"
        default: return "未知"
        }
    }
}

// MARK: - 配置子视图（简化版本）
struct SearchEngineConfigView: View {
    @ObservedObject private var dataSyncCenter = DataSyncCenter.shared
    @State private var selectedCategory = "国内搜索"

    // 按分类组织的搜索引擎 - 分解为更小的部分以避免编译器超时
    private var domesticEngines: [(String, String, String, Color)] {
        [
            ("baidu", "百度", "magnifyingglass.circle.fill", Color.themeGreen),
            ("sogou", "搜狗", "s.circle.fill", Color.themeLightGreen),
            ("360", "360搜索", "360.circle.fill", Color.themeSuccessGreen),
            ("shenma", "神马搜索", "s.square.fill", Color.themeDarkGreen),
            ("chinaso", "中国搜索", "c.circle.fill", Color.themeGreen),
            ("haosou", "好搜", "h.circle.fill", Color.themeLightGreen)
        ]
    }

    private var internationalEngines: [(String, String, String, Color)] {
        [
            ("google", "Google", "globe", Color.themeGreen),
            ("bing", "必应", "b.circle.fill", Color.themeLightGreen),
            ("duckduckgo", "DuckDuckGo", "shield.fill", Color.themeDarkGreen),
            ("yahoo", "Yahoo", "y.circle.fill", Color.themeGreen),
            ("yandex", "Yandex", "y.square.fill", Color.themeLightGreen),
            ("ask", "Ask", "questionmark.circle.fill", Color.themeSuccessGreen)
        ]
    }

    private var aiEngines: [(String, String, String, Color)] {
        [
            ("perplexity", "Perplexity", "brain.head.profile", Color.themeGreen),
            ("you", "You.com", "y.circle", Color.themeLightGreen),
            ("phind", "Phind", "p.circle.fill", Color.themeSuccessGreen),
            ("andi", "Andi", "a.circle.fill", Color.themeDarkGreen),
            ("neeva", "Neeva", "n.circle.fill", Color.themeGreen),
            ("kagi", "Kagi", "k.circle.fill", Color.themeLightGreen)
        ]
    }

    private var professionalEngines: [(String, String, String, Color)] {
        [
            ("scholar", "谷歌学术", "graduationcap.fill", Color.themeGreen),
            ("github", "GitHub", "chevron.left.forwardslash.chevron.right", Color.themeDarkGreen),
            ("stackoverflow", "Stack Overflow", "questionmark.square.fill", Color.themeLightGreen),
            ("arxiv", "arXiv", "doc.text.fill", Color.themeGreen),
            ("pubmed", "PubMed", "cross.case.fill", Color.themeSuccessGreen),
            ("ieee", "IEEE Xplore", "bolt.circle.fill", Color.themeDarkGreen)
        ]
    }

    private var searchEngineCategories: [String: [(String, String, String, Color)]] {
        [
            "国内搜索": domesticEngines,
            "国际搜索": internationalEngines,
            "AI搜索": aiEngines,
            "专业搜索": professionalEngines
        ]
    }

    private var categories: [String] {
        Array(searchEngineCategories.keys).sorted()
    }

    private var currentEngines: [(String, String, String, Color)] {
        searchEngineCategories[selectedCategory] ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            // 简约标题栏
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("搜索引擎")
                            .font(.title3)
                            .fontWeight(.semibold)

                        HStack(spacing: 12) {
                            Label("\(dataSyncCenter.selectedSearchEngines.count)", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.themeGreen)

                            Label("已同步", systemImage: "icloud.and.arrow.up")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }

                    Spacer()

                    // 配置提示
                    Text("按分类选择")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                }

                // 分类选择器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedCategory = category
                                }
                            }) {
                                Text(category)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedCategory == category ? .white : .blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(selectedCategory == category ? Color.blue : Color.blue.opacity(0.1))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // 搜索引擎网格
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                    ForEach(currentEngines, id: \.0) { engine in
                        SearchEngineCard(
                            engine: engine,
                            isSelected: dataSyncCenter.selectedSearchEngines.contains(engine.0),
                            onTap: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    toggleSearchEngine(engine.0)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // 底部提示
                VStack(spacing: 8) {
                    Divider()
                        .padding(.horizontal, 16)

                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.themeGreen)
                            .font(.caption)

                        Text("最多选择4个搜索引擎，至少保留1个")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
        }
        .onAppear {
            dataSyncCenter.refreshAllData()
            dataSyncCenter.refreshUserSelections()
            dataSyncCenter.forceUIRefresh()
        }
    }

    private func toggleSearchEngine(_ engineId: String) {
        print("🚨🚨🚨 toggleSearchEngine 被调用: \(engineId)")

        var engines = dataSyncCenter.selectedSearchEngines
        print("🚨 当前搜索引擎: \(engines)")

        if let index = engines.firstIndex(of: engineId) {
            // 至少保留1个
            if engines.count > 1 {
                engines.remove(at: index)
                print("🚨 移除搜索引擎: \(engineId)")
            } else {
                print("🚨 至少保留1个搜索引擎，不移除: \(engineId)")
                return
            }
        } else if engines.count < 4 {
            engines.append(engineId)
            print("🚨 添加搜索引擎: \(engineId)")
        } else {
            print("🚨 搜索引擎数量已达上限，不添加: \(engineId)")
            return
        }

        print("🚨 新的搜索引擎列表: \(engines)")

        // 🔥🔥🔥 统一数据保存：同时保存到两个键值确保兼容性
        dataSyncCenter.selectedSearchEngines = engines

        // 保存到标准UserDefaults（小组件读取）
        UserDefaults.standard.set(engines, forKey: "iosbrowser_engines")

        // 同时保存到App Groups键值（如果配置了App Groups）
        if let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared") {
            sharedDefaults.set(engines, forKey: "widget_search_engines")
            sharedDefaults.synchronize()
            print("🚨 已保存到App Groups")
        }

        let syncResult = UserDefaults.standard.synchronize()
        print("🚨 已保存搜索引擎到UserDefaults，同步结果: \(syncResult)")

        // 立即刷新小组件
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
            print("🚨 已刷新小组件")
        }

        // 验证保存结果
        let savedEngines = UserDefaults.standard.stringArray(forKey: "iosbrowser_engines") ?? []
        print("🚨 验证保存结果: \(savedEngines)")
        if savedEngines == engines {
            print("🚨 ✅ 搜索引擎数据保存成功！")
        } else {
            print("🚨 ❌ 搜索引擎数据保存失败！")
        }
    }
}

struct UnifiedAppConfigView: View {
    @ObservedObject private var dataSyncCenter = DataSyncCenter.shared
    @State private var selectedCategory = "全部"

    // 应用分类
    private var categories: [String] {
        var cats = ["全部"]
        let uniqueCategories = Set(dataSyncCenter.allApps.map { $0.category })
        cats.append(contentsOf: uniqueCategories.sorted())
        return cats
    }

    // 获取当前分类的应用
    private var availableApps: [UnifiedAppData] {
        if selectedCategory == "全部" {
            return dataSyncCenter.allApps
        }
        return dataSyncCenter.allApps.filter { $0.category == selectedCategory }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 标题和统计
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("应用选择")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("从搜索tab同步的 \(dataSyncCenter.allApps.count) 个应用")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("当前已选择: \(dataSyncCenter.selectedApps.count) 个")
                            .font(.caption)
                            .foregroundColor(.themeGreen)
                    }

                    Spacer()

                    Button(action: {
                        dataSyncCenter.refreshAllData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.themeGreen)
                            .font(.title3)
                    }
                }

                Text("配置将同步到桌面小组件")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            .padding(.horizontal)
            .padding(.top)

            // 分类选择
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Text(category)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedCategory == category ? Color.blue : Color(.systemGray6))
                                )
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            // 应用网格
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(availableApps, id: \.id) { app in
                        Button(action: {
                            print("🔄 点击应用: \(app.name) (\(app.id))")
                            toggleApp(app.id)
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: app.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(app.color)

                                Text(app.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .lineLimit(1)

                                Text(app.category)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(dataSyncCenter.selectedApps.contains(app.id) ? app.color.opacity(0.2) : Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(dataSyncCenter.selectedApps.contains(app.id) ? app.color : Color.clear, lineWidth: 2)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .onAppear {
            print("🔥🔥🔥 UnifiedAppConfigView onAppear 开始...")

            // 1. 刷新基础数据
            dataSyncCenter.refreshAllData()

            // 2. 强制刷新用户选择（关键修复）
            dataSyncCenter.refreshUserSelections()

            // 3. 强制UI更新
            dataSyncCenter.forceUIRefresh()

            print("🔥🔥🔥 UnifiedAppConfigView 数据加载完成")
            print("📱 总应用数量: \(dataSyncCenter.allApps.count)")
            print("📱 当前分类: \(selectedCategory)")
            print("📱 当前分类应用数量: \(availableApps.count)")
            print("🔥🔥🔥 当前选中的应用: \(dataSyncCenter.selectedApps)")
            print("📱 应用列表: \(dataSyncCenter.allApps.map { $0.name })")

            // 4. 延迟验证确保数据正确
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("🔥🔥🔥 UnifiedAppConfigView 延迟验证:")
                print("   内存中的选择: \(self.dataSyncCenter.selectedApps)")

                // 验证UserDefaults中的数据
                let defaults = UserDefaults.standard
                let savedApps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []
                print("   UserDefaults中的数据: \(savedApps)")

                if self.dataSyncCenter.selectedApps != savedApps && !savedApps.isEmpty {
                    print("⚠️ 应用数据不一致，强制重新加载...")
                    self.dataSyncCenter.refreshUserSelections()
                    self.dataSyncCenter.forceUIRefresh()
                }
            }
        }
        .onChange(of: selectedCategory) { _ in
            print("📱 切换分类到: \(selectedCategory)，应用数量: \(availableApps.count)")
        }
    }

    private func toggleApp(_ appId: String) {
        print("🚨🚨🚨 toggleApp 被调用: \(appId)")

        var apps = dataSyncCenter.selectedApps
        print("🚨 当前应用: \(apps)")

        if let index = apps.firstIndex(of: appId) {
            // 至少保留1个
            if apps.count > 1 {
                apps.remove(at: index)
                print("🚨 移除应用: \(appId)")
            } else {
                print("🚨 至少保留1个应用，不移除: \(appId)")
                return
            }
        } else if apps.count < 8 {
            apps.append(appId)
            print("🚨 添加应用: \(appId)")
        } else {
            print("🚨 应用数量已达上限，不添加: \(appId)")
            return
        }

        print("🚨 新的应用列表: \(apps)")

        // 🔥🔥🔥 统一数据保存：同时保存到两个键值确保兼容性
        dataSyncCenter.selectedApps = apps

        // 保存到标准UserDefaults（小组件读取）
        UserDefaults.standard.set(apps, forKey: "iosbrowser_apps")

        // 同时保存到App Groups键值（如果配置了App Groups）
        if let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared") {
            sharedDefaults.set(apps, forKey: "widget_apps")
            sharedDefaults.synchronize()
            print("🚨 已保存到App Groups")
        }

        let syncResult = UserDefaults.standard.synchronize()
        print("🚨 已保存应用到UserDefaults，同步结果: \(syncResult)")

        // 立即刷新小组件
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
            print("🚨 已刷新小组件")
        }

        // 验证保存结果
        let savedApps = UserDefaults.standard.stringArray(forKey: "iosbrowser_apps") ?? []
        print("🚨 验证保存结果: \(savedApps)")
        if savedApps == apps {
            print("🚨 ✅ 应用数据保存成功！")
        } else {
            print("🚨 ❌ 应用数据保存失败！")
        }
    }
}

struct UnifiedAIConfigView: View {
    @ObservedObject private var dataSyncCenter = DataSyncCenter.shared
    @StateObject private var apiManager = APIConfigManager.shared
    @State private var showOnlyAvailable = true

    // 获取当前显示的AI助手
    private var displayedAIAssistants: [UnifiedAIData] {
        if showOnlyAvailable {
            return dataSyncCenter.availableAIAssistants
        } else {
            return dataSyncCenter.allAIAssistants
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 标题和统计
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI助手选择")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("从AI tab同步的 \(dataSyncCenter.allAIAssistants.count) 个AI助手")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("已配置API: \(dataSyncCenter.availableAIAssistants.count) 个")
                            .font(.caption)
                            .foregroundColor(.green)

                        Text("当前已选择: \(dataSyncCenter.selectedAIAssistants.count) 个")
                            .font(.caption)
                            .foregroundColor(.themeGreen)
                    }

                    Spacer()

                    Button(action: {
                        dataSyncCenter.refreshAllData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.themeGreen)
                            .font(.title3)
                    }
                }

                Text("配置将同步到桌面小组件")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            .padding(.horizontal)
            .padding(.top)

            // 显示模式切换
            HStack(spacing: 16) {
                Button(action: {
                    showOnlyAvailable = true
                }) {
                    Text("已配置API (\(dataSyncCenter.availableAIAssistants.count))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(showOnlyAvailable ? Color.green : Color(.systemGray6))
                        )
                        .foregroundColor(showOnlyAvailable ? .white : .primary)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    showOnlyAvailable = false
                }) {
                    Text("全部AI (\(dataSyncCenter.allAIAssistants.count))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(!showOnlyAvailable ? Color.blue : Color(.systemGray6))
                        )
                        .foregroundColor(!showOnlyAvailable ? .white : .primary)
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // AI助手网格
            ScrollView {
                if displayedAIAssistants.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.themeLightGreen)

                        Text(showOnlyAvailable ? "暂无已配置API的AI助手" : "AI助手列表为空")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text(showOnlyAvailable ? "请先在AI tab中配置AI助手的API密钥" : "请检查AI数据配置")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach(displayedAIAssistants, id: \.id) { ai in
                            Button(action: {
                                print("🔄 点击AI: \(ai.name) (\(ai.id))")
                                toggleAssistant(ai.id)
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: ai.icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(ai.color)

                                    Text(ai.name)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .lineLimit(1)

                                    Text(ai.description)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)

                                    // API状态指示
                                    if apiManager.hasAPIKey(for: ai.id) {
                                        Text("已配置API")
                                            .font(.caption2)
                                            .foregroundColor(.green)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.green.opacity(0.2))
                                            .cornerRadius(4)
                                    } else {
                                        Text("未配置API")
                                            .font(.caption2)
                                            .foregroundColor(.red)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.themeErrorRed.opacity(0.2))
                                            .cornerRadius(4)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(dataSyncCenter.selectedAIAssistants.contains(ai.id) ? ai.color.opacity(0.2) : Color(.systemGray6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(dataSyncCenter.selectedAIAssistants.contains(ai.id) ? ai.color : Color.clear, lineWidth: 2)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
        }
        .onAppear {
            print("🔥🔥🔥 UnifiedAIConfigView onAppear 开始...")

            // 1. 刷新基础数据
            dataSyncCenter.refreshAllData()

            // 2. 强制刷新用户选择（关键修复）
            dataSyncCenter.refreshUserSelections()

            // 3. 强制UI更新
            dataSyncCenter.forceUIRefresh()

            print("🔥🔥🔥 UnifiedAIConfigView 数据加载完成")
            print("🤖 所有AI数量: \(dataSyncCenter.allAIAssistants.count)")
            print("🤖 可用AI数量: \(dataSyncCenter.availableAIAssistants.count)")
            print("🔥🔥🔥 当前选中的AI助手: \(dataSyncCenter.selectedAIAssistants)")
            print("🤖 AI列表: \(dataSyncCenter.allAIAssistants.map { $0.name })")

            // 4. 延迟验证确保数据正确
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("🔥🔥🔥 UnifiedAIConfigView 延迟验证:")
                print("   内存中的选择: \(self.dataSyncCenter.selectedAIAssistants)")

                // 验证UserDefaults中的数据
                let defaults = UserDefaults.standard
                let savedAI = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
                print("   UserDefaults中的数据: \(savedAI)")

                if self.dataSyncCenter.selectedAIAssistants != savedAI && !savedAI.isEmpty {
                    print("⚠️ AI数据不一致，强制重新加载...")
                    self.dataSyncCenter.refreshUserSelections()
                    self.dataSyncCenter.forceUIRefresh()
                }
            }
        }
        .onChange(of: apiManager.apiKeys) { _ in
            print("🤖 API配置变化，重新加载AI列表")
            dataSyncCenter.refreshAllData()
        }
        .onChange(of: showOnlyAvailable) { _ in
            print("🤖 切换显示模式: \(showOnlyAvailable ? "仅已配置API" : "全部AI")")
        }
    }

    private func toggleAssistant(_ assistantId: String) {
        print("🚨🚨🚨 toggleAssistant 被调用: \(assistantId)")

        var assistants = dataSyncCenter.selectedAIAssistants
        print("🚨 当前AI助手: \(assistants)")

        if let index = assistants.firstIndex(of: assistantId) {
            // 至少保留1个
            if assistants.count > 1 {
                assistants.remove(at: index)
                print("🚨 移除AI助手: \(assistantId)")
            } else {
                print("🚨 至少保留1个AI助手，不移除: \(assistantId)")
                return
            }
        } else if assistants.count < 8 {
            assistants.append(assistantId)
            print("🚨 添加AI助手: \(assistantId)")
        } else {
            print("🚨 AI助手数量已达上限，不添加: \(assistantId)")
            return
        }

        print("🚨 新的AI助手列表: \(assistants)")

        // 🔥🔥🔥 统一数据保存：同时保存到两个键值确保兼容性
        dataSyncCenter.selectedAIAssistants = assistants

        // 保存到标准UserDefaults（小组件读取）
        UserDefaults.standard.set(assistants, forKey: "iosbrowser_ai")

        // 同时保存到App Groups键值（如果配置了App Groups）
        if let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared") {
            sharedDefaults.set(assistants, forKey: "widget_ai_assistants")
            sharedDefaults.synchronize()
            print("🚨 已保存到App Groups")
        }

        let syncResult = UserDefaults.standard.synchronize()
        print("🚨 已保存AI助手到UserDefaults，同步结果: \(syncResult)")

        // 立即刷新小组件
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
            print("🚨 已刷新小组件")
        }

        // 验证保存结果
        let savedAssistants = UserDefaults.standard.stringArray(forKey: "iosbrowser_ai") ?? []
        print("🚨 验证保存结果: \(savedAssistants)")
        if savedAssistants == assistants {
            print("🚨 ✅ AI助手数据保存成功！")
        } else {
            print("🚨 ❌ AI助手数据保存失败！")
        }
    }
}

struct QuickActionConfigView: View {
    @ObservedObject private var dataSyncCenter = DataSyncCenter.shared

    // 快捷操作选项 - 统一绿色系
    private let quickActions = [
        ("search", "快速搜索", "magnifyingglass", Color.themeGreen),
        ("bookmark", "书签管理", "bookmark.fill", Color.themeLightGreen),
        ("history", "浏览历史", "clock.fill", Color.themeSuccessGreen),
        ("ai_chat", "AI对话", "brain.head.profile", Color.themeDarkGreen),
        ("translate", "翻译工具", "textformat.abc", Color.themeGreen),
        ("qr_scan", "二维码扫描", "qrcode.viewfinder", Color.themeLightGreen),
        ("clipboard", "剪贴板", "doc.on.clipboard", Color.themeDarkGreen),
        ("settings", "快速设置", "gearshape.fill", Color.themeGreen)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 标题和统计
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("快捷操作选择")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("选择小组件中显示的快捷操作")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("当前已选择: \(dataSyncCenter.selectedQuickActions.count) 个")
                            .font(.caption)
                            .foregroundColor(.themeGreen)
                    }

                    Spacer()

                    Button(action: {
                        dataSyncCenter.refreshAllData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.themeGreen)
                            .font(.title3)
                    }
                }

                Text("配置将同步到桌面小组件")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            .padding(.horizontal)
            .padding(.top)

            // 快捷操作网格
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(quickActions, id: \.0) { action in
                        Button(action: {
                            print("🔄 点击快捷操作: \(action.1) (\(action.0))")
                            toggleQuickAction(action.0)
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: action.2)
                                    .font(.system(size: 24))
                                    .foregroundColor(action.3)

                                Text(action.1)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(dataSyncCenter.selectedQuickActions.contains(action.0) ? action.3.opacity(0.2) : Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(dataSyncCenter.selectedQuickActions.contains(action.0) ? action.3 : Color.clear, lineWidth: 2)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .onAppear {
            print("🔥🔥🔥 QuickActionConfigView onAppear 开始...")

            // 1. 刷新基础数据
            dataSyncCenter.refreshAllData()

            // 2. 强制刷新用户选择（关键修复）
            dataSyncCenter.refreshUserSelections()

            // 3. 强制UI更新
            dataSyncCenter.forceUIRefresh()

            print("🔥🔥🔥 QuickActionConfigView 数据加载完成")
            print("🔥🔥🔥 当前选中的快捷操作: \(dataSyncCenter.selectedQuickActions)")

            // 4. 延迟验证确保数据正确
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("🔥🔥🔥 QuickActionConfigView 延迟验证:")
                print("   内存中的选择: \(self.dataSyncCenter.selectedQuickActions)")

                // 验证UserDefaults中的数据
                let defaults = UserDefaults.standard
                let savedActions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []
                print("   UserDefaults中的数据: \(savedActions)")

                if self.dataSyncCenter.selectedQuickActions != savedActions && !savedActions.isEmpty {
                    print("⚠️ 快捷操作数据不一致，强制重新加载...")
                    self.dataSyncCenter.refreshUserSelections()
                    self.dataSyncCenter.forceUIRefresh()
                }
            }
        }
    }

    private func toggleQuickAction(_ actionId: String) {
        print("🚨🚨🚨 ===== toggleQuickAction 被调用 =====")
        print("🚨🚨🚨 操作的actionId: \(actionId)")
        print("🚨🚨🚨 这是用户点击操作的明确证据！")

        var actions = dataSyncCenter.selectedQuickActions
        print("🚨 当前快捷操作: \(actions)")

        if let index = actions.firstIndex(of: actionId) {
            // 至少保留1个
            if actions.count > 1 {
                actions.remove(at: index)
                print("🚨 移除快捷操作: \(actionId)")
            } else {
                print("🚨 至少保留1个快捷操作，不移除: \(actionId)")
                return
            }
        } else if actions.count < 6 {
            actions.append(actionId)
            print("🚨 添加快捷操作: \(actionId)")
        } else {
            print("🚨 快捷操作数量已达上限，不添加: \(actionId)")
            return
        }

        print("🚨 新的快捷操作列表: \(actions)")

        // 🔥🔥🔥 统一数据保存：同时保存到两个键值确保兼容性
        dataSyncCenter.selectedQuickActions = actions

        // 保存到标准UserDefaults（小组件读取）
        UserDefaults.standard.set(actions, forKey: "iosbrowser_actions")

        // 同时保存到App Groups键值（如果配置了App Groups）
        if let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared") {
            sharedDefaults.set(actions, forKey: "widget_quick_actions")
            sharedDefaults.synchronize()
            print("🚨 已保存到App Groups")
        }

        let syncResult = UserDefaults.standard.synchronize()
        print("🚨 已保存快捷操作到UserDefaults，同步结果: \(syncResult)")

        // 立即刷新小组件
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
            print("🚨 已刷新小组件")
        }

        // 验证保存结果
        let savedActions = UserDefaults.standard.stringArray(forKey: "iosbrowser_actions") ?? []
        print("🚨 验证保存结果: \(savedActions)")
        if savedActions == actions {
            print("🚨🚨🚨 ✅✅✅ 快捷操作数据保存成功！✅✅✅")
            print("🚨🚨🚨 用户选择已保存: \(savedActions)")
            print("🚨🚨🚨 小组件应该显示这些数据而不是默认数据！")
        } else {
            print("🚨🚨🚨 ❌❌❌ 快捷操作数据保存失败！❌❌❌")
            print("🚨🚨🚨 期望: \(actions)")
            print("🚨🚨🚨 实际: \(savedActions)")
        }
    }
}

struct WidgetGuideView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                Text("小组件使用指南")
                    .font(.title)
                    .fontWeight(.bold)

                Text("配置完成后，请在桌面添加小组件")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            .navigationBarItems(
                trailing: Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - API配置管理器
class APIConfigManager: ObservableObject {
    static let shared = APIConfigManager()

    @Published var apiKeys: [String: String] = [:]
    @Published var pinnedContacts: Set<String> = []
    @Published var hiddenContacts: Set<String> = []

    private init() {
        loadAPIKeys()
        loadContactSettings()
    }

    func setAPIKey(for serviceId: String, key: String) {
        apiKeys[serviceId] = key
        UserDefaults.standard.set(key, forKey: "api_key_\(serviceId)")
        NotificationCenter.default.post(name: NSNotification.Name("APIKeysUpdated"), object: nil)
    }

    func getAPIKey(for serviceId: String) -> String? {
        return apiKeys[serviceId]
    }

    func hasAPIKey(for serviceId: String) -> Bool {
        guard let key = apiKeys[serviceId] else { return false }
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedKey.isEmpty && trimmedKey.count > 10
    }

    func removeAPIKey(for serviceId: String) {
        apiKeys.removeValue(forKey: serviceId)
        UserDefaults.standard.removeObject(forKey: "api_key_\(serviceId)")
        NotificationCenter.default.post(name: NSNotification.Name("APIKeysUpdated"), object: nil)
    }

    func pinContact(_ contactId: String) {
        pinnedContacts.insert(contactId)
        savePinnedContacts()
    }

    func unpinContact(_ contactId: String) {
        pinnedContacts.remove(contactId)
        savePinnedContacts()
    }

    func hideContact(_ contactId: String) {
        hiddenContacts.insert(contactId)
        saveHiddenContacts()
    }

    func showContact(_ contactId: String) {
        hiddenContacts.remove(contactId)
        saveHiddenContacts()
    }

    private func loadAPIKeys() {
        let services = [
            "deepseek", "qwen", "chatglm", "moonshot", "doubao", "wenxin", "spark", "baichuan", "minimax",
            "siliconflow-qwen", "openai", "claude", "gemini", "groq", "together", "perplexity",
            "dalle", "stablediffusion", "elevenlabs", "whisper", "ollama"
        ]

        for service in services {
            if let key = UserDefaults.standard.string(forKey: "api_key_\(service)") {
                apiKeys[service] = key
            }
        }
    }

    private func loadContactSettings() {
        if let pinnedData = UserDefaults.standard.data(forKey: "pinned_contacts"),
           let pinned = try? JSONDecoder().decode(Set<String>.self, from: pinnedData) {
            pinnedContacts = pinned
        }

        if let hiddenData = UserDefaults.standard.data(forKey: "hidden_contacts"),
           let hidden = try? JSONDecoder().decode(Set<String>.self, from: hiddenData) {
            hiddenContacts = hidden
        }
    }

    private func savePinnedContacts() {
        if let data = try? JSONEncoder().encode(pinnedContacts) {
            UserDefaults.standard.set(data, forKey: "pinned_contacts")
        }
    }

    private func saveHiddenContacts() {
        if let data = try? JSONEncoder().encode(hiddenContacts) {
            UserDefaults.standard.set(data, forKey: "hidden_contacts")
        }
    }

    // MARK: - 便捷方法
    func isPinned(_ contactId: String) -> Bool {
        return pinnedContacts.contains(contactId)
    }

    func isHidden(_ contactId: String) -> Bool {
        return hiddenContacts.contains(contactId)
    }

    func setPinned(_ contactId: String, pinned: Bool) {
        if pinned {
            pinnedContacts.insert(contactId)
        } else {
            pinnedContacts.remove(contactId)
        }
        savePinnedContacts()
    }

    func setHidden(_ contactId: String, hidden: Bool) {
        if hidden {
            hiddenContacts.insert(contactId)
        } else {
            hiddenContacts.remove(contactId)
        }
        saveHiddenContacts()
    }
}

// MARK: - 深度链接通知名称
extension Notification.Name {
    static let switchSearchEngine = Notification.Name("switchSearchEngine")
    static let performSearch = Notification.Name("performSearch")
    static let switchToAI = Notification.Name("switchToAI")
    static let sendPrompt = Notification.Name("sendPrompt")
    static let searchInApp = Notification.Name("searchInApp")
    static let browserClipboardSearch = Notification.Name("browserClipboardSearch")
    static let navigateToChat = Notification.Name("navigateToChat")
    static let sendPromptToActiveChat = Notification.Name("sendPromptToActiveChat")
    static let showBatchOperation = Notification.Name("showBatchOperation")
    static let openDirectChat = Notification.Name("openDirectChat")
    static let smartSearchWithClipboard = Notification.Name("smartSearchWithClipboard")
    static let appSearchWithClipboard = Notification.Name("appSearchWithClipboard")
    static let directAppSearch = Notification.Name("directAppSearch")
    static let browseWithClipboard = Notification.Name("browseWithClipboard")
    static let loadSearchEngine = Notification.Name("loadSearchEngine")
    static let activateAppSearch = Notification.Name("activateAppSearch")
    static let showAIAssistant = Notification.Name("showAIAssistant")
}

// MARK: - 数据模型
struct DirectChatRequest {
    let assistantId: String
    let presetPrompt: String?
    let autoSend: Bool

    init(assistantId: String, presetPrompt: String? = nil, autoSend: Bool = false) {
        self.assistantId = assistantId
        self.presetPrompt = presetPrompt
        self.autoSend = autoSend
    }
}



struct ContentView: View {
    @StateObject private var webViewModel = WebViewModel()
    @EnvironmentObject var deepLinkHandler: DeepLinkHandler
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {

            // 主内容区域 - 微信风格的简洁滑动
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    SearchView()
                        .frame(width: geometry.size.width)

                    BrowserView(viewModel: webViewModel)
                        .frame(width: geometry.size.width)

                    SimpleAIChatView()
                        .frame(width: geometry.size.width)

                    WidgetConfigView()
                        .frame(width: geometry.size.width)
                }
                .offset(x: -CGFloat(selectedTab) * geometry.size.width)
                .animation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0), value: selectedTab)
                .clipped()
            }

            // 微信风格的底部Tab栏
            WeChatTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            // 🔥🔥🔥 应用启动时立即初始化小组件数据
            initializeWidgetDataOnAppStart()
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
        .onChange(of: deepLinkHandler.targetTab) { newTab in
            print("🔗 深度链接切换到tab: \(newTab)")
            selectedTab = newTab
        }
        .onChange(of: deepLinkHandler.searchQuery) { query in
            if !query.isEmpty {
                print("🔗 深度链接搜索查询: \(query)")
                // 通过深度链接处理器传递搜索查询
                // SearchView会监听这个变化
            }
        }
    }

    // MARK: - 应用启动时初始化小组件数据
    private func initializeWidgetDataOnAppStart() {
        print("🚨🚨🚨 ===== 应用启动时初始化小组件数据开始 =====")
        print("🚀🚀🚀 应用启动时初始化小组件数据...")

        let defaults = UserDefaults.standard
        var needsSync = false

        // 检查并初始化搜索引擎数据
        if defaults.stringArray(forKey: "iosbrowser_engines")?.isEmpty != false {
            let defaultEngines = ["baidu", "google"]
            defaults.set(defaultEngines, forKey: "iosbrowser_engines")
            print("🚀 应用启动初始化: 保存默认搜索引擎 \(defaultEngines)")
            needsSync = true
        }

        // 检查并初始化应用数据
        if defaults.stringArray(forKey: "iosbrowser_apps")?.isEmpty != false {
            let defaultApps = ["taobao", "zhihu", "douyin"]
            defaults.set(defaultApps, forKey: "iosbrowser_apps")
            print("🚀 应用启动初始化: 保存默认应用 \(defaultApps)")
            needsSync = true
        }

        // 检查并初始化AI助手数据
        if defaults.stringArray(forKey: "iosbrowser_ai")?.isEmpty != false {
            let defaultAI = ["deepseek", "qwen"]
            defaults.set(defaultAI, forKey: "iosbrowser_ai")
            print("🚀 应用启动初始化: 保存默认AI助手 \(defaultAI)")
            needsSync = true
        }

        // 检查并初始化快捷操作数据
        if defaults.stringArray(forKey: "iosbrowser_actions")?.isEmpty != false {
            let defaultActions = ["search", "bookmark"]
            defaults.set(defaultActions, forKey: "iosbrowser_actions")
            print("🚀 应用启动初始化: 保存默认快捷操作 \(defaultActions)")
            needsSync = true
        }

        if needsSync {
            // 强制同步
            let syncResult = defaults.synchronize()
            print("🚀 应用启动初始化: UserDefaults同步结果 \(syncResult)")

            // 延迟刷新小组件，确保数据已保存
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("🚀 应用启动初始化: 延迟刷新小组件...")
                if #available(iOS 14.0, *) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }

            print("🚀🚀🚀 应用启动初始化完成，已保存默认数据")
        } else {
            print("🚀🚀🚀 应用启动检查完成，数据已存在")
        }
    }

    // 增强的深度链接处理
    private func handleDeepLink(_ url: URL) {
        print("🔗 收到深度链接: \(url.absoluteString)")

        guard url.scheme == "iosbrowser" else {
            print("❌ 无效的URL scheme: \(url.scheme ?? "nil")")
            return
        }

        let host = url.host ?? ""
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems

        print("🔗 Host: \(host), QueryItems: \(queryItems?.description ?? "无")")

        switch host {
        case "search":
            print("🔗 跳转到搜索tab")
            selectedTab = 2 // 搜索tab
            handleSearchDeepLink(queryItems: queryItems)
        case "ai":
            print("🔗 跳转到AI联系人tab")
            selectedTab = 1 // AI联系人tab
            handleAIDeepLink(queryItems: queryItems)
        case "apps":
            print("🔗 跳转到应用搜索tab")
            selectedTab = 2 // 搜索tab
            handleAppsDeepLink(queryItems: queryItems)
        case "clipboard-search":
            print("🔗 处理剪贴板搜索")
            handleClipboardSearch(queryItems: queryItems)
        case "batch-operation":
            print("🔗 处理批量操作")
            handleBatchOperation(queryItems: queryItems)
        case "direct-chat":
            print("🔗 处理直接聊天")
            handleDirectChat(queryItems: queryItems)
        case "ai-chat":
            print("🔗 处理AI聊天")
            handleAIChat(queryItems: queryItems)
        case "browse-tab":
            print("🔗 处理浏览tab")
            handleBrowseTab(queryItems: queryItems)
        case "app-search-tab":
            print("🔗 处理应用搜索tab")
            handleAppSearchTab(queryItems: queryItems)
        case "smart-search":
            print("🔗 处理智能搜索")
            handleSmartSearch(queryItems: queryItems)
        case "app-search":
            print("🔗 处理应用搜索")
            handleAppSearch(queryItems: queryItems)
        case "direct-app-launch":
            print("🔗 处理直接应用启动")
            handleDirectAppLaunch(queryItems: queryItems)
        default:
            print("❌ 未知的深度链接host: \(host)")
            break
        }
    }

    private func handleSearchDeepLink(queryItems: [URLQueryItem]?) {
        // 处理搜索相关的深度链接
        print("🔍 处理搜索深度链接: \(queryItems?.description ?? "无参数")")

        if let engine = queryItems?.first(where: { $0.name == "engine" })?.value {
            print("🔍 切换搜索引擎: \(engine)")
            // 切换到指定搜索引擎并执行搜索
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: .switchSearchEngine, object: engine)
            }
        }

        if let query = queryItems?.first(where: { $0.name == "query" })?.value {
            print("🔍 执行搜索: \(query)")
            // 执行搜索
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                NotificationCenter.default.post(name: .performSearch, object: query)
            }
        }

        if let clipboard = queryItems?.first(where: { $0.name == "clipboard" })?.value, clipboard == "true" {
            print("🔍 搜索剪贴板内容")
            // 搜索剪贴板内容
            let pasteboard = UIPasteboard.general.string ?? ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                NotificationCenter.default.post(name: .performSearch, object: pasteboard)
            }
        }
    }

    private func handleAIDeepLink(queryItems: [URLQueryItem]?) {
        print("🤖 处理AI深度链接: \(queryItems?.description ?? "无参数")")

        if let assistant = queryItems?.first(where: { $0.name == "assistant" })?.value {
            print("🤖 跳转到AI助手: \(assistant)")
            // 跳转到指定AI助手
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: .switchToAI, object: assistant)
            }
        }

        if let prompt = queryItems?.first(where: { $0.name == "prompt" })?.value {
            print("🤖 发送预设提示词: \(prompt)")
            // 发送预设提示词
            let decodedPrompt = prompt.removingPercentEncoding ?? prompt
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                NotificationCenter.default.post(name: .sendPrompt, object: decodedPrompt)
            }
        }
    }

    private func handleAppsDeepLink(queryItems: [URLQueryItem]?) {
        print("📱 处理应用深度链接: \(queryItems?.description ?? "无参数")")

        if let appName = queryItems?.first(where: { $0.name == "app" })?.value {
            let searchQuery = queryItems?.first(where: { $0.name == "search" })?.value
            print("📱 在应用中搜索: \(appName), 关键词: \(searchQuery ?? "无")")

            // 在指定App中搜索
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: .searchInApp, object: ["app": appName, "query": searchQuery ?? ""])
            }
        }
    }

    private func handleClipboardSearch(queryItems: [URLQueryItem]?) {
        print("📋 处理剪贴板搜索: \(queryItems?.description ?? "无参数")")

        selectedTab = 0 // 浏览器tab
        let pasteboard = UIPasteboard.general.string ?? ""
        let engine = queryItems?.first(where: { $0.name == "engine" })?.value ?? "google"

        print("📋 剪贴板内容: \(pasteboard)")
        print("📋 搜索引擎: \(engine)")

        // 在浏览器中搜索剪贴板内容
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(name: .browserClipboardSearch, object: ["query": pasteboard, "engine": engine])
        }
    }

    private func handleBatchOperation(queryItems: [URLQueryItem]?) {
        print("🔗 处理批量操作: \(queryItems?.description ?? "无参数")")

        let clipboardContent = UIPasteboard.general.string ?? ""

        // 显示批量操作界面
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(name: .showBatchOperation, object: clipboardContent)
        }
    }

    private func handleDirectChat(queryItems: [URLQueryItem]?) {
        print("🔗 处理直接聊天: \(queryItems?.description ?? "无参数")")

        if let assistantId = queryItems?.first(where: { $0.name == "assistant" })?.value {
            let prompt = queryItems?.first(where: { $0.name == "prompt" })?.value

            let chatRequest = DirectChatRequest(
                assistantId: assistantId,
                presetPrompt: prompt,
                autoSend: prompt != nil
            )

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: .openDirectChat, object: chatRequest)
            }
        }
    }

    private func handleSmartSearch(queryItems: [URLQueryItem]?) {
        print("🔗 处理智能搜索: \(queryItems?.description ?? "无参数")")

        let engine = queryItems?.first(where: { $0.name == "engine" })?.value ?? "google"
        let auto = queryItems?.first(where: { $0.name == "auto" })?.value == "true"

        if auto {
            // 自动使用剪贴板内容搜索
            let clipboardContent = UIPasteboard.general.string ?? ""

            if !clipboardContent.isEmpty {
                // 切换到搜索页面并自动搜索
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NotificationCenter.default.post(name: .smartSearchWithClipboard, object: [
                        "engine": engine,
                        "query": clipboardContent
                    ])
                }
            } else {
                // 没有剪贴板内容，切换到搜索页面
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NotificationCenter.default.post(name: .switchSearchEngine, object: engine)
                }
            }
        }
    }

    private func handleAppSearch(queryItems: [URLQueryItem]?) {
        print("🔗 处理应用搜索: \(queryItems?.description ?? "无参数")")

        let appId = queryItems?.first(where: { $0.name == "app" })?.value ?? ""
        let auto = queryItems?.first(where: { $0.name == "auto" })?.value == "true"

        if auto && !appId.isEmpty {
            // 自动使用剪贴板内容在指定应用中搜索
            let clipboardContent = UIPasteboard.general.string ?? "热门推荐"

            // 直接跳转到应用搜索结果页面
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: .directAppSearch, object: [
                    "app": appId,
                    "query": clipboardContent
                ])
            }
        }
    }

    private func handleDirectAppLaunch(queryItems: [URLQueryItem]?) {
        print("🚀 处理直接应用启动: \(queryItems?.description ?? "无参数")")

        let appId = queryItems?.first(where: { $0.name == "app" })?.value ?? ""

        if !appId.isEmpty {
            // 获取剪贴板内容
            let clipboardContent = UIPasteboard.general.string ?? ""
            let searchQuery = clipboardContent.isEmpty ? "热门推荐" : clipboardContent
            let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchQuery

            print("📋 剪贴板内容: \(clipboardContent)")
            print("🔍 搜索词: \(searchQuery)")

            // 构建应用搜索URL
            var appURL: String

            switch appId {
            case "taobao":
                appURL = "taobao://s.taobao.com?q=\(encodedQuery)"
            case "jd":
                appURL = "openapp.jdmobile://virtual?params={\"category\":\"jump\",\"des\":\"search\",\"keyWord\":\"\(encodedQuery)\"}"
            case "meituan":
                appURL = "imeituan://www.meituan.com/search?q=\(encodedQuery)"
            case "douyin":
                appURL = "snssdk1128://search?keyword=\(encodedQuery)"
            case "alipay":
                appURL = "alipay://platformapi/startapp?appId=20000067&query=\(encodedQuery)"
            case "wechat":
                appURL = "weixin://"
            default:
                print("❌ 不支持的应用: \(appId)")
                return
            }

            print("🔗 准备打开URL: \(appURL)")

            // 直接打开应用
            if let url = URL(string: appURL) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url) { success in
                        if success {
                            print("✅ 成功打开应用: \(appId)")
                        } else {
                            print("❌ 打开应用失败: \(appId)")
                            // 如果打开失败，显示提示
                            DispatchQueue.main.async {
                                // 这里可以显示一个提示，告诉用户应用未安装
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - 新的深度链接处理函数

    private func handleAIChat(queryItems: [URLQueryItem]?) {
        print("🤖 处理AI聊天: \(queryItems?.description ?? "无参数")")

        let assistantId = queryItems?.first(where: { $0.name == "assistant" })?.value ?? "deepseek"

        // 切换到AI tab
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedTab = 2 // AI tab

            // 发送通知显示AI助手信息
            NotificationCenter.default.post(name: .showAIAssistant, object: assistantId)
        }
    }

    private func handleBrowseTab(queryItems: [URLQueryItem]?) {
        print("🌐 处理浏览tab: \(queryItems?.description ?? "无参数")")

        let engine = queryItems?.first(where: { $0.name == "engine" })?.value ?? "google"
        let auto = queryItems?.first(where: { $0.name == "auto" })?.value == "true"

        // 切换到浏览tab
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedTab = 1 // 浏览tab

            if auto {
                // 自动使用剪贴板内容搜索
                let clipboardContent = UIPasteboard.general.string ?? ""

                if !clipboardContent.isEmpty {
                    // 构建搜索URL并在浏览器中打开
                    let searchURL = getSearchURL(for: engine, query: clipboardContent)
                    webViewModel.loadUrl(searchURL)
                } else {
                    // 没有剪贴板内容，加载搜索引擎首页
                    let homeURL = getEngineHomeURL(for: engine)
                    webViewModel.loadUrl(homeURL)
                }
            }
        }
    }

    private func handleAppSearchTab(queryItems: [URLQueryItem]?) {
        print("📱 处理应用搜索tab: \(queryItems?.description ?? "无参数")")

        let appId = queryItems?.first(where: { $0.name == "app" })?.value ?? ""

        // 切换到搜索tab
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedTab = 0 // 搜索tab

            if !appId.isEmpty {
                let clipboardContent = UIPasteboard.general.string ?? ""

                // 发送通知激活指定应用并设置搜索状态
                NotificationCenter.default.post(name: .activateAppSearch, object: [
                    "app": appId,
                    "query": clipboardContent
                ])
            }
        }
    }

    // MARK: - 搜索URL构建函数

    private func getSearchURL(for engine: String, query: String) -> String {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query

        switch engine {
        case "google":
            return "https://www.google.com/search?q=\(encodedQuery)"
        case "baidu":
            return "https://www.baidu.com/s?wd=\(encodedQuery)"
        case "bing":
            return "https://www.bing.com/search?q=\(encodedQuery)"
        case "duckduckgo":
            return "https://duckduckgo.com/?q=\(encodedQuery)"
        default:
            return "https://www.google.com/search?q=\(encodedQuery)"
        }
    }

    private func getEngineHomeURL(for engine: String) -> String {
        switch engine {
        case "google":
            return "https://www.google.com"
        case "baidu":
            return "https://www.baidu.com"
        case "bing":
            return "https://www.bing.com"
        case "duckduckgo":
            return "https://duckduckgo.com"
        default:
            return "https://www.google.com"
        }
    }
}





struct WeChatTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            // 搜索
            WeChatTabItem(
                icon: "magnifyingglass",
                title: "搜索",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }

            // 浏览
            WeChatTabItem(
                icon: "globe",
                title: "浏览",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }

            // AI
            WeChatTabItem(
                icon: "brain.head.profile",
                title: "AI",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }

            // 小组件
            WeChatTabItem(
                icon: "widget.small",
                title: "小组件",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .top
        )
    }
}

struct WeChatTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            // 微信风格的快速响应
            withAnimation(.spring(response: 0.2, dampingFraction: 1.0, blendDuration: 0)) {
                action()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(isSelected ? Color(red: 0.2, green: 0.7, blue: 0.3) : Color(.systemGray))
                    .scaleEffect(isPressed ? 0.9 : 1.0)

                Text(title)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(isSelected ? Color(red: 0.2, green: 0.7, blue: 0.3) : Color(.systemGray))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .opacity(isPressed ? 0.6 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.1, dampingFraction: 1.0, blendDuration: 0)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// 临时的SearchView定义，直到文件被正确添加到项目中
// MARK: - 分类配置结构
struct CategoryConfig: Identifiable, Codable {
    let id = UUID()
    var name: String
    var color: Color
    var icon: String
    var order: Int
    var isCustom: Bool = false

    // 颜色编码支持
    enum CodingKeys: String, CodingKey {
        case name, icon, order, isCustom
        case colorRed, colorGreen, colorBlue, colorAlpha
    }

    init(name: String, color: Color, icon: String, order: Int, isCustom: Bool = false) {
        self.name = name
        self.color = color
        self.icon = icon
        self.order = order
        self.isCustom = isCustom
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decode(String.self, forKey: .icon)
        order = try container.decode(Int.self, forKey: .order)
        isCustom = try container.decodeIfPresent(Bool.self, forKey: .isCustom) ?? false

        let red = try container.decode(Double.self, forKey: .colorRed)
        let green = try container.decode(Double.self, forKey: .colorGreen)
        let blue = try container.decode(Double.self, forKey: .colorBlue)
        let alpha = try container.decode(Double.self, forKey: .colorAlpha)
        color = Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(order, forKey: .order)
        try container.encode(isCustom, forKey: .isCustom)

        // 正确的颜色编码 - 提取实际的RGB值
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        try container.encode(Double(red), forKey: .colorRed)
        try container.encode(Double(green), forKey: .colorGreen)
        try container.encode(Double(blue), forKey: .colorBlue)
        try container.encode(Double(alpha), forKey: .colorAlpha)
    }
}

struct SearchView: View {
    @EnvironmentObject var deepLinkHandler: DeepLinkHandler
    @State private var searchText = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedCategory = "全部"
    @State private var categoryConfigs: [CategoryConfig] = []
    @State private var customApps: [String] = [] // 自定义分类中的应用ID
    @State private var showingCategoryEditor = false
    @State private var showingCategoryDrawer = true // 抽屉显示状态
    @State private var showingCustomAlert = false // 自定义分类提示
    @State private var customAlertMessage = "" // 自定义分类消息

    // 默认分类配置 - 绿色简约风格
    private var defaultCategories: [CategoryConfig] {
        [
            CategoryConfig(name: "自定义", color: Color.green, icon: "star.fill", order: 0, isCustom: true),
            CategoryConfig(name: "全部", color: Color.primary, icon: "square.grid.2x2.fill", order: 1),
            CategoryConfig(name: "购物", color: Color.green, icon: "bag.fill", order: 2),
            CategoryConfig(name: "社交", color: Color(red: 0.2, green: 0.7, blue: 0.3), icon: "bubble.left.and.bubble.right.fill", order: 3),
            CategoryConfig(name: "视频", color: Color.green, icon: "play.rectangle.fill", order: 4),
            CategoryConfig(name: "音乐", color: Color(red: 0.3, green: 0.8, blue: 0.4), icon: "music.note", order: 5),
            CategoryConfig(name: "生活", color: Color.green, icon: "house.fill", order: 6),
            CategoryConfig(name: "地图", color: Color(red: 0.2, green: 0.7, blue: 0.3), icon: "map.fill", order: 7),
            CategoryConfig(name: "浏览器", color: Color.green, icon: "globe", order: 8),
            CategoryConfig(name: "金融", color: Color(red: 0.3, green: 0.8, blue: 0.4), icon: "creditcard.fill", order: 9),
            CategoryConfig(name: "出行", color: Color.green, icon: "car.fill", order: 10),
            CategoryConfig(name: "招聘", color: Color(red: 0.2, green: 0.7, blue: 0.3), icon: "briefcase.fill", order: 11),
            CategoryConfig(name: "教育", color: Color.green, icon: "book.fill", order: 12),
            CategoryConfig(name: "新闻", color: Color(red: 0.3, green: 0.8, blue: 0.4), icon: "newspaper.fill", order: 13)
        ]
    }

    // 应用数据 - 使用更贴近原App的图标和品牌色
    private let apps = [
        // 购物类
        AppInfo(name: "淘宝", icon: "T", systemIcon: "bag.circle.fill", color: Color(red: 1.0, green: 0.4, blue: 0.0), urlScheme: "taobao://s.taobao.com/search?q=", bundleId: "com.taobao.taobao4iphone", category: "购物", appStoreId: "387682726"),
        AppInfo(name: "天猫", icon: "天", systemIcon: "bag.fill", color: Color(red: 1.0, green: 0.2, blue: 0.2), urlScheme: "tmall://search?q=", bundleId: "com.tmall.wireless", category: "购物", appStoreId: "518966501"),
        AppInfo(name: "拼多多", icon: "P", systemIcon: "cart.circle.fill", color: Color(red: 1.0, green: 0.2, blue: 0.2), urlScheme: "pinduoduo://search?keyword=", bundleId: "com.xunmeng.pinduoduo", category: "购物", appStoreId: "1044283059"),
        AppInfo(name: "京东", icon: "京", systemIcon: "cube.box.fill", color: Color(red: 0.8, green: 0.0, blue: 0.0), urlScheme: "openapp.jdmobile://virtual?params={\"category\":\"jump\",\"des\":\"search\",\"keyword\":\"", bundleId: "com.360buy.jdmobile", category: "购物", appStoreId: "414245413"),
        AppInfo(name: "闲鱼", icon: "闲", systemIcon: "fish.circle.fill", color: Color(red: 0.0, green: 0.6, blue: 1.0), urlScheme: "fleamarket://search?q=", bundleId: "com.taobao.fleamarket", category: "购物", appStoreId: "510909506"),

        // 社交媒体
        AppInfo(name: "知乎", icon: "知", systemIcon: "bubble.left.circle.fill", color: Color(red: 0.0, green: 0.5, blue: 1.0), urlScheme: "zhihu://search?q=", bundleId: "com.zhihu.ios", category: "社交", appStoreId: "432274380"),
        AppInfo(name: "微博", icon: "微", systemIcon: "at.circle.fill", color: Color(red: 1.0, green: 0.3, blue: 0.3), urlScheme: "sinaweibo://search?q=", bundleId: "com.sina.weibo", category: "社交", appStoreId: "350962117"),
        AppInfo(name: "小红书", icon: "小", systemIcon: "heart.circle.fill", color: Color(red: 1.0, green: 0.2, blue: 0.4), urlScheme: "xhsdiscover://search?keyword=", bundleId: "com.xingin.xhs", category: "社交", appStoreId: "741292507"),

        // 视频娱乐
        AppInfo(name: "抖音", icon: "抖", systemIcon: "music.note.tv.fill", color: Color(red: 0.0, green: 0.0, blue: 0.0), urlScheme: "snssdk1128://search?keyword=", bundleId: "com.ss.iphone.ugc.Aweme", category: "视频", appStoreId: "1142110895"),
        AppInfo(name: "快手", icon: "快", systemIcon: "video.circle.fill", color: Color(red: 1.0, green: 0.4, blue: 0.0), urlScheme: "kwai://search?keyword=", bundleId: "com.kuaishou.gif", category: "视频", appStoreId: "440948110"),
        AppInfo(name: "bilibili", icon: "B", systemIcon: "tv.circle.fill", color: Color(red: 0.2, green: 0.7, blue: 0.3), urlScheme: "bilibili://search?keyword=", bundleId: "tv.danmaku.bili", category: "视频", appStoreId: "736536022"),
        AppInfo(name: "YouTube", icon: "Y", systemIcon: "play.tv.fill", color: Color(red: 1.0, green: 0.0, blue: 0.0), urlScheme: "youtube://results?search_query=", bundleId: "com.google.ios.youtube", category: "视频", appStoreId: "544007664"),
        AppInfo(name: "优酷", icon: "优", systemIcon: "play.rectangle.fill", color: Color(red: 0.0, green: 0.6, blue: 1.0), urlScheme: "youku://search?keyword=", bundleId: "com.youku.YouKu", category: "视频", appStoreId: "336141475"),
        AppInfo(name: "爱奇艺", icon: "爱", systemIcon: "tv.fill", color: Color(red: 0.0, green: 0.8, blue: 0.4), urlScheme: "qiyi-iphone://search?key=", bundleId: "com.qiyi.iphone", category: "视频", appStoreId: "393765873"),

        // 音乐
        AppInfo(name: "QQ音乐", icon: "Q", systemIcon: "music.note.circle.fill", color: Color(red: 0.0, green: 0.8, blue: 0.2), urlScheme: "qqmusic://search?key=", bundleId: "com.tencent.QQMusic", category: "音乐", appStoreId: "414603431"),
        AppInfo(name: "网易云音乐", icon: "网", systemIcon: "music.note.list", color: Color(red: 1.0, green: 0.2, blue: 0.2), urlScheme: "orpheus://search?keyword=", bundleId: "com.netease.cloudmusic", category: "音乐", appStoreId: "590338362"),

        // 生活服务
        AppInfo(name: "美团", icon: "美", systemIcon: "takeoutbag.and.cup.and.straw.fill", color: Color(red: 1.0, green: 0.8, blue: 0.0), urlScheme: "imeituan://www.meituan.com/search?q=", bundleId: "com.meituan.imeituan", category: "生活", appStoreId: "423084029"),
        AppInfo(name: "饿了么", icon: "饿", systemIcon: "fork.knife.circle.fill", color: Color(red: 0.0, green: 0.6, blue: 1.0), urlScheme: "eleme://search?keyword=", bundleId: "me.ele.ios.eleme", category: "生活", appStoreId: "507161324"),
        AppInfo(name: "大众点评", icon: "大", systemIcon: "star.circle.fill", color: Color(red: 1.0, green: 0.6, blue: 0.0), urlScheme: "dianping://search?keyword=", bundleId: "com.dianping.dpscope", category: "生活", appStoreId: "351091731"),
        AppInfo(name: "豆瓣", icon: "豆", systemIcon: "book.circle.fill", color: Color(red: 0.0, green: 0.7, blue: 0.3), urlScheme: "douban://search?q=", bundleId: "com.douban.frodo", category: "生活", appStoreId: "907002334"),

        // 地图导航
        AppInfo(name: "高德地图", icon: "高", systemIcon: "map.circle.fill", color: Color(red: 0.0, green: 0.7, blue: 1.0), urlScheme: "iosamap://search?keywords=", bundleId: "com.autonavi.minimap", category: "地图", appStoreId: "461703208"),
        AppInfo(name: "腾讯地图", icon: "腾", systemIcon: "location.circle.fill", color: Color(red: 0.0, green: 0.8, blue: 0.4), urlScheme: "sosomap://search?keyword=", bundleId: "com.tencent.map", category: "地图", appStoreId: "481623196"),

        // 浏览器
        AppInfo(name: "夸克", icon: "夸", systemIcon: "globe.circle.fill", color: Color(red: 0.4, green: 0.6, blue: 1.0), urlScheme: "quark://search?q=", bundleId: "com.quark.browser", category: "浏览器", appStoreId: "1160172628"),
        AppInfo(name: "UC浏览器", icon: "UC", systemIcon: "safari.fill", color: Color(red: 1.0, green: 0.4, blue: 0.0), urlScheme: "ucbrowser://search?keyword=", bundleId: "com.uc.iphone", category: "浏览器", appStoreId: "586871187"),

        // 金融支付
        AppInfo(name: "支付宝", icon: "支", systemIcon: "creditcard.circle.fill", color: Color(red: 0.0, green: 0.6, blue: 1.0), urlScheme: "alipay://platformapi/startapp?appId=20000067&query=", bundleId: "com.alipay.iphoneclient", category: "金融", appStoreId: "333206289"),
        AppInfo(name: "微信支付", icon: "微", systemIcon: "dollarsign.circle.fill", color: Color(red: 0.0, green: 0.8, blue: 0.2), urlScheme: "weixin://dl/business/?ticket=", bundleId: "com.tencent.xin", category: "金融", appStoreId: "414478124"),
        AppInfo(name: "招商银行", icon: "招", systemIcon: "building.columns.circle.fill", color: Color(red: 0.8, green: 0.0, blue: 0.0), urlScheme: "cmbmobilebank://search?keyword=", bundleId: "com.cmbchina.cmbphone", category: "金融", appStoreId: "392966996"),
        AppInfo(name: "蚂蚁财富", icon: "蚂", systemIcon: "chart.line.uptrend.xyaxis.circle.fill", color: Color(red: 0.0, green: 0.5, blue: 1.0), urlScheme: "antfortune://search?keyword=", bundleId: "com.alipay.antfortune", category: "金融", appStoreId: "1015961470"),

        // 出行交通
        AppInfo(name: "滴滴出行", icon: "滴", systemIcon: "car.circle.fill", color: Color(red: 1.0, green: 0.6, blue: 0.0), urlScheme: "diditaxi://search?keyword=", bundleId: "com.xiaojukeji.didi", category: "出行", appStoreId: "554499054"),
        AppInfo(name: "12306", icon: "12", systemIcon: "train.side.front.car", color: Color(red: 0.0, green: 0.4, blue: 0.8), urlScheme: "cn.12306://search?keyword=", bundleId: "com.MCS.MobileTicket", category: "出行", appStoreId: "564818797"),
        AppInfo(name: "携程旅行", icon: "携", systemIcon: "airplane.circle.fill", color: Color(red: 0.0, green: 0.6, blue: 1.0), urlScheme: "ctrip://search?keyword=", bundleId: "com.ctrip.wireless", category: "出行", appStoreId: "379395415"),
        AppInfo(name: "去哪儿", icon: "去", systemIcon: "location.north.circle.fill", color: Color(red: 0.0, green: 0.8, blue: 0.4), urlScheme: "qunar://search?keyword=", bundleId: "com.Qunar.travel", category: "出行", appStoreId: "395096736"),
        AppInfo(name: "哈啰出行", icon: "哈", systemIcon: "bicycle.circle.fill", color: Color(red: 0.0, green: 0.7, blue: 1.0), urlScheme: "hellobike://search?keyword=", bundleId: "com.jingyao.easybike", category: "出行", appStoreId: "1189319138"),

        // 求职招聘
        AppInfo(name: "BOSS直聘", icon: "B", systemIcon: "person.crop.circle.fill", color: Color(red: 0.0, green: 0.8, blue: 0.4), urlScheme: "bosszhipin://search?keyword=", bundleId: "com.kanzhun.boss", category: "招聘", appStoreId: "1032153068"),
        AppInfo(name: "拉勾网", icon: "拉", systemIcon: "briefcase.circle.fill", color: Color(red: 0.0, green: 0.7, blue: 0.3), urlScheme: "lagou://search?keyword=", bundleId: "com.lagou.ios", category: "招聘", appStoreId: "653057711"),
        AppInfo(name: "猎聘", icon: "猎", systemIcon: "target", color: Color(red: 1.0, green: 0.4, blue: 0.0), urlScheme: "liepin://search?keyword=", bundleId: "com.liepin.swift", category: "招聘", appStoreId: "1067859622"),
        AppInfo(name: "前程无忧", icon: "前", systemIcon: "person.badge.plus.fill", color: Color(red: 0.0, green: 0.5, blue: 1.0), urlScheme: "51job://search?keyword=", bundleId: "com.51job.iphone.client", category: "招聘", appStoreId: "400651660"),

        // 教育学习
        AppInfo(name: "有道词典", icon: "有", systemIcon: "book.circle.fill", color: Color(red: 1.0, green: 0.2, blue: 0.2), urlScheme: "yddict://search?keyword=", bundleId: "com.youdao.dict", category: "教育", appStoreId: "353115739"),
        AppInfo(name: "百词斩", icon: "百", systemIcon: "textbook.circle.fill", color: Color(red: 0.0, green: 0.8, blue: 0.4), urlScheme: "bdc://search?keyword=", bundleId: "com.jiongji.anddict", category: "教育", appStoreId: "847068615"),
        AppInfo(name: "作业帮", icon: "作", systemIcon: "pencil.circle.fill", color: Color(red: 0.0, green: 0.6, blue: 1.0), urlScheme: "zuoyebang://search?keyword=", bundleId: "com.baidu.homework", category: "教育", appStoreId: "1001508196"),
        AppInfo(name: "小猿搜题", icon: "猿", systemIcon: "questionmark.circle.fill", color: Color(red: 1.0, green: 0.6, blue: 0.0), urlScheme: "xiaoyuan://search?keyword=", bundleId: "com.fenbi.iphone.ape", category: "教育", appStoreId: "1034006541"),

        // 新闻资讯
        AppInfo(name: "今日头条", icon: "今", systemIcon: "newspaper.circle.fill", color: Color(red: 1.0, green: 0.2, blue: 0.2), urlScheme: "snssdk32://search?keyword=", bundleId: "com.ss.iphone.article.News", category: "新闻", appStoreId: "529092160"),
        AppInfo(name: "腾讯新闻", icon: "腾", systemIcon: "doc.text.circle.fill", color: Color(red: 0.0, green: 0.6, blue: 1.0), urlScheme: "qqnews://search?keyword=", bundleId: "com.tencent.news", category: "新闻", appStoreId: "399363894"),
        AppInfo(name: "网易新闻", icon: "网", systemIcon: "globe.asia.australia.fill", color: Color(red: 1.0, green: 0.2, blue: 0.2), urlScheme: "newsapp://search?keyword=", bundleId: "com.netease.news", category: "新闻", appStoreId: "425349261")
    ]

    var filteredApps: [AppInfo] {
        if selectedCategory == "全部" {
            return apps
        } else if selectedCategory == "自定义" {
            return apps.filter { app in
                customApps.contains(app.name)
            }
        } else {
            return apps.filter { $0.category == selectedCategory }
        }
    }

    // 获取排序后的分类
    var sortedCategories: [CategoryConfig] {
        categoryConfigs.sorted { $0.order < $1.order }
    }

    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                // 左侧分类抽屉
                if showingCategoryDrawer {
                    GeometryReader { geometry in
                        VStack(alignment: .leading, spacing: 0) {
                            // 分类标题
                            HStack {
                                Text("分类")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.3))

                                Spacer()

                                Button(action: {
                                    showingCategoryEditor = true
                                }) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.system(size: 13))
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)

                            Divider()
                                .background(Color.green.opacity(0.3))

                            // 分类列表
                            ScrollView {
                                LazyVStack(spacing: 1) {
                                    ForEach(sortedCategories) { category in
                                        CategoryButton(
                                            category: category,
                                            isSelected: selectedCategory == category.name,
                                            customAppsCount: category.name == "自定义" ? customApps.count : nil,
                                            screenHeight: geometry.size.height
                                        ) {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                selectedCategory = category.name
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .frame(width: 110)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.green.opacity(0.05),
                                Color.green.opacity(0.1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .transition(.move(edge: .leading))

                    Divider()
                }

                // 右侧内容区域
                VStack(spacing: 0) {
                    // 顶部工具栏
                    HStack {
                        // 抽屉切换按钮
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingCategoryDrawer.toggle()
                            }
                        }) {
                            Image(systemName: showingCategoryDrawer ? "sidebar.left" : "sidebar.right")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.themeGreen)
                        }

                        Spacer()

                        // 当前分类显示
                        if !showingCategoryDrawer {
                            HStack(spacing: 6) {
                                if let currentCategory = sortedCategories.first(where: { $0.name == selectedCategory }) {
                                    Image(systemName: currentCategory.icon)
                                        .font(.system(size: 12))
                                        .foregroundColor(currentCategory.color)

                                    Text(currentCategory.name)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray6))
                            .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // 搜索栏
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))

                            TextField("输入搜索关键词", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())

                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16))
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                        if selectedCategory == "自定义" && customApps.isEmpty {
                            Text("长按应用图标添加到自定义分类")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        } else {
                            Text("选择应用进行搜索")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)

                    // 应用网格
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 16) {
                            ForEach(filteredApps, id: \.name) { app in
                                AppButton(app: app, searchText: searchText) {
                                    searchInApp(app: app)
                                }
                                .onLongPressGesture {
                                    handleLongPress(app: app)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("应用搜索")
            .navigationBarTitleDisplayMode(.inline)
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .alert("自定义分类", isPresented: $showingCustomAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(customAlertMessage)
            }
            .sheet(isPresented: $showingCategoryEditor) {
                CategoryEditorView(
                    categories: $categoryConfigs,
                    customApps: $customApps,
                    allApps: apps
                )
            }
            .onAppear {
                // 首次启动时重置为绿色主题
                resetToGreenTheme()
                loadCategoryConfigs()
            }
            .onChange(of: deepLinkHandler.searchQuery) { query in
                if !query.isEmpty {
                    print("🔗 SearchView收到深度链接搜索查询: \(query)")
                    searchText = query
                    // 清空深度链接查询，避免重复触发
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        deepLinkHandler.searchQuery = ""
                    }
                }
            }
        }
    }

    // MARK: - 分类配置管理
    private func loadCategoryConfigs() {
        // 检查是否需要重置为绿色主题
        let shouldResetToGreen = UserDefaults.standard.bool(forKey: "ShouldResetToGreenTheme")

        if shouldResetToGreen || !UserDefaults.standard.bool(forKey: "CategoryConfigsInitialized") {
            // 重置为绿色主题或首次初始化
            categoryConfigs = defaultCategories
            saveCategoryConfigs()
            UserDefaults.standard.set(true, forKey: "CategoryConfigsInitialized")
            UserDefaults.standard.set(false, forKey: "ShouldResetToGreenTheme")
        } else if let data = UserDefaults.standard.data(forKey: "CategoryConfigs"),
                  let configs = try? JSONDecoder().decode([CategoryConfig].self, from: data) {
            categoryConfigs = configs
        } else {
            categoryConfigs = defaultCategories
            saveCategoryConfigs()
        }

        // 加载自定义应用列表
        customApps = UserDefaults.standard.stringArray(forKey: "CustomApps") ?? []
    }

    private func saveCategoryConfigs() {
        if let data = try? JSONEncoder().encode(categoryConfigs) {
            UserDefaults.standard.set(data, forKey: "CategoryConfigs")
        }
        UserDefaults.standard.set(customApps, forKey: "CustomApps")
    }

    // 重置为绿色主题
    private func resetToGreenTheme() {
        UserDefaults.standard.set(true, forKey: "ShouldResetToGreenTheme")
        loadCategoryConfigs()
    }

    private func searchInApp(app: AppInfo) {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "请输入搜索关键词"
            showingAlert = true
            return
        }

        let keyword = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText
        let urlString = app.urlScheme + keyword

        if let url = URL(string: urlString) {
            // 检查应用是否已安装
            if UIApplication.shared.canOpenURL(url) {
                // 应用已安装，直接打开搜索
                UIApplication.shared.open(url) { success in
                    if !success {
                        DispatchQueue.main.async {
                            self.alertMessage = "打开\(app.name)失败，请稍后重试"
                            self.showingAlert = true
                        }
                    }
                }
            } else {
                // 应用未安装，提示用户下载
                showAppInstallAlert(for: app, searchKeyword: keyword)
            }
        } else {
            alertMessage = "无效的应用链接"
            showingAlert = true
        }
    }

    private func showAppInstallAlert(for app: AppInfo, searchKeyword: String) {
        let alert = UIAlertController(
            title: "应用未安装",
            message: "您还没有安装\(app.name)，是否前往App Store下载？\n\n下载完成后可以搜索：\(searchKeyword)",
            preferredStyle: .alert
        )

        // 取消按钮
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))

        // 前往App Store按钮
        alert.addAction(UIAlertAction(title: "前往下载", style: .default) { _ in
            self.openAppStore(for: app)
        })

        // 显示弹窗
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }

    private func openAppStore(for app: AppInfo) {
        var appStoreURL: URL?

        // 优先使用App Store ID
        if let appStoreId = app.appStoreId {
            appStoreURL = URL(string: "https://apps.apple.com/app/id\(appStoreId)")
        }
        // 如果没有App Store ID，检查是否有Bundle ID然后搜索应用名称
        else if app.bundleId != nil {
            let searchQuery = app.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? app.name
            appStoreURL = URL(string: "https://apps.apple.com/search?term=\(searchQuery)")
        }
        // 最后使用应用名称搜索
        else {
            let searchQuery = app.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? app.name
            appStoreURL = URL(string: "https://apps.apple.com/search?term=\(searchQuery)")
        }

        if let url = appStoreURL {
            UIApplication.shared.open(url) { success in
                if !success {
                    DispatchQueue.main.async {
                        self.alertMessage = "无法打开App Store，请手动搜索\(app.name)"
                        self.showingAlert = true
                    }
                }
            }
        }
    }

    // MARK: - 长按手势处理
    private func handleLongPress(app: AppInfo) {
        let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
        hapticFeedback.impactOccurred()

        if customApps.contains(app.name) {
            // 从自定义分类中移除
            customApps.removeAll { $0 == app.name }
            customAlertMessage = "已将「\(app.name)」从自定义分类中移除"
            showingCustomAlert = true
        } else {
            // 添加到自定义分类
            customApps.append(app.name)
            customAlertMessage = "已将「\(app.name)」添加到自定义分类"
            showingCustomAlert = true
        }

        // 保存配置
        saveCategoryConfigs()
    }
}

struct AppInfo {
    let name: String
    let icon: String // Emoji图标或自定义图标名称
    let systemIcon: String // 系统图标作为备用
    let color: Color
    let urlScheme: String
    let bundleId: String? // App的Bundle ID，用于获取真实图标
    let category: String // 应用分类
    let appStoreId: String? // App Store ID，用于跳转下载

    // 便利初始化器，保持向后兼容
    init(name: String, icon: String, systemIcon: String, color: Color, urlScheme: String, bundleId: String?, category: String, appStoreId: String? = nil) {
        self.name = name
        self.icon = icon
        self.systemIcon = systemIcon
        self.color = color
        self.urlScheme = urlScheme
        self.bundleId = bundleId
        self.category = category
        self.appStoreId = appStoreId
    }
}

// 获取已安装App图标的辅助函数
func getAppIcon(for bundleId: String) -> UIImage? {
    guard let url = URL(string: "app-settings:") else { return nil }

    // 尝试通过LSApplicationWorkspace获取图标（私有API，可能不被App Store接受）
    // 这里使用一个更安全的方法
    if UIApplication.shared.canOpenURL(URL(string: bundleId + "://") ?? url) {
        // App已安装，但我们无法直接获取图标
        // 返回nil，让界面使用备用图标
        return nil
    }
    return nil
}

struct AppButton: View {
    let app: AppInfo
    let searchText: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    // 背景圆形，使用应用的品牌色
                    Circle()
                        .fill(app.color)
                        .frame(width: 50, height: 50)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

                    // 显示文字图标或自定义图标
                    Group {
                        if UIImage(named: app.icon) != nil {
                            // 显示自定义图标
                            Image(app.icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        } else {
                            // 显示文字图标
                            Text(app.icon)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                }

                Text(app.name)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
    }
}

// MARK: - AI相关类型定义
struct AIContact {
    let id: String
    let name: String
    let description: String
    let model: String
    let avatar: String
    let isOnline: Bool
    let apiEndpoint: String?
    let requiresApiKey: Bool
    let supportedFeatures: [AIFeature]
    let color: Color
}

enum AIFeature: String, CaseIterable {
    case textGeneration = "文本生成"
    case imageGeneration = "图像生成"
    case videoGeneration = "视频生成"
    case audioGeneration = "语音合成"
    case codeGeneration = "代码生成"
    case translation = "翻译"
    case summarization = "摘要"
    case search = "搜索"
    case hotTrends = "热榜推送"  // 新增：热榜功能
}

struct ChatMessage: Identifiable, Codable {
    let id: String
    var content: String
    let isFromUser: Bool
    let timestamp: Date
    var status: MessageStatus
    var actions: [MessageAction]
    var isHistorical: Bool = false
    var aiSource: String? = nil // 标识来自哪个AI
    var isStreaming: Bool = false // 是否正在流式接收
    var avatar: String? = nil // 头像
    var isFavorited: Bool = false // 是否收藏
    var isEdited: Bool = false // 是否已编辑
}

enum MessageStatus: String, Codable {
    case sending = "发送中"
    case sent = "已发送"
    case delivered = "已送达"
    case failed = "发送失败"
}

struct MessageAction: Identifiable, Codable {
    let id: String
    let title: String
    let action: String
    let type: MessageActionType

    init(id: String, title: String, type: MessageActionType) {
        self.id = id
        self.title = title
        self.action = title
        self.type = type
    }
}

enum MessageActionType: String, Codable {
    case refresh = "refresh"
    case settings = "settings"
    case viewContent = "view_content"
    case share = "share"
    case openLink = "open_link"
}

// MARK: - API配置管理器已移至APIConfigManager.swift

// MARK: - ChatView定义
struct ChatView: View {
    let contact: AIContact
    let onBack: () -> Void
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isLoading = false
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        VStack(spacing: 0) {
            // 自定义导航栏
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .fontWeight(.medium)
                        Text("返回")
                            .font(.body)
                    }
                    .foregroundColor(.themeGreen)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text(contact.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(contact.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: onBack) {
                    Text("完成")
                        .foregroundColor(.themeGreen)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(.separator)),
                alignment: .bottom
            )

            // 聊天消息列表
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            ChatMessageRow(message: message)
                                .id(message.id)
                        }

                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("AI正在思考...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding()
                            .id("loading")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .onChange(of: messages.count) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let lastMessage = messages.last {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let lastMessage = messages.last {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }

            Divider()

            // 输入区域
            HStack(spacing: 12) {
                TextField("输入消息...", text: $messageText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...4)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(messageText.isEmpty ? .gray : .blue)
                        .font(.title2)
                }
                .disabled(messageText.isEmpty || isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .offset(x: dragOffset.width)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.width > 0 {
                        dragOffset = value.translation
                    }
                }
                .onEnded { value in
                    if value.translation.width > 100 {
                        onBack()
                    } else {
                        withAnimation(.spring()) {
                            dragOffset = .zero
                        }
                    }
                }
        )
        .onAppear {
            loadHistoryMessages()
        }
        .onReceive(NotificationCenter.default.publisher(for: .editMessage)) { notification in
            if let data = notification.object as? [String: String],
               let messageId = data["id"],
               let newContent = data["content"] {
                editMessage(id: messageId, newContent: newContent)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .toggleFavorite)) { notification in
            if let messageId = notification.object as? String {
                toggleMessageFavorite(id: messageId)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .deleteMessage)) { notification in
            if let messageId = notification.object as? String {
                deleteMessage(id: messageId)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .forwardMessage)) { notification in
            if let content = notification.object as? String {
                forwardMessage(content: content)
            }
        }
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = ChatMessage(
            id: UUID().uuidString,
            content: messageText,
            isFromUser: true,
            timestamp: Date(),
            status: .sent,
            actions: [],
            isHistorical: false,
            aiSource: nil,
            isStreaming: false,
            avatar: getUserAvatar(),
            isFavorited: false,
            isEdited: false
        )

        messages.append(userMessage)
        let currentMessage = messageText
        messageText = ""
        isLoading = true

        // 保存用户消息到历史记录
        saveHistoryMessages()

        // 调用真实的AI API
        callAIAPI(message: currentMessage)
    }

    private func callAIAPI(message: String) {
        print("🔍 开始API调用检查...")
        print("🔍 联系人名称: '\(contact.name)'")
        print("🔍 联系人ID: '\(contact.id)'")

        // 检查API密钥
        guard let apiKey = APIConfigManager.shared.getAPIKey(for: contact.id) else {
            showAPIKeyMissingError()
            return
        }

        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAPIKeyMissingError()
            return
        }

        print("✅ 找到API密钥: \(apiKey.prefix(10))...")

        // 根据联系人ID调用对应的API
        if contact.id == "deepseek" {
            print("🎯 确认调用DeepSeek API")
            callDeepSeekAPIDirectly(message: message, apiKey: apiKey)
        } else if contact.id == "openai" {
            print("🎯 确认调用OpenAI API")
            callOpenAIAPIDirectly(message: message, apiKey: apiKey)
        } else {
            showUnsupportedServiceError()
        }
    }

    private func callDeepSeekAPIDirectly(message: String, apiKey: String) {
        print("🚀 开始DeepSeek API流式调用")

        guard let url = URL(string: "https://api.deepseek.com/chat/completions") else {
            showAPIError("无效的API地址")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                [
                    "role": "user",
                    "content": message
                ]
            ],
            "max_tokens": 2000,
            "temperature": 0.7,
            "stream": true // 启用流式响应
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            showAPIError("请求数据编码失败: \(error.localizedDescription)")
            return
        }

        // 创建流式响应的AI消息
        let streamingMessage = ChatMessage(
            id: UUID().uuidString,
            content: "",
            isFromUser: false,
            timestamp: Date(),
            status: .sending,
            actions: [],
            isHistorical: false,
            aiSource: contact.name,
            isStreaming: true,
            avatar: getAIAvatar(),
            isFavorited: false,
            isEdited: false
        )

        messages.append(streamingMessage)
        let messageIndex = messages.count - 1

        // 使用URLSessionDataTask处理流式响应
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAPIError("网络连接失败: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📊 HTTP状态码: \(httpResponse.statusCode)")

                    if httpResponse.statusCode != 200 {
                        self.showAPIError("API调用失败，状态码: \(httpResponse.statusCode)")
                        return
                    }
                }

                guard let data = data else {
                    self.showAPIError("未收到响应数据")
                    return
                }

                self.parseStreamingResponse(data: data, messageIndex: messageIndex)
            }
        }

        task.resume()
    }

    private func parseStreamingResponse(data: Data, messageIndex: Int) {
        guard messageIndex < messages.count else { return }

        let dataString = String(data: data, encoding: .utf8) ?? ""
        let lines = dataString.components(separatedBy: .newlines)

        for line in lines {
            if line.hasPrefix("data: ") {
                let jsonString = String(line.dropFirst(6))

                if jsonString.trimmingCharacters(in: .whitespacesAndNewlines) == "[DONE]" {
                    // 流式响应结束
                    messages[messageIndex].isStreaming = false
                    messages[messageIndex].status = .sent
                    isLoading = false
                    saveHistoryMessages()
                    print("✅ 流式响应完成")
                    return
                }

                guard let jsonData = jsonString.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                      let choices = json["choices"] as? [[String: Any]],
                      let firstChoice = choices.first,
                      let delta = firstChoice["delta"] as? [String: Any],
                      let content = delta["content"] as? String else {
                    continue
                }

                // 逐字添加内容
                messages[messageIndex].content += content

                // 触发UI更新
                DispatchQueue.main.async {
                    // UI会自动更新，因为messages是@State
                }
            }
        }
    }

    private func getAIAvatar() -> String {
        switch contact.id {
        case "deepseek":
            return "brain.head.profile"
        case "openai":
            return "bubble.left.and.bubble.right.fill"
        case "claude":
            return "c.circle.fill"
        case "gemini":
            return "diamond.fill"
        default:
            return "brain.head.profile"
        }
    }

    private func getUserAvatar() -> String {
        return "person.circle.fill"
    }

    private func callOpenAIAPIDirectly(message: String, apiKey: String) {
        print("🚀 开始OpenAI API直接调用")

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            showAPIError("无效的API地址")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": message
                ]
            ],
            "max_tokens": 2000,
            "temperature": 0.7
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            showAPIError("请求数据编码失败: \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAPIError("网络连接失败: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📊 HTTP状态码: \(httpResponse.statusCode)")

                    if httpResponse.statusCode != 200 {
                        self.showAPIError("API调用失败，状态码: \(httpResponse.statusCode)")
                        return
                    }
                }

                guard let data = data else {
                    self.showAPIError("未收到响应数据")
                    return
                }

                self.parseDeepSeekAPIResponse(data: data) // OpenAI和DeepSeek响应格式相同
            }
        }.resume()
    }

    private func parseDeepSeekAPIResponse(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                // 检查是否有错误
                if let error = json["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    showAPIError("API错误: \(message)")
                    return
                }

                // 解析正常响应
                guard let choices = json["choices"] as? [[String: Any]],
                      let firstChoice = choices.first,
                      let message = firstChoice["message"] as? [String: Any],
                      let content = message["content"] as? String else {
                    showAPIError("响应格式错误，无法提取AI回复内容")
                    return
                }

                print("✅ 成功提取AI回复: \(content.prefix(50))...")

                let aiResponse = ChatMessage(
                    id: UUID().uuidString,
                    content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                    isFromUser: false,
                    timestamp: Date(),
                    status: .sent,
                    actions: []
                )

                self.messages.append(aiResponse)
                self.saveHistoryMessages() // 保存AI响应
                self.isLoading = false

                print("✅ \(contact.name) API调用完全成功")
            }
        } catch {
            showAPIError("响应解析失败: \(error.localizedDescription)")
        }
    }

    private func showAPIKeyMissingError() {
        isLoading = false

        let errorMessage = """
        ❌ 未配置API密钥

        请按以下步骤配置：
        1. 点击右上角设置按钮
        2. 找到\(contact.name)配置
        3. 输入有效的API密钥
        4. 保存后重新尝试
        """

        let errorResponse = ChatMessage(
            id: UUID().uuidString,
            content: errorMessage,
            isFromUser: false,
            timestamp: Date(),
            status: .sent,
            actions: []
        )

        messages.append(errorResponse)
        saveHistoryMessages()

        print("❌ API密钥未配置: \(contact.name)")
    }

    private func showAPIError(_ errorMessage: String) {
        isLoading = false

        let fullErrorMessage = """
        ❌ API调用失败

        \(errorMessage)

        请检查：
        • API密钥是否正确
        • 网络连接是否正常
        • API额度是否充足
        """

        let errorResponse = ChatMessage(
            id: UUID().uuidString,
            content: fullErrorMessage,
            isFromUser: false,
            timestamp: Date(),
            status: .sent,
            actions: []
        )

        messages.append(errorResponse)
        saveHistoryMessages()

        print("❌ API错误: \(errorMessage)")
    }

    private func showUnsupportedServiceError() {
        isLoading = false

        let errorMessage = """
        ❌ 暂不支持的AI服务

        当前仅支持：
        • DeepSeek
        • OpenAI

        请选择支持的AI服务进行对话。
        """

        let errorResponse = ChatMessage(
            id: UUID().uuidString,
            content: errorMessage,
            isFromUser: false,
            timestamp: Date(),
            status: .sent,
            actions: []
        )

        messages.append(errorResponse)
        saveHistoryMessages()

        print("❌ 不支持的AI服务: \(contact.name)")
    }

    // MARK: - 历史记录管理
    private func saveHistoryMessages() {
        let key = "chat_history_\(contact.id)"
        if let data = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(data, forKey: key)
            print("💾 已保存\(contact.name)聊天历史: \(messages.count)条消息")
        }
    }

    private func loadHistoryMessages() {
        let key = "chat_history_\(contact.id)"
        if let data = UserDefaults.standard.data(forKey: key),
           let savedMessages = try? JSONDecoder().decode([ChatMessage].self, from: data) {
            messages = savedMessages
            print("📚 已加载\(contact.name)聊天历史: \(messages.count)条消息")
        }
    }

    // 滚动到底部功能已内联到调用处

    // MARK: - 消息操作实现
    private func editMessage(id: String, newContent: String) {
        if let index = messages.firstIndex(where: { $0.id == id }) {
            messages[index].content = newContent
            messages[index].isEdited = true
            saveHistoryMessages()
        }
    }

    private func toggleMessageFavorite(id: String) {
        if let index = messages.firstIndex(where: { $0.id == id }) {
            messages[index].isFavorited.toggle()
            saveHistoryMessages()
        }
    }

    private func deleteMessage(id: String) {
        messages.removeAll { $0.id == id }
        saveHistoryMessages()
    }

    private func forwardMessage(content: String) {
        // 将消息内容设置到输入框
        messageText = content
    }
}

struct ChatMessageRow: View {
    let message: ChatMessage
    @State private var showingActions = false
    @State private var showingEditDialog = false
    @State private var editedContent = ""

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.isFromUser {
                Spacer()

                // 用户消息
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(alignment: .bottom, spacing: 8) {
                        VStack(alignment: .trailing, spacing: 4) {
                            // 消息内容
                            VStack(alignment: .leading, spacing: 8) {
                                SimpleMarkdownText(content: cleanContent(message.content), isFromUser: message.isFromUser)

                                if message.isStreaming {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.6)
                                        Text("正在输入...")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.themeGreen)
                            .cornerRadius(18)
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                            .onLongPressGesture {
                                showingActions = true
                            }

                            // 时间和状态
                            HStack(spacing: 4) {
                                if message.isEdited {
                                    Text("已编辑")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }

                                Text(formatTime(message.timestamp))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)

                                if message.isFavorited {
                                    Image(systemName: "heart.fill")
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                }
                            }
                        }

                        // 用户头像
                        Image(systemName: message.avatar ?? "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.themeGreen)
                            .frame(width: 32, height: 32)
                    }
                }
            } else {
                // AI消息
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .bottom, spacing: 8) {
                        // AI头像
                        Image(systemName: message.avatar ?? "brain.head.profile")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 32, height: 32)

                        VStack(alignment: .leading, spacing: 4) {
                            // AI名称
                            if let aiSource = message.aiSource {
                                Text(aiSource)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            // 消息内容
                            VStack(alignment: .leading, spacing: 8) {
                                SimpleMarkdownText(content: cleanContent(message.content), isFromUser: false)

                                if message.isStreaming {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.6)
                                        Text("正在输入...")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray5))
                            .cornerRadius(18)
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                            .onLongPressGesture {
                                showingActions = true
                            }

                            // 时间和状态
                            HStack(spacing: 4) {
                                if message.isEdited {
                                    Text("已编辑")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }

                                Text(formatTime(message.timestamp))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)

                                if message.isFavorited {
                                    Image(systemName: "heart.fill")
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                }
                            }
                        }

                        Spacer()
                    }
                }
            }
        }
        .actionSheet(isPresented: $showingActions) {
            ActionSheet(
                title: Text("消息操作"),
                buttons: [
                    .default(Text("复制")) {
                        copyMessage()
                    },
                    .default(Text("编辑")) {
                        startEditing()
                    },
                    .default(Text(message.isFavorited ? "取消收藏" : "收藏")) {
                        toggleFavorite()
                    },
                    .default(Text("分享")) {
                        shareMessage()
                    },
                    .default(Text("转发")) {
                        forwardMessage()
                    },
                    .destructive(Text("删除")) {
                        deleteMessage()
                    },
                    .cancel()
                ]
            )
        }
        .alert("编辑消息", isPresented: $showingEditDialog) {
            TextField("消息内容", text: $editedContent)
            Button("取消", role: .cancel) { }
            Button("保存") {
                saveEdit()
            }
        }
    }

    private func cleanContent(_ content: String) -> String {
        // 移除过多的表情符号和符号堆积
        var cleaned = content

        // 移除连续的表情符号（保留单个）
        let emojiPattern = #"[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]{2,}"#
        cleaned = cleaned.replacingOccurrences(of: emojiPattern, with: "", options: .regularExpression)

        // 移除过多的符号重复
        let symbolPattern = #"[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\?]{3,}"#
        cleaned = cleaned.replacingOccurrences(of: symbolPattern, with: "", options: .regularExpression)

        // 移除多余的空行
        cleaned = cleaned.replacingOccurrences(of: #"\n{3,}"#, with: "\n\n", options: .regularExpression)

        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - 消息操作
    private func copyMessage() {
        UIPasteboard.general.string = message.content
    }

    private func startEditing() {
        editedContent = message.content
        showingEditDialog = true
    }

    private func saveEdit() {
        // 这里需要通过回调或通知来更新消息
        NotificationCenter.default.post(
            name: .editMessage,
            object: ["id": message.id, "content": editedContent]
        )
    }

    private func toggleFavorite() {
        NotificationCenter.default.post(
            name: .toggleFavorite,
            object: message.id
        )
    }

    private func shareMessage() {
        let shareText = message.content
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }

    private func forwardMessage() {
        NotificationCenter.default.post(
            name: .forwardMessage,
            object: message.content
        )
    }

    private func deleteMessage() {
        NotificationCenter.default.post(
            name: .deleteMessage,
            object: message.id
        )
    }
}

// MARK: - SimpleAIChatView定义
struct SimpleAIChatView: View {
    @StateObject private var apiManager = APIConfigManager.shared

    @State private var showingDirectChat = false
    @State private var selectedAssistantId = "deepseek"
    @State private var currentContact: AIContact?
    @State private var showingAPIConfig = false
    @State private var showingContactAPIConfig = false
    @State private var selectedContactForAPI: AIContact?
    @State private var searchText = ""
    @State private var showDetailedInfo = false
    @State private var showingMultiAIChat = false
    @State private var showingContactsManagement = false
    @StateObject private var contactsManager = SimpleContactsManager.shared



    // AI联系人列表
    @State private var contacts: [AIContact] = [
        // 🇨🇳 国内主流AI服务商
        AIContact(id: "deepseek", name: "DeepSeek", description: "专业的AI编程助手，代码能力强", model: "deepseek-chat", avatar: "brain.head.profile", isOnline: true, apiEndpoint: "https://api.deepseek.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .purple),
        AIContact(id: "qwen", name: "通义千问", description: "阿里云大语言模型，多模态能力", model: "qwen-max", avatar: "cloud.fill", isOnline: true, apiEndpoint: "https://dashscope.aliyuncs.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .translation, .summarization], color: .cyan),
        AIContact(id: "chatglm", name: "智谱清言", description: "清华智谱AI，智能对话专家", model: "glm-4", avatar: "lightbulb.fill", isOnline: true, apiEndpoint: "https://open.bigmodel.cn", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .yellow),
        AIContact(id: "moonshot", name: "Kimi", description: "月之暗面AI，长文本处理专家", model: "moonshot-v1-128k", avatar: "moon.stars.fill", isOnline: true, apiEndpoint: "https://api.moonshot.cn", requiresApiKey: true, supportedFeatures: [.textGeneration, .summarization], color: .orange),
        AIContact(id: "doubao", name: "豆包", description: "字节跳动AI助手，多模态能力", model: "doubao-pro", avatar: "bubble.left.and.bubble.right", isOnline: true, apiEndpoint: "https://ark.cn-beijing.volces.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .translation], color: .blue),
        AIContact(id: "wenxin", name: "文心一言", description: "百度AI助手，中文理解优秀", model: "ernie-4.0", avatar: "w.circle.fill", isOnline: true, apiEndpoint: "https://aip.baidubce.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .translation], color: .red),
        AIContact(id: "spark", name: "讯飞星火", description: "科大讯飞AI助手，语音能力强", model: "spark-3.5", avatar: "sparkles", isOnline: true, apiEndpoint: "https://spark-api.xf-yun.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .translation], color: .orange),
        AIContact(id: "baichuan", name: "百川智能", description: "百川AI助手，推理能力强", model: "baichuan2-13b", avatar: "b.circle.fill", isOnline: true, apiEndpoint: "https://api.baichuan-ai.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .green),
        AIContact(id: "minimax", name: "MiniMax", description: "MiniMax AI助手，创意能力强", model: "abab6-chat", avatar: "m.circle.fill", isOnline: true, apiEndpoint: "https://api.minimax.chat", requiresApiKey: true, supportedFeatures: [.textGeneration, .imageGeneration], color: .purple),

        // 🌍 国际主流AI服务商
        AIContact(id: "openai", name: "ChatGPT", description: "OpenAI的GPT-4o模型", model: "gpt-4o", avatar: "bubble.left.and.bubble.right.fill", isOnline: true, apiEndpoint: "https://api.openai.com/v1", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration, .translation, .summarization], color: .green),
        AIContact(id: "claude", name: "Claude", description: "Anthropic的Claude-3.5-Sonnet", model: "claude-3-5-sonnet", avatar: "c.circle.fill", isOnline: true, apiEndpoint: "https://api.anthropic.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration, .translation, .summarization], color: .indigo),
        AIContact(id: "gemini", name: "Gemini", description: "Google的Gemini Pro模型", model: "gemini-pro", avatar: "diamond.fill", isOnline: true, apiEndpoint: "https://generativelanguage.googleapis.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .imageGeneration], color: .blue),
        AIContact(id: "copilot", name: "Copilot", description: "Microsoft Copilot AI助手", model: "gpt-4", avatar: "chevron.left.forwardslash.chevron.right", isOnline: true, apiEndpoint: "https://api.bing.microsoft.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .blue),

        // ⚡ 高性能推理
        AIContact(id: "groq", name: "Groq", description: "超高速AI推理引擎", model: "llama3-70b", avatar: "bolt.circle.fill", isOnline: true, apiEndpoint: "https://api.groq.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .orange),
        AIContact(id: "together", name: "Together AI", description: "开源模型推理平台", model: "meta-llama/Llama-2-70b", avatar: "link.circle.fill", isOnline: true, apiEndpoint: "https://api.together.xyz", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .purple),
        AIContact(id: "perplexity", name: "Perplexity", description: "AI搜索引擎，实时信息", model: "llama-3-sonar", avatar: "questionmark.diamond.fill", isOnline: true, apiEndpoint: "https://api.perplexity.ai", requiresApiKey: true, supportedFeatures: [.textGeneration, .summarization], color: .blue),

        // 🎨 专业工具
        AIContact(id: "dalle", name: "DALL-E", description: "OpenAI图像生成模型", model: "dall-e-3", avatar: "photo.circle.fill", isOnline: true, apiEndpoint: "https://api.openai.com/v1", requiresApiKey: true, supportedFeatures: [.imageGeneration], color: .pink),
        AIContact(id: "midjourney", name: "Midjourney", description: "专业AI绘画工具", model: "midjourney-v6", avatar: "paintbrush.fill", isOnline: true, apiEndpoint: "https://api.midjourney.com", requiresApiKey: true, supportedFeatures: [.imageGeneration], color: .purple),
        AIContact(id: "stablediffusion", name: "Stable Diffusion", description: "开源AI图像生成", model: "stable-diffusion-xl", avatar: "camera.macro.circle.fill", isOnline: true, apiEndpoint: "https://api.stability.ai", requiresApiKey: true, supportedFeatures: [.imageGeneration], color: .orange),

        // 📱 平台热榜联系人
        AIContact(id: "douyin", name: "抖音", description: "短视频热门内容推送", model: "platform-douyin", avatar: "music.note", isOnline: true, apiEndpoint: "https://www.douyin.com/hot", requiresApiKey: false, supportedFeatures: [.hotTrends], color: .black),
        AIContact(id: "xiaohongshu", name: "小红书", description: "生活方式热门分享", model: "platform-xiaohongshu", avatar: "heart.fill", isOnline: true, apiEndpoint: "https://www.xiaohongshu.com/explore", requiresApiKey: false, supportedFeatures: [.hotTrends], color: .red),
        AIContact(id: "wechat_mp", name: "公众号", description: "微信公众号热文推送", model: "platform-wechat", avatar: "bubble.left.and.bubble.right.fill", isOnline: true, apiEndpoint: nil, requiresApiKey: false, supportedFeatures: [.hotTrends], color: .green),
        AIContact(id: "weixin_channels", name: "视频号", description: "微信视频号热门内容", model: "platform-channels", avatar: "video.fill", isOnline: true, apiEndpoint: nil, requiresApiKey: false, supportedFeatures: [.hotTrends], color: .green),
        AIContact(id: "toutiao", name: "今日头条", description: "新闻资讯热点推送", model: "platform-toutiao", avatar: "newspaper.fill", isOnline: true, apiEndpoint: "https://www.toutiao.com/hot-event/", requiresApiKey: false, supportedFeatures: [.hotTrends], color: .red),
        AIContact(id: "bilibili", name: "B站", description: "哔哩哔哩热门视频", model: "platform-bilibili", avatar: "tv.fill", isOnline: true, apiEndpoint: "https://www.bilibili.com/ranking", requiresApiKey: false, supportedFeatures: [.hotTrends], color: .pink),
        AIContact(id: "youtube", name: "油管", description: "YouTube热门视频", model: "platform-youtube", avatar: "play.rectangle.fill", isOnline: true, apiEndpoint: "https://www.youtube.com/feed/trending", requiresApiKey: false, supportedFeatures: [.hotTrends], color: .red),
        AIContact(id: "jike", name: "即刻", description: "即刻热门动态", model: "platform-jike", avatar: "bolt.fill", isOnline: true, apiEndpoint: "https://web.okjike.com/", requiresApiKey: false, supportedFeatures: [.hotTrends], color: .yellow),
        AIContact(id: "baijiahao", name: "百家号", description: "百度百家号热文", model: "platform-baijiahao", avatar: "doc.text.fill", isOnline: true, apiEndpoint: "https://baijiahao.baidu.com/", requiresApiKey: false, supportedFeatures: [.hotTrends], color: .blue),
        AIContact(id: "xigua", name: "西瓜", description: "西瓜视频热门内容", model: "platform-xigua", avatar: "play.circle.fill", isOnline: true, apiEndpoint: "https://www.ixigua.com/", requiresApiKey: false, supportedFeatures: [.hotTrends], color: .green),
        AIContact(id: "ximalaya", name: "喜马拉雅", description: "音频内容热门推荐", model: "platform-ximalaya", avatar: "waveform", isOnline: true, apiEndpoint: "https://www.ximalaya.com/", requiresApiKey: false, supportedFeatures: [.hotTrends], color: .orange)
    ]

    // 已启用的联系人列表
    var enabledContacts: [AIContact] {
        return contacts.filter { contact in
            // 平台联系人：检查是否在联系人管理器中启用
            if contact.supportedFeatures.contains(.hotTrends) {
                return contactsManager.isContactEnabled(contact.id)
            }
            // AI助手：需要有API配置且在联系人管理器中启用
            else {
                return apiManager.hasAPIKey(for: contact.id) && contactsManager.isContactEnabled(contact.id)
            }
        }
    }

    var filteredContacts: [AIContact] {
        let filtered = enabledContacts.filter { contact in
            !apiManager.isHidden(contact.id) &&
            (searchText.isEmpty || contact.name.localizedCaseInsensitiveContains(searchText) || contact.description.localizedCaseInsensitiveContains(searchText))
        }

        return filtered.sorted { contact1, contact2 in
            let pinned1 = apiManager.isPinned(contact1.id)
            let pinned2 = apiManager.isPinned(contact2.id)

            if pinned1 && !pinned2 {
                return true
            } else if !pinned1 && pinned2 {
                return false
            } else {
                return contact1.name < contact2.name
            }
        }
    }

    var body: some View {
        NavigationView {
            Group {
                if showingDirectChat, let contact = currentContact {
                    // 显示单个AI聊天界面
                    ChatView(contact: contact, onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingDirectChat = false
                            currentContact = nil
                        }
                    })
                    .navigationBarHidden(true)
                } else if showingMultiAIChat {
                    // 显示多AI同步聊天界面
                    MultiAIChatView(
                        selectedContacts: contacts.filter { apiManager.hasAPIKey(for: $0.id) },
                        onBack: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingMultiAIChat = false
                            }
                        }
                    )
                    .navigationBarHidden(true)
                } else {
                    // 显示AI联系人列表（包含平台联系人）
                    AIContactsListView()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onReceive(NotificationCenter.default.publisher(for: .showAIAssistant)) { notification in
            if let assistantId = notification.object as? String {
                startDirectChat(with: assistantId)
            }
        }

    }

    // AI联系人列表视图
    func AIContactsListView() -> some View {
        VStack(spacing: 0) {
            // 智能搜索框
            SmartSearchBar(
                searchText: $searchText,
                contacts: contacts,
                onMultiAISearch: { query in
                    startMultiAISearch(with: query)
                },
                onHistorySearch: { query in
                    searchChatHistory(with: query)
                }
            )
            .padding(.horizontal)
            .padding(.top, 8)

            // 工具栏
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showDetailedInfo.toggle()
                    }
                }) {
                    Text(showDetailedInfo ? "简洁模式" : "详细信息")
                        .font(.caption)
                        .foregroundColor(.themeGreen)
                }

                Spacer()

                Button(action: {
                    showingContactsManagement = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.circle")
                        Text("管理")
                    }
                    .font(.caption)
                    .foregroundColor(.themeGreen)
                }

                Button(action: {
                    showingAPIConfig = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.themeGreen)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // 联系人列表
            List(filteredContacts, id: \.id) { contact in
                ContactRow(
                    contact: contact,
                    hasAPIKey: apiManager.hasAPIKey(for: contact.id),
                    isPinned: apiManager.isPinned(contact.id),
                    showDetailedInfo: showDetailedInfo,
                    onTap: {
                        if canEnterChat(contact) {
                            currentContact = contact
                            showingDirectChat = true
                        } else {
                            showAPIConfigAlert(for: contact)
                        }
                    },
                    onConfigAPI: {
                        selectedContactForAPI = contact
                        showingContactAPIConfig = true
                    },
                    onPin: {
                        apiManager.setPinned(contact.id, pinned: !apiManager.isPinned(contact.id))
                    },
                    onHide: {
                        apiManager.setHidden(contact.id, hidden: true)
                    }
                )
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("AI助手")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingAPIConfig) {
            APIConfigView()
        }
        .sheet(isPresented: $showingContactAPIConfig) {
            if let contact = selectedContactForAPI {
                SingleContactAPIConfigView(contact: contact)
            }
        }
        .sheet(isPresented: $showingContactsManagement) {
            SimpleContactsManagementView()
        }
    }

    private func startDirectChat(with assistantId: String) {
        selectedAssistantId = assistantId

        // 查找对应的AI联系人
        if let contact = contacts.first(where: { $0.id == assistantId }) {
            currentContact = contact
            showingDirectChat = true
        }
    }

    private func canEnterChat(_ contact: AIContact) -> Bool {
        return !contact.requiresApiKey || apiManager.hasAPIKey(for: contact.id)
    }

    private func showAPIConfigAlert(for contact: AIContact) {
        let alert = UIAlertController(
            title: "需要配置API密钥",
            message: "使用\(contact.name)需要先配置API密钥。是否前往设置？",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "去设置", style: .default) { _ in
            selectedContactForAPI = contact
            showingContactAPIConfig = true
        })

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }

    private func startMultiAISearch(with query: String) {
        // 自动选择有API密钥的AI进行搜索
        let availableContacts = contacts.filter { apiManager.hasAPIKey(for: $0.id) }

        // 启动多AI聊天并自动发送查询
        showingMultiAIChat = true

        // 延迟发送消息，等待界面加载完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: .sendMultiAIQuery, object: (query, availableContacts))
        }
    }

    private func searchChatHistory(with query: String) {
        // 搜索聊天历史记录
        // 这里可以实现历史记录搜索功能
        print("🔍 搜索聊天历史: \(query)")
        // TODO: 实现历史记录搜索
    }
}

// MARK: - 智能搜索框组件
struct SmartSearchBar: View {
    @Binding var searchText: String
    let contacts: [AIContact]
    let onMultiAISearch: (String) -> Void
    let onHistorySearch: (String) -> Void

    @State private var searchQuery = ""
    @State private var showingPromptPicker = false
    @State private var showingPreview = false
    @State private var isSearching = false

    var body: some View {
        VStack(spacing: 0) {
            // 主搜索框
            HStack(spacing: 8) {
                // 搜索图标
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.themeGreen)
                    .font(.title3)

                // 输入框
                TextField("输入问题，向所有AI提问...", text: $searchQuery)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        handleSearch()
                    }
                    .onChange(of: searchQuery) { newQuery in
                        searchText = newQuery
                        showingPreview = !newQuery.isEmpty
                    }

                // 清除按钮
                if !searchQuery.isEmpty {
                    Button(action: {
                        searchQuery = ""
                        searchText = ""
                        showingPreview = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }

                // Prompt选择器按钮
                Button(action: {
                    showingPromptPicker = true
                }) {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.themeLightGreen)
                        .font(.title3)
                }

                // 搜索按钮
                Button(action: handleSearch) {
                    if isSearching {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(searchQuery.isEmpty ? .gray : .blue)
                            .font(.title3)
                    }
                }
                .disabled(searchQuery.isEmpty || isSearching)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // 预览浮框
            if showingPreview && !searchQuery.isEmpty {
                SearchPreviewCard(
                    query: searchQuery,
                    contacts: contacts,
                    onAISearch: {
                        handleSearch()
                    },
                    onHistorySearch: {
                        onHistorySearch(searchQuery)
                    }
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.3), value: showingPreview)
            }
        }
        .sheet(isPresented: $showingPromptPicker) {
            PromptPickerView { selectedPrompt in
                searchQuery = selectedPrompt
            }
        }
    }

    private func handleSearch() {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isSearching = true
        showingPreview = false

        // 向所有AI提问
        onMultiAISearch(searchQuery)

        // 重置状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isSearching = false
        }
    }
}

// MARK: - 搜索预览卡片
struct SearchPreviewCard: View {
    let query: String
    let contacts: [AIContact]
    let onAISearch: () -> Void
    let onHistorySearch: () -> Void

    private var availableAIs: [AIContact] {
        contacts.filter { APIConfigManager.shared.hasAPIKey(for: $0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // AI搜索预览
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.themeGreen)
                    Text("AI搜索")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(availableAIs.count)个AI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text("向所有可用AI同时提问")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // 显示前几个可用AI
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(availableAIs.prefix(5), id: \.id) { contact in
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(contact.color)
                                    .frame(width: 12, height: 12)
                                Text(contact.name)
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                        }

                        if availableAIs.count > 5 {
                            Text("+\(availableAIs.count - 5)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Button(action: onAISearch) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("向所有AI提问")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.themeGreen)
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(.systemBackground))

            Divider()

            // 历史搜索预览
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.themeLightGreen)
                    Text("历史记录")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }

                Text("搜索聊天历史记录")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Button(action: onHistorySearch) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("搜索历史")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.themeLightGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.themeLightGreen.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 4)
        .padding(.top, 8)
    }
}

// MARK: - 联系人行组件
struct ContactRow: View {
    let contact: AIContact
    let hasAPIKey: Bool
    let isPinned: Bool
    let showDetailedInfo: Bool
    let onTap: () -> Void
    let onConfigAPI: () -> Void
    let onPin: () -> Void
    let onHide: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // AI头像
            ZStack {
                Circle()
                    .fill(contact.color)
                    .frame(width: 50, height: 50)

                Image(systemName: contact.avatar)
                    .font(.title2)
                    .foregroundColor(.white)
            }

            // 联系人信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(contact.name)
                        .font(.headline)
                        .fontWeight(.medium)

                    if isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundColor(.themeLightGreen)
                    }

                    Spacer()

                    // API状态指示器
                    Circle()
                        .fill(hasAPIKey ? Color.themeSuccessGreen : Color.themeErrorRed)
                        .frame(width: 8, height: 8)
                }

                Text(getLastMessagePreview(for: contact.id))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(showDetailedInfo ? nil : 1)

                if showDetailedInfo {
                    HStack {
                        ForEach(contact.supportedFeatures.prefix(3), id: \.self) { feature in
                            Text(feature.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray5))
                                .cornerRadius(4)
                        }

                        if contact.supportedFeatures.count > 3 {
                            Text("+\(contact.supportedFeatures.count - 3)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Spacer()

            // 状态指示器
            VStack(spacing: 4) {
                if hasAPIKey {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                }

                Text(hasAPIKey ? "已配置" : "需配置")
                    .font(.caption2)
                    .foregroundColor(hasAPIKey ? .green : .red)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .contextMenu {
            Button(action: onConfigAPI) {
                Label("配置API", systemImage: "key.fill")
            }

            Button(action: onPin) {
                Label(isPinned ? "取消置顶" : "置顶", systemImage: isPinned ? "pin.slash.fill" : "pin.fill")
            }

            Button(action: onHide) {
                Label("隐藏", systemImage: "eye.slash.fill")
            }
        }
    }

    private func getLastMessagePreview(for contactId: String) -> String {
        let key = "chat_history_\(contactId)"
        if let data = UserDefaults.standard.data(forKey: key),
           let savedMessages = try? JSONDecoder().decode([ChatMessage].self, from: data),
           let lastMessage = savedMessages.last {

            // 清理内容并截取预览
            let cleanedContent = lastMessage.content
                .replacingOccurrences(of: "\n", with: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if cleanedContent.count > 50 {
                return String(cleanedContent.prefix(50)) + "..."
            } else {
                return cleanedContent.isEmpty ? "暂无对话" : cleanedContent
            }
        }

        return "暂无对话"
    }
}

// MARK: - 简化Markdown文本组件
struct SimpleMarkdownText: View {
    let content: String
    let isFromUser: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(parseSimpleMarkdown(content), id: \.id) { element in
                renderMarkdownElement(element)
            }
        }
    }

    private func renderMarkdownElement(_ element: SimpleMarkdownElement) -> some View {
        Group {
            switch element.type {
            case .heading:
                Text(element.content)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(isFromUser ? .white : .primary)

            case .code:
                Text(element.content)
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(4)
                    .foregroundColor(.primary)

            case .codeBlock:
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("代码")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(action: {
                            UIPasteboard.general.string = element.content
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(element.content)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 12)
                            .padding(.bottom, 8)
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)

            case .list:
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(element.listItems, id: \.self) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(isFromUser ? .white : .primary)
                            Text(item)
                                .foregroundColor(isFromUser ? .white : .primary)
                            Spacer()
                        }
                    }
                }

            case .text:
                Text(element.content)
                    .foregroundColor(isFromUser ? .white : .primary)
            }
        }
    }
}

struct SimpleMarkdownElement {
    let id = UUID()
    let type: SimpleMarkdownType
    let content: String
    let listItems: [String]

    init(type: SimpleMarkdownType, content: String, listItems: [String] = []) {
        self.type = type
        self.content = content
        self.listItems = listItems
    }
}

enum SimpleMarkdownType {
    case heading, code, codeBlock, list, text
}

func parseSimpleMarkdown(_ content: String) -> [SimpleMarkdownElement] {
    var elements: [SimpleMarkdownElement] = []
    let lines = content.components(separatedBy: .newlines)
    var i = 0

    while i < lines.count {
        let line = lines[i].trimmingCharacters(in: .whitespaces)

        if line.isEmpty {
            i += 1
            continue
        }

        // 代码块
        if line.hasPrefix("```") {
            var codeContent = ""
            i += 1

            while i < lines.count && !lines[i].hasPrefix("```") {
                codeContent += lines[i] + "\n"
                i += 1
            }

            elements.append(SimpleMarkdownElement(
                type: .codeBlock,
                content: codeContent.trimmingCharacters(in: .newlines)
            ))
            i += 1
            continue
        }

        // 标题
        if line.hasPrefix("#") {
            let content = line.replacingOccurrences(of: #"^#+\s*"#, with: "", options: .regularExpression)
            elements.append(SimpleMarkdownElement(type: .heading, content: content))
        }
        // 列表
        else if line.hasPrefix("- ") || line.hasPrefix("* ") {
            var listItems: [String] = []
            while i < lines.count && (lines[i].hasPrefix("- ") || lines[i].hasPrefix("* ")) {
                let item = String(lines[i].dropFirst(2)).trimmingCharacters(in: .whitespaces)
                listItems.append(item)
                i += 1
            }
            elements.append(SimpleMarkdownElement(type: .list, content: "", listItems: listItems))
            continue
        }
        // 内联代码处理
        else if line.contains("`") {
            let processedElements = processInlineCode(line)
            elements.append(contentsOf: processedElements)
        }
        // 普通文本
        else {
            elements.append(SimpleMarkdownElement(type: .text, content: line))
        }

        i += 1
    }

    return elements
}

func processInlineCode(_ text: String) -> [SimpleMarkdownElement] {
    var elements: [SimpleMarkdownElement] = []
    let codePattern = #"`([^`]+)`"#

    if let regex = try? NSRegularExpression(pattern: codePattern) {
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))

        if !matches.isEmpty {
            var lastEnd = text.startIndex

            for match in matches {
                let range = Range(match.range, in: text)!
                let codeRange = Range(match.range(at: 1), in: text)!

                // 添加代码前的文本
                if lastEnd < range.lowerBound {
                    let beforeText = String(text[lastEnd..<range.lowerBound])
                    if !beforeText.isEmpty {
                        elements.append(SimpleMarkdownElement(type: .text, content: beforeText))
                    }
                }

                // 添加代码
                let codeText = String(text[codeRange])
                elements.append(SimpleMarkdownElement(type: .code, content: codeText))

                lastEnd = range.upperBound
            }

            // 添加剩余文本
            if lastEnd < text.endIndex {
                let remainingText = String(text[lastEnd...])
                if !remainingText.isEmpty {
                    elements.append(SimpleMarkdownElement(type: .text, content: remainingText))
                }
            }

            return elements
        }
    }

    // 如果没有代码，直接返回文本
    elements.append(SimpleMarkdownElement(type: .text, content: text))
    return elements
}

// MARK: - 多AI聊天视图
struct MultiAIChatView: View {
    let selectedContacts: [AIContact]
    let onBack: () -> Void
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isLoading = false
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        VStack(spacing: 0) {
            // 自定义导航栏
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .fontWeight(.medium)
                        Text("返回")
                            .font(.body)
                    }
                    .foregroundColor(.themeGreen)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("多AI对话")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("\(selectedContacts.count)个AI助手")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: onBack) {
                    Text("完成")
                        .foregroundColor(.themeGreen)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(.separator)),
                alignment: .bottom
            )

            // 顶部AI列表
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(selectedContacts, id: \.id) { contact in
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(contact.color)
                                    .frame(width: 40, height: 40)

                                Image(systemName: contact.avatar)
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }

                            Text(contact.name)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color(.systemGray6))

            Divider()

            // 聊天消息列表
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        MultiAIChatMessageRow(message: message)
                    }

                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("AI们正在思考...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }

            Divider()

            // 输入区域
            HStack(spacing: 12) {
                TextField("向\(selectedContacts.count)个AI提问...", text: $messageText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...4)

                Button(action: sendToAllAIs) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(messageText.isEmpty ? .gray : .blue)
                        .font(.title2)
                }
                .disabled(messageText.isEmpty || isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .offset(x: dragOffset.width)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.width > 0 {
                        dragOffset = value.translation
                    }
                }
                .onEnded { value in
                    if value.translation.width > 100 {
                        onBack()
                    } else {
                        withAnimation(.spring()) {
                            dragOffset = .zero
                        }
                    }
                }
        )
        .onReceive(NotificationCenter.default.publisher(for: .sendMultiAIQuery)) { notification in
            if let (query, _) = notification.object as? (String, [AIContact]) {
                messageText = query
                sendToAllAIs()
            }
        }
    }

    private func sendToAllAIs() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = ChatMessage(
            id: UUID().uuidString,
            content: messageText,
            isFromUser: true,
            timestamp: Date(),
            status: .sent,
            actions: []
        )

        messages.append(userMessage)
        let currentMessage = messageText
        messageText = ""
        isLoading = true

        // 模拟多个AI同时响应
        for (index, contact) in selectedContacts.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index + 1) * 0.5) {
                let aiResponse = ChatMessage(
                    id: UUID().uuidString,
                    content: generateAIResponse(for: currentMessage, from: contact),
                    isFromUser: false,
                    timestamp: Date(),
                    status: .sent,
                    actions: [],
                    aiSource: contact.name
                )
                messages.append(aiResponse)

                if index == selectedContacts.count - 1 {
                    isLoading = false
                }
            }
        }
    }

    private func generateAIResponse(for message: String, from contact: AIContact) -> String {
        let responses = [
            "[\(contact.name)] 我理解您的问题，让我来帮助您。",
            "[\(contact.name)] 这是一个很好的问题，我来为您详细解答。",
            "[\(contact.name)] 根据您的描述，我建议您可以尝试以下方法。",
            "[\(contact.name)] 感谢您的提问，我很乐意为您提供帮助。",
            "[\(contact.name)] 这个问题很有意思，让我来分析一下。"
        ]
        return responses.randomElement() ?? "[\(contact.name)] 我正在思考您的问题，请稍等。"
    }
}

// MARK: - 多AI聊天消息行
struct MultiAIChatMessageRow: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.themeGreen)
                        .foregroundColor(.white)
                        .cornerRadius(18)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)

                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        if let aiSource = message.aiSource {
                            Text(aiSource)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.themeGreen)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }

                        Spacer()

                        Text(formatTime(message.timestamp))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(18)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                }

                Spacer()
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - API配置视图
struct APIConfigView: View {
    @StateObject private var apiManager = APIConfigManager.shared
    @Environment(\.presentationMode) var presentationMode

    // 只显示需要API配置的AI助手，不包含平台联系人
    let services = [
        // 🇨🇳 国内主流AI服务商
        ("deepseek", "DeepSeek"),
        ("qwen", "通义千问"),
        ("chatglm", "智谱清言"),
        ("moonshot", "Kimi"),
        ("doubao", "豆包"),
        ("wenxin", "文心一言"),
        ("spark", "讯飞星火"),
        ("baichuan", "百川智能"),
        ("minimax", "MiniMax"),
        ("siliconflow-qwen", "千问-硅基流动"),

        // 🌍 国际AI服务商
        ("openai", "OpenAI ChatGPT"),
        ("claude", "Anthropic Claude"),
        ("gemini", "Google Gemini"),

        // ⚡ 高性能推理
        ("groq", "Groq"),
        ("together", "Together AI"),
        ("perplexity", "Perplexity"),

        // 🎨 专业工具
        ("dalle", "DALL-E"),
        ("midjourney", "Midjourney"),
        ("stablediffusion", "Stable Diffusion"),
        ("elevenlabs", "ElevenLabs"),
        ("whisper", "Whisper")
    ]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("AI服务API配置")) {
                    ForEach(services, id: \.0) { serviceId, serviceName in
                        APIConfigRow(
                            serviceId: serviceId,
                            serviceName: serviceName,
                            apiKey: Binding(
                                get: { apiManager.apiKeys[serviceId] ?? "" },
                                set: { apiManager.setAPIKey(for: serviceId, key: $0) }
                            )
                        )
                    }
                }

                Section(footer: Text("API密钥将安全存储在本地设备上。请从各AI服务商官网获取API密钥。")) {
                    EmptyView()
                }
            }
            .navigationTitle("API配置")
            .navigationBarItems(
                leading: Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct APIConfigRow: View {
    let serviceId: String
    let serviceName: String
    @Binding var apiKey: String
    @State private var isSecure = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(serviceName)
                .font(.headline)

            HStack {
                Group {
                    if isSecure {
                        SecureField("输入API密钥", text: $apiKey)
                    } else {
                        TextField("输入API密钥", text: $apiKey)
                    }
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    isSecure.toggle()
                }) {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }

            if !apiKey.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("已配置")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 单个联系人API配置视图
struct SingleContactAPIConfigView: View {
    let contact: AIContact
    @StateObject private var apiManager = APIConfigManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var apiKey: String = ""
    @State private var isSecure = true

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 联系人信息
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(contact.color)
                            .frame(width: 80, height: 80)

                        Image(systemName: contact.avatar)
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }

                    Text(contact.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(contact.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)

                // API配置
                VStack(alignment: .leading, spacing: 16) {
                    Text("API密钥配置")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("API密钥")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack {
                            Group {
                                if isSecure {
                                    SecureField("输入API密钥", text: $apiKey)
                                } else {
                                    TextField("输入API密钥", text: $apiKey)
                                }
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                            Button(action: {
                                isSecure.toggle()
                            }) {
                                Image(systemName: isSecure ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    if !apiKey.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("API密钥已配置")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }

                    Button(action: {
                        apiManager.setAPIKey(for: contact.id, key: apiKey)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("保存配置")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(apiKey.isEmpty ? Color.gray : Color.themeGreen)
                            .cornerRadius(10)
                    }
                    .disabled(apiKey.isEmpty)
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .navigationTitle("API配置")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            apiKey = apiManager.getAPIKey(for: contact.id) ?? ""
        }
    }
}

// MARK: - Prompt选择器视图
struct PromptPickerView: View {
    let onPromptSelected: (String) -> Void
    @Environment(\.presentationMode) var presentationMode

    private let presetPrompts = [
        ("编程助手", "请帮我解决这个编程问题："),
        ("文案写作", "请帮我写一篇关于以下主题的文章："),
        ("学习助手", "请详细解释以下概念："),
        ("翻译助手", "请将以下内容翻译成中文："),
        ("创意灵感", "请为以下主题提供创意想法："),
        ("问题分析", "请分析以下问题并提供解决方案："),
        ("代码审查", "请审查以下代码并提供改进建议："),
        ("技术解释", "请用简单易懂的方式解释："),
        ("市场分析", "请分析以下市场趋势："),
        ("产品设计", "请为以下需求设计产品方案：")
    ]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("预设Prompt模板")) {
                    ForEach(presetPrompts, id: \.0) { prompt in
                        Button(action: {
                            onPromptSelected(prompt.1)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(prompt.0)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text(prompt.1)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section(header: Text("自定义Prompt")) {
                    Button(action: {
                        // TODO: 实现自定义prompt功能
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.themeGreen)
                            Text("创建自定义Prompt")
                                .foregroundColor(.themeGreen)
                        }
                    }
                }
            }
            .navigationTitle("选择Prompt")
            .navigationBarItems(
                trailing: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - 搜索引擎卡片组件
struct SearchEngineCard: View {
    let engine: (String, String, String, Color)
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: engine.2)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(engine.3)

                Text(engine.1)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundColor(.primary)

                // 选中状态指示器
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.caption)
                    .foregroundColor(isSelected ? .green : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? engine.3.opacity(0.15) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? engine.3 : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - 通知名称扩展
extension Notification.Name {
    static let sendMultiAIQuery = Notification.Name("sendMultiAIQuery")
    static let showPlatformHotTrends = Notification.Name("showPlatformHotTrends")
    static let editMessage = Notification.Name("editMessage")
    static let toggleFavorite = Notification.Name("toggleFavorite")
    static let shareMessage = Notification.Name("shareMessage")
    static let forwardMessage = Notification.Name("forwardMessage")
    static let deleteMessage = Notification.Name("deleteMessage")
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - 分类按钮组件
struct CategoryButton: View {
    let category: CategoryConfig
    let isSelected: Bool
    let customAppsCount: Int?
    let screenHeight: CGFloat
    let action: () -> Void

    @State private var isPressed = false

    // 根据屏幕高度计算按钮尺寸
    private var buttonHeight: CGFloat {
        let baseHeight: CGFloat = 36
        let maxCategories: CGFloat = 14
        let availableHeight = screenHeight - 120 // 减去标题和边距
        let calculatedHeight = availableHeight / maxCategories
        return max(min(calculatedHeight, 50), 32) // 最小32，最大50
    }

    private var fontSize: CGFloat {
        buttonHeight > 40 ? 13 : 11
    }

    private var iconSize: CGFloat {
        buttonHeight > 40 ? 14 : 12
    }

    var body: some View {
        Button(action: {
            // 苹果风格的触觉反馈
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            action()
        }) {
            HStack(spacing: 6) {
                // 图标
                Image(systemName: category.icon)
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: iconSize + 4)

                // 分类名称
                VStack(alignment: .leading, spacing: 1) {
                    Text(category.name)
                        .font(.system(size: fontSize, weight: .medium))
                        .foregroundColor(textColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    // 自定义分类显示应用数量
                    if let count = customAppsCount {
                        Text("\(count)个")
                            .font(.system(size: fontSize - 2))
                            .foregroundColor(subtextColor)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(height: buttonHeight)
            .background(backgroundView)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 4)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }

    // 计算颜色
    private var iconColor: Color {
        if isSelected {
            return .white
        } else {
            return category.color
        }
    }

    private var textColor: Color {
        if isSelected {
            return .white
        } else {
            return .primary
        }
    }

    private var subtextColor: Color {
        if isSelected {
            return .white.opacity(0.8)
        } else {
            return .secondary
        }
    }

    // 背景视图
    private var backgroundView: some View {
        Group {
            if isSelected {
                // 选中状态：绿色背景
                RoundedRectangle(cornerRadius: 8)
                    .fill(category.color)
                    .shadow(color: category.color.opacity(0.3), radius: 1, x: 0, y: 1)
            } else {
                // 未选中状态：淡绿色背景 + 边框
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(category.color.opacity(0.15), lineWidth: 0.5)
                    )
            }
        }
    }
}

// MARK: - 分类编辑器视图
struct CategoryEditorView: View {
    @Binding var categories: [CategoryConfig]
    @Binding var customApps: [String]
    let allApps: [AppInfo]
    @Environment(\.presentationMode) var presentationMode
    @State private var editingCategory: CategoryConfig?
    @State private var showingColorPicker = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 分类列表
                List {
                    Section(header: Text("分类管理")) {
                        ForEach(categories.sorted { $0.order < $1.order }) { category in
                            CategoryEditRow(
                                category: category,
                                onEdit: {
                                    editingCategory = category
                                    showingColorPicker = true
                                },
                                onMoveUp: {
                                    moveCategory(category, direction: -1)
                                },
                                onMoveDown: {
                                    moveCategory(category, direction: 1)
                                }
                            )
                        }
                    }

                    Section(header: Text("使用说明")) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "hand.tap.fill")
                                    .foregroundColor(.themeGreen)
                                Text("点击分类按钮切换分类")
                                    .font(.system(size: 14))
                                Spacer()
                            }

                            HStack {
                                Image(systemName: "hand.point.up.left.fill")
                                    .foregroundColor(.themeLightGreen)
                                Text("长按应用图标添加到自定义分类")
                                    .font(.system(size: 14))
                                Spacer()
                            }

                            HStack {
                                Image(systemName: "paintpalette.fill")
                                    .foregroundColor(Color(red: 0.2, green: 0.7, blue: 0.3))
                                Text("点击调色板按钮自定义分类外观")
                                    .font(.system(size: 14))
                                Spacer()
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("分类设置")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("完成") {
                    saveCategoryConfigs()
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $showingColorPicker) {
                if let category = editingCategory {
                    CategoryColorPickerView(category: category) { updatedCategory in
                        updateCategory(updatedCategory)
                    }
                }
            }
        }
    }

    private func moveCategory(_ category: CategoryConfig, direction: Int) {
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }

        let newOrder = category.order + direction
        if newOrder >= 0 && newOrder < categories.count {
            // 找到目标位置的分类并交换order
            if let targetIndex = categories.firstIndex(where: { $0.order == newOrder }) {
                categories[targetIndex].order = category.order
                categories[index].order = newOrder
            }
        }
    }

    private func updateCategory(_ updatedCategory: CategoryConfig) {
        if let index = categories.firstIndex(where: { $0.id == updatedCategory.id }) {
            categories[index] = updatedCategory
        }
    }



    private func saveCategoryConfigs() {
        if let data = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(data, forKey: "CategoryConfigs")
        }
        UserDefaults.standard.set(customApps, forKey: "CustomApps")
    }
}

// MARK: - 分类编辑行
struct CategoryEditRow: View {
    let category: CategoryConfig
    let onEdit: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // 图标和颜色
            Image(systemName: category.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(category.color)
                .frame(width: 24)

            // 分类信息
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.system(size: 15, weight: .medium))

                Text("顺序: \(category.order)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            // 操作按钮
            HStack(spacing: 8) {
                Button(action: onMoveUp) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 12))
                        .foregroundColor(.themeGreen)
                }

                Button(action: onMoveDown) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.themeGreen)
                }

                Button(action: onEdit) {
                    Image(systemName: "paintpalette")
                        .font(.system(size: 12))
                        .foregroundColor(.themeLightGreen)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 自定义应用行
struct CustomAppRow: View {
    let app: AppInfo
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // 应用图标
            ZStack {
                Circle()
                    .fill(app.color)
                    .frame(width: 32, height: 32)

                Text(app.icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }

            // 应用信息
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.system(size: 14, weight: .medium))

                Text(app.category)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }

            Spacer()

            // 选择状态
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20))
                .foregroundColor(isSelected ? .blue : .gray)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }
}

// MARK: - 颜色选择器视图
struct CategoryColorPickerView: View {
    let category: CategoryConfig
    let onSave: (CategoryConfig) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedColor: Color
    @State private var selectedIcon: String

    let availableColors: [Color] = [
        .green, Color(red: 0.2, green: 0.7, blue: 0.3), Color(red: 0.3, green: 0.8, blue: 0.4), Color(red: 0.1, green: 0.6, blue: 0.2),
        .primary, .black, .gray, .secondary,
        Color(.systemGreen), Color(.systemMint), Color(.systemTeal), Color(.systemCyan)
    ]

    let availableIcons: [String] = [
        "star.fill", "heart.fill", "bookmark.fill", "flag.fill",
        "tag.fill", "folder.fill", "doc.fill", "photo.fill",
        "music.note", "video.fill", "gamecontroller.fill", "car.fill",
        "house.fill", "person.fill", "globe", "gear"
    ]

    init(category: CategoryConfig, onSave: @escaping (CategoryConfig) -> Void) {
        self.category = category
        self.onSave = onSave
        self._selectedColor = State(initialValue: category.color)
        self._selectedIcon = State(initialValue: category.icon)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 预览
                VStack(spacing: 16) {
                    Text("预览效果")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)

                    VStack(spacing: 12) {
                        // 未选中状态预览
                        HStack(spacing: 8) {
                            Image(systemName: selectedIcon)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedColor)
                                .frame(width: 20)

                            Text(category.name)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedColor.opacity(0.2), lineWidth: 0.5)
                                )
                        )

                        Text("未选中状态")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        // 选中状态预览
                        HStack(spacing: 8) {
                            Image(systemName: selectedIcon)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 20)

                            Text(category.name)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)

                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedColor)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        )

                        Text("选中状态")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(16)

                // 颜色选择
                VStack(alignment: .leading, spacing: 16) {
                    Text("选择颜色")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(availableColors, id: \.self) { color in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedColor = color
                                }
                                // 触觉反馈
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                            }) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(color)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.primary, lineWidth: selectedColor == color ? 2 : 0)
                                    )
                                    .overlay(
                                        // 选中状态的勾选标记
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(color == .black || color == .primary ? .white : .black)
                                            .opacity(selectedColor == color ? 1 : 0)
                                    )
                                    .scaleEffect(selectedColor == color ? 1.05 : 1.0)
                                    .shadow(color: .black.opacity(0.08), radius: selectedColor == color ? 3 : 1, x: 0, y: 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }

                // 图标选择
                VStack(alignment: .leading, spacing: 12) {
                    Text("选择图标")
                        .font(.headline)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.system(size: 20))
                                .foregroundColor(selectedIcon == icon ? selectedColor : .gray)
                                .frame(width: 32, height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.clear)
                                )
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("编辑分类")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    var updatedCategory = category
                    updatedCategory.color = selectedColor
                    updatedCategory.icon = selectedIcon
                    onSave(updatedCategory)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - 平台热榜数据模型

struct HotTrendItem: Identifiable, Codable {
    let id: String
    let title: String
    let description: String?
    let rank: Int
    let hotValue: String?
    let url: String?
    let imageURL: String?
    let category: String?
    let timestamp: Date
    let platform: String
}

struct HotTrendsList: Codable {
    let platform: String
    let updateTime: Date
    let items: [HotTrendItem]
    let totalCount: Int
}



// MARK: - HotTrendItem 扩展
extension HotTrendItem {
    var displayRank: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }

    var isTopThree: Bool {
        return rank <= 3
    }
}





// MARK: - 热榜管理器协议和工厂
protocol HotTrendsManagerProtocol: ObservableObject {
    var hotTrends: [String: HotTrendsList] { get }
    var isLoading: [String: Bool] { get }
    var lastUpdateTime: [String: Date] { get }

    func getHotTrends(for platform: String) -> HotTrendsList?
    func refreshHotTrends(for platform: String)
    func refreshAllHotTrends()
    func shouldUpdate(platform: String) -> Bool
    func getPerformanceStats() -> [String: Any]
    func clearCache()
}

// 创建热榜管理器的工厂函数
func createHotTrendsManager() -> any HotTrendsManagerProtocol {
    // 暂时使用模拟实现，确保编译通过
    return MockHotTrendsManager.shared
}

// 简化的热榜管理器实现
class MockHotTrendsManager: ObservableObject, HotTrendsManagerProtocol {
    static let shared = MockHotTrendsManager()
    @Published var hotTrends: [String: HotTrendsList] = [:]
    @Published var isLoading: [String: Bool] = [:]
    @Published var lastUpdateTime: [String: Date] = [:]

    init() {
        // 初始化时生成一些示例数据
        initializeWithSampleData()
    }

    private func initializeWithSampleData() {
        // 初始化前几个平台的示例数据
        let platformIds = ["douyin", "xiaohongshu", "bilibili"]
        for platformId in platformIds {
            hotTrends[platformId] = generateMockData(for: platformId)
            lastUpdateTime[platformId] = Date()
        }
    }

    func getHotTrends(for platform: String) -> HotTrendsList? {
        return hotTrends[platform]
    }

    func refreshHotTrends(for platform: String) {
        isLoading[platform] = true

        // 模拟数据生成
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.hotTrends[platform] = self.generateMockData(for: platform)
            self.lastUpdateTime[platform] = Date()
            self.isLoading[platform] = false
        }
    }

    func refreshAllHotTrends() {
        // 所有平台ID列表
        let platformIds = ["douyin", "xiaohongshu", "wechat_mp", "weixin_channels", "toutiao", "bilibili", "youtube", "jike", "baijiahao", "xigua", "ximalaya"]
        for platformId in platformIds {
            refreshHotTrends(for: platformId)
        }
    }

    func shouldUpdate(platform: String) -> Bool {
        guard let lastUpdate = lastUpdateTime[platform] else { return true }
        return Date().timeIntervalSince(lastUpdate) > 1800 // 30分钟
    }

    func getPerformanceStats() -> [String: Any] {
        return [
            "cached_platforms": hotTrends.keys.count,
            "loading_platforms": isLoading.filter { $0.value }.keys.count,
            "last_update_count": lastUpdateTime.count,
            "memory_usage": hotTrends.values.reduce(0) { $0 + $1.items.count }
        ]
    }

    func clearCache() {
        hotTrends.removeAll()
        lastUpdateTime.removeAll()
    }

    private func generateMockData(for platform: String) -> HotTrendsList {
        // 平台ID到名称的映射
        let platformNames: [String: String] = [
            "douyin": "抖音",
            "xiaohongshu": "小红书",
            "wechat_mp": "公众号",
            "weixin_channels": "视频号",
            "toutiao": "今日头条",
            "bilibili": "B站",
            "youtube": "油管",
            "jike": "即刻",
            "baijiahao": "百家号",
            "xigua": "西瓜",
            "ximalaya": "喜马拉雅"
        ]
        let platformName = platformNames[platform] ?? platform

        let mockItems = (1...10).map { index in
            HotTrendItem(
                id: "\(platform)_\(index)",
                title: "\(platformName)热门内容 \(index)",
                description: "这是\(platformName)的热门内容描述",
                rank: index,
                hotValue: "🔥 热门",
                url: nil,
                imageURL: nil,
                category: "热门",
                timestamp: Date(),
                platform: platform
            )
        }

        return HotTrendsList(
            platform: platform,
            updateTime: Date(),
            items: mockItems,
            totalCount: mockItems.count
        )
    }
}

// MARK: - 简化的联系人管理器
class SimpleContactsManager: ObservableObject {
    static let shared = SimpleContactsManager()

    @Published var enabledContacts: Set<String> = []

    private init() {
        loadContactSettings()
    }

    func loadContactSettings() {
        if let data = UserDefaults.standard.data(forKey: "enabled_contacts"),
           let contacts = try? JSONDecoder().decode(Set<String>.self, from: data) {
            enabledContacts = contacts
        } else {
            // 默认启用所有平台联系人和主要AI助手
            let defaultEnabled = Set([
                // 平台联系人（默认全部启用）
                "douyin", "xiaohongshu", "wechat_mp", "weixin_channels", "toutiao",
                "bilibili", "youtube", "jike", "baijiahao", "xigua", "ximalaya",
                // 主要AI助手（用户可以选择启用）
                "deepseek", "qwen", "chatglm", "moonshot", "openai", "claude", "gemini"
            ])
            enabledContacts = defaultEnabled
            saveContactSettings()
        }
    }

    func saveContactSettings() {
        if let data = try? JSONEncoder().encode(enabledContacts) {
            UserDefaults.standard.set(data, forKey: "enabled_contacts")
        }
    }

    func isContactEnabled(_ contactId: String) -> Bool {
        return enabledContacts.contains(contactId)
    }

    func setContactEnabled(_ contactId: String, enabled: Bool) {
        if enabled {
            enabledContacts.insert(contactId)
        } else {
            enabledContacts.remove(contactId)
        }
        saveContactSettings()
    }
}

// MARK: - 简化的联系人管理视图
struct SimpleContactsManagementView: View {
    @StateObject private var apiManager = APIConfigManager.shared
    @StateObject private var contactsManager = SimpleContactsManager.shared
    @Environment(\.presentationMode) var presentationMode

    @State private var searchText = ""

    // 获取所有联系人（从SimpleAIChatView的contacts数组）
    private let allContacts: [AIContact] = [
        // AI助手
        AIContact(id: "deepseek", name: "DeepSeek", description: "专业的AI编程助手", model: "deepseek-chat", avatar: "brain.head.profile", isOnline: true, apiEndpoint: "https://api.deepseek.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .purple),
        AIContact(id: "qwen", name: "通义千问", description: "阿里云大语言模型", model: "qwen-max", avatar: "cloud.fill", isOnline: true, apiEndpoint: "https://dashscope.aliyuncs.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .translation, .summarization], color: .cyan),
        AIContact(id: "openai", name: "ChatGPT", description: "OpenAI对话AI", model: "gpt-4", avatar: "bubble.left.and.bubble.right.fill", isOnline: true, apiEndpoint: "https://api.openai.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .green),
        AIContact(id: "claude", name: "Claude", description: "Anthropic智能助手", model: "claude-3", avatar: "sparkles", isOnline: true, apiEndpoint: "https://api.anthropic.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .purple),
        AIContact(id: "gemini", name: "Gemini", description: "Google AI助手", model: "gemini-pro", avatar: "diamond.fill", isOnline: true, apiEndpoint: "https://api.google.com", requiresApiKey: true, supportedFeatures: [.textGeneration], color: .blue),

        // 平台联系人
        AIContact(id: "douyin", name: "抖音", description: "短视频热门内容推送", model: "platform-douyin", avatar: "music.note", isOnline: true, apiEndpoint: "https://www.douyin.com/hot", requiresApiKey: false, supportedFeatures: [.hotTrends], color: .black),
        AIContact(id: "xiaohongshu", name: "小红书", description: "生活方式热门分享", model: "platform-xiaohongshu", avatar: "heart.fill", isOnline: true, apiEndpoint: "https://www.xiaohongshu.com/explore", requiresApiKey: false, supportedFeatures: [.hotTrends], color: .red),
        AIContact(id: "bilibili", name: "B站", description: "哔哩哔哩热门视频", model: "platform-bilibili", avatar: "tv.fill", isOnline: true, apiEndpoint: "https://www.bilibili.com/ranking", requiresApiKey: false, supportedFeatures: [.hotTrends], color: .pink),
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("搜索联系人...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom, 8)

                // 联系人列表
                List {
                    ForEach(filteredContacts, id: \.id) { contact in
                        SimpleContactRow(contact: contact)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("联系人管理")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("关闭") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }

    private var filteredContacts: [AIContact] {
        let filtered = allContacts.filter { contact in
            searchText.isEmpty ||
            contact.name.localizedCaseInsensitiveContains(searchText) ||
            contact.description.localizedCaseInsensitiveContains(searchText)
        }

        return filtered.sorted { $0.name < $1.name }
    }

    private func SimpleContactRow(contact: AIContact) -> some View {
        HStack(spacing: 12) {
            // 联系人图标
            Image(systemName: contact.avatar)
                .font(.system(size: 24))
                .foregroundColor(contact.color)
                .frame(width: 40, height: 40)
                .background(contact.color.opacity(0.1))
                .clipShape(Circle())

            // 联系人信息
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.headline)
                    .fontWeight(.medium)

                Text(contact.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                // 状态标签
                HStack(spacing: 8) {
                    if contact.supportedFeatures.contains(.hotTrends) {
                        // 平台联系人
                        Label("内容平台", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        // AI助手
                        if apiManager.hasAPIKey(for: contact.id) {
                            Label("已配置API", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Label("需要配置API", systemImage: "exclamationmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }

            Spacer()

            // 启用开关
            Toggle("", isOn: Binding(
                get: { contactsManager.isContactEnabled(contact.id) },
                set: { enabled in
                    contactsManager.setContactEnabled(contact.id, enabled: enabled)
                }
            ))
            .toggleStyle(SwitchToggleStyle())
        }
        .padding(.vertical, 4)
    }
}










