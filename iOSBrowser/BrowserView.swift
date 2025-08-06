//
//  BrowserView.swift
//  iOSBrowser
//
//  Created by LZH on 2025/7/19.
//

import SwiftUI
import UIKit
import WebKit
import Foundation

// 全局Prompt数据结构
struct SavedPrompt: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    let name: String
    let timestamp: Date

    init(content: String, name: String) {
        self.id = UUID()
        self.content = content
        self.name = name
        self.timestamp = Date()
    }

    static func == (lhs: SavedPrompt, rhs: SavedPrompt) -> Bool {
        return lhs.id == rhs.id
    }
}

// 全局Prompt管理器
class GlobalPromptManager: ObservableObject {
    static let shared = GlobalPromptManager()

    @Published var savedPrompts: [SavedPrompt] = []
    @Published var currentPrompt: SavedPrompt?

    private init() {
        loadPrompts()
    }

    func savePrompt(_ content: String, name: String) {
        let prompt = SavedPrompt(content: content, name: name)
        savedPrompts.append(prompt)
        currentPrompt = prompt
        savePrompts()
    }

    func deletePrompt(_ id: UUID) {
        savedPrompts.removeAll { $0.id == id }
        if currentPrompt?.id == id {
            currentPrompt = savedPrompts.first
        }
        savePrompts()
    }

    func setCurrentPrompt(_ prompt: SavedPrompt) {
        currentPrompt = prompt
        UserDefaults.standard.set(prompt.id.uuidString, forKey: "currentPromptId")
    }

    private func savePrompts() {
        if let data = try? JSONEncoder().encode(savedPrompts) {
            UserDefaults.standard.set(data, forKey: "savedPrompts")
        }

        if let current = currentPrompt {
            UserDefaults.standard.set(current.id.uuidString, forKey: "currentPromptId")
        }
    }

    private func loadPrompts() {
        if let data = UserDefaults.standard.data(forKey: "savedPrompts"),
           let decoded = try? JSONDecoder().decode([SavedPrompt].self, from: data) {
            savedPrompts = decoded

            // 加载当前选中的Prompt
            if let currentId = UserDefaults.standard.string(forKey: "currentPromptId"),
               let uuid = UUID(uuidString: currentId),
               let current = savedPrompts.first(where: { $0.id == uuid }) {
                currentPrompt = current
            } else {
                currentPrompt = savedPrompts.first
            }
        }
    }
}

struct BrowserSearchEngine {
    let id: String
    let name: String
    let url: String
    let icon: String
    let color: Color
}

struct BrowserView: View {
    @ObservedObject var viewModel: WebViewModel

    @State private var urlText: String = ""
    @State private var showingBookmarks = false
    @State private var showingSearchEngines = false
    @State private var selectedSearchEngine = 0
    @State private var bookmarks: [String] = []
    @State private var showingCustomHomePage = true
    @State private var searchQuery = ""
    @State private var showingFloatingPrompt = false
    @State private var showingPromptManager = false
    @State private var showingSearchEngineSelector = false
    
    // 新增功能状态
    @State private var showingExpandedInput = false
    @State private var expandedUrlText = ""
    @State private var showingAIChat = false
    @State private var selectedAI = "deepseek"
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var favoritePages: Set<String> = []

    // 边缘滑动返回手势状态
    @State private var edgeSwipeOffset: CGFloat = 0
    @State private var isEdgeSwiping = false

    // 全局Prompt状态管理
    @StateObject private var promptManager = GlobalPromptManager.shared

