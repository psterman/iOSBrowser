//
//  SearchView.swift
//  iOSBrowser
//
//  Created by LZH on 2025/7/20.
//

import SwiftUI
import UIKit

struct SearchView: View {
    @EnvironmentObject var deepLinkHandler: DeepLinkHandler
    @StateObject private var accessibilityManager = AccessibilityManager.shared
    @State private var searchText = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedSearchEngine = "google"
    
    // 应用数据 - 使用更贴近真实应用的图标和颜色
    private let apps = [
        AppInfo(name: "淘宝", icon: "bag.fill", color: .green, urlScheme: "taobao://s.taobao.com/search?q="),
        AppInfo(name: "拼多多", icon: "cart.fill", color: .green, urlScheme: "pinduoduo://search?keyword="),
        AppInfo(name: "知乎", icon: "bubble.left.and.bubble.right.fill", color: .green, urlScheme: "zhihu://search?q="),
        AppInfo(name: "抖音", icon: "music.note", color: .green, urlScheme: "snssdk1128://search?keyword="),
        AppInfo(name: "美团", icon: "fork.knife", color: .green, urlScheme: "imeituan://www.meituan.com/search?q="),
        AppInfo(name: "豆瓣", icon: "book.fill", color: .green, urlScheme: "douban://search?q="),
        AppInfo(name: "微博", icon: "at", color: .green, urlScheme: "sinaweibo://search?q="),
        AppInfo(name: "bilibili", icon: "tv.fill", color: .green, urlScheme: "bilibili://search?keyword="),
        AppInfo(name: "YouTube", icon: "play.rectangle.fill", color: .green, urlScheme: "youtube://results?search_query="),
        AppInfo(name: "京东", icon: "shippingbox.fill", color: .green, urlScheme: "openapp.jdmobile://virtual?params={\"category\":\"jump\",\"des\":\"search\",\"keyword\":\""),
        AppInfo(name: "闲鱼", icon: "fish.fill", color: .green, urlScheme: "fleamarket://search?q="),
        AppInfo(name: "小红书", icon: "heart.fill", color: .green, urlScheme: "xhsdiscover://search/result?keyword="),
        AppInfo(name: "网易云音乐", icon: "music.note.list", color: .green, urlScheme: "orpheuswidget://search?keyword="),
        AppInfo(name: "QQ音乐", icon: "music.quarternote.3", color: .green, urlScheme: "qqmusic://search?key=")
    ]
    
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
                            .onSubmit {
                                // 可以添加默认搜索行为
                            }
                            .onTapGesture {
                                accessibilityManager.setSearchFocused(true)
                            }
                        
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
                .padding(.bottom, 24)
                .background(Color(.systemBackground))
                
