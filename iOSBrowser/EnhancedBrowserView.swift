//
//  EnhancedBrowserView.swift
//  iOSBrowser
//
//  增强的浏览器视图 - 完整的网页浏览功能
//

import SwiftUI
import WebKit

struct EnhancedBrowserView: View {
    @ObservedObject var viewModel: WebViewModel
    @State private var showingBookmarks = false
    @State private var showingHistory = false
    @State private var showingShareSheet = false
    @State private var showingSearchEngines = false
    @State private var showingGestureGuide = false
    @State private var currentURL: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 地址栏和工具栏
            browserToolbar
            
            // 网页内容
            WebViewContainer(viewModel: viewModel)
                .onReceive(viewModel.$currentURL) { url in
                    currentURL = url
                }
        }
        .sheet(isPresented: $showingBookmarks) {
            BookmarksView()
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView()
        }
        .sheet(isPresented: $showingSearchEngines) {
            SearchEngineSelectorView { engine in
                viewModel.loadSearchEngine(engine)
                showingSearchEngines = false
            }
        }
        .sheet(isPresented: $showingGestureGuide) {
            GestureGuideView()
        }
        .actionSheet(isPresented: $showingShareSheet) {
            ActionSheet(
                title: Text("分享"),
                buttons: [
                    .default(Text("复制链接")) {
                        UIPasteboard.general.string = currentURL
                    },
                    .default(Text("分享到微信")) {
                        shareToWeChat()
                    },
                    .default(Text("分享到微博")) {
                        shareToWeibo()
                    },
                    .default(Text("系统分享")) {
                        shareToSystem()
                    },
                    .cancel()
                ]
            )
        }
    }
    
    // MARK: - 浏览器工具栏
    private var browserToolbar: some View {
        VStack(spacing: 0) {
            // 地址栏
            HStack(spacing: 8) {
                // 后退按钮
                Button(action: viewModel.goBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(viewModel.canGoBack ? .themeGreen : .gray)
                }
                .disabled(!viewModel.canGoBack)
                
                // 前进按钮
                Button(action: viewModel.goForward) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(viewModel.canGoForward ? .themeGreen : .gray)
                }
                .disabled(!viewModel.canGoForward)
                
                // 地址栏
                HStack {
                    if !currentURL.isEmpty {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "magnifyingglass")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(currentURL.isEmpty ? "输入网址或搜索关键词" : currentURL)
                        .font(.system(size: 14))
                        .foregroundColor(currentURL.isEmpty ? .secondary : .primary)
                        .lineLimit(1)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .onTapGesture {
                    // 可以在这里添加地址栏编辑功能
                }
                
                // 刷新按钮
                Button(action: viewModel.refresh) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.themeGreen)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
            
            // 功能工具栏
            HStack(spacing: 16) {
                // 书签按钮
                Button(action: { showingBookmarks = true }) {
                    VStack(spacing: 2) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 18))
                        Text("书签")
                            .font(.caption2)
                    }
                    .foregroundColor(.themeGreen)
                }
                
                // 历史按钮
                Button(action: { showingHistory = true }) {
                    VStack(spacing: 2) {
                        Image(systemName: "clock")
                            .font(.system(size: 18))
                        Text("历史")
                            .font(.caption2)
                    }
                    .foregroundColor(.themeGreen)
                }
                
                // 搜索引擎按钮
                Button(action: { showingSearchEngines = true }) {
                    VStack(spacing: 2) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18))
                        Text("搜索")
                            .font(.caption2)
                    }
                    .foregroundColor(.themeGreen)
                }
                
                Spacer()
                
                // 手势指南按钮
                Button(action: { showingGestureGuide = true }) {
                    VStack(spacing: 2) {
                        Image(systemName: "hand.raised")
                            .font(.system(size: 18))
                        Text("手势")
                            .font(.caption2)
                    }
                    .foregroundColor(.themeGreen)
                }
                
                // 分享按钮
                Button(action: { showingShareSheet = true }) {
                    VStack(spacing: 2) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18))
                        Text("分享")
                            .font(.caption2)
                    }
                    .foregroundColor(.themeGreen)
                }
                
                // 菜单按钮
                Button(action: showMenu) {
                    VStack(spacing: 2) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18))
                        Text("更多")
                            .font(.caption2)
                    }
                    .foregroundColor(.themeGreen)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            Divider()
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - 分享功能
    private func shareToWeChat() {
        // 分享到微信
        if let url = URL(string: "weixin://") {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareToWeibo() {
        // 分享到微博
        if let url = URL(string: "sinaweibo://") {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareToSystem() {
        // 系统分享
        let activityVC = UIActivityViewController(
            activityItems: [currentURL],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func showMenu() {
        // 显示更多菜单
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "添加到书签", style: .default) { _ in
            addToBookmarks()
        })
        
        alert.addAction(UIAlertAction(title: "清除历史记录", style: .destructive) { _ in
            clearHistory()
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
    
    private func addToBookmarks() {
        // 添加到书签
        let bookmark = Bookmark(
            id: UUID(),
            title: viewModel.pageTitle,
            url: currentURL,
            dateAdded: Date()
        )
        BookmarkManager.shared.addBookmark(bookmark)
    }
    
    private func clearHistory() {
        // 清除历史记录
        HistoryManager.shared.clearHistory()
    }
}

// MARK: - WebView容器
struct WebViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = false
        
        // 设置内容拦截
        if ContentBlockManager.shared.isEnabled {
            let rules = ContentBlockManager.shared.getAllBlockRules()
            // 这里可以添加内容拦截规则
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // 更新WebView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewContainer
        
        init(_ parent: WebViewContainer) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.viewModel.currentURL = webView.url?.absoluteString ?? ""
            parent.viewModel.pageTitle = webView.title ?? ""
            parent.viewModel.canGoBack = webView.canGoBack
            parent.viewModel.canGoForward = webView.canGoForward
            parent.viewModel.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.viewModel.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.viewModel.isLoading = false
        }
    }
}

// MARK: - 书签视图
struct BookmarksView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var bookmarkManager = BookmarkManager.shared
    
    var body: some View {
        NavigationView {
            List {
                ForEach(bookmarkManager.bookmarks) { bookmark in
                    BookmarkRow(bookmark: bookmark)
                }
                .onDelete(perform: deleteBookmarks)
            }
            .navigationTitle("书签")
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
    
    private func deleteBookmarks(offsets: IndexSet) {
        bookmarkManager.removeBookmarks(at: offsets)
    }
}

// MARK: - 书签行
struct BookmarkRow: View {
    let bookmark: Bookmark
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(bookmark.title)
                .font(.headline)
                .lineLimit(1)
            
            Text(bookmark.url)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Text(bookmark.dateAdded, style: .date)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 历史视图
struct HistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var historyManager = HistoryManager.shared
    
    var body: some View {
        NavigationView {
            List {
                ForEach(historyManager.historyItems) { item in
                    HistoryRow(item: item)
                }
                .onDelete(perform: deleteHistory)
            }
            .navigationTitle("历史记录")
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
    
    private func deleteHistory(offsets: IndexSet) {
        historyManager.removeHistoryItems(at: offsets)
    }
}

// MARK: - 历史行
struct HistoryRow: View {
    let item: HistoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.headline)
                .lineLimit(1)
            
            Text(item.url)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Text(item.dateVisited, style: .date)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 搜索引擎选择器
struct SearchEngineSelectorView: View {
    @Environment(\.presentationMode) var presentationMode
    let onSelect: (SearchEngine) -> Void
    
    private let searchEngines: [SearchEngine] = [
        SearchEngine(id: "baidu", name: "百度", url: "https://www.baidu.com/s?wd="),
        SearchEngine(id: "google", name: "Google", url: "https://www.google.com/search?q="),
        SearchEngine(id: "bing", name: "必应", url: "https://www.bing.com/search?q="),
        SearchEngine(id: "sogou", name: "搜狗", url: "https://www.sogou.com/web?query=")
    ]
    
    var body: some View {
        NavigationView {
            List(searchEngines) { engine in
                Button(action: {
                    onSelect(engine)
                }) {
                    HStack {
                        Text(engine.name)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("选择搜索引擎")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 数据模型
struct Bookmark: Identifiable, Codable {
    let id: UUID
    let title: String
    let url: String
    let dateAdded: Date
}

struct HistoryItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let url: String
    let dateVisited: Date
}

struct SearchEngine: Identifiable {
    let id: String
    let name: String
    let url: String
}

// MARK: - 管理器
class BookmarkManager: ObservableObject {
    static let shared = BookmarkManager()
    
    @Published var bookmarks: [Bookmark] = []
    
    private init() {
        loadBookmarks()
    }
    
    func addBookmark(_ bookmark: Bookmark) {
        bookmarks.append(bookmark)
        saveBookmarks()
    }
    
    func removeBookmarks(at offsets: IndexSet) {
        bookmarks.remove(atOffsets: offsets)
        saveBookmarks()
    }
    
    private func loadBookmarks() {
        if let data = UserDefaults.standard.data(forKey: "bookmarks"),
           let bookmarks = try? JSONDecoder().decode([Bookmark].self, from: data) {
            self.bookmarks = bookmarks
        }
    }
    
    private func saveBookmarks() {
        if let data = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(data, forKey: "bookmarks")
        }
    }
}

class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    
    @Published var historyItems: [HistoryItem] = []
    
    private init() {
        loadHistory()
    }
    
    func addHistoryItem(_ item: HistoryItem) {
        historyItems.insert(item, at: 0)
        if historyItems.count > 100 {
            historyItems = Array(historyItems.prefix(100))
        }
        saveHistory()
    }
    
    func removeHistoryItems(at offsets: IndexSet) {
        historyItems.remove(atOffsets: offsets)
        saveHistory()
    }
    
    func clearHistory() {
        historyItems.removeAll()
        saveHistory()
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "browser_history"),
           let history = try? JSONDecoder().decode([HistoryItem].self, from: data) {
            self.historyItems = history
        }
    }
    
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(historyItems) {
            UserDefaults.standard.set(data, forKey: "browser_history")
        }
    }
} 