    private let searchEngines = [
        BrowserSearchEngine(id: "baidu", name: "百度", url: "https://www.baidu.com/s?wd=", icon: "magnifyingglass", color: .green),
        BrowserSearchEngine(id: "bing", name: "必应", url: "https://www.bing.com/search?q=", icon: "magnifyingglass.circle", color: .green),
        BrowserSearchEngine(id: "deepseek", name: "DeepSeek", url: "https://chat.deepseek.com/", icon: "brain.head.profile", color: .green),
        BrowserSearchEngine(id: "kimi", name: "Kimi", url: "https://kimi.moonshot.cn/", icon: "moon.stars", color: .green),
        BrowserSearchEngine(id: "doubao", name: "豆包", url: "https://www.doubao.com/chat/", icon: "bubble.left.and.bubble.right", color: .green),
        BrowserSearchEngine(id: "wenxin", name: "文心一言", url: "https://yiyan.baidu.com/", icon: "doc.text", color: .green),
        BrowserSearchEngine(id: "yuanbao", name: "元宝", url: "https://yuanbao.tencent.com/", icon: "diamond", color: .green),
        BrowserSearchEngine(id: "chatglm", name: "智谱清言", url: "https://chatglm.cn/main/gdetail", icon: "lightbulb.fill", color: .green),
        BrowserSearchEngine(id: "tongyi", name: "通义千问", url: "https://tongyi.aliyun.com/qianwen/", icon: "cloud.fill", color: .green),
        BrowserSearchEngine(id: "claude", name: "Claude", url: "https://claude.ai/chats", icon: "sparkles", color: .green),
        BrowserSearchEngine(id: "chatgpt", name: "ChatGPT", url: "https://chat.openai.com/", icon: "bubble.left.and.bubble.right.fill", color: .green),
        BrowserSearchEngine(id: "metaso", name: "秘塔", url: "https://metaso.cn/", icon: "lock.shield", color: .green),
        BrowserSearchEngine(id: "nano", name: "纳米搜索", url: "https://bot.n.cn/", icon: "atom", color: .green)
    ]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // 固定顶部工具栏
                    if viewModel.isUIVisible {
                        VStack(spacing: 8) {
                            // 搜索引擎选择栏（可折叠）
                            if showingSearchEngineSelector {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(Array(searchEngines.enumerated()), id: \.offset) { index, engine in
                                            SearchEngineButton(
                                                engine: engine,
                                                isSelected: selectedSearchEngine == index
                                            ) {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    selectedSearchEngine = index
                                                    showingSearchEngineSelector = false
                                                    // 如果是AI搜索引擎，直接加载对话页面
                                                    if ["deepseek", "kimi", "doubao", "wenxin", "yuanbao", "chatglm", "tongyi", "claude", "chatgpt", "metaso", "nano"].contains(engine.id) {
                                                        urlText = engine.url
                                                        loadURL()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                                .frame(height: 70)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .move(edge: .top).combined(with: .opacity)
                                ))
                            }

                        // URL输入栏
                        HStack(spacing: 8) {
                            // 搜索引擎选择按钮
                            Button(action: {
                                withAnimation(.spring()) {
                                    showingSearchEngineSelector.toggle()
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: searchEngines[selectedSearchEngine].icon)
                                        .foregroundColor(searchEngines[selectedSearchEngine].color)
                                        .font(.system(size: 16, weight: .medium))
                                        .frame(width: 20, height: 20)
                                        .clipped()

                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 10, weight: .medium))
                                        .frame(width: 12, height: 12)
                                        .rotationEffect(.degrees(showingSearchEngineSelector ? 180 : 0))
                                }
                                .frame(width: 44, height: 44)
                                .padding(.horizontal, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }

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
                                    .foregroundColor(viewModel.canGoBack ? .green : .gray)
                            }
                            .disabled(!viewModel.canGoBack)
                            
                            Button(action: {
                                viewModel.goForward()
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(viewModel.canGoForward ? .green : .gray)
                            }
                            .disabled(!viewModel.canGoForward)
                            
                            Button(action: {
                                viewModel.webView.reload()
                            }) {
                                Image(systemName: viewModel.isLoading ? "stop.fill" : "arrow.clockwise")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.green)
                            }

                            Button(action: {
                                goToHomePage()
                            }) {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.green)
                            }

                            Spacer()
                            
                            // AI对话按钮
                            Button(action: {
                                showAIChat()
                            }) {
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.green)
                            }
                            
                            Button(action: {
                                toggleFavorite()
                            }) {
                                let isBookmarked = viewModel.urlString != nil && favoritePages.contains(viewModel.urlString!)
                                Image(systemName: isBookmarked ? "star.fill" : "star")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(isBookmarked ? .yellow : .green)
                            }
                            