                // 应用网格
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 24) {
                        ForEach(apps, id: \.name) { app in
                            AppButton(app: app, searchText: searchText) {
                                searchInApp(app: app)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("应用搜索")
            .navigationBarTitleDisplayMode(.large)
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                setupNotificationObservers()
                handleDeepLinkIfNeeded()
            }
            .onDisappear {
                removeNotificationObservers()
            }
        }
    }

    // MARK: - 深度链接处理
    private func handleDeepLinkIfNeeded() {
        // 处理应用搜索深度链接
        if !deepLinkHandler.selectedApp.isEmpty {
            // 根据应用ID找到对应的应用
            if let app = findAppById(deepLinkHandler.selectedApp) {
                // 如果有搜索查询，设置搜索文本
                if !deepLinkHandler.searchQuery.isEmpty {
                    searchText = deepLinkHandler.searchQuery
                }
                print("🔗 深度链接处理: 选择应用 \(app.name), 搜索: \(searchText)")
            }

            // 清除深度链接状态
            deepLinkHandler.selectedApp = ""
            deepLinkHandler.searchQuery = ""
        }

        // 处理搜索引擎深度链接
        if !deepLinkHandler.selectedEngine.isEmpty {
            selectedSearchEngine = deepLinkHandler.selectedEngine

            // 如果有搜索查询，设置搜索文本
            if !deepLinkHandler.searchQuery.isEmpty {
                searchText = deepLinkHandler.searchQuery
            }

            print("🔗 深度链接处理: 选择搜索引擎 \(selectedSearchEngine), 搜索: \(searchText)")

            // 清除深度链接状态
            deepLinkHandler.selectedEngine = ""
            deepLinkHandler.searchQuery = ""
        }
    }

    private func findAppById(_ appId: String) -> AppInfo? {
        // 根据应用ID映射到应用名称
        let appNameMap: [String: String] = [
            "taobao": "淘宝",
            "pinduoduo": "拼多多",
            "zhihu": "知乎",
            "douyin": "抖音",
            "meituan": "美团",
            "douban": "豆瓣",
            "weibo": "微博",
            "bilibili": "bilibili",
            "youtube": "YouTube",
            "jd": "京东",
            "xianyu": "闲鱼",
            "xiaohongshu": "小红书",
            "netease_music": "网易云音乐",
            "qqmusic": "QQ音乐"
        ]

        if let appName = appNameMap[appId] {
            return apps.first { $0.name == appName }
        }

        return nil
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
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url) { success in
                    if !success {
                        DispatchQueue.main.async {
                            alertMessage = "无法打开\(app.name)应用，请确保已安装该应用"
                            showingAlert = true
                        }
                    }
                }
            } else {
                alertMessage = "未安装\(app.name)应用或不支持该搜索功能"
                showingAlert = true
            }
        }
    }

    // MARK: - 通知处理
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .searchInApp,
            object: nil,
            queue: .main
        ) { notification in
            if let data = notification.object as? [String: String],
               let appName = data["app"],
               let query = data["query"] {
                handleAppSearch(appName: appName, query: query)
            }
        }

        NotificationCenter.default.addObserver(
            forName: .performSearch,
            object: nil,
            queue: .main
        ) { notification in
            if let query = notification.object as? String {
                searchText = query
            }
        }

        NotificationCenter.default.addObserver(
            forName: .switchSearchEngine,
            object: nil,
            queue: .main
        ) { notification in
            if let engine = notification.object as? String {
                selectedSearchEngine = engine
            }
        }

        // 智能搜索通知处理
        NotificationCenter.default.addObserver(
            forName: .smartSearchWithClipboard,
            object: nil,
            queue: .main
        ) { notification in
            if let data = notification.object as? [String: String],
               let engine = data["engine"],
               let query = data["query"] {
                handleSmartSearchWithClipboard(engine: engine, query: query)
            }
        }

        // 应用搜索通知处理
        NotificationCenter.default.addObserver(
            forName: .appSearchWithClipboard,
            object: nil,
            queue: .main
        ) { notification in
            if let data = notification.object as? [String: String],
               let appId = data["app"],
               let query = data["query"] {
                handleAppSearchWithClipboard(appId: appId, query: query)
            }
        }

        // 直接应用搜索通知处理
        NotificationCenter.default.addObserver(
            forName: .directAppSearch,
            object: nil,
            queue: .main
        ) { notification in
            if let data = notification.object as? [String: String],
               let appId = data["app"],
               let query = data["query"] {
                handleDirectAppSearch(appId: appId, query: query)
            }
        }

        // 激活应用搜索通知处理
        NotificationCenter.default.addObserver(
            forName: .activateAppSearch,
            object: nil,
            queue: .main
        ) { notification in
            if let data = notification.object as? [String: String],
               let appId = data["app"],
               let query = data["query"] {
                handleActivateAppSearch(appId: appId, query: query)
            }
        }
    }

    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 智能搜索处理
    private func handleSmartSearchWithClipboard(engine: String, query: String) {
        print("🔍 智能搜索: 引擎=\(engine), 查询=\(query)")

        // 设置搜索引擎
        selectedSearchEngine = engine

        // 设置搜索文本
        searchText = query

        // 自动执行搜索
        if !query.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                performSearch()
            }
        }
    }

    // MARK: - 应用搜索处理
    private func handleAppSearchWithClipboard(appId: String, query: String) {
        print("📱 应用搜索: 应用=\(appId), 查询=\(query)")

        // 设置搜索文本
        if !query.isEmpty {
            searchText = query
        } else {
            searchText = "热门推荐" // 默认搜索词
        }

        // 查找并激活对应的应用
        if let app = apps.first(where: { getAppIdentifier(from: $0.name) == appId }) {
            // 直接跳转到应用搜索结果
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                openApp(app)
            }
        }
    }

    // 获取应用标识符
    private func getAppIdentifier(from appName: String) -> String {
        let appMapping: [String: String] = [
            "淘宝": "taobao",
            "微信": "wechat",
            "抖音": "douyin",
            "支付宝": "alipay",
            "京东": "jd",
            "美团": "meituan"
        ]
        return appMapping[appName] ?? appName.lowercased()
    }

    // MARK: - 激活应用搜索处理
    private func handleActivateAppSearch(appId: String, query: String) {
        print("🎯 激活应用搜索: 应用=\(appId), 查询=\(query)")

        // 查找对应的应用
        if let appIndex = apps.firstIndex(where: { getAppIdentifier(from: $0.name) == appId }) {
            // 选中对应的应用
            selectedAppIndex = appIndex

            // 设置搜索文本
            if !query.isEmpty {
                searchText = query

                // 自动执行搜索
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    performSearch()
                }
            } else {
                // 清空搜索文本，等待用户输入
                searchText = ""

                // 聚焦搜索框
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // 这里可以添加聚焦搜索框的代码
                }
            }
        }
    }

    // MARK: - 直接应用搜索处理
    private func handleDirectAppSearch(appId: String, query: String) {
        print("🚀 直接应用搜索: 应用=\(appId), 查询=\(query)")

        // 查找对应的应用
        guard let app = apps.first(where: { getAppIdentifier(from: $0.name) == appId }) else {
            print("❌ 未找到应用: \(appId)")
            return
        }

        print("✅ 找到应用: \(app.name)")

        // 构建搜索URL
        let searchQuery = query.isEmpty ? "热门推荐" : query
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchQuery

        var searchURL: String

        // 根据应用类型构建不同的搜索URL
        switch appId {
        case "taobao":
            searchURL = "taobao://s.taobao.com?q=\(encodedQuery)"
        case "jd":
            searchURL = "openapp.jdmobile://virtual?params={\"category\":\"jump\",\"des\":\"search\",\"keyWord\":\"\(encodedQuery)\"}"
        case "meituan":
            searchURL = "imeituan://www.meituan.com/search?q=\(encodedQuery)"
        case "douyin":
            searchURL = "snssdk1128://search?keyword=\(encodedQuery)"
        case "wechat":
            // 微信搜索比较特殊，直接打开微信
            searchURL = "weixin://"
        case "alipay":
            // 支付宝搜索
            searchURL = "alipay://platformapi/startapp?appId=20000067&query=\(encodedQuery)"
        default:
            // 默认使用应用的URL scheme
            searchURL = app.urlScheme
        }

        print("🔗 打开搜索URL: \(searchURL)")

        // 直接打开应用搜索结果
        if let url = URL(string: searchURL) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url) { success in
                    if success {
                        print("✅ 成功打开应用搜索: \(app.name)")
                    } else {
                        print("❌ 打开应用搜索失败: \(app.name)")
                        // 如果直接搜索失败，尝试打开应用主页
                        if let fallbackURL = URL(string: app.urlScheme) {
                            UIApplication.shared.open(fallbackURL)
                        }
                    }
                }
            }
        }
    }

    private func handleAppSearch(appName: String, query: String) {
        print("📱 处理应用搜索: \(appName), 查询: \(query)")

        // 设置搜索文本（如果有查询内容）
        if !query.isEmpty {
            searchText = query
        }

        // 查找对应的应用
        if let app = apps.first(where: { $0.name.lowercased().contains(appName.lowercased()) }) {
            print("📱 找到应用: \(app.name)")
            // 直接选择应用，无需输入内容
            selectAppDirectly(app: app, query: query)
        } else {
            // 尝试根据应用ID匹配
            let appMapping: [String: String] = [
                "taobao": "淘宝",
                "jd": "京东",
                "meituan": "美团",
                "douyin": "抖音",
                "wechat": "微信",
                "alipay": "支付宝"
            ]

            if let mappedName = appMapping[appName.lowercased()],
               let app = apps.first(where: { $0.name == mappedName }) {
                print("📱 通过映射找到应用: \(app.name)")
                selectAppDirectly(app: app, query: query)
            } else {
                print("📱 未找到应用: \(appName)")
                alertMessage = "未找到应用: \(appName)"
                showingAlert = true
            }
        }
    }

    // 直接选择应用，绕过输入限制
    private func selectAppDirectly(app: App, query: String) {
        // 如果有查询内容，直接搜索
        if !query.isEmpty {
            searchText = query
            searchInApp(app: app)
        } else {
            // 没有查询内容时，设置一个默认搜索词或直接打开应用搜索页面
            searchText = "热门推荐" // 设置默认搜索词

            // 延迟执行，确保UI更新
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.searchInApp(app: app)
            }
        }
    }
}

