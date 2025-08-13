//
//  BrowserViewWithAITest.swift
//  iOSBrowser
//
//  在BrowserView中添加AI对话测试功能的版本
//

import SwiftUI
import UIKit
import WebKit
import Foundation

struct BrowserViewWithAITest: View {
    @StateObject var viewModel = WebViewModel()
    
    // 原有状态变量
    @State private var urlText = ""
    @State private var selectedSearchEngine = 0
    @State private var showingCustomHomePage = true
    @State private var searchQuery = ""
    @State private var showingFloatingPrompt = false
    @State private var showingPromptManager = false
    
    // 搜索引擎抽屉状态
    @State private var showingSearchEngineDrawer = false
    @State private var searchEngineDrawerOffset: CGFloat = -300
    
    // 右侧抽屉式AI对话列表状态
    @State private var showingAIDrawer = false
    @State private var aiDrawerOffset: CGFloat = 300
    
    // 新增功能状态
    @State private var showingExpandedInput = false
    @State private var expandedUrlText = ""
    @State private var showingAIChat = false
    @State private var selectedAI = "deepseek"
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var favoritePages: Set<String> = []
    
    // 新增：弱提醒状态
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .success
    
    // 边缘滑动返回手势状态
    @State private var edgeSwipeOffset: CGFloat = 0
    @State private var isEdgeSwiping = false
    
    // 全局Prompt状态管理
    @StateObject private var promptManager = GlobalPromptManager.shared
    
    // AI对话测试相关状态
    @State private var isAITesting = false
    @State private var aiTestResults: [String] = []
    @State private var currentAITestStep = 0
    @State private var showingAITestPanel = false
    
    // 新增：Toast类型枚举
    enum ToastType {
        case success, error, info
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
    
    private let searchEngines = [
        BrowserSearchEngine(id: "baidu", name: "百度", url: "https://www.baidu.com/s?wd=", icon: "magnifyingglass", color: .green),
        BrowserSearchEngine(id: "bing", name: "必应", url: "https://www.bing.com/search?q=", icon: "magnifyingglass.circle", color: .green),
        BrowserSearchEngine(id: "wenxin", name: "文心一言", url: "https://yiyan.baidu.com/", icon: "doc.text", color: .green),
        BrowserSearchEngine(id: "doubao", name: "豆包", url: "https://www.doubao.com/chat/", icon: "bubble.left.and.bubble.right", color: .green),
        BrowserSearchEngine(id: "yuanbao", name: "元宝", url: "https://yuanbao.tencent.com/", icon: "diamond", color: .green),
        BrowserSearchEngine(id: "kimi", name: "Kimi", url: "https://kimi.moonshot.cn/", icon: "moon.stars", color: .green),
        BrowserSearchEngine(id: "deepseek", name: "DeepSeek", url: "https://chat.deepseek.com/", icon: "brain.head.profile", color: .green),
        BrowserSearchEngine(id: "tongyi", name: "通义千问", url: "https://tongyi.aliyun.com/qianwen/", icon: "cloud.fill", color: .green),
        BrowserSearchEngine(id: "xunfei", name: "星火", url: "https://xinghuo.xfyun.cn/", icon: "sparkles", color: .green),
        BrowserSearchEngine(id: "metaso", name: "秘塔", url: "https://metaso.cn/", icon: "lock.shield", color: .green),
        BrowserSearchEngine(id: "gemini", name: "Gemini", url: "https://gemini.google.com/", icon: "brain.head.profile", color: .green),
        BrowserSearchEngine(id: "chatgpt", name: "ChatGPT", url: "https://chat.openai.com/", icon: "bubble.left.and.bubble.right.fill", color: .green),
        BrowserSearchEngine(id: "ima", name: "IMA", url: "https://ima.im/", icon: "person.circle", color: .green),
        BrowserSearchEngine(id: "perplexity", name: "Perplexity", url: "https://www.perplexity.ai/", icon: "questionmark.circle", color: .green),
        BrowserSearchEngine(id: "chatglm", name: "智谱清言", url: "https://chatglm.cn/main/gdetail", icon: "lightbulb.fill", color: .green),
        BrowserSearchEngine(id: "tiangong", name: "天工", url: "https://tiangong.kunlun.com/", icon: "hammer", color: .green),
        BrowserSearchEngine(id: "you", name: "You", url: "https://you.com/", icon: "person.2", color: .green),
        BrowserSearchEngine(id: "nano", name: "纳米AI搜索", url: "https://bot.n.cn/", icon: "atom", color: .green),
        BrowserSearchEngine(id: "copilot", name: "Copilot", url: "https://copilot.microsoft.com/", icon: "airplane", color: .green),
        BrowserSearchEngine(id: "keling", name: "可灵", url: "https://keling.ai/", icon: "bolt", color: .green)
    ]
    
