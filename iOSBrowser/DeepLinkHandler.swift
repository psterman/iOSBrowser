import SwiftUI

class DeepLinkHandler: ObservableObject {
    @Published var targetTab = 0
    @Published var searchQuery = ""
    @Published var selectedApp = ""
    @Published var selectedEngine = ""
    
    func handleDeepLink(_ url: URL) {
        print("🔗 处理深度链接: \(url.absoluteString)")
        
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
            // iosbrowser://app?id=taobao&q=商品
            targetTab = 0 // 切换到搜索标签页
            if let appId = params["id"] {
                selectedApp = appId
            }
            if let query = params["q"] {
                searchQuery = query
            }
            
        case "ai":
            // iosbrowser://ai?assistant=deepseek&q=问题
            targetTab = 2 // 切换到AI标签页
            if let query = params["q"] {
                searchQuery = query
            }
            
        default:
            print("❌ 未知的深度链接host: \(host)")
            break
        }
    }
} 