                            Button(action: {
                                showingBookmarks.toggle()
                            }) {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.green)
                            }
                            
                            Button(action: {
                                shareCurrentURL()
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                    .background(Color(.systemBackground))
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isUIVisible)
                }
                
                // 内容区域（可滚动）
                if showingCustomHomePage {
                    ScrollableCustomHomePage(
                        searchQuery: $searchQuery,
                        onSearch: { query in
                            urlText = query
                            showingCustomHomePage = false
                            loadURL()
                        },
                        onPromptSelected: { prompt in
                            searchQuery = prompt
                        },
                        promptManager: promptManager,
                        availableHeight: geometry.size.height - (viewModel.isUIVisible ? 140 : 0)
                    )
                } else {
                    WebView(viewModel: viewModel)
                        .clipped()
                }
                }
                .offset(x: edgeSwipeOffset)
                .gesture(
                    DragGesture(coordinateSpace: .global)
                        .onChanged { value in
                            // 只响应从左边缘开始的滑动
                            let edgeThreshold: CGFloat = 30
                            let isFromLeftEdge = value.startLocation.x < edgeThreshold

                            // 只有从左边缘开始且向右滑动才响应
                            if isFromLeftEdge && value.translation.width > 0 {
                                isEdgeSwiping = true
                                // 限制滑动距离，创建阻尼效果
                                let maxOffset: CGFloat = 100
                                let progress = min(value.translation.width / maxOffset, 1.0)
                                edgeSwipeOffset = progress * maxOffset
                            }
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 80
                            let velocity = value.predictedEndLocation.x - value.location.x

                            // 判断是否应该执行返回操作
                            let shouldGoBack = (value.translation.width > threshold || velocity > 300) &&
                                             value.startLocation.x < 30 &&
                                             viewModel.canGoBack

                            if shouldGoBack {
                                // 执行返回操作
                                viewModel.webView.goBack()

                                // 添加成功反馈动画
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    edgeSwipeOffset = 0
                                }
                            } else {
                                // 重置位置
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    edgeSwipeOffset = 0
                                }
                            }

                            isEdgeSwiping = false
                        }
                )
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingBookmarks) {
                BookmarksView(bookmarks: $bookmarks, onBookmarkSelected: { bookmark in
                    urlText = bookmark
                    showingBookmarks = false
                    loadURL()
                })
            }
            .sheet(isPresented: $showingExpandedInput) {
                ExpandedInputView(
                    urlText: $expandedUrlText,
                    onConfirm: {
                        urlText = expandedUrlText
                        showingExpandedInput = false
                        loadURL()
                    },
                    onCancel: {
                        showingExpandedInput = false
                    }
                )
            }
            .sheet(isPresented: $showingAIChat) {
                BrowserAIChatView(
                    selectedAI: $selectedAI,
                    initialMessage: urlText
                )
            }
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                setupNotificationObservers()
                loadBookmarks()
                loadFavorites()
            }
            .onDisappear {
                removeNotificationObservers()
            }
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
    }
    
    private func loadURL() {
        let trimmedText = urlText.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedText.isEmpty {
            return
        }

        var urlString = trimmedText
        let selectedEngine = searchEngines[selectedSearchEngine]

        // 检查是否是有效的URL
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            // 如果包含点号，假设是域名
            if urlString.contains(".") && !urlString.contains(" ") {
                urlString = "https://" + urlString
            } else {
                // 否则根据选择的搜索引擎处理
                switch selectedEngine.id {
                case "baidu":
                    urlString = selectedEngine.url + urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                case "bing":
                    urlString = selectedEngine.url + urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                case "deepseek", "kimi", "doubao", "wenxin", "yuanbao", "chatglm", "tongyi", "claude", "chatgpt", "metaso", "nano":
                    // AI聊天类搜索引擎，直接跳转到主页
                    urlString = selectedEngine.url
                default:
                    urlString = "https://www.baidu.com/s?wd=" + urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                }
            }
        }

        // 直接加载URL，不显示中间页面
        showingCustomHomePage = false
        viewModel.loadUrl(urlString)
    }
    
    private func addToBookmarks() {
        guard let currentURL = viewModel.urlString, !currentURL.isEmpty else {
            // 显示提示
            showAlert(title: "无法收藏", message: "当前页面无效，无法添加到书签")
            return
        }

        if !bookmarks.contains(currentURL) {
            // 添加到书签
            bookmarks.append(currentURL)
            saveBookmarks()
            showAlert(title: "收藏成功", message: "页面已添加到书签")
        } else {
            // 从书签中移除
            bookmarks.removeAll { $0 == currentURL }
            saveBookmarks()
            showAlert(title: "取消收藏", message: "页面已从书签中移除")
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(alert, animated: true)
        }
    }
    
    private func shareCurrentURL() {
        guard let currentURL = viewModel.urlString, !currentURL.isEmpty else { return }
        
        let activityVC = UIActivityViewController(activityItems: [currentURL], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func loadBookmarks() {
        if let savedBookmarks = UserDefaults.standard.array(forKey: "bookmarks") as? [String] {
            bookmarks = savedBookmarks
        }
    }
    
    private func saveBookmarks() {
        UserDefaults.standard.set(bookmarks, forKey: "bookmarks")
    }

    private func pasteFromClipboard() {
        if let clipboardString = UIPasteboard.general.string {
            urlText = clipboardString.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    private func isHomePage(_ url: String) -> Bool {
        return url.isEmpty || url == "about:blank" || url.contains("custom-home")
    }

    private func goToHomePage() {
        showingCustomHomePage = true
        urlText = ""
        viewModel.urlString = ""
        // 确保WebView加载空白页面
        viewModel.loadUrl("about:blank")
    }

    // MARK: - 通知处理
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name("browserClipboardSearch"),
            object: nil,
            queue: .main
        ) { notification in
            if let data = notification.object as? [String: String],
               let query = data["query"],
               let engine = data["engine"] {
                handleClipboardSearch(query: query, engine: engine)
            }
        }

        NotificationCenter.default.addObserver(
            forName: Notification.Name("performSearch"),
            object: nil,
            queue: .main
        ) { notification in
            if let query = notification.object as? String {
                performSearch(query: query)
            }
        }

        NotificationCenter.default.addObserver(
            forName: Notification.Name("switchSearchEngine"),
            object: nil,
            queue: .main
        ) { notification in
            if let engineId = notification.object as? String {
                switchToSearchEngine(engineId: engineId)
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: Notification.Name.pasteToBrowserInput,
            object: nil,
            queue: .main
        ) { notification in
            if let content = notification.object as? String {
                urlText = content
            }
        }
    }

    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    private func handleClipboardSearch(query: String, engine: String) {
        showingCustomHomePage = false
        urlText = query

        // 根据搜索引擎构建搜索URL
        let searchURL: String
        switch engine {
        case "google":
            searchURL = "https://www.google.com/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        case "baidu":
            searchURL = "https://www.baidu.com/s?wd=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        case "bing":
            searchURL = "https://www.bing.com/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        default:
            searchURL = "https://www.google.com/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }

        viewModel.urlString = searchURL
        if let url = URL(string: searchURL) {
            viewModel.webView.load(URLRequest(url: url))
        }
    }

    private func performSearch(query: String) {
        showingCustomHomePage = false
        urlText = query
        loadURL()
    }

    private func switchToSearchEngine(engineId: String) {
        // 这里可以实现切换搜索引擎的逻辑
        // 例如更新selectedSearchEngine状态
    }

    private func showExpandedInput() {
        expandedUrlText = urlText
        showingExpandedInput = true
    }

    private func showPasteMenu() {
        let pasteAction = UIAction(title: "粘贴", image: UIImage(systemName: "doc.on.clipboard")) { _ in
            self.pasteFromClipboard()
        }
        let pasteToInputAction = UIAction(title: "粘贴到输入框", image: UIImage(systemName: "doc.on.doc")) { _ in
            self.pasteToInput()
        }
        let pasteToSearchEngineAction = UIAction(title: "粘贴到搜索引擎", image: UIImage(systemName: "magnifyingglass")) { _ in
            self.pasteToSearchEngine()
        }

        let menu = UIMenu(title: "粘贴选项", children: [pasteAction, pasteToInputAction, pasteToSearchEngineAction])
        // 使用AlertController来显示菜单选项
        let alertController = UIAlertController(title: "粘贴选项", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "粘贴", style: .default) { _ in
            self.pasteFromClipboard()
        })
        
        alertController.addAction(UIAlertAction(title: "粘贴到输入框", style: .default) { _ in
            self.pasteToInput()
        })
        
        alertController.addAction(UIAlertAction(title: "粘贴到搜索引擎", style: .default) { _ in
            self.pasteToSearchEngine()
        })
        
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(alertController, animated: true)
        }
    }

    private func pasteToInput() {
        NotificationCenter.default.post(name: .pasteToBrowserInput, object: expandedUrlText)
        showingExpandedInput = false
    }

    private func pasteToSearchEngine() {
        let trimmedText = expandedUrlText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedText.isEmpty {
            return
        }

        let selectedEngine = searchEngines[selectedSearchEngine]
        var urlString = trimmedText

        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            if urlString.contains(".") && !urlString.contains(" ") {
                urlString = "https://" + urlString
            } else {
                switch selectedEngine.id {
                case "baidu":
                    urlString = selectedEngine.url + urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                case "bing":
                    urlString = selectedEngine.url + urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                case "deepseek", "kimi", "doubao", "wenxin", "yuanbao", "chatglm", "tongyi", "claude", "chatgpt", "metaso", "nano":
                    urlString = selectedEngine.url
                default:
                    urlString = "https://www.baidu.com/s?wd=" + urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                }
            }
        }

        showingCustomHomePage = false
        viewModel.loadUrl(urlString)
        showingExpandedInput = false
    }

    private func showAIChat() {
        showingAIChat = true
    }
    
    // MARK: - 收藏功能
    private func loadFavorites() {
        if let savedFavorites = UserDefaults.standard.array(forKey: "favoritePages") as? [String] {
            favoritePages = Set(savedFavorites)
        }
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoritePages), forKey: "favoritePages")
    }
    
    private func toggleFavorite() {
        guard let currentURL = viewModel.urlString, !currentURL.isEmpty else {
            alertMessage = "无法收藏，当前页面无效"
            showingAlert = true
            return
        }
        
        if favoritePages.contains(currentURL) {
            favoritePages.remove(currentURL)
            alertMessage = "已取消收藏当前页面"
        } else {
            favoritePages.insert(currentURL)
            alertMessage = "已收藏当前页面"
        }
        showingAlert = true
        saveFavorites()
    }
}