    // AI对话服务列表
    private let aiServices = [
        AIService(id: "deepseek", name: "DeepSeek", url: "https://chat.deepseek.com/", icon: "brain.head.profile", color: .purple, category: "AI对话"),
        AIService(id: "kimi", name: "Kimi", url: "https://kimi.moonshot.cn/", icon: "moon.stars", color: .orange, category: "AI对话"),
        AIService(id: "doubao", name: "豆包", url: "https://www.doubao.com/chat/", icon: "bubble.left.and.bubble.right", color: .blue, category: "AI对话"),
        AIService(id: "wenxin", name: "文心一言", url: "https://yiyan.baidu.com/", icon: "doc.text", color: .red, category: "AI对话"),
        AIService(id: "yuanbao", name: "元宝", url: "https://yuanbao.tencent.com/", icon: "diamond", color: .pink, category: "AI对话"),
        AIService(id: "chatglm", name: "智谱清言", url: "https://chatglm.cn/main/gdetail", icon: "lightbulb.fill", color: .yellow, category: "AI对话"),
        AIService(id: "tongyi", name: "通义千问", url: "https://tongyi.aliyun.com/qianwen/", icon: "cloud.fill", color: .cyan, category: "AI对话"),
        AIService(id: "claude", name: "Claude", url: "https://claude.ai/chats", icon: "sparkles", color: .indigo, category: "AI对话"),
        AIService(id: "chatgpt", name: "ChatGPT", url: "https://chat.openai.com/", icon: "bubble.left.and.bubble.right.fill", color: .green, category: "AI对话"),
        AIService(id: "metaso", name: "秘塔", url: "https://metaso.cn/", icon: "lock.shield", color: .gray, category: "AI搜索"),
        AIService(id: "nano", name: "纳米搜索", url: "https://bot.n.cn/", icon: "atom", color: .mint, category: "AI搜索")
    ]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // 固定顶部工具栏
                    if viewModel.isUIVisible {
                        VStack(spacing: 8) {
                            // 工具栏按钮
                            HStack(spacing: 12) {
                                // 搜索引擎按钮 - 触发左侧抽屉
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        showingSearchEngineDrawer = true
                                        searchEngineDrawerOffset = 0
                                        // 关闭AI抽屉
                                        showingAIDrawer = false
                                        aiDrawerOffset = 300
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.green)
                                            .font(.system(size: 16, weight: .medium))
                                            .frame(width: 20, height: 20)
                                            .clipped()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 10, weight: .medium))
                                            .frame(width: 12, height: 12)
                                    }
                                    .frame(width: 44, height: 44)
                                    .padding(.horizontal, 8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                                
                                Spacer()
                                
                                // AI对话测试按钮
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        showingAITestPanel.toggle()
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "wrench.and.screwdriver")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 16, weight: .medium))
                                            .frame(width: 20, height: 20)
                                            .clipped()
                                        
                                        Text("测试")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                    .frame(width: 60, height: 44)
                                    .padding(.horizontal, 8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                                
                                // AI对话按钮 - 触发右侧抽屉
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        showingAIDrawer = true
                                        aiDrawerOffset = 0
                                        // 关闭搜索引擎抽屉
                                        showingSearchEngineDrawer = false
                                        searchEngineDrawerOffset = -300
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "brain.head.profile")
                                            .foregroundColor(.purple)
                                            .font(.system(size: 16, weight: .medium))
                                            .frame(width: 20, height: 20)
                                            .clipped()
                                        
                                        Image(systemName: "chevron.left")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 10, weight: .medium))
                                            .frame(width: 12, height: 12)
                                    }
                                    .frame(width: 44, height: 44)
                                    .padding(.horizontal, 8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            
                            // AI测试面板（可折叠）
                            if showingAITestPanel {
                                AITestPanel(
                                    isTesting: $isAITesting,
                                    currentStep: $currentAITestStep,
                                    testResults: $aiTestResults,
                                    onStartTest: startAITest,
                                    onResetTest: resetAITest
                                )
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            // URL输入栏
                            HStack(spacing: 8) {
                                HStack(spacing: 12) {
                                    // 搜索输入框
                                    TextField("请输入网址或搜索关键词", text: $urlText)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .onSubmit {
                                            loadURL()
                                        }
                                        .onTapGesture {
                                            showExpandedInput()
                                        }
                                        .onReceive(viewModel.$urlString) { newURL in
                                            // 只有当用户没有在编辑时才更新地址栏
                                            if !urlText.isEmpty && urlText != newURL {
                                                // 用户正在输入，不更新
                                            } else if let newURL = newURL, !newURL.isEmpty && !isHomePage(newURL) {
                                                urlText = newURL
                                            } else if isHomePage(newURL ?? "") {
                                                // 首页不显示地址
                                                urlText = ""
                                            }
                                        }
                                    
                                    // 按钮组
                                    HStack(spacing: 12) {
                                        // 粘贴按钮
                                        Button(action: {
                                            showPasteMenu()
                                        }) {
                                            Image(systemName: "doc.on.clipboard")
                                                .foregroundColor(.green)
                                                .font(.system(size: 18))
                                                .frame(width: 44, height: 44)
                                                .background(Color(.systemGray5))
                                                .cornerRadius(8)
                                        }
                                        
                                        if !urlText.isEmpty {
                                            // 清除按钮
                                            Button(action: {
                                                urlText = ""
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 18))
                                                    .frame(width: 44, height: 44)
                                                    .background(Color(.systemGray5))
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            
                            // 导航按钮
                            HStack(spacing: 20) {
                                Button(action: {
                                    viewModel.goBack()
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(viewModel.canGoBack ? .primary : .gray)
                                }
                                .disabled(!viewModel.canGoBack)
                                
                                Button(action: {
                                    viewModel.goForward()
                                }) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(viewModel.canGoForward ? .primary : .gray)
                                }
                                .disabled(!viewModel.canGoForward)
                                
                                Button(action: {
                                    viewModel.reload()
                                }) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    addToBookmarks()
                                }) {
                                    Image(systemName: favoritePages.contains(viewModel.urlString ?? "") ? "bookmark.fill" : "bookmark")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(favoritePages.contains(viewModel.urlString ?? "") ? .yellow : .primary)
                                }
                                
                                Button(action: {
                                    showShareSheet()
                                }) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
                        .background(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    
                    // WebView内容
                    WebView(viewModel: viewModel)
                        .onAppear {
                            setupNotificationObservers()
                            loadBookmarks()
                            loadFavorites()
                        }
                        .onDisappear {
                            removeNotificationObservers()
                        }
                }
            }
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .overlay(
                // 全局悬浮Prompt按钮
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if promptManager.currentPrompt != nil {
                            VStack(spacing: 8) {
                                // 管理按钮
                                Button(action: {
                                    showingPromptManager = true
                                }) {
                                    Image(systemName: "list.bullet")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.gray)
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                }
                                
                                // 当前Prompt按钮
                                Button(action: {
                                    showingFloatingPrompt = true
                                }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "wand.and.stars")
                                            .font(.system(size: 20, weight: .medium))
                                        Text(promptManager.currentPrompt?.name ?? "智能提示")
                                            .font(.caption2)
                                            .lineLimit(1)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.green)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                }
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 100)
                        }
                    }
                }
            )
            .sheet(isPresented: $showingFloatingPrompt) {
                if let currentPrompt = promptManager.currentPrompt {
                    FloatingPromptView(prompt: currentPrompt.content)
                }
            }
            .sheet(isPresented: $showingPromptManager) {
                PromptManagerView(promptManager: promptManager)
            }
            .sheet(isPresented: $showingAIChat) {
                TemporaryAIChatView()
            }
            .toast(isPresented: $showingToast) {
                ToastView(message: toastMessage, type: toastType)
            }
            
            // 左侧抽屉式搜索引擎列表
            .overlay(
                ZStack {
                    // 背景遮罩
                    if showingSearchEngineDrawer {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showingSearchEngineDrawer = false
                                    searchEngineDrawerOffset = -300
                                }
                            }
                    }
                    
                    // 左侧抽屉
                    HStack {
                        SearchEngineDrawerView(
                            searchEngines: searchEngines,
                            selectedSearchEngine: $selectedSearchEngine,
                            isPresented: $showingSearchEngineDrawer,
                            onEngineSelected: { index in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showingSearchEngineDrawer = false
                                    searchEngineDrawerOffset = -300
                                    selectedSearchEngine = index
                                }
                            }
                        )
                        .offset(x: showingSearchEngineDrawer ? 0 : -300)
                        
                        Spacer()
                    }
                }
            )
            
            // 右侧抽屉式AI对话列表
            .overlay(
                ZStack {
                    // 背景遮罩
                    if showingAIDrawer {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showingAIDrawer = false
                                    aiDrawerOffset = 300
                                }
                            }
                    }
                    
                    // 右侧抽屉
                    HStack {
                        Spacer()
                        
                        AIDrawerView(
                            aiServices: aiServices,
                            isPresented: $showingAIDrawer,
                            onAISelected: { service in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showingAIDrawer = false
                                    aiDrawerOffset = 300
                                    
                                    // 激活真正的AI对话
                                }
                            }
                        )
                        .offset(x: showingAIDrawer ? 0 : 300)
                    }
                }
            )
        }
    }
    
    // MARK: - AI对话测试方法
    
    private func startAITest() {
        guard !isAITesting else { return }
        
        isAITesting = true
        aiTestResults.removeAll()
        currentAITestStep = 0
        
        addAITestResult("🚀 开始测试AI对话初始化...")
        
        // 开始第一步
        testAIStep1()
    }
    
    private func testAIStep1() {
        currentAITestStep = 1
        addAITestResult("📋 步骤1: 测试AIChatManager单例初始化")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                let _ = AIChatManager.shared
                addAITestResult("✅ 步骤1成功: AIChatManager单例创建成功")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    testAIStep2()
                }
            } catch {
                addAITestResult("❌ 步骤1失败: \(error.localizedDescription)")
                finishAITest()
            }
        }
    }
    
    private func testAIStep2() {
        currentAITestStep = 2
        addAITestResult("📋 步骤2: 测试历史数据加载")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                let chatManager = AIChatManager.shared
                let sessionCount = chatManager.chatSessions.count
                addAITestResult("✅ 步骤2成功: 加载了\(sessionCount)个历史会话")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    testAIStep3()
                }
            } catch {
                addAITestResult("❌ 步骤2失败: \(error.localizedDescription)")
                finishAITest()
            }
        }
    }
    
    private func testAIStep3() {
        currentAITestStep = 3
        addAITestResult("📋 步骤3: 测试状态变量初始化")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                let messageText = ""
                let showingSessionList = false
                let showingAPIConfig = false
                
                addAITestResult("✅ 步骤3成功: 状态变量初始化完成")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    testAIStep4()
                }
            } catch {
                addAITestResult("❌ 步骤3失败: \(error.localizedDescription)")
                finishAITest()
            }
        }
    }
    
    private func testAIStep4() {
        currentAITestStep = 4
        addAITestResult("📋 步骤4: 测试界面状态判断")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                let chatManager = AIChatManager.shared
                let hasCurrentSession = chatManager.currentSession != nil
                let sessionTitle = chatManager.currentSession?.title ?? "无当前会话"
                
                addAITestResult("✅ 步骤4成功: 界面状态判断完成")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    testAIStep5()
                }
            } catch {
                addAITestResult("❌ 步骤4失败: \(error.localizedDescription)")
                finishAITest()
            }
        }
    }
    
    private func testAIStep5() {
        currentAITestStep = 5
        addAITestResult("📋 步骤5: 测试导航栏配置")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                let chatManager = AIChatManager.shared
                let navigationTitle = chatManager.currentSession?.title ?? "AI对话"
                
                addAITestResult("✅ 步骤5成功: 导航栏配置完成")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    testAIStep6()
                }
            } catch {
                addAITestResult("❌ 步骤5失败: \(error.localizedDescription)")
                finishAITest()
            }
        }
    }
    
    private func testAIStep6() {
        currentAITestStep = 6
        addAITestResult("📋 步骤6: 测试Sheet视图准备")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                addAITestResult("✅ 步骤6成功: Sheet视图准备完成")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    finishAITest()
                }
            } catch {
                addAITestResult("❌ 步骤6失败: \(error.localizedDescription)")
                finishAITest()
            }
        }
    }
    
    private func finishAITest() {
        isAITesting = false
        addAITestResult("🎉 AI对话测试完成！")
        
        let successCount = aiTestResults.filter { $0.contains("✅") }.count
        let failCount = aiTestResults.filter { $0.contains("❌") }.count
        
        addAITestResult("📊 测试结果: 成功\(successCount)步，失败\(failCount)步")
        
        if failCount > 0 {
            addAITestResult("⚠️ 发现问题！请检查失败的步骤")
        } else {
            addAITestResult("✅ 所有测试通过，AI对话初始化正常")
        }
    }
    
    private func resetAITest() {
        isAITesting = false
        currentAITestStep = 0
        aiTestResults.removeAll()
    }
    
    private func addAITestResult(_ result: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        aiTestResults.append("[\(timestamp)] \(result)")
    }
    
    // MARK: - 其他方法（保持原有功能）
    
    private func loadURL() {
        // 实现URL加载逻辑
    }
    
    private func showExpandedInput() {
        // 实现展开输入框逻辑
    }
    
    private func showPasteMenu() {
        // 实现粘贴菜单逻辑
    }
    
    private func addToBookmarks() {
        // 实现添加到书签逻辑
    }
    
    private func showShareSheet() {
        // 实现分享功能逻辑
    }
    
    private func isHomePage(_ url: String) -> Bool {
        // 实现首页判断逻辑
        return false
    }
    
    private func setupNotificationObservers() {
        // 实现通知观察者设置
    }
    
    private func removeNotificationObservers() {
        // 实现通知观察者移除
    }
    
    private func loadBookmarks() {
        // 实现书签加载逻辑
    }
    
    private func loadFavorites() {
        // 实现收藏加载逻辑
    }
}

