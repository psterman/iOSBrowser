//
//  EnhancedContentView.swift
//  iOSBrowser
//
//  增强的主视图 - 集成所有新功能
//

import SwiftUI

struct EnhancedContentView: View {
    @StateObject private var dataSyncCenter = DataSyncCenter.shared
    @StateObject private var contentBlockManager = ContentBlockManager.shared
    @StateObject private var httpsManager = HTTPSManager.shared
    @StateObject private var encryptionManager = DataEncryptionManager.shared
    
    @State private var selectedTab = 0
    @State private var showingAggregatedSearch = false
    @State private var showingEnhancedAIChat = false
    @State private var showingSettings = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 搜索Tab
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("搜索")
                }
                .tag(0)
            
            // AI聊天Tab
            EnhancedAIChatView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("AI对话")
                }
                .tag(1)
            
            // 聚合搜索Tab
            AggregatedSearchView()
                .tabItem {
                    Image(systemName: "network")
                    Text("聚合搜索")
                }
                .tag(2)
            
            // 浏览器Tab
            BrowserView()
                .tabItem {
                    Image(systemName: "globe")
                    Text("浏览器")
                }
                .tag(3)
            
            // 设置Tab
            EnhancedSettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("设置")
                }
                .tag(4)
        }
        .accentColor(.themeGreen)
        .onReceive(NotificationCenter.default.publisher(for: .showAggregatedSearch)) { notification in
            if let query = notification.object as? String {
                // 跳转到聚合搜索并设置查询
                selectedTab = 2
            }
        }
    }
}

// MARK: - 增强设置视图
struct EnhancedSettingsView: View {
    @StateObject private var contentBlockManager = ContentBlockManager.shared
    @StateObject private var httpsManager = HTTPSManager.shared
    @StateObject private var encryptionManager = DataEncryptionManager.shared
    @State private var selectedSection = 0
    
