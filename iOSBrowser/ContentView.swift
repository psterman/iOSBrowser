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
            // 购物类
            UnifiedAppData(id: "taobao", name: "淘宝", icon: "bag.fill", color: .orange, category: "购物"),
            UnifiedAppData(id: "tmall", name: "天猫", icon: "bag.fill", color: .red, category: "购物"),
            UnifiedAppData(id: "pinduoduo", name: "拼多多", icon: "cart.fill", color: .orange, category: "购物"),
            UnifiedAppData(id: "jd", name: "京东", icon: "shippingbox.fill", color: .red, category: "购物"),
            UnifiedAppData(id: "xianyu", name: "闲鱼", icon: "fish.fill", color: .blue, category: "购物"),

            // 社交媒体
            UnifiedAppData(id: "zhihu", name: "知乎", icon: "bubble.left.and.bubble.right.fill", color: .blue, category: "社交"),
            UnifiedAppData(id: "weibo", name: "微博", icon: "at", color: .orange, category: "社交"),
            UnifiedAppData(id: "xiaohongshu", name: "小红书", icon: "heart.fill", color: .red, category: "社交"),
            UnifiedAppData(id: "wechat", name: "微信", icon: "message.circle.fill", color: .green, category: "社交"),

            // 视频娱乐
            UnifiedAppData(id: "douyin", name: "抖音", icon: "music.note", color: .black, category: "视频"),
            UnifiedAppData(id: "kuaishou", name: "快手", icon: "video.circle.fill", color: .orange, category: "视频"),
            UnifiedAppData(id: "bilibili", name: "bilibili", icon: "tv.fill", color: .pink, category: "视频"),
            UnifiedAppData(id: "youtube", name: "YouTube", icon: "play.rectangle.fill", color: .red, category: "视频"),
            UnifiedAppData(id: "youku", name: "优酷", icon: "play.rectangle.fill", color: .blue, category: "视频"),
            UnifiedAppData(id: "iqiyi", name: "爱奇艺", icon: "tv.fill", color: .green, category: "视频"),

            // 音乐
            UnifiedAppData(id: "qqmusic", name: "QQ音乐", icon: "music.quarternote.3", color: .green, category: "音乐"),
            UnifiedAppData(id: "netease_music", name: "网易云音乐", icon: "music.note.list", color: .red, category: "音乐"),

            // 生活服务
            UnifiedAppData(id: "meituan", name: "美团", icon: "fork.knife", color: .yellow, category: "生活"),
            UnifiedAppData(id: "eleme", name: "饿了么", icon: "takeoutbag.and.cup.and.straw.fill", color: .blue, category: "生活"),
            UnifiedAppData(id: "dianping", name: "大众点评", icon: "star.circle.fill", color: .orange, category: "生活"),
            UnifiedAppData(id: "alipay", name: "支付宝", icon: "creditcard.circle.fill", color: .blue, category: "生活"),

            // 地图导航
            UnifiedAppData(id: "gaode", name: "高德地图", icon: "map.circle.fill", color: .green, category: "地图"),
            UnifiedAppData(id: "tencent_map", name: "腾讯地图", icon: "location.circle.fill", color: .green, category: "地图"),

            // 浏览器
            UnifiedAppData(id: "quark", name: "夸克", icon: "globe.circle.fill", color: .blue, category: "浏览器"),
            UnifiedAppData(id: "uc", name: "UC浏览器", icon: "safari.fill", color: .orange, category: "浏览器"),

            // 其他
            UnifiedAppData(id: "douban", name: "豆瓣", icon: "book.fill", color: .green, category: "其他")
        ]

        print("📱 从搜索tab加载应用数据: \(allApps.count) 个应用")
        saveToSharedStorage()
    }

    // MARK: - 从AI tab加载AI助手数据
    private func loadAIFromContactsTab() {
        allAIAssistants = [
            // 🇨🇳 国内主流AI服务商
            UnifiedAIData(id: "deepseek", name: "DeepSeek", icon: "brain.head.profile", color: .purple, description: "专业编程助手", apiEndpoint: "https://api.deepseek.com"),
            UnifiedAIData(id: "qwen", name: "通义千问", icon: "cloud.fill", color: .cyan, description: "阿里云AI", apiEndpoint: "https://dashscope.aliyuncs.com"),
            UnifiedAIData(id: "chatglm", name: "智谱清言", icon: "lightbulb.fill", color: .yellow, description: "清华智谱AI", apiEndpoint: "https://open.bigmodel.cn"),
            UnifiedAIData(id: "moonshot", name: "Kimi", icon: "moon.stars.fill", color: .orange, description: "月之暗面", apiEndpoint: "https://api.moonshot.cn"),
            UnifiedAIData(id: "doubao", name: "豆包", icon: "bubble.left.and.bubble.right", color: .blue, description: "字节跳动AI", apiEndpoint: "https://ark.cn-beijing.volces.com"),
            UnifiedAIData(id: "wenxin", name: "文心一言", icon: "w.circle.fill", color: .red, description: "百度AI", apiEndpoint: "https://aip.baidubce.com"),
            UnifiedAIData(id: "spark", name: "讯飞星火", icon: "sparkles", color: .orange, description: "科大讯飞AI", apiEndpoint: "https://spark-api.xf-yun.com"),
            UnifiedAIData(id: "baichuan", name: "百川智能", icon: "b.circle.fill", color: .green, description: "百川智能AI", apiEndpoint: "https://api.baichuan-ai.com"),
            UnifiedAIData(id: "minimax", name: "MiniMax", icon: "m.circle.fill", color: .purple, description: "MiniMax AI", apiEndpoint: "https://api.minimax.chat"),

            // 硅基流动
            UnifiedAIData(id: "siliconflow-qwen", name: "千问-硅基流动", icon: "cpu.fill", color: .gray, description: "硅基流动API", apiEndpoint: "https://api.siliconflow.cn"),

            // 🌍 国际主流AI服务商
            UnifiedAIData(id: "openai", name: "ChatGPT", icon: "bubble.left.and.bubble.right.fill", color: .green, description: "OpenAI GPT-4", apiEndpoint: "https://api.openai.com"),
            UnifiedAIData(id: "claude", name: "Claude", icon: "c.circle.fill", color: .indigo, description: "Anthropic Claude", apiEndpoint: "https://api.anthropic.com"),
            UnifiedAIData(id: "gemini", name: "Gemini", icon: "diamond.fill", color: .blue, description: "Google Gemini", apiEndpoint: "https://generativelanguage.googleapis.com"),

            // ⚡ 高性能推理
            UnifiedAIData(id: "groq", name: "Groq", icon: "bolt.circle.fill", color: .orange, description: "超快推理", apiEndpoint: "https://api.groq.com"),
            UnifiedAIData(id: "together", name: "Together AI", icon: "link.circle.fill", color: .purple, description: "开源模型", apiEndpoint: "https://api.together.xyz"),
            UnifiedAIData(id: "perplexity", name: "Perplexity", icon: "questionmark.diamond.fill", color: .blue, description: "搜索增强", apiEndpoint: "https://api.perplexity.ai"),

            // 🎨 专业工具
            UnifiedAIData(id: "dalle", name: "DALL-E", icon: "photo.circle.fill", color: .pink, description: "AI绘画", apiEndpoint: "https://api.openai.com"),
            UnifiedAIData(id: "stablediffusion", name: "Stable Diffusion", icon: "camera.macro.circle.fill", color: .orange, description: "开源绘画", apiEndpoint: "https://api.stability.ai"),
            UnifiedAIData(id: "elevenlabs", name: "ElevenLabs", icon: "speaker.wave.3.fill", color: .purple, description: "AI语音", apiEndpoint: "https://api.elevenlabs.io"),
            UnifiedAIData(id: "whisper", name: "Whisper", icon: "mic.circle.fill", color: .blue, description: "语音识别", apiEndpoint: "https://api.openai.com"),

            // 本地部署
            UnifiedAIData(id: "ollama", name: "Ollama", icon: "server.rack", color: .gray, description: "本地部署", apiEndpoint: "http://localhost:11434")
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
        case "orange": return .orange
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "pink": return .pink
        case "purple": return .purple
        case "cyan": return .cyan
        case "gray": return .gray
        case "black": return .black
        default: return .blue
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
        case "orange": return .orange
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "pink": return .pink
        case "purple": return .purple
        case "cyan": return .cyan
        case "gray": return .gray
        case "indigo": return .indigo
        default: return .blue
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
                        .background(Color.blue)
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
                        .background(Color.orange)
                        .cornerRadius(6)
                    }

                    Button(action: {
                        showingWidgetGuide = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
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
                            .foregroundColor(selectedTab == index ? .blue : .secondary)
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
            ("baidu", "百度", "magnifyingglass.circle.fill", Color.blue),
            ("sogou", "搜狗", "s.circle.fill", Color.orange),
            ("360", "360搜索", "360.circle.fill", Color.green),
            ("shenma", "神马搜索", "s.square.fill", Color.purple),
            ("chinaso", "中国搜索", "c.circle.fill", Color.red),
            ("haosou", "好搜", "h.circle.fill", Color.cyan)
        ]
    }

    private var internationalEngines: [(String, String, String, Color)] {
        [
            ("google", "Google", "globe", Color.red),
            ("bing", "必应", "b.circle.fill", Color.blue),
            ("duckduckgo", "DuckDuckGo", "shield.fill", Color.orange),
            ("yahoo", "Yahoo", "y.circle.fill", Color.purple),
            ("yandex", "Yandex", "y.square.fill", Color.red),
            ("ask", "Ask", "questionmark.circle.fill", Color.green)
        ]
    }

    private var aiEngines: [(String, String, String, Color)] {
        [
            ("perplexity", "Perplexity", "brain.head.profile", Color.purple),
            ("you", "You.com", "y.circle", Color.blue),
            ("phind", "Phind", "p.circle.fill", Color.green),
            ("andi", "Andi", "a.circle.fill", Color.orange),
            ("neeva", "Neeva", "n.circle.fill", Color.indigo),
            ("kagi", "Kagi", "k.circle.fill", Color.mint)
        ]
    }

    private var professionalEngines: [(String, String, String, Color)] {
        [
            ("scholar", "谷歌学术", "graduationcap.fill", Color.blue),
            ("github", "GitHub", "chevron.left.forwardslash.chevron.right", Color.black),
            ("stackoverflow", "Stack Overflow", "questionmark.square.fill", Color.orange),
            ("arxiv", "arXiv", "doc.text.fill", Color.red),
            ("pubmed", "PubMed", "cross.case.fill", Color.green),
            ("ieee", "IEEE Xplore", "bolt.circle.fill", Color.blue)
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
                                .foregroundColor(.blue)

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
                            .foregroundColor(.blue)
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
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    Button(action: {
                        dataSyncCenter.refreshAllData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
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
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    Button(action: {
                        dataSyncCenter.refreshAllData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
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
                            .foregroundColor(.orange)

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
                                            .background(Color.red.opacity(0.2))
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

    // 快捷操作选项
    private let quickActions = [
        ("search", "快速搜索", "magnifyingglass", Color.blue),
        ("bookmark", "书签管理", "bookmark.fill", Color.orange),
        ("history", "浏览历史", "clock.fill", Color.green),
        ("ai_chat", "AI对话", "brain.head.profile", Color.purple),
        ("translate", "翻译工具", "textformat.abc", Color.red),
        ("qr_scan", "二维码扫描", "qrcode.viewfinder", Color.cyan),
        ("clipboard", "剪贴板", "doc.on.clipboard", Color.gray),
        ("settings", "快速设置", "gearshape.fill", Color.blue)
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
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    Button(action: {
                        dataSyncCenter.refreshAllData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
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
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var initialDragLocation: CGPoint = .zero
    @State private var canSwitchTab = false

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
                .offset(x: -CGFloat(selectedTab) * geometry.size.width + dragOffset)
                .animation(isDragging ? .none : .spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0), value: selectedTab)
                .gesture(
                    DragGesture(coordinateSpace: .global)
                        .onChanged { value in
                            // 检查边界条件
                            let canSwipeLeft = selectedTab < 3 // 不是最后一个tab
                            let canSwipeRight = selectedTab > 0 // 不是第一个tab

                            // 根据滑动方向和边界条件决定是否允许拖拽
                            let isSwipingLeft = value.translation.width < 0
                            let isSwipingRight = value.translation.width > 0

                            // 检查是否是从屏幕边缘开始的滑动（提高优先级）
                            let edgeThreshold: CGFloat = 50
                            let isFromLeftEdge = value.startLocation.x < edgeThreshold
                            let isFromRightEdge = value.startLocation.x > geometry.size.width - edgeThreshold
                            let isEdgeSwipe = isFromLeftEdge || isFromRightEdge

                            // 检查滑动距离是否足够（避免误触）
                            let swipeDistance = abs(value.translation.width)
                            let minSwipeDistance: CGFloat = isEdgeSwipe ? 10 : 30

                            if swipeDistance > minSwipeDistance &&
                               ((isSwipingLeft && canSwipeLeft) || (isSwipingRight && canSwipeRight)) {
                                isDragging = true
                                // 限制拖拽范围，防止过度滑动
                                let maxOffset = geometry.size.width * 0.3
                                dragOffset = max(-maxOffset, min(maxOffset, value.translation.width))
                            }
                        }
                        .onEnded { value in
                            isDragging = false
                            let threshold: CGFloat = geometry.size.width * 0.12 // 更低的阈值，更敏感
                            let velocity = value.predictedEndLocation.x - value.location.x

                            // 考虑速度和距离，微信风格的快速响应
                            let shouldSwitchTab = abs(value.translation.width) > threshold || abs(velocity) > 200

                            // 向右滑动（显示前一个tab）
                            if (value.translation.width > 0 || velocity > 0) && shouldSwitchTab && selectedTab > 0 {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9, blendDuration: 0)) {
                                    selectedTab -= 1
                                }
                            }
                            // 向左滑动（显示后一个tab）
                            else if (value.translation.width < 0 || velocity < 0) && shouldSwitchTab && selectedTab < 3 {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9, blendDuration: 0)) {
                                    selectedTab += 1
                                }
                            }

                            // 快速重置拖拽偏移
                            withAnimation(.spring(response: 0.2, dampingFraction: 1.0, blendDuration: 0)) {
                                dragOffset = 0
                            }
                        }
                )
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
struct SearchView: View {
    @EnvironmentObject var deepLinkHandler: DeepLinkHandler
    @State private var searchText = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedCategory = "全部"

    private let categories = ["全部", "购物", "社交", "视频", "音乐", "生活", "地图", "浏览器", "其他"]

    // 应用数据 - 使用更贴近原App的图标和品牌色
    private let apps = [
        // 购物类
        AppInfo(name: "淘宝", icon: "T", systemIcon: "bag.circle.fill", color: Color(red: 1.0, green: 0.4, blue: 0.0), urlScheme: "taobao://s.taobao.com/search?q=", bundleId: "com.taobao.taobao4iphone", category: "购物"),
        AppInfo(name: "天猫", icon: "天", systemIcon: "bag.fill", color: Color(red: 1.0, green: 0.2, blue: 0.2), urlScheme: "tmall://search?q=", bundleId: "com.tmall.wireless", category: "购物"),
        AppInfo(name: "拼多多", icon: "P", systemIcon: "cart.circle.fill", color: Color(red: 1.0, green: 0.2, blue: 0.2), urlScheme: "pinduoduo://search?keyword=", bundleId: "com.xunmeng.pinduoduo", category: "购物"),
        AppInfo(name: "京东", icon: "京", systemIcon: "cube.box.fill", color: Color(red: 0.8, green: 0.0, blue: 0.0), urlScheme: "openapp.jdmobile://virtual?params={\"category\":\"jump\",\"des\":\"search\",\"keyword\":\"", bundleId: "com.360buy.jdmobile", category: "购物"),
        AppInfo(name: "闲鱼", icon: "闲", systemIcon: "fish.circle.fill", color: Color(red: 0.0, green: 0.6, blue: 1.0), urlScheme: "fleamarket://search?q=", bundleId: "com.taobao.fleamarket", category: "购物"),

        // 社交媒体
        AppInfo(name: "知乎", icon: "知", systemIcon: "bubble.left.circle.fill", color: Color(red: 0.0, green: 0.5, blue: 1.0), urlScheme: "zhihu://search?q=", bundleId: "com.zhihu.ios", category: "社交"),
        AppInfo(name: "微博", icon: "微", systemIcon: "at.circle.fill", color: Color(red: 1.0, green: 0.3, blue: 0.3), urlScheme: "sinaweibo://search?q=", bundleId: "com.sina.weibo", category: "社交"),
        AppInfo(name: "小红书", icon: "小", systemIcon: "heart.circle.fill", color: Color(red: 1.0, green: 0.2, blue: 0.4), urlScheme: "xhsdiscover://search?keyword=", bundleId: "com.xingin.xhs", category: "社交"),

        // 视频娱乐
        AppInfo(name: "抖音", icon: "抖", systemIcon: "music.note.tv.fill", color: Color(red: 0.0, green: 0.0, blue: 0.0), urlScheme: "snssdk1128://search?keyword=", bundleId: "com.ss.iphone.ugc.Aweme", category: "视频"),
        AppInfo(name: "快手", icon: "快", systemIcon: "video.circle.fill", color: Color(red: 1.0, green: 0.4, blue: 0.0), urlScheme: "kwai://search?keyword=", bundleId: "com.kuaishou.gif", category: "视频"),
        AppInfo(name: "bilibili", icon: "B", systemIcon: "tv.circle.fill", color: Color(red: 1.0, green: 0.4, blue: 0.7), urlScheme: "bilibili://search?keyword=", bundleId: "tv.danmaku.bili", category: "视频"),
        AppInfo(name: "YouTube", icon: "Y", systemIcon: "play.tv.fill", color: Color(red: 1.0, green: 0.0, blue: 0.0), urlScheme: "youtube://results?search_query=", bundleId: "com.google.ios.youtube", category: "视频"),
        AppInfo(name: "优酷", icon: "优", systemIcon: "play.rectangle.fill", color: Color(red: 0.0, green: 0.6, blue: 1.0), urlScheme: "youku://search?keyword=", bundleId: "com.youku.YouKu", category: "视频"),
        AppInfo(name: "爱奇艺", icon: "爱", systemIcon: "tv.fill", color: Color(red: 0.0, green: 0.8, blue: 0.4), urlScheme: "qiyi-iphone://search?key=", bundleId: "com.qiyi.iphone", category: "视频"),

        // 音乐
        AppInfo(name: "QQ音乐", icon: "Q", systemIcon: "music.note.circle.fill", color: Color(red: 0.0, green: 0.8, blue: 0.2), urlScheme: "qqmusic://search?key=", bundleId: "com.tencent.QQMusic", category: "音乐"),
        AppInfo(name: "网易云音乐", icon: "网", systemIcon: "music.note.list", color: Color(red: 1.0, green: 0.2, blue: 0.2), urlScheme: "orpheus://search?keyword=", bundleId: "com.netease.cloudmusic", category: "音乐"),

        // 生活服务
        AppInfo(name: "美团", icon: "美", systemIcon: "takeoutbag.and.cup.and.straw.fill", color: Color(red: 1.0, green: 0.8, blue: 0.0), urlScheme: "imeituan://www.meituan.com/search?q=", bundleId: "com.meituan.imeituan", category: "生活"),
        AppInfo(name: "饿了么", icon: "饿", systemIcon: "fork.knife.circle.fill", color: Color(red: 0.0, green: 0.6, blue: 1.0), urlScheme: "eleme://search?keyword=", bundleId: "me.ele.ios.eleme", category: "生活"),
        AppInfo(name: "大众点评", icon: "大", systemIcon: "star.circle.fill", color: Color(red: 1.0, green: 0.6, blue: 0.0), urlScheme: "dianping://search?keyword=", bundleId: "com.dianping.dpscope", category: "生活"),

        // 地图导航
        AppInfo(name: "高德地图", icon: "高", systemIcon: "map.circle.fill", color: Color(red: 0.0, green: 0.7, blue: 1.0), urlScheme: "iosamap://search?keywords=", bundleId: "com.autonavi.minimap", category: "地图"),
        AppInfo(name: "腾讯地图", icon: "腾", systemIcon: "location.circle.fill", color: Color(red: 0.0, green: 0.8, blue: 0.4), urlScheme: "sosomap://search?keyword=", bundleId: "com.tencent.map", category: "地图"),

        // 浏览器
        AppInfo(name: "夸克", icon: "夸", systemIcon: "globe.circle.fill", color: Color(red: 0.4, green: 0.6, blue: 1.0), urlScheme: "quark://search?q=", bundleId: "com.quark.browser", category: "浏览器"),
        AppInfo(name: "UC浏览器", icon: "UC", systemIcon: "safari.fill", color: Color(red: 1.0, green: 0.4, blue: 0.0), urlScheme: "ucbrowser://search?keyword=", bundleId: "com.uc.iphone", category: "浏览器"),

        // 其他
        AppInfo(name: "豆瓣", icon: "豆", systemIcon: "book.circle.fill", color: Color(red: 0.0, green: 0.7, blue: 0.3), urlScheme: "douban://search?q=", bundleId: "com.douban.frodo", category: "其他")
    ]

    var filteredApps: [AppInfo] {
        if selectedCategory == "全部" {
            return apps
        } else {
            return apps.filter { $0.category == selectedCategory }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                VStack(spacing: 16) {
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
                    .padding(.horizontal, 16)

                    Text("选择应用进行搜索")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.top, 16)
                .padding(.bottom, 16)

                // 分类选择器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)

                // 应用网格
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 16) {
                        ForEach(filteredApps, id: \.name) { app in
                            AppButton(app: app, searchText: searchText) {
                                searchInApp(app: app)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("应用搜索")
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
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

    private func searchInApp(app: AppInfo) {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "请输入搜索关键词"
            showingAlert = true
            return
        }

        let keyword = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText
        let urlString = app.urlScheme + keyword

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
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
                    .foregroundColor(.blue)
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
                        .foregroundColor(.blue)
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
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        ChatMessageRow(message: message)
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
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
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
    }

    private func sendMessage() {
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

        // 模拟AI响应
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let aiResponse = ChatMessage(
                id: UUID().uuidString,
                content: generateAIResponse(for: currentMessage),
                isFromUser: false,
                timestamp: Date(),
                status: .sent,
                actions: []
            )
            messages.append(aiResponse)
            isLoading = false
        }
    }

    private func generateAIResponse(for message: String) -> String {
        let responses = [
            "我理解您的问题，让我来帮助您。",
            "这是一个很好的问题，我来为您详细解答。",
            "根据您的描述，我建议您可以尝试以下方法。",
            "感谢您的提问，我很乐意为您提供帮助。",
            "这个问题很有意思，让我来分析一下。"
        ]
        return responses.randomElement() ?? "我正在思考您的问题，请稍等。"
    }
}

struct ChatMessageRow: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(18)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)

                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(18)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)

                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
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
    ]

    var filteredContacts: [AIContact] {
        let filtered = contacts.filter { contact in
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
                    // 显示AI联系人列表
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
                        .foregroundColor(.blue)
                }

                Spacer()

                Button(action: {
                    showingAPIConfig = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.blue)
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
                    .foregroundColor(.blue)
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
                        .foregroundColor(.orange)
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
                        .foregroundColor(.blue)
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
                    .background(Color.blue)
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
                        .foregroundColor(.orange)
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
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
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
                            .foregroundColor(.orange)
                    }

                    Spacer()

                    // API状态指示器
                    Circle()
                        .fill(hasAPIKey ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                }

                Text(contact.description)
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
                    .foregroundColor(.blue)
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
                        .foregroundColor(.blue)
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
                        .background(Color.blue)
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
                                .foregroundColor(.blue)
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

    let services = [
        ("deepseek", "DeepSeek"),
        ("qwen", "通义千问"),
        ("chatglm", "智谱清言"),
        ("moonshot", "Kimi"),
        ("doubao", "豆包"),
        ("wenxin", "文心一言"),
        ("openai", "OpenAI ChatGPT"),
        ("claude", "Anthropic Claude"),
        ("gemini", "Google Gemini"),
        ("groq", "Groq"),
        ("together", "Together AI"),
        ("perplexity", "Perplexity")
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
                            .background(apiKey.isEmpty ? Color.gray : Color.blue)
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
                                .foregroundColor(.blue)
                            Text("创建自定义Prompt")
                                .foregroundColor(.blue)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
