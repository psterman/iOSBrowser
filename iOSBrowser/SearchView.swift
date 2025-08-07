//  SearchView.swift
//  iOSBrowser
//
//  Created by LZH on 2025/7/20.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    
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
            
            // 提示信息
            VStack(spacing: 16) {
                Image(systemName: "magnifyingglass.circle")
                    .font(.system(size: 48))
                    .foregroundColor(.gray)
                
                Text("请输入搜索关键词")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("搜索功能已简化，请使用浏览 tab 进行详细搜索")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.top, 60)
            
            Spacer()
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        // 使用默认搜索引擎（百度）
        let urlString = "https://www.baidu.com/s?wd=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText)"
        
        // 发送通知切换到浏览器标签页并执行搜索
        NotificationCenter.default.post(name: .performSearch, object: urlString)
    }
}

