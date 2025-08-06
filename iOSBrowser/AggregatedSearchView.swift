//
//  AggregatedSearchView.swift
//  iOSBrowser
//
//  聚合搜索视图 - 支持多平台同时搜索
//

import SwiftUI
import WebKit

struct AggregatedSearchView: View {
    @State private var searchQuery = ""
    @State private var isSearching = false
    @State private var searchResults: [PlatformSearchResult] = []
    @State private var selectedPlatform: String?
    @State private var showingWebView = false
    @State private var webViewURL: URL?
    
    // 支持的平台配置
    private let platforms: [SearchPlatform] = [
        SearchPlatform(
            id: "bilibili",
            name: "B站",
            icon: "tv.fill",
            color: Color(red: 0.2, green: 0.7, blue: 0.3),
            searchURL: "https://search.bilibili.com/all?keyword=",
            appScheme: "bilibili://search?keyword="
        ),
        SearchPlatform(
            id: "toutiao",
            name: "今日头条",
            icon: "newspaper.fill",
            color: Color(red: 1.0, green: 0.2, blue: 0.2),
            searchURL: "https://so.toutiao.com/search?keyword=",
            appScheme: "snssdk32://search?keyword="
        ),
        SearchPlatform(
            id: "wechat_mp",
            name: "微信公众号",
            icon: "message.circle.fill",
            color: Color(red: 0.0, green: 0.8, blue: 0.2),
            searchURL: "https://weixin.sogou.com/weixin?type=1&query=",
            appScheme: "weixin://"
        ),
        SearchPlatform(
            id: "ximalaya",
            name: "喜马拉雅",
            icon: "headphones",
            color: Color(red: 1.0, green: 0.4, blue: 0.0),
            searchURL: "https://www.ximalaya.com/search/",
            appScheme: "ximalaya://search?keyword="
        ),
        SearchPlatform(
            id: "xiaohongshu",
            name: "小红书",
            icon: "heart.fill",
            color: Color(red: 1.0, green: 0.2, blue: 0.4),
            searchURL: "https://www.xiaohongshu.com/search_result?keyword=",
            appScheme: "xhsdiscover://search?keyword="
        ),
        SearchPlatform(
            id: "zhihu",
            name: "知乎",
            icon: "bubble.left.and.bubble.right.fill",
            color: Color(red: 0.0, green: 0.5, blue: 1.0),
            searchURL: "https://www.zhihu.com/search?q=",
            appScheme: "zhihu://search?q="
        ),
        SearchPlatform(
            id: "douyin",
            name: "抖音",
            icon: "music.note",
            color: Color(red: 0.0, green: 0.0, blue: 0.0),
            searchURL: "https://www.douyin.com/search/",
            appScheme: "snssdk1128://search?keyword="
        ),
        SearchPlatform(
            id: "weibo",
            name: "微博",
            icon: "at",
            color: Color(red: 1.0, green: 0.3, blue: 0.3),
            searchURL: "https://s.weibo.com/weibo?q=",
            appScheme: "sinaweibo://search?q="
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索输入区域
                searchInputSection
                
                // 平台选择区域
                platformSelectionSection
                
                // 搜索结果区域
                searchResultsSection
                
                Spacer()
            }
            .navigationTitle("聚合搜索")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingWebView) {
                if let url = webViewURL {
                    WebView(url: url)
                        .navigationTitle("搜索结果")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
    
    // MARK: - 搜索输入区域
    private var searchInputSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                TextField("输入搜索关键词...", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        performAggregatedSearch()
                    }
                
                Button(action: performAggregatedSearch) {
                    if isSearching {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
                .frame(width: 44, height: 44)
                .background(searchQuery.isEmpty ? Color.gray : Color.themeGreen)
                .cornerRadius(8)
                .disabled(searchQuery.isEmpty || isSearching)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // 快速搜索建议
            if searchQuery.isEmpty {
                quickSearchSuggestions
            }
        }
    }
    
    // MARK: - 快速搜索建议
    private var quickSearchSuggestions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["热门话题", "科技资讯", "娱乐八卦", "美食推荐", "旅游攻略"], id: \.self) { suggestion in
                    Button(action: {
                        searchQuery = suggestion
                        performAggregatedSearch()
                    }) {
                        Text(suggestion)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.themeLightGreen.opacity(0.2))
                            .foregroundColor(.themeGreen)
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - 平台选择区域
    private var platformSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择搜索平台")
                .font(.headline)
                .padding(.horizontal, 16)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(platforms) { platform in
                    PlatformCard(
                        platform: platform,
                        isSelected: selectedPlatform == platform.id
                    ) {
                        selectedPlatform = platform.id
                        if !searchQuery.isEmpty {
                            performSinglePlatformSearch(platform: platform)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - 搜索结果区域
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !searchResults.isEmpty {
                HStack {
                    Text("搜索结果")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button("清空") {
                        searchResults.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.themeGreen)
                }
                .padding(.horizontal, 16)
                
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(searchResults) { result in
                            SearchResultCard(result: result) {
                                openSearchResult(result)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            } else if isSearching {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("正在搜索中...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    // MARK: - 执行聚合搜索
    private func performAggregatedSearch() {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isSearching = true
        searchResults.removeAll()
        
        // 模拟多平台搜索
        Task {
            await performMultiPlatformSearch()
            
            DispatchQueue.main.async {
                isSearching = false
            }
        }
    }
    
    // MARK: - 执行单平台搜索
    private func performSinglePlatformSearch(platform: SearchPlatform) {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // 尝试打开应用
        if let appURL = URL(string: platform.appScheme + searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
            UIApplication.shared.open(appURL) { success in
                if !success {
                    // 应用未安装，打开网页版
                    self.openWebSearch(platform: platform)
                }
            }
        } else {
            // 直接打开网页版
            openWebSearch(platform: platform)
        }
    }
    
    // MARK: - 打开网页搜索
    private func openWebSearch(platform: SearchPlatform) {
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchQuery
        if let url = URL(string: platform.searchURL + encodedQuery) {
            webViewURL = url
            showingWebView = true
        }
    }
    
    // MARK: - 执行多平台搜索
    private func performMultiPlatformSearch() async {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 模拟多平台搜索结果
        var results: [PlatformSearchResult] = []
        
        for platform in platforms {
            // 模拟搜索延迟
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            
            let result = PlatformSearchResult(
                platform: platform,
                title: "\(platform.name)搜索结果：\(query)",
                description: "在\(platform.name)中找到关于"\(query)"的相关内容",
                url: platform.searchURL + query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                timestamp: Date()
            )
            
            results.append(result)
        }
        
        DispatchQueue.main.async {
            self.searchResults = results
        }
    }
    
    // MARK: - 打开搜索结果
    private func openSearchResult(_ result: PlatformSearchResult) {
        if let url = URL(string: result.url) {
            webViewURL = url
            showingWebView = true
        }
    }
}

// MARK: - 平台卡片
struct PlatformCard: View {
    let platform: SearchPlatform
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: platform.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : platform.color)
                
                Text(platform.name)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? platform.color : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 搜索结果卡片
struct SearchResultCard: View {
    let result: PlatformSearchResult
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: result.platform.icon)
                    .font(.title3)
                    .foregroundColor(result.platform.color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(result.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Text(result.platform.name)
                        .font(.caption2)
                        .foregroundColor(result.platform.color)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 数据模型
struct SearchPlatform: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let searchURL: String
    let appScheme: String
}

struct PlatformSearchResult: Identifiable {
    let id = UUID()
    let platform: SearchPlatform
    let title: String
    let description: String
    let url: String
    let timestamp: Date
}

// MARK: - WebView
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
} 