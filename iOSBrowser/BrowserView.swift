//
//  BrowserView.swift
//  iOSBrowser
//
//  Created by LZH on 2025/7/19.
//

import SwiftUI
import UIKit

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

    private let searchEngines = [
        BrowserSearchEngine(id: "baidu", name: "百度", url: "https://www.baidu.com/s?wd=", icon: "magnifyingglass", color: .blue),
        BrowserSearchEngine(id: "bing", name: "必应", url: "https://www.bing.com/search?q=", icon: "magnifyingglass.circle", color: .orange),
        BrowserSearchEngine(id: "deepseek", name: "DeepSeek", url: "https://chat.deepseek.com/", icon: "brain.head.profile", color: .purple),
        BrowserSearchEngine(id: "kimi", name: "Kimi", url: "https://kimi.moonshot.cn/", icon: "moon.stars", color: .orange),
        BrowserSearchEngine(id: "doubao", name: "豆包", url: "https://www.doubao.com/chat/", icon: "bubble.left.and.bubble.right", color: .green),
        BrowserSearchEngine(id: "wenxin", name: "文心一言", url: "https://yiyan.baidu.com/", icon: "doc.text", color: .red),
        BrowserSearchEngine(id: "yuanbao", name: "元宝", url: "https://yuanbao.tencent.com/", icon: "diamond", color: .blue),
        BrowserSearchEngine(id: "chatglm", name: "智谱清言", url: "https://chatglm.cn/main/gdetail", icon: "lightbulb.fill", color: .yellow),
        BrowserSearchEngine(id: "tongyi", name: "通义千问", url: "https://tongyi.aliyun.com/qianwen/", icon: "cloud.fill", color: .cyan),
        BrowserSearchEngine(id: "claude", name: "Claude", url: "https://claude.ai/chats", icon: "sparkles", color: .indigo),
        BrowserSearchEngine(id: "chatgpt", name: "ChatGPT", url: "https://chat.openai.com/", icon: "bubble.left.and.bubble.right.fill", color: .green),
        BrowserSearchEngine(id: "metaso", name: "秘塔", url: "https://metaso.cn/", icon: "lock.shield", color: .gray),
        BrowserSearchEngine(id: "nano", name: "纳米搜索", url: "https://bot.n.cn/", icon: "atom", color: .pink)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏和工具栏
                if viewModel.isUIVisible {
                    VStack(spacing: 8) {
                        // 搜索引擎选择栏
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(searchEngines.enumerated()), id: \.offset) { index, engine in
                                    SearchEngineButton(
                                        engine: engine,
                                        isSelected: selectedSearchEngine == index
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedSearchEngine = index
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
                        .padding(.top, 8)

                        // URL输入栏
                        HStack(spacing: 8) {
                            HStack {
                                Image(systemName: searchEngines[selectedSearchEngine].icon)
                                    .foregroundColor(searchEngines[selectedSearchEngine].color)
                                    .font(.system(size: 16))

                                TextField("输入网址或搜索内容", text: $urlText)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .onSubmit {
                                        loadURL()
                                    }
                                    .onReceive(viewModel.$urlString) { newURL in
                                        // 只有当用户没有在编辑时才更新地址栏
                                        if !urlText.isEmpty && urlText != newURL {
                                            // 用户正在输入，不更新
                                        } else if let newURL = newURL, !newURL.isEmpty {
                                            urlText = newURL
                                        }
                                    }

                                HStack(spacing: 8) {
                                    // 粘贴按钮
                                    Button(action: {
                                        pasteFromClipboard()
                                    }) {
                                        Image(systemName: "doc.on.clipboard")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 16))
                                    }

                                    if !urlText.isEmpty {
                                        // 前往按钮
                                        Button(action: {
                                            loadURL()
                                        }) {
                                            Image(systemName: "arrow.right.circle.fill")
                                                .foregroundColor(.blue)
                                                .font(.system(size: 16))
                                        }

                                        // 清除按钮
                                        Button(action: {
                                            urlText = ""
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 16))
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                            Button(action: {
                                showingBookmarks.toggle()
                            }) {
                                Image(systemName: "book.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 18))
                            }
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
                                    .foregroundColor(viewModel.canGoBack ? .blue : .gray)
                            }
                            .disabled(!viewModel.canGoBack)
                            
                            Button(action: {
                                viewModel.goForward()
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(viewModel.canGoForward ? .blue : .gray)
                            }
                            .disabled(!viewModel.canGoForward)
                            
                            Button(action: {
                                viewModel.webView.reload()
                            }) {
                                Image(systemName: viewModel.isLoading ? "stop.fill" : "arrow.clockwise")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                addToBookmarks()
                            }) {
                                Image(systemName: "star")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                            
                            Button(action: {
                                shareCurrentURL()
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.blue)
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
                
                // WebView
                WebView(viewModel: viewModel)
                    .clipped()
            }
            .navigationBarHidden(true)
            .onAppear {
                // 设置默认URL
                if urlText.isEmpty {
                    urlText = "https://www.baidu.com"
                    loadURL()
                }
                loadBookmarks()
            }
            .sheet(isPresented: $showingBookmarks) {
                BookmarksView(bookmarks: $bookmarks) { url in
                    urlText = url
                    loadURL()
                    showingBookmarks = false
                }
            }
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
                    // AI聊天类搜索引擎，如果用户输入了搜索词，则搜索；否则跳转到主页
                    if !trimmedText.isEmpty && !trimmedText.contains(".") {
                        // 对于AI搜索引擎，直接跳转到主页让用户输入问题
                        urlString = selectedEngine.url
                    } else {
                        urlString = selectedEngine.url
                    }
                default:
                    urlString = "https://www.baidu.com/s?wd=" + urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                }
            }
        }

        viewModel.loadUrl(urlString)
    }
    
    private func addToBookmarks() {
        guard let currentURL = viewModel.urlString, !currentURL.isEmpty else { return }
        
        if !bookmarks.contains(currentURL) {
            bookmarks.append(currentURL)
            saveBookmarks()
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
                            
                            Text(bookmark)
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
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? .white : engine.color)

                Text(engine.name)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white : engine.color)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
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

struct BrowserView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserView(viewModel: WebViewModel())
    }
}
