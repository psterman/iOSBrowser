//
//  BrowseView.swift
//  iOSBrowser
//
//  浏览tab - 支持搜索引擎浏览和剪贴板搜索
//

import SwiftUI
import WebKit

struct BrowseView: View {
    @State private var searchText = ""
    @State private var selectedEngine = "google"
    @State private var isLoading = false
    @State private var webView: WKWebView?
    
    // 搜索引擎配置
    private let searchEngines = [
        ("google", "Google", "https://www.google.com/search?q="),
        ("baidu", "百度", "https://www.baidu.com/s?wd="),
        ("bing", "Bing", "https://www.bing.com/search?q="),
        ("duckduckgo", "DuckDuckGo", "https://duckduckgo.com/?q=")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 搜索栏
            VStack(spacing: 12) {
                // 搜索引擎选择
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(searchEngines, id: \.0) { engine in
                            Button(action: {
                                selectedEngine = engine.0
                                loadSearchEngine()
                            }) {
                                Text(engine.1)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedEngine == engine.0 ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedEngine == engine.0 ? Color.blue : Color(.systemGray6))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 搜索输入框
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("搜索...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onSubmit {
                            performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color(.systemBackground))
            
            // WebView
            WebViewRepresentable(webView: $webView, isLoading: $isLoading)
                .onAppear {
                    setupNotificationObservers()
                    loadSearchEngine()
                }
        }
        .navigationTitle("浏览")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 功能函数
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText
        let searchURL = getSearchURL(for: selectedEngine, query: query)
        
        if let url = URL(string: searchURL) {
            webView?.load(URLRequest(url: url))
        }
    }
    
    private func loadSearchEngine() {
        let homeURL = getEngineHomeURL(for: selectedEngine)
        if let url = URL(string: homeURL) {
            webView?.load(URLRequest(url: url))
        }
    }
    
    private func getSearchURL(for engine: String, query: String) -> String {
        switch engine {
        case "google":
            return "https://www.google.com/search?q=\(query)"
        case "baidu":
            return "https://www.baidu.com/s?wd=\(query)"
        case "bing":
            return "https://www.bing.com/search?q=\(query)"
        case "duckduckgo":
            return "https://duckduckgo.com/?q=\(query)"
        default:
            return "https://www.google.com/search?q=\(query)"
        }
    }
    
    private func getEngineHomeURL(for engine: String) -> String {
        switch engine {
        case "google":
            return "https://www.google.com"
        case "baidu":
            return "https://www.baidu.com"
        case "bing":
            return "https://www.bing.com"
        case "duckduckgo":
            return "https://duckduckgo.com"
        default:
            return "https://www.google.com"
        }
    }
    
    // MARK: - 通知处理
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .browseWithClipboard,
            object: nil,
            queue: .main
        ) { notification in
            if let data = notification.object as? [String: String],
               let engine = data["engine"],
               let query = data["query"] {
                handleBrowseWithClipboard(engine: engine, query: query)
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .loadSearchEngine,
            object: nil,
            queue: .main
        ) { notification in
            if let engine = notification.object as? String {
                selectedEngine = engine == "default" ? "google" : engine
                loadSearchEngine()
            }
        }
    }
    
    private func handleBrowseWithClipboard(engine: String, query: String) {
        print("🌐 浏览剪贴板搜索: 引擎=\(engine), 查询=\(query)")
        
        selectedEngine = engine == "default" ? "google" : engine
        searchText = query
        
        // 执行搜索
        performSearch()
    }
}

// MARK: - WebView Representable

struct WebViewRepresentable: UIViewRepresentable {
    @Binding var webView: WKWebView?
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        self.webView = webView
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 更新UI
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebViewRepresentable
        
        init(_ parent: WebViewRepresentable) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
    }
}
