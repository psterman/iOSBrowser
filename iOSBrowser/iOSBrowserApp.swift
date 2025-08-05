//
//  iOSBrowserApp.swift
//  iOSBrowser
//
//  Created by LZH on 2025/7/13.
//

import SwiftUI
import UIKit
import WidgetKit
import BackgroundTasks

// MARK: - 通知名称扩展
extension Notification.Name {
    static let startAIConversation = Notification.Name("startAIConversation")
}

@main
struct iOSBrowserApp: App {
    @StateObject private var deepLinkHandler = DeepLinkHandler()

    init() {
        print("🚨🚨🚨 ===== iOSBrowserApp.init() 被调用 =====")
        print("🚨🚨🚨 ===== 应用启动，立即初始化数据 =====")
        print("🚨🚨🚨 ===== 如果你看到这个日志，说明应用启动正常 =====")
        Self.initializeWidgetData()
        // 热榜管理器将在需要时自动初始化
        print("🚨🚨🚨 ===== 应用数据初始化完成 =====")
        print("🚨🚨🚨 ===== iOSBrowserApp.init() 执行完成 =====")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deepLinkHandler)
                .onOpenURL { url in
                    print("🔗 收到深度链接: \(url)")
                    deepLinkHandler.handleDeepLink(url)
                }
        }
    }

    // MARK: - 应用启动时立即初始化小组件数据
    static func initializeWidgetData() {
        print("🚀🚀🚀 开始初始化小组件数据...")

        let defaults = UserDefaults.standard
        var hasChanges = false

        // 检查并初始化搜索引擎数据
        if defaults.stringArray(forKey: "iosbrowser_engines") == nil {
            let defaultEngines = ["baidu", "google"]
            defaults.set(defaultEngines, forKey: "iosbrowser_engines")
            print("🚀 初始化搜索引擎: \(defaultEngines)")
            hasChanges = true
        } else {
            let engines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
            print("🚀 搜索引擎已存在: \(engines)")
        }

        // 检查并初始化应用数据
        if defaults.stringArray(forKey: "iosbrowser_apps") == nil {
            let defaultApps = ["taobao", "zhihu", "douyin"]
            defaults.set(defaultApps, forKey: "iosbrowser_apps")
            print("🚀 初始化应用: \(defaultApps)")
            hasChanges = true
        } else {
            let apps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []
            print("🚀 应用已存在: \(apps)")
        }

        // 检查并初始化AI助手数据
        if defaults.stringArray(forKey: "iosbrowser_ai") == nil {
            let defaultAI = ["deepseek", "qwen"]
            defaults.set(defaultAI, forKey: "iosbrowser_ai")
            print("🚀 初始化AI助手: \(defaultAI)")
            hasChanges = true
        } else {
            let ai = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
            print("🚀 AI助手已存在: \(ai)")
        }

        // 检查并初始化快捷操作数据
        if defaults.stringArray(forKey: "iosbrowser_actions") == nil {
            let defaultActions = ["search", "bookmark"]
            defaults.set(defaultActions, forKey: "iosbrowser_actions")
            print("🚀 初始化快捷操作: \(defaultActions)")
            hasChanges = true
        } else {
            let actions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []
            print("🚀 快捷操作已存在: \(actions)")
        }

        if hasChanges {
            // 强制同步
            let syncResult = defaults.synchronize()
            print("🚀 UserDefaults同步结果: \(syncResult)")

            // 立即刷新小组件
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
                print("🚀 已触发小组件刷新")
            }
        }

        print("🚀🚀🚀 小组件数据初始化完成")

        // 🧪🧪🧪 临时测试：强制设置测试数据验证数据流
        print("🧪🧪🧪 开始强制测试数据验证...")
        defaults.set(["ai_chat", "translate", "settings"], forKey: "iosbrowser_actions")
        defaults.synchronize()
        let testData = defaults.stringArray(forKey: "iosbrowser_actions") ?? []
        print("🧪🧪🧪 强制设置测试数据: \(testData)")
        print("🧪🧪🧪 如果小组件显示这些数据，说明数据流正常")
        print("🧪🧪🧪 如果小组件仍显示默认数据，说明小组件读取有问题")
    }
}

