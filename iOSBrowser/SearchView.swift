//
//  SearchView.swift
//  iOSBrowser
//
//  Created by LZH on 2025/7/20.
//

import SwiftUI
import UIKit

struct SearchView: View {
    @State private var searchText = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // 应用数据
    private let apps = [
        AppInfo(name: "淘宝", icon: "bag.fill", color: .orange, urlScheme: "taobao://s.taobao.com/search?q="),
        AppInfo(name: "拼多多", icon: "cart.fill", color: .red, urlScheme: "pinduoduo://search?keyword="),
        AppInfo(name: "知乎", icon: "questionmark.circle.fill", color: .blue, urlScheme: "zhihu://search?q="),
        AppInfo(name: "抖音", icon: "music.note", color: .black, urlScheme: "snssdk1128://search?keyword="),
        AppInfo(name: "美团", icon: "fork.knife", color: .yellow, urlScheme: "imeituan://www.meituan.com/search?q="),
        AppInfo(name: "豆瓣", icon: "book.fill", color: .green, urlScheme: "douban://search?q="),
        AppInfo(name: "微博", icon: "at", color: .red, urlScheme: "sinaweibo://search?q="),
        AppInfo(name: "bilibili", icon: "tv.fill", color: .pink, urlScheme: "bilibili://search?keyword="),
        AppInfo(name: "YouTube", icon: "play.rectangle.fill", color: .red, urlScheme: "youtube://results?search_query="),
        AppInfo(name: "京东", icon: "shippingbox.fill", color: .red, urlScheme: "openapp.jdmobile://virtual?params={\"category\":\"jump\",\"des\":\"search\",\"keyword\":\""),
        AppInfo(name: "闲鱼", icon: "fish.fill", color: .blue, urlScheme: "fleamarket://search?q=")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                        
                        TextField("输入搜索关键词", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .onSubmit {
                                // 可以添加默认搜索行为
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    
                    Text("选择应用进行搜索")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.top, 16)
                .padding(.bottom, 24)
                .background(Color(.systemBackground))
                
                // 应用网格
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 24) {
                        ForEach(apps, id: \.name) { app in
                            AppButton(app: app, searchText: searchText) {
                                searchInApp(app: app)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("应用搜索")
            .navigationBarTitleDisplayMode(.large)
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func searchInApp(app: AppInfo) {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "请输入搜索关键词"
            showingAlert = true
            return
        }
        
        let keyword = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText
        let urlString = app.urlScheme + keyword
        
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url) { success in
                    if !success {
                        DispatchQueue.main.async {
                            alertMessage = "无法打开\(app.name)应用，请确保已安装该应用"
                            showingAlert = true
                        }
                    }
                }
            } else {
                alertMessage = "未安装\(app.name)应用或不支持该搜索功能"
                showingAlert = true
            }
        }
    }
}

struct AppInfo {
    let name: String
    let icon: String
    let color: Color
    let urlScheme: String
}

struct AppButton: View {
    let app: AppInfo
    let searchText: String
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
                // 应用图标
                ZStack {
                    Circle()
                        .fill(app.color.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: app.icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(app.color)
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
                
                // 应用名称
                Text(app.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
