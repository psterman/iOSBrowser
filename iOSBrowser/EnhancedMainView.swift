//
//  EnhancedMainView.swift
//  iOSBrowser
//
//  增强的主视图 - 为每个tab添加设置功能
//

import SwiftUI

struct EnhancedMainView: View {
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
            // 应用启动时立即初始化小组件数据
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
        }
        
        print("🚨🚨🚨 ===== 应用启动时初始化小组件数据完成 =====")
    }
    
    private func handleDeepLink(_ url: URL) {
        print("🔗 收到深度链接: \(url)")
        deepLinkHandler.handleDeepLink(url)
    }
}

// MARK: - 微信风格的Tab栏
struct WeChatTabBar: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        ("magnifyingglass", "搜索"),
        ("safari", "浏览"),
        ("message", "AI聊天"),
        ("gearshape", "设置")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<4) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].0)
                            .font(.system(size: 24))
                        Text(tabs[index].1)
                            .font(.system(size: 10))
                    }
                    .foregroundColor(selectedTab == index ? .green : .gray)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.systemGray4)),
            alignment: .top
        )
    }
}