struct AppInfo {
    let name: String
    let icon: String
    let color: Color
    let urlScheme: String
}

struct AppButton: View {
    let app: AppInfo
    let searchText: String
    let action: () -> Void
    @State private var isPressed = false
    @State private var isInstalled = false

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                action()
            }
        }) {
            VStack(spacing: 12) {
                // 应用图标
                ZStack {
                    Circle()
                        .fill(app.color.opacity(isInstalled ? 0.2 : 0.1))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(isInstalled ? app.color.opacity(0.3) : Color.clear, lineWidth: 2)
                        )

                    Image(systemName: app.icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(isInstalled ? app.color : app.color.opacity(0.6))

                    // 已安装指示器
                    if isInstalled {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 16, height: 16)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                    .offset(x: 8, y: 8)
                            }
                        }
                    }
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)

                // 应用名称
                VStack(spacing: 2) {
                    Text(app.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isInstalled ? .primary : .secondary)
                        .lineLimit(1)

                    if !isInstalled {
                        Text("未安装")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
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
        .onAppear {
            checkIfInstalled()
        }
    }

    private func checkIfInstalled() {
        // 提取URL scheme的协议部分
        let scheme = String(app.urlScheme.prefix(while: { $0 != ":" }))
        if let url = URL(string: scheme + "://") {
            isInstalled = UIApplication.shared.canOpenURL(url)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
