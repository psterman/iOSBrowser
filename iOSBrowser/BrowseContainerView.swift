//
//  BrowseContainerView.swift
//  iOSBrowser
//
//  浏览容器视图 - 简化版浏览tab
//

import SwiftUI

struct BrowseContainerView: View {
    @State private var searchText = ""
    @State private var selectedEngine = "google"
    @State private var currentURL = "https://www.google.com"
    
    // 搜索引擎配置
    private let searchEngines = [
        ("google", "Google", "https://www.google.com"),
        ("baidu", "百度", "https://www.baidu.com"),
        ("bing", "Bing", "https://www.bing.com"),
        ("duckduckgo", "DuckDuckGo", "https://duckduckgo.com")
    ]
    
    var body: some View {
        NavigationView {
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
                
                // 简化的网页显示区域
                VStack {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                        Text(currentURL)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding()
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "safari")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("浏览器")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("选择搜索引擎并输入关键词开始搜索")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
                .background(Color(.systemGray6).opacity(0.3))
            }
            .navigationTitle("浏览")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(NotificationCenter.default.publisher(for: .browseWithClipboard)) { notification in
                if let data = notification.object as? [String: String],
                   let engine = data["engine"],
                   let query = data["query"] {
                    handleBrowseWithClipboard(engine: engine, query: query)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .loadSearchEngine)) { notification in
                if let engine = notification.object as? String {
                    selectedEngine = engine == "default" ? "google" : engine
                    loadSearchEngine()
                }
            }
        }
    }
    
    // MARK: - 功能函数
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText
        currentURL = getSearchURL(for: selectedEngine, query: query)
        
        print("🔍 搜索: \(searchText) 使用 \(selectedEngine)")
    }
    
    private func loadSearchEngine() {
        currentURL = getEngineHomeURL(for: selectedEngine)
        print("🌐 加载搜索引擎: \(selectedEngine)")
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
    
    private func handleBrowseWithClipboard(engine: String, query: String) {
        print("🌐 浏览剪贴板搜索: 引擎=\(engine), 查询=\(query)")
        
        selectedEngine = engine == "default" ? "google" : engine
        searchText = query
        
        // 执行搜索
        performSearch()
    }
}