struct BookmarksView: View {
    @Binding var bookmarks: [String]
    let onBookmarkSelected: (String) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(bookmarks, id: \.self) { bookmark in
                    Button(action: {
                        onBookmarkSelected(bookmark)
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(extractDomain(from: bookmark))
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(extractDomain(from: bookmark))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .onDelete(perform: deleteBookmarks)
            }
            .navigationTitle("书签")
            .navigationBarItems(
                leading: Button("关闭") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: EditButton()
            )
        }
    }
    
    private func deleteBookmarks(offsets: IndexSet) {
        bookmarks.remove(atOffsets: offsets)
        UserDefaults.standard.set(bookmarks, forKey: "bookmarks")
    }
    
    private func extractDomain(from url: String) -> String {
        if let url = URL(string: url) {
            return url.host ?? url.absoluteString
        }
        return url
    }
}

struct SearchEngineButton: View {
    let engine: BrowserSearchEngine
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                    isPressed = false
                }
                action()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: engine.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : engine.color)
                    .frame(width: 20, height: 20)
                    .clipped()

                Text(engine.name)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : engine.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(minWidth: 60, minHeight: 50)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? engine.color : engine.color.opacity(0.1))
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
    }
}

// 可滚动的自定义首页
struct ScrollableCustomHomePage: View {
    @Binding var searchQuery: String
    let onSearch: (String) -> Void
    let onPromptSelected: (String) -> Void
    @ObservedObject var promptManager: GlobalPromptManager
    let availableHeight: CGFloat

