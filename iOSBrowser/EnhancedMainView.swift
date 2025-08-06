//
//  EnhancedMainView.swift
//  iOSBrowser
//
//  增强的主视图 - 为每个tab添加设置功能
//

import SwiftUI

struct EnhancedMainView: View {
    @StateObject private var webViewModel = WebViewModel()
    @StateObject private var accessibilityManager = AccessibilityManager.shared
    @EnvironmentObject var deepLinkHandler: DeepLinkHandler
    @State private var selectedTab = 0
    
    // 各tab的设置状态
    @State private var showingSearchSettings = false
    @State private var showingAISettings = false
    @State private var showingAggregatedSearchSettings = false
    @State private var showingBrowserSettings = false
    @State private var showingGeneralSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // 主内容区域
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // 搜索Tab
                    NavigationView {
                        SearchView()
                            .navigationTitle("搜索")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: { showingSearchSettings = true }) {
                                        Image(systemName: "gearshape.fill")
                                            .foregroundColor(.themeGreen)
                                    }
                                }
                            }
                    }
                    .frame(width: geometry.size.width)
                    
                    // AI聊天Tab
                    NavigationView {
                        SimpleAIChatView()
                            .navigationTitle("AI对话")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: { showingAISettings = true }) {
                                        Image(systemName: "gearshape.fill")
                                            .foregroundColor(.themeGreen)
                                    }
                                }
                            }
                    }
                    .frame(width: geometry.size.width)
                    
                    // 聚合搜索Tab
                    NavigationView {
                        AggregatedSearchView()
                            .navigationTitle("聚合搜索")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: { showingAggregatedSearchSettings = true }) {
                                        Image(systemName: "gearshape.fill")
                                            .foregroundColor(.themeGreen)
                                    }
                                }
                            }
                    }
                    .frame(width: geometry.size.width)
                    
                    // 浏览器Tab
                    NavigationView {
                        EnhancedBrowserView(viewModel: webViewModel)
                            .navigationTitle("浏览器")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: { showingBrowserSettings = true }) {
                                        Image(systemName: "gearshape.fill")
                                            .foregroundColor(.themeGreen)
                                    }
                                }
                            }
                    }
                    .frame(width: geometry.size.width)
                    
                    // 设置Tab
                    NavigationView {
                        WidgetConfigView()
                            .navigationTitle("设置")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: { showingGeneralSettings = true }) {
                                        Image(systemName: "gearshape.fill")
                                            .foregroundColor(.themeGreen)
                                    }
                                }
                            }
                    }
                    .frame(width: geometry.size.width)
                }
                .offset(x: -CGFloat(selectedTab) * geometry.size.width)
                .animation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0), value: selectedTab)
                .clipped()
            }

            // 底部Tab栏
            WeChatTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
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
            }
        }
        // 各tab的设置sheet
        .sheet(isPresented: $showingSearchSettings) {
            SearchSettingsView()
        }
        .sheet(isPresented: $showingAISettings) {
            AISettingsView()
        }
        .sheet(isPresented: $showingAggregatedSearchSettings) {
            AggregatedSearchSettingsView()
        }
        .sheet(isPresented: $showingBrowserSettings) {
            BrowserSettingsView()
        }
        .sheet(isPresented: $showingGeneralSettings) {
            GeneralSettingsView()
        }
    }

    // MARK: - 应用启动时初始化小组件数据
    private func initializeWidgetDataOnAppStart() {
        print("🚀 应用启动时初始化小组件数据...")
        
        let defaults = UserDefaults.standard
        var needsSync = false

        // 检查并初始化搜索引擎数据
        if defaults.stringArray(forKey: "iosbrowser_engines")?.isEmpty != false {
            let defaultEngines = ["baidu", "google"]
            defaults.set(defaultEngines, forKey: "iosbrowser_engines")
            needsSync = true
        }

        // 检查并初始化应用数据
        if defaults.stringArray(forKey: "iosbrowser_apps")?.isEmpty != false {
            let defaultApps = ["taobao", "zhihu", "douyin"]
            defaults.set(defaultApps, forKey: "iosbrowser_apps")
            needsSync = true
        }

        // 检查并初始化AI助手数据
        if defaults.stringArray(forKey: "iosbrowser_ai")?.isEmpty != false {
            let defaultAI = ["deepseek", "qwen"]
            defaults.set(defaultAI, forKey: "iosbrowser_ai")
            needsSync = true
        }

        // 检查并初始化快捷操作数据
        if defaults.stringArray(forKey: "iosbrowser_actions")?.isEmpty != false {
            let defaultActions = ["search", "bookmark"]
            defaults.set(defaultActions, forKey: "iosbrowser_actions")
            needsSync = true
        }

        if needsSync {
            defaults.synchronize()
        }
    }

    private func handleDeepLink(_ url: URL) {
        deepLinkHandler.handleDeepLink(url)
    }
}

// MARK: - 搜索设置视图
struct SearchSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var dataSyncCenter = DataSyncCenter.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("搜索引擎设置")) {
                    NavigationLink("搜索引擎配置") {
                        UnifiedSearchEngineConfigView()
                    }
                    
                    NavigationLink("应用搜索配置") {
                        UnifiedAppConfigView()
                    }
                }
                
                Section(header: Text("搜索功能")) {
                    Toggle("智能跳转", isOn: .constant(true))
                    Toggle("搜索历史", isOn: .constant(true))
                    Toggle("快速搜索建议", isOn: .constant(true))
                }
                
                Section(header: Text("分类管理")) {
                    NavigationLink("分类设置") {
                        Text("分类管理功能")
                            .navigationTitle("分类管理")
                    }
                }
            }
            .navigationTitle("搜索设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - AI设置视图
struct AISettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var dataSyncCenter = DataSyncCenter.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("AI助手配置")) {
                    NavigationLink("AI助手选择") {
                        UnifiedAIConfigView()
                    }
                    
