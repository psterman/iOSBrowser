//
//  iOSBrowserApp.swift
//  iOSBrowser
//
//  Created by LZH on 2025/7/13.
//

import SwiftUI
import UIKit
import WidgetKit
import BackgroundTasks

// 导入 WidgetDataManager
@_exported import struct Foundation.Notification
@_exported import class Foundation.NotificationCenter

@main
struct iOSBrowserApp: App {
    @StateObject private var deepLinkHandler = DeepLinkHandler()
    
    init() {
        print("🚨🚨🚨 ===== iOSBrowserApp.init() 被调用 =====")
        print("🚨🚨🚨 ===== 应用启动，立即初始化数据 =====")
        print("🚨🚨🚨 ===== 如果你看到这个日志，说明应用启动正常 =====")
        WidgetDataManager.shared.initializeData()
        print("🚨🚨🚨 ===== 应用数据初始化完成 =====")
        print("🚨🚨🚨 ===== iOSBrowserApp.init() 执行完成 =====")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deepLinkHandler)
                .onOpenURL { url in
                    print("🔗 收到深度链接: \(url)")
                    deepLinkHandler.handleDeepLink(url)
                }
        }
    }
}

// MARK: - 深度链接处理器
class DeepLinkHandler: ObservableObject {
    @Published var targetTab = 0
    @Published var searchQuery = ""
    @Published var selectedApp = ""
    @Published var selectedEngine = ""
    
    func handleDeepLink(_ url: URL) {
        print("🔗 处理深度链接: \(url)")
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else {
            print("❌ 无效的深度链接URL")
            return
        }
        
        // 解析查询参数
        let queryItems = components.queryItems ?? []
        let params = Dictionary(uniqueKeysWithValues: queryItems.map { ($0.name, $0.value ?? "") })
        
        switch host {
        case "search":
            // iosbrowser://search?engine=baidu&q=swift
            targetTab = 0 // 切换到搜索标签页
            if let engine = params["engine"] {
                selectedEngine = engine
            }
            if let query = params["q"] {
                searchQuery = query
            }
            
        case "app":
            // iosbrowser://app?id=taobao&q=iphone
            targetTab = 0 // 切换到搜索标签页
            if let appId = params["id"] {
                selectedApp = appId
            }
            if let query = params["q"] {
                searchQuery = query
            }
            
        case "browser":
            // iosbrowser://browser?url=https://www.example.com
            targetTab = 1 // 切换到浏览器标签页
            if let urlString = params["url"] {
                NotificationCenter.default.post(
                    name: Notification.Name("loadUrl"),
                    object: urlString
                )
            }
            
        case "ai":
            // iosbrowser://ai?assistant=deepseek&q=hello
            targetTab = 2 // 切换到AI聊天标签页
            if let assistant = params["assistant"],
               let query = params["q"] {
                NotificationCenter.default.post(
                    name: Notification.Name("startAIConversation"),
                    object: [
                        "assistantId": assistant,
                        "initialMessage": query
                    ]
                )
            }
            
        case "settings":
            // iosbrowser://settings
            targetTab = 3 // 切换到设置标签页
            
        default:
            print("❌ 未知的深度链接类型: \(host)")
        }
    }
}