// MARK: - 深度链接处理器
class DeepLinkHandler: ObservableObject {
    @Published var targetTab: Int = 0
    @Published var searchQuery: String = ""
    @Published var selectedApp: String = ""
    @Published var selectedAI: String = ""
    @Published var selectedEngine: String = ""
    @Published var actionType: String = ""

    func handleDeepLink(_ url: URL) {
        print("🔗 处理深度链接: \(url)")

        guard url.scheme == "iosbrowser" else {
            print("❌ 无效的URL scheme: \(url.scheme ?? "nil")")
            return
        }

        let host = url.host ?? ""
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []

        print("🔗 Host: \(host)")
        print("🔗 Query items: \(queryItems)")

        switch host {
        case "search":
            // 处理搜索引擎参数
            if let engine = queryItems.first(where: { $0.name == "engine" })?.value {
                handleSearchEngineAction(engine)
            }

            // 处理应用搜索参数
            if let app = queryItems.first(where: { $0.name == "app" })?.value {
                handleAppSearchAction(app)
            }

        case "ai":
            // 处理AI助手参数
            if let assistant = queryItems.first(where: { $0.name == "assistant" })?.value {
                handleAIAssistantAction(assistant)
            }

        case "action":
            if let type = queryItems.first(where: { $0.name == "type" })?.value {
                actionType = type
                handleQuickAction(type)
                print("⚡ 执行快捷操作: \(type)")
            }

        default:
            print("❌ 未知的深度链接host: \(host)")
        }
    }