                    NavigationLink("API配置") {
                        APIConfigView()
                    }
                }
                
                Section(header: Text("平台对话人")) {
                    NavigationLink("平台助手管理") {
                        Text("平台助手管理功能")
                            .navigationTitle("平台助手管理")
                    }
                    
                    Toggle("自动加载搜索结果", isOn: .constant(true))
                    Toggle("智能对话建议", isOn: .constant(true))
                }
                
                Section(header: Text("对话设置")) {
                    Toggle("保存对话历史", isOn: .constant(true))
                    Toggle("语音输入", isOn: .constant(false))
                    Toggle("自动翻译", isOn: .constant(false))
                }
            }
            .navigationTitle("AI设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 聚合搜索设置视图
struct AggregatedSearchSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPlatforms: Set<String> = ["bilibili", "toutiao", "wechat_mp", "ximalaya"]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("搜索平台")) {
                    PlatformToggleRow(title: "B站", isOn: $selectedPlatforms.contains("bilibili")) {
                        if selectedPlatforms.contains("bilibili") {
                            selectedPlatforms.remove("bilibili")
                        } else {
                            selectedPlatforms.insert("bilibili")
                        }
                    }
                    
                    PlatformToggleRow(title: "今日头条", isOn: $selectedPlatforms.contains("toutiao")) {
                        if selectedPlatforms.contains("toutiao") {
                            selectedPlatforms.remove("toutiao")
                        } else {
                            selectedPlatforms.insert("toutiao")
                        }
                    }
                    
                    PlatformToggleRow(title: "微信公众号", isOn: $selectedPlatforms.contains("wechat_mp")) {
                        if selectedPlatforms.contains("wechat_mp") {
                            selectedPlatforms.remove("wechat_mp")
                        } else {
                            selectedPlatforms.insert("wechat_mp")
                        }
                    }
                    
                    PlatformToggleRow(title: "喜马拉雅", isOn: $selectedPlatforms.contains("ximalaya")) {
                        if selectedPlatforms.contains("ximalaya") {
                            selectedPlatforms.remove("ximalaya")
                        } else {
                            selectedPlatforms.insert("ximalaya")
                        }
                    }
                }
                
                Section(header: Text("搜索行为")) {
                    Toggle("优先打开应用", isOn: .constant(true))
                    Toggle("显示搜索结果预览", isOn: .constant(true))
                    Toggle("保存搜索历史", isOn: .constant(true))
                }
                
                Section(header: Text("快速搜索")) {
                    NavigationLink("搜索建议管理") {
                        Text("搜索建议管理功能")
                            .navigationTitle("搜索建议管理")
                    }
                }
            }
            .navigationTitle("聚合搜索设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 浏览器设置视图
struct BrowserSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var contentBlockManager = ContentBlockManager.shared
    @StateObject private var httpsManager = HTTPSManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("内容拦截")) {
                    Toggle("启用内容拦截", isOn: $contentBlockManager.isEnabled)
                    
                    if contentBlockManager.isEnabled {
                        Toggle("拦截广告", isOn: $contentBlockManager.blockAds)
                        Toggle("拦截追踪器", isOn: $contentBlockManager.blockTrackers)
                        Toggle("拦截恶意软件", isOn: $contentBlockManager.blockMalware)
                    }
                }
                
                Section(header: Text("安全传输")) {
                    Toggle("仅使用HTTPS", isOn: $httpsManager.isHTTPSOnly)
                    Toggle("证书固定", isOn: $httpsManager.certificatePinning)
                }
                
                Section(header: Text("浏览功能")) {
                    Toggle("自动刷新", isOn: .constant(false))
                    Toggle("保存浏览历史", isOn: .constant(true))
                    Toggle("书签同步", isOn: .constant(true))
                }
                
                Section(header: Text("搜索引擎")) {
                    NavigationLink("默认搜索引擎") {
                        Text("搜索引擎选择")
                            .navigationTitle("默认搜索引擎")
                    }
                }
            }
            .navigationTitle("浏览器设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 通用设置视图
struct GeneralSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var encryptionManager = DataEncryptionManager.shared
    @StateObject private var accessibilityManager = AccessibilityManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("数据安全")) {
                    Toggle("启用数据加密", isOn: $encryptionManager.isEncryptionEnabled)
                    
                    if encryptionManager.isEncryptionEnabled {
                        NavigationLink("加密统计") {
                            Text("加密统计信息")
                                .navigationTitle("加密统计")
                        }
                    }
                }
                
                Section(header: Text("小组件配置")) {
                    NavigationLink("小组件设置") {
                        WidgetConfigView()
                    }
                }
                
                Section(header: Text("使用帮助")) {
                    NavigationLink("手势操作指南") {
                        GestureGuideView()
                    }
                }
                
                Section(header: Text("适老化设置")) {
                    NavigationLink("适老化模式") {
                        AccessibilityModeToggleView()
                    }
                }
                
                Section(header: Text("应用信息")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("构建版本")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("通用设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: accessibilityManager.getFontSize(16), weight: .medium))
                }
            }
        }
    }
}

// MARK: - 平台切换行
struct PlatformToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Toggle("", isOn: $isOn)
                .onChange(of: isOn) { _ in
                    action()
                }
        }
    }
} 