    var body: some View {
        ScrollView {
            CustomHomePage(
                searchQuery: $searchQuery,
                onSearch: onSearch,
                onPromptSelected: onPromptSelected,
                promptManager: promptManager
            )
            .frame(minHeight: availableHeight)
        }
    }
}

// 自定义首页
struct CustomHomePage: View {
    @Binding var searchQuery: String
    let onSearch: (String) -> Void
    let onPromptSelected: (String) -> Void
    @ObservedObject var promptManager: GlobalPromptManager

    @State private var selectedAssistant: AssistantType? = nil
    @State private var selectedIdentity: IdentityType? = nil
    @State private var selectedReplyStyle: ReplyStyleType? = nil
    @State private var selectedTone: ToneType? = nil
    @State private var showingAssistantPicker = false
    @State private var showingIdentityPicker = false
    @State private var showingReplyStylePicker = false
    @State private var showingTonePicker = false

    private let promptCategories = [
        PromptCategory(title: "助手", icon: "person.circle", color: .green, type: .assistant),
        PromptCategory(title: "身份", icon: "person.badge.key", color: .green, type: .identity),
        PromptCategory(title: "回复样式", icon: "doc.richtext", color: .green, type: .replyStyle),
        PromptCategory(title: "文风风格", icon: "textformat", color: .green, type: .tone)
    ]

    var body: some View {
        VStack(spacing: 24) {

            // 移除重复的搜索框，只使用顶部的搜索栏

            // 智能助手选项
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(promptCategories, id: \.title) { category in
                    PromptCategoryButton(
                        category: category,
                        isSelected: isSelected(category: category),
                        selectedText: getSelectedText(for: category)
                    ) {
                        handleCategoryTap(category)
                    }
                }
            }
            .padding(.horizontal, 24)

            // 生成最终Prompt按钮
            if hasSelections() {
                Button(action: {
                    let finalPrompt = generateFinalPrompt()
                    onPromptSelected(finalPrompt)
                }) {
                    Text("生成智能提示")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .background(Color(.systemBackground))
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 40)
        .sheet(isPresented: $showingAssistantPicker) {
            AssistantPickerView(selectedAssistant: $selectedAssistant)
        }
        .sheet(isPresented: $showingIdentityPicker) {
            IdentityPickerView(selectedIdentity: $selectedIdentity)
        }
        .sheet(isPresented: $showingReplyStylePicker) {
            ReplyStylePickerView(selectedReplyStyle: $selectedReplyStyle)
        }
        .sheet(isPresented: $showingTonePicker) {
            TonePickerView(selectedTone: $selectedTone)
        }
    }

    private func isSelected(category: PromptCategory) -> Bool {
        switch category.type {
        case .assistant: return selectedAssistant != nil
        case .identity: return selectedIdentity != nil
        case .replyStyle: return selectedReplyStyle != nil
        case .tone: return selectedTone != nil
        }
    }

    private func getSelectedText(for category: PromptCategory) -> String {
        switch category.type {
        case .assistant: return selectedAssistant?.rawValue ?? "选择助手"
        case .identity: return selectedIdentity?.rawValue ?? "选择身份"
        case .replyStyle: return selectedReplyStyle?.rawValue ?? "选择样式"
        case .tone: return selectedTone?.rawValue ?? "选择风格"
        }
    }

    private func handleCategoryTap(_ category: PromptCategory) {
        switch category.type {
        case .assistant: showingAssistantPicker = true
        case .identity: showingIdentityPicker = true
        case .replyStyle: showingReplyStylePicker = true
        case .tone: showingTonePicker = true
        }
    }

    private func hasSelections() -> Bool {
        return selectedAssistant != nil || selectedIdentity != nil ||
               selectedReplyStyle != nil || selectedTone != nil
    }

    private func generateFinalPrompt() -> String {
        var promptParts: [String] = []

        if let assistant = selectedAssistant {
            promptParts.append("作为一个\(assistant.description)专家")
        }

        if let identity = selectedIdentity {
            promptParts.append("考虑到我是\(identity.description)")
        }

        if let replyStyle = selectedReplyStyle {
            promptParts.append("请用\(replyStyle.description)的方式回复")
        }

        if let tone = selectedTone {
            promptParts.append("语言风格要\(tone.description)")
        }

        let basePrompt = promptParts.joined(separator: "，")
        let finalPrompt = basePrompt + "。请回答以下问题："

        // 生成Prompt名称
        let promptName = generatePromptName()

        // 保存到全局管理器
        promptManager.savePrompt(finalPrompt, name: promptName)

        return finalPrompt
    }

    private func generatePromptName() -> String {
        var nameParts: [String] = []

        if let assistant = selectedAssistant {
            nameParts.append(assistant.rawValue)
        }

        if let identity = selectedIdentity {
            nameParts.append(identity.rawValue)
        }

        if let replyStyle = selectedReplyStyle {
            nameParts.append(replyStyle.rawValue)
        }

        if let tone = selectedTone {
            nameParts.append(tone.rawValue)
        }

        return nameParts.isEmpty ? "智能提示" : nameParts.joined(separator: " + ")
    }
}

// Prompt分类数据结构
struct PromptCategory {
    let title: String
    let icon: String
    let color: Color
    let type: PromptCategoryType
}

enum PromptCategoryType {
    case assistant, identity, replyStyle, tone
}

// 助手类型
enum AssistantType: String, CaseIterable {
    case emotional = "情感咨询"
    case education = "教育指导"
    case art = "艺术创作"
    case design = "设计策划"
    case medical = "医疗健康"
    case life = "生活助手"
    case academic = "学术研究"
    case business = "商业分析"
    case technology = "技术开发"
    case legal = "法律咨询"