    // MARK: - 智能应用搜索处理
    private func handleAppSearchAction(_ appId: String) {
        let clipboardText = getClipboardText()

        if !clipboardText.isEmpty {
            // 剪贴板有内容，直接跳转到对应应用搜索
            print("📋 检测到剪贴板内容: \(clipboardText)")
            print("🚀 直接跳转到\(getAppSearchQuery(appId))搜索: \(clipboardText)")

            // 构建应用搜索URL并跳转
            if let appURL = buildAppSearchURL(appId: appId, query: clipboardText) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    UIApplication.shared.open(appURL) { success in
                        if success {
                            print("✅ 成功跳转到\(self.getAppSearchQuery(appId))搜索")
                        } else {
                            print("❌ 跳转失败，回退到应用内搜索")
                            self.fallbackToInAppSearch(appId: appId, query: clipboardText)
                        }
                    }
                }
            } else {
                // 无法构建URL，回退到应用内搜索
                fallbackToInAppSearch(appId: appId, query: clipboardText)
            }
        } else {
            // 剪贴板为空，跳转到应用内搜索tab
            print("📋 剪贴板为空，跳转到应用内搜索")
            fallbackToInAppSearch(appId: appId, query: "")
        }
    }

    // MARK: - 智能搜索引擎处理
    private func handleSearchEngineAction(_ engineId: String) {
        let clipboardText = getClipboardText()

        if !clipboardText.isEmpty {
            // 剪贴板有内容，直接跳转到对应搜索引擎
            print("📋 检测到剪贴板内容: \(clipboardText)")
            print("🚀 直接跳转到\(getSearchEngineName(engineId))搜索: \(clipboardText)")

            // 构建搜索引擎URL并跳转
            if let searchURL = buildSearchEngineURL(engineId: engineId, query: clipboardText) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    UIApplication.shared.open(searchURL) { success in
                        if success {
                            print("✅ 成功跳转到\(self.getSearchEngineName(engineId))搜索")
                        } else {
                            print("❌ 跳转失败，回退到应用内搜索")
                            self.fallbackToInAppSearch(engineId: engineId, query: clipboardText)
                        }
                    }
                }
            } else {
                // 无法构建URL，回退到应用内搜索
                fallbackToInAppSearch(engineId: engineId, query: clipboardText)
            }
        } else {
            // 剪贴板为空，跳转到应用内搜索tab
            print("📋 剪贴板为空，跳转到应用内搜索")
            fallbackToInAppSearch(engineId: engineId, query: "")
        }
    }

    // MARK: - 智能AI助手处理
    private func handleAIAssistantAction(_ assistantId: String) {
        let clipboardText = getClipboardText()

        if !clipboardText.isEmpty {
            // 剪贴板有内容，直接跳转到AI tab并开始对话
            print("📋 检测到剪贴板内容: \(clipboardText)")
            print("🤖 直接跳转到\(getAIAssistantName(assistantId))并开始对话: \(clipboardText)")

            // 跳转到AI tab并设置对话内容
            targetTab = 2 // AI tab (SimpleAIChatView)
            selectedAI = assistantId

            // 发送通知给AI tab，传递剪贴板内容作为初始消息
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: .startAIConversation, object: [
                    "assistantId": assistantId,
                    "initialMessage": clipboardText
                ])
            }
        } else {
            // 剪贴板为空，跳转到AI tab并选择助手
            print("📋 剪贴板为空，跳转到AI tab")
            fallbackToInAppAI(assistantId: assistantId)
        }
    }

    // MARK: - 回退到应用内AI
    private func fallbackToInAppAI(assistantId: String) {
        targetTab = 2 // AI tab (SimpleAIChatView)
        selectedAI = assistantId
        print("🤖 应用内选择AI助手: \(assistantId)")
    }

    // MARK: - 获取AI助手名称
    private func getAIAssistantName(_ assistantId: String) -> String {
        switch assistantId {
        case "deepseek": return "DeepSeek"
        case "qwen": return "通义千问"
        case "chatglm": return "智谱清言"
        case "moonshot": return "Kimi"
        case "claude": return "Claude"
        case "gpt": return "ChatGPT"
        case "gemini": return "Gemini"
        case "doubao": return "豆包"
        case "baichuan": return "百川"
        case "minimax": return "MiniMax"
        case "zhipu": return "智谱AI"
        case "spark": return "讯飞星火"
        case "wenxin": return "文心一言"
        case "tongyi": return "通义千问"
        case "hunyuan": return "腾讯混元"
        default: return assistantId
        }
    }

    // MARK: - 回退到应用内搜索
    private func fallbackToInAppSearch(appId: String? = nil, engineId: String? = nil, query: String) {
        targetTab = 0 // 搜索tab (SearchView)

        if let appId = appId {
            selectedApp = appId
            searchQuery = query.isEmpty ? getAppSearchQuery(appId) : query
            print("📱 应用内搜索应用: \(appId), 查询: \(searchQuery)")
        } else if let engineId = engineId {
            selectedEngine = engineId
            searchQuery = query
            print("🔍 应用内选择搜索引擎: \(engineId), 查询: \(searchQuery)")
        }
    }

    // MARK: - 剪贴板检测
    private func getClipboardText() -> String {
        let pasteboard = UIPasteboard.general
        let clipboardText = pasteboard.string?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        print("📋 剪贴板内容: '\(clipboardText)'")
        return clipboardText
    }

    private func getAppSearchQuery(_ appId: String) -> String {
        switch appId {
        case "taobao": return "淘宝"
        case "zhihu": return "知乎"
        case "douyin": return "抖音"
        case "wechat": return "微信"
        case "alipay": return "支付宝"
        case "meituan": return "美团"
        case "jd": return "京东"
        case "bilibili": return "哔哩哔哩"
        case "xiaohongshu": return "小红书"
        case "didi": return "滴滴出行"
        case "eleme": return "饿了么"
        case "pinduoduo": return "拼多多"
        case "kuaishou": return "快手"
        case "qqmusic": return "QQ音乐"
        case "netease_music": return "网易云音乐"
        case "iqiyi": return "爱奇艺"
        case "youku": return "优酷"
        case "tencent_video": return "腾讯视频"
        case "gaode": return "高德地图"
        case "baidu_map": return "百度地图"
        case "12306": return "12306"
        case "ctrip": return "携程"
        case "qunar": return "去哪儿"
        case "boss": return "BOSS直聘"
        case "lagou": return "拉勾"
        case "liepin": return "猎聘"
        default: return appId
        }
    }

    // MARK: - 构建应用搜索URL
    private func buildAppSearchURL(appId: String, query: String) -> URL? {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        switch appId {
        case "taobao":
            return URL(string: "taobao://s.taobao.com?q=\(encodedQuery)")
        case "zhihu":
            return URL(string: "zhihu://search?q=\(encodedQuery)")
        case "douyin":
            return URL(string: "snssdk1128://search?keyword=\(encodedQuery)")
        case "wechat":
            return URL(string: "weixin://dl/search?query=\(encodedQuery)")
        case "alipay":
            return URL(string: "alipay://platformapi/startapp?appId=20000067&query=\(encodedQuery)")
        case "meituan":
            return URL(string: "imeituan://www.meituan.com/search?q=\(encodedQuery)")
        case "jd":
            return URL(string: "openapp.jdmobile://virtual?params={\"category\":\"jump\",\"des\":\"search\",\"keyword\":\"\(encodedQuery)\"}")
        case "bilibili":
            return URL(string: "bilibili://search?keyword=\(encodedQuery)")
        case "xiaohongshu":
            return URL(string: "xhsdiscover://search/result?keyword=\(encodedQuery)")
        case "didi":
            return URL(string: "diditaxi://search?q=\(encodedQuery)")
        case "eleme":
            return URL(string: "eleme://search?keyword=\(encodedQuery)")
        case "pinduoduo":
            return URL(string: "pinduoduo://com.xunmeng.pinduoduo/search_result.html?search_key=\(encodedQuery)")
        case "kuaishou":
            return URL(string: "kwai://search?keyword=\(encodedQuery)")
        case "qqmusic":
            return URL(string: "qqmusic://search?key=\(encodedQuery)")
        case "netease_music":
            return URL(string: "orpheus://search?keyword=\(encodedQuery)")
        case "iqiyi":
            return URL(string: "iqiyi://search?key=\(encodedQuery)")
        case "youku":
            return URL(string: "youku://search?keyword=\(encodedQuery)")
        case "tencent_video":
            return URL(string: "tenvideo2://search?keyword=\(encodedQuery)")
        case "gaode":
            return URL(string: "iosamap://search?keywords=\(encodedQuery)")
        case "baidu_map":
            return URL(string: "baidumap://map/search?query=\(encodedQuery)")
        case "12306":
            return URL(string: "cn.12306://search?q=\(encodedQuery)")
        case "ctrip":
            return URL(string: "ctrip://search?keyword=\(encodedQuery)")
        case "qunar":
            return URL(string: "qunar://search?keyword=\(encodedQuery)")
        case "boss":
            return URL(string: "bosszhipin://search?query=\(encodedQuery)")
        case "lagou":
            return URL(string: "lagou://search?keyword=\(encodedQuery)")
        case "liepin":
            return URL(string: "liepin://search?keyword=\(encodedQuery)")
        default:
            print("❌ 未知应用ID: \(appId)")
            return nil
        }
    }

    // MARK: - 构建搜索引擎URL
    private func buildSearchEngineURL(engineId: String, query: String) -> URL? {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        switch engineId {
        case "baidu":
            return URL(string: "https://www.baidu.com/s?wd=\(encodedQuery)")
        case "google":
            return URL(string: "https://www.google.com/search?q=\(encodedQuery)")
        case "bing":
            return URL(string: "https://www.bing.com/search?q=\(encodedQuery)")
        case "sogou":
            return URL(string: "https://www.sogou.com/web?query=\(encodedQuery)")
        case "360":
            return URL(string: "https://www.so.com/s?q=\(encodedQuery)")
        case "duckduckgo":
            return URL(string: "https://duckduckgo.com/?q=\(encodedQuery)")
        default:
            print("❌ 未知搜索引擎ID: \(engineId)")
            return nil
        }
    }

    // MARK: - 获取搜索引擎名称
    private func getSearchEngineName(_ engineId: String) -> String {
        switch engineId {
        case "baidu": return "百度"
        case "google": return "Google"
        case "bing": return "必应"
        case "sogou": return "搜狗"
        case "360": return "360搜索"
        case "duckduckgo": return "DuckDuckGo"
        default: return engineId
        }
    }

    private func handleQuickAction(_ action: String) {
        switch action {
        case "search":
            targetTab = 0 // 搜索tab (SearchView)
        case "bookmark", "history":
            targetTab = 1 // 浏览tab (BrowserView)
        case "ai_chat":
            targetTab = 2 // AI tab (SimpleAIChatView)
        case "translate":
            targetTab = 2 // AI tab，可以设置翻译提示
            selectedAI = "qwen"
        case "settings":
            targetTab = 3 // 小组件配置tab (WidgetConfigView)
        default:
            break
        }
    }


}