    var body: some View {
        NavigationView {
            List {
                // 内容拦截设置
                Section(header: Text("内容拦截")) {
                    Toggle("启用内容拦截", isOn: $contentBlockManager.isEnabled)
                        .onChange(of: contentBlockManager.isEnabled) { _ in
                            contentBlockManager.saveSettings()
                        }
                    
                    if contentBlockManager.isEnabled {
                        Toggle("拦截广告", isOn: $contentBlockManager.blockAds)
                            .onChange(of: contentBlockManager.blockAds) { _ in
                                contentBlockManager.saveSettings()
                            }
                        
                        Toggle("拦截追踪器", isOn: $contentBlockManager.blockTrackers)
                            .onChange(of: contentBlockManager.blockTrackers) { _ in
                                contentBlockManager.saveSettings()
                            }
                        
                        Toggle("拦截恶意软件", isOn: $contentBlockManager.blockMalware)
                            .onChange(of: contentBlockManager.blockMalware) { _ in
                                contentBlockManager.saveSettings()
                            }
                        
                        NavigationLink("自定义规则") {
                            CustomRulesView()
                        }
                        
                        NavigationLink("拦截统计") {
                            BlockingStatsView()
                        }
                    }
                }
                
                // HTTPS设置
                Section(header: Text("安全传输")) {
                    Toggle("仅使用HTTPS", isOn: $httpsManager.isHTTPSOnly)
                        .onChange(of: httpsManager.isHTTPSOnly) { _ in
                            httpsManager.saveSettings()
                        }
                    
                    Toggle("证书固定", isOn: $httpsManager.certificatePinning)
                        .onChange(of: httpsManager.certificatePinning) { _ in
                            httpsManager.saveSettings()
                        }
                    
                    NavigationLink("连接信息") {
                        ConnectionInfoView()
                    }
                }
                
                // 数据加密设置
                Section(header: Text("数据加密")) {
                    Toggle("启用数据加密", isOn: $encryptionManager.isEncryptionEnabled)
                        .onChange(of: encryptionManager.isEncryptionEnabled) { _ in
                            encryptionManager.saveSettings()
                        }
                    
                    if encryptionManager.isEncryptionEnabled {
                        NavigationLink("加密统计") {
                            EncryptionStatsView()
                        }
                        
                        Button("重置加密密钥") {
                            resetEncryptionKey()
                        }
                        .foregroundColor(.red)
                        
                        Button("验证加密状态") {
                            verifyEncryption()
                        }
                        .foregroundColor(.themeGreen)
                    }
                }
                
                // 原有设置
                Section(header: Text("应用设置")) {
                    NavigationLink("小组件配置") {
                        WidgetConfigView()
                    }
                    
                    NavigationLink("API配置") {
                        APIConfigView()
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
    
    private func resetEncryptionKey() {
        do {
            try encryptionManager.resetEncryptionKey()
        } catch {
            print("重置加密密钥失败: \(error)")
        }
    }
    
    private func verifyEncryption() {
        let isValid = encryptionManager.verifyEncryption()
        print("加密验证结果: \(isValid ? "成功" : "失败")")
    }
}

// MARK: - 自定义规则视图
struct CustomRulesView: View {
    @StateObject private var contentBlockManager = ContentBlockManager.shared
    @State private var newRule = ""
    
    var body: some View {
        List {
            Section(header: Text("添加新规则")) {
                HStack {
                    TextField("输入过滤规则 (例如: *.ad.com/*)", text: $newRule)
                    
                    Button("添加") {
                        if !newRule.isEmpty {
                            contentBlockManager.addCustomRule(newRule)
                            newRule = ""
                        }
                    }
                    .disabled(newRule.isEmpty)
                }
            }
            
            Section(header: Text("自定义规则")) {
                ForEach(contentBlockManager.customRules, id: \.self) { rule in
                    HStack {
                        Text(rule)
                        Spacer()
                        Button("删除") {
                            contentBlockManager.removeCustomRule(rule)
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("自定义规则")
    }
}

// MARK: - 拦截统计视图
struct BlockingStatsView: View {
    @StateObject private var contentBlockManager = ContentBlockManager.shared
    @State private var stats = BlockingStats(totalRequests: 0, blockedRequests: 0, adsBlocked: 0, trackersBlocked: 0, malwareBlocked: 0)
    
    var body: some View {
        List {
            Section(header: Text("拦截统计")) {
                StatRow(title: "总请求数", value: "\(stats.totalRequests)")
                StatRow(title: "已拦截", value: "\(stats.blockedRequests)")
                StatRow(title: "拦截率", value: String(format: "%.1f%%", stats.blockingPercentage))
            }
            
            Section(header: Text("分类统计")) {
                StatRow(title: "广告拦截", value: "\(stats.adsBlocked)")
                StatRow(title: "追踪器拦截", value: "\(stats.trackersBlocked)")
                StatRow(title: "恶意软件拦截", value: "\(stats.malwareBlocked)")
            }
        }
        .navigationTitle("拦截统计")
        .onAppear {
            stats = contentBlockManager.getBlockingStats()
        }
    }
}

// MARK: - 连接信息视图
struct ConnectionInfoView: View {
    @StateObject private var httpsManager = HTTPSManager.shared
    @State private var connectionInfo = ConnectionInfo(isConnected: false, connectionType: "Unknown", isSecure: false, totalRequests: 0, successRate: 0)
    
    var body: some View {
        List {
            Section(header: Text("连接状态")) {
                StatRow(title: "连接状态", value: connectionInfo.isConnected ? "已连接" : "未连接")
                StatRow(title: "连接类型", value: connectionInfo.connectionType)
                StatRow(title: "安全状态", value: connectionInfo.isSecure ? "安全" : "不安全")
            }
            
            Section(header: Text("请求统计")) {
                StatRow(title: "总请求数", value: "\(connectionInfo.totalRequests)")
                StatRow(title: "成功率", value: String(format: "%.1f%%", connectionInfo.successRate))
            }
        }
        .navigationTitle("连接信息")
        .onAppear {
            connectionInfo = httpsManager.getConnectionInfo()
        }
    }
}

// MARK: - 加密统计视图
struct EncryptionStatsView: View {
    @StateObject private var encryptionManager = DataEncryptionManager.shared
    @State private var stats = EncryptionStats()
    
    var body: some View {
        List {
            Section(header: Text("加密统计")) {
                StatRow(title: "加密尝试", value: "\(stats.encryptionAttempts)")
                StatRow(title: "加密成功", value: "\(stats.successfulEncryptions)")
                StatRow(title: "加密失败", value: "\(stats.failedEncryptions)")
                StatRow(title: "加密成功率", value: String(format: "%.1f%%", stats.encryptionSuccessRate))
            }
            
            Section(header: Text("解密统计")) {
                StatRow(title: "解密尝试", value: "\(stats.decryptionAttempts)")
                StatRow(title: "解密成功", value: "\(stats.successfulDecryptions)")
                StatRow(title: "解密失败", value: "\(stats.failedDecryptions)")
                StatRow(title: "解密成功率", value: String(format: "%.1f%%", stats.decryptionSuccessRate))
            }
        }
        .navigationTitle("加密统计")
        .onAppear {
            stats = encryptionManager.getEncryptionStats()
        }
    }
}

// MARK: - 统计行组件
struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.themeGreen)
                .fontWeight(.medium)
        }
    }
}

// MARK: - 通知扩展
extension Notification.Name {
    static let showAggregatedSearch = Notification.Name("showAggregatedSearch")
} 