    var description: String {
        switch self {
        case .emotional: return "情感咨询和心理支持"
        case .education: return "教育指导和学习规划"
        case .art: return "艺术创作和审美指导"
        case .design: return "设计策划和创意思维"
        case .medical: return "医疗健康和养生建议"
        case .life: return "生活助手和日常规划"
        case .academic: return "学术研究和论文写作"
        case .business: return "商业分析和市场策略"
        case .technology: return "技术开发和编程指导"
        case .legal: return "法律咨询和合规建议"
        }
    }
}

// 身份类型
enum IdentityType: String, CaseIterable {
    case student = "学生"
    case teacher = "教师"
    case engineer = "工程师"
    case designer = "设计师"
    case manager = "管理者"
    case entrepreneur = "创业者"
    case researcher = "研究员"
    case artist = "艺术家"
    case doctor = "医生"
    case lawyer = "律师"
    case parent = "家长"
    case senior = "老年人"

    var description: String {
        switch self {
        case .student: return "在校学生，需要学习指导"
        case .teacher: return "教育工作者，关注教学方法"
        case .engineer: return "技术工程师，注重实用性"
        case .designer: return "设计师，追求创意和美感"
        case .manager: return "管理者，需要决策支持"
        case .entrepreneur: return "创业者，关注商业机会"
        case .researcher: return "研究人员，需要深度分析"
        case .artist: return "艺术创作者，追求灵感"
        case .doctor: return "医疗工作者，注重专业性"
        case .lawyer: return "法律工作者，需要严谨性"
        case .parent: return "家长，关注家庭和教育"
        case .senior: return "老年人，需要简单易懂的解释"
        }
    }
}

// 回复样式类型
enum ReplyStyleType: String, CaseIterable {
    case ascii = "ASCII图表"
    case mermaid = "Mermaid图"
    case list = "列表展示"
    case comparison = "对比分析"
    case sources = "信息源引用"
    case stepByStep = "分步骤"
    case summary = "要点总结"
    case detailed = "详细解释"

    var description: String {
        switch self {
        case .ascii: return "用ASCII字符绘制图表和示意图"
        case .mermaid: return "用Mermaid语法生成流程图"
        case .list: return "用清晰的列表形式组织信息"
        case .comparison: return "用对比表格分析优缺点"
        case .sources: return "提供信息来源和参考链接"
        case .stepByStep: return "分步骤详细说明操作流程"
        case .summary: return "提炼关键要点和核心信息"
        case .detailed: return "提供深入详细的解释说明"
        }
    }
}

// 文风类型
enum ToneType: String, CaseIterable {
    case rigorous = "严谨"
    case caring = "贴心"
    case humorous = "幽默"
    case playful = "戏谑"
    case grand = "大气"
    case satirical = "恶搞"
    case critical = "锐评"
    case talkShow = "脱口秀"
    case speech = "演讲"
    case academic = "论文"
    case marketing = "文案"
    case casual = "随意"

    var description: String {
        switch self {
        case .rigorous: return "严谨专业，逻辑清晰"
        case .caring: return "温暖贴心，关怀备至"
        case .humorous: return "幽默风趣，轻松愉快"
        case .playful: return "调侃戏谑，生动有趣"
        case .grand: return "大气磅礴，格局宏大"
        case .satirical: return "恶搞讽刺，另类有趣"
        case .critical: return "犀利点评，一针见血"
        case .talkShow: return "脱口秀风格，妙语连珠"
        case .speech: return "演讲风格，激情澎湃"
        case .academic: return "学术论文，严肃正式"
        case .marketing: return "营销文案，吸引眼球"
        case .casual: return "随意轻松，自然亲切"
        }
    }
}

// Prompt分类按钮
struct PromptCategoryButton: View {
    let category: PromptCategory
    let isSelected: Bool
    let selectedText: String
    let action: () -> Void
    @State private var isPressed = false

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
                ZStack {
                    Circle()
                        .fill(category.color.opacity(isSelected ? 0.2 : 0.1))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? category.color : Color.clear, lineWidth: 2)
                        )

