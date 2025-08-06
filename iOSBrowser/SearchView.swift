//  SearchView.swift
//  iOSBrowser
//
//  Created by LZH on 2025/7/20.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedEngine = "baidu"
    
    let engines = [
        ("baidu", "百度", "magnifyingglass.circle.fill", Color.blue),
        ("google", "谷歌", "globe", Color.green),
        ("bing", "必应", "b.circle.fill", Color.blue),
        ("duckduckgo", "DuckDuckGo", "shield.fill", Color.orange)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("输入搜索关键词", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                Button(action: performSearch) {
                    Text("搜索")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            
            // 搜索引擎选择
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(engines, id: \.0) { engine in
                        Button(action: {
                            selectedEngine = engine.0
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: engine.2)
                                    .font(.title2)
                                    .foregroundColor(selectedEngine == engine.0 ? engine.3 : .gray)
                                
                                Text(engine.1)
                                    .font(.caption)
                                    .foregroundColor(selectedEngine == engine.0 ? .primary : .gray)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedEngine == engine.0 ? engine.3.opacity(0.1) : Color.clear)
                            )
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        // 构建搜索URL
        var urlString = ""
        switch selectedEngine {
        case "baidu":
            urlString = "https://www.baidu.com/s?wd=\(searchText)"
        case "google":
            urlString = "https://www.google.com/search?q=\(searchText)"
        case "bing":
            urlString = "https://www.bing.com/search?q=\(searchText)"
        case "duckduckgo":
            urlString = "https://duckduckgo.com/?q=\(searchText)"
        default:
            urlString = "https://www.baidu.com/s?wd=\(searchText)"
        }
        
        // 发送通知切换到浏览器标签页并执行搜索
        NotificationCenter.default.post(name: .performSearch, object: urlString)
    }
}