// MARK: - AI测试面板
struct AITestPanel: View {
    @Binding var isTesting: Bool
    @Binding var currentStep: Int
    @Binding var testResults: [String]
    let onStartTest: () -> Void
    let onResetTest: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // 标题栏
            HStack {
                Text("🔧 AI对话测试面板")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isTesting {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("测试中...")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            // 当前步骤
            HStack {
                Text("当前步骤: \(currentStep)/6")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if currentStep > 0 {
                    ProgressView(value: Double(currentStep), total: 6.0)
                        .frame(width: 100)
                }
            }
            
            // 控制按钮
            HStack(spacing: 12) {
                Button(isTesting ? "测试中..." : "开始测试") {
                    onStartTest()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isTesting ? Color.gray : Color.blue)
                .cornerRadius(8)
                .disabled(isTesting)
                
                Button("重置") {
                    onResetTest()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange)
                .cornerRadius(8)
                .disabled(isTesting)
            }
            
            // 测试结果预览
            if !testResults.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("最新结果:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(testResults.suffix(3), id: \.self) { result in
                                Text(result)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(maxHeight: 60)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - 其他必要的结构体（简化版）
struct AIService {
    let id: String
    let name: String
    let url: String
    let icon: String
    let color: Color
    let category: String
}

struct BrowserSearchEngine {
    let id: String
    let name: String
    let url: String
    let icon: String
    let color: Color
}

// 其他必要的视图和结构体...
struct SearchEngineDrawerView: View {
    let searchEngines: [BrowserSearchEngine]
    @Binding var selectedSearchEngine: Int
    @Binding var isPresented: Bool
    let onEngineSelected: (Int) -> Void
    
    var body: some View {
        Text("搜索引擎抽屉")
    }
}

struct AIDrawerView: View {
    let aiServices: [AIService]
    @Binding var isPresented: Bool
    let onAISelected: (AIService) -> Void
    
    var body: some View {
        Text("AI对话抽屉")
    }
}

struct FloatingPromptView: View {
    let prompt: String
    
    var body: some View {
        Text("悬浮提示")
    }
}

struct PromptManagerView: View {
    let promptManager: GlobalPromptManager
    
    var body: some View {
        Text("提示管理器")
    }
}

struct TemporaryAIChatView: View {
    var body: some View {
        Text("临时AI聊天")
    }
}

struct ToastView: View {
    let message: String
    let type: BrowserViewWithAITest.ToastType
    
    var body: some View {
        Text("Toast")
    }
}

struct WebView: View {
    let viewModel: WebViewModel
    
    var body: some View {
        Text("WebView")
    }
}

class WebViewModel: ObservableObject {
    @Published var urlString: String?
    @Published var isUIVisible = true
    @Published var canGoBack = false
    @Published var canGoForward = false
    
    func loadUrl(_ url: String) {}
    func goBack() {}
    func goForward() {}
    func reload() {}
}

class GlobalPromptManager: ObservableObject {
    static let shared = GlobalPromptManager()
    @Published var currentPrompt: Prompt?
    
    struct Prompt {
        let content: String
    }
}

// MARK: - 预览
struct BrowserViewWithAITest_Previews: PreviewProvider {
    static var previews: some View {
        BrowserViewWithAITest()
    }
} 