                    Image(systemName: category.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(isSelected ? category.color : category.color.opacity(0.7))
                }

                VStack(spacing: 4) {
                    Text(category.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(selectedText)
                        .font(.caption)
                        .foregroundColor(isSelected ? category.color : .secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? category.color.opacity(0.3) : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
            .cornerRadius(16)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}



// 助手选择器
struct AssistantPickerView: View {
    @Binding var selectedAssistant: AssistantType?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List(AssistantType.allCases, id: \.self) { assistant in
                Button(action: {
                    selectedAssistant = assistant
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(assistant.rawValue)
                                .foregroundColor(.primary)
                            Text(assistant.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if selectedAssistant == assistant {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("选择助手类型")
            .navigationBarItems(trailing: Button("取消") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// 身份选择器
struct IdentityPickerView: View {
    @Binding var selectedIdentity: IdentityType?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List(IdentityType.allCases, id: \.self) { identity in
                Button(action: {
                    selectedIdentity = identity
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(identity.rawValue)
                                .foregroundColor(.primary)
                            Text(identity.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if selectedIdentity == identity {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("选择身份背景")
            .navigationBarItems(trailing: Button("取消") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// 回复样式选择器
struct ReplyStylePickerView: View {
    @Binding var selectedReplyStyle: ReplyStyleType?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List(ReplyStyleType.allCases, id: \.self) { style in
                Button(action: {
                    selectedReplyStyle = style
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(style.rawValue)
                                .foregroundColor(.primary)
                            Text(style.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if selectedReplyStyle == style {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("选择回复样式")
            .navigationBarItems(trailing: Button("取消") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// 文风选择器
struct TonePickerView: View {
    @Binding var selectedTone: ToneType?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List(ToneType.allCases, id: \.self) { tone in
                Button(action: {
                    selectedTone = tone
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(tone.rawValue)
                                .foregroundColor(.primary)
                            Text(tone.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if selectedTone == tone {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("选择文风风格")
            .navigationBarItems(trailing: Button("取消") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// 悬浮Prompt视图
struct FloatingPromptView: View {
    let prompt: String
    @Environment(\.presentationMode) var presentationMode
    @State private var copiedToClipboard = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 50))
                        .foregroundColor(.green)

                    Text("智能提示")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("当前生成的智能提示内容")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("提示内容：")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(prompt)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .textSelection(.enabled)
                }

                VStack(spacing: 12) {
                    Button(action: {
                        UIPasteboard.general.string = prompt
                        copiedToClipboard = true

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            copiedToClipboard = false
                        }
                    }) {
                        HStack {
                            Image(systemName: copiedToClipboard ? "checkmark" : "doc.on.doc")
                            Text(copiedToClipboard ? "已复制" : "复制到剪贴板")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(copiedToClipboard ? Color.green : Color.green)
                        .cornerRadius(12)
                    }
                    .disabled(copiedToClipboard)

                    Text("复制后可在AI聊天中粘贴使用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding(24)
            .navigationTitle("智能提示")
            .navigationBarItems(
                trailing: Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// Prompt管理视图
struct PromptManagerView: View {
    @ObservedObject var promptManager: GlobalPromptManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingNameInput = false
    @State private var newPromptName = ""
    @State private var editingPrompt: SavedPrompt?
    @State private var showingPasteAlert = false
    @State private var pasteAlertMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                if promptManager.savedPrompts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("暂无保存的提示")
                            .font(.title2)
                            .foregroundColor(.gray)

                        Text("在浏览器首页生成智能提示后会自动保存到这里")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(promptManager.savedPrompts) { prompt in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(prompt.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)

                                        Text(prompt.timestamp, style: .relative)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    if promptManager.currentPrompt?.id == prompt.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }

                                Text(prompt.content)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .lineLimit(3)

                                HStack {
                                    Button(action: {
                                        promptManager.setCurrentPrompt(prompt)
                                    }) {
                                        Text(promptManager.currentPrompt?.id == prompt.id ? "当前使用" : "设为当前")
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 4)
                                            .background(promptManager.currentPrompt?.id == prompt.id ? Color.green : Color.gray)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                    .disabled(promptManager.currentPrompt?.id == prompt.id)

                                    Button(action: {
                                        UIPasteboard.general.string = prompt.content
                                    }) {
                                        Text("复制")
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 4)
                                            .background(Color.green)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }

                                    Button(action: {
                                        pasteToInput(prompt.content)
                                    }) {
                                        Text("粘贴")
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 4)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }

                                    Spacer()
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let prompt = promptManager.savedPrompts[index]
                                promptManager.deletePrompt(prompt.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("智能提示管理")
            .navigationBarItems(
                trailing: Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .alert("粘贴成功", isPresented: $showingPasteAlert) {
                Button("确定") { }
            } message: {
                Text(pasteAlertMessage)
            }
        }
    }
    
    private func pasteToInput(_ content: String) {
        // 发送通知给浏览器输入框，实现粘贴功能
        NotificationCenter.default.post(name: .pasteToBrowserInput, object: content)
        pasteAlertMessage = "已粘贴到浏览器输入框"
        showingPasteAlert = true
    }
}

struct BrowserView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserView(viewModel: WebViewModel())
    }
}

// MARK: - 扩大输入界面
struct ExpandedInputView: View {
    @Binding var urlText: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.presentationMode) var presentationMode
    
    // 快速输入建议
    private let suggestions = [
        "https://www.baidu.com",
        "https://www.google.com", 
        "https://www.bing.com",
        "https://chat.openai.com",
        "https://chat.deepseek.com",
        "https://kimi.moonshot.cn"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 大输入框
                VStack(alignment: .leading, spacing: 12) {
                    Text("网址或搜索关键词")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("请输入网址或搜索关键词", text: $urlText, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                        .focused($isTextFieldFocused)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                // 快速输入建议
                VStack(alignment: .leading, spacing: 12) {
                    Text("快速访问")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button(action: { 
                                urlText = suggestion
                            }) {
                                Text(suggestion)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.systemGray6))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // 底部按钮
                HStack(spacing: 16) {
                    Button(action: {
                        onCancel()
                    }) {
                        Text("取消")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                    }
                    
                    Button(action: {
                        onConfirm()
                    }) {
                        Text("确定")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.green)
                            )
                    }
                    .disabled(urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("输入网址")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("完成") {
                    onConfirm()
                }
                .disabled(urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
        .onAppear { 
            isTextFieldFocused = true
        }
    }
}

// MARK: - 浏览器AI对话界面
struct BrowserAIChatView: View {
    @Binding var selectedAI: String
    let initialMessage: String
    @Environment(\.presentationMode) var presentationMode
    
    @State private var messageText = ""
    @State private var messages: [BrowserChatMessage] = []
    @State private var isLoading = false
    @State private var showingPromptPicker = false
    
    // 支持API的AI列表
    private let aiList = [
        ("deepseek", "DeepSeek", "brain.head.profile", Color.purple),
        ("qwen", "通义千问", "cloud.fill", Color.cyan),
        ("chatglm", "智谱清言", "lightbulb.fill", Color.yellow),
        ("moonshot", "Kimi", "moon.stars.fill", Color.orange),
        ("claude", "Claude", "c.circle.fill", Color.blue),
        ("gpt", "ChatGPT", "g.circle.fill", Color.green)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // AI选择栏
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(aiList, id: \.0) { ai in
                            Button(action: {
                                selectedAI = ai.0
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: ai.2)
                                        .foregroundColor(selectedAI == ai.0 ? .white : ai.3)
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Text(ai.1)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(selectedAI == ai.0 ? .white : .primary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(selectedAI == ai.0 ? ai.3 : Color(.systemGray6))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                // 聊天消息列表
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            BrowserChatMessageView(message: message)
                        }
                        
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("AI正在思考...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
                
                // 输入区域
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        // 智能提示按钮
                        Button(action: {
                            showingPromptPicker = true
                        }) {
                            Image(systemName: "wand.and.stars")
                                .foregroundColor(.green)
                                .font(.system(size: 18))
                        }
                        
                        // 粘贴按钮
                        Button(action: {
                            if let clipboardText = UIPasteboard.general.string {
                                messageText = clipboardText
                            }
                        }) {
                            Image(systemName: "doc.on.clipboard")
                                .foregroundColor(.blue)
                                .font(.system(size: 18))
                        }
                        
                        // 输入框
                        TextField("输入消息...", text: $messageText, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(1...4)
                        
                        // 发送按钮
                        Button(action: sendMessage) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(messageText.isEmpty ? .gray : .green)
                                .font(.system(size: 18))
                        }
                        .disabled(messageText.isEmpty || isLoading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
            }
            .navigationTitle("AI对话")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $showingPromptPicker) {
                PromptPickerView { prompt in
                    messageText = prompt
                }
            }
        }
        .onAppear {
            if !initialMessage.isEmpty {
                messageText = initialMessage
            }
        }
    }
    
    private func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        // 添加用户消息
        let userMessage = BrowserChatMessage(
            id: UUID().uuidString,
            content: trimmedMessage,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        // 清空输入框
        messageText = ""
        
        // 模拟AI回复
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let aiMessage = BrowserChatMessage(
                id: UUID().uuidString,
                content: "这是来自\(getAIName(selectedAI))的回复：\n\n\(trimmedMessage)",
                isUser: false,
                timestamp: Date()
            )
            messages.append(aiMessage)
            isLoading = false
        }
    }
    
    private func getAIName(_ aiId: String) -> String {
        return aiList.first { $0.0 == aiId }?.1 ?? aiId
    }
}

// MARK: - 聊天消息模型
struct BrowserChatMessage: Identifiable {
    let id: String
    let content: String
    let isUser: Bool
    let timestamp: Date
}

// MARK: - 聊天消息视图
struct BrowserChatMessageView: View {
    let message: BrowserChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
    }
}
