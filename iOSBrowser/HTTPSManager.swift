//
//  HTTPSManager.swift
//  iOSBrowser
//
//  HTTPS传输管理器 - 确保所有数据传输使用HTTPS协议
//

import Foundation
import Network
import Security

class HTTPSManager: ObservableObject {
    static let shared = HTTPSManager()
    
    @Published var isHTTPSOnly = true
    @Published var certificatePinning = true
    @Published var connectionStats = ConnectionStats()
    
    private let session: URLSession
    private let networkMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "HTTPSManager")
    
    private init() {
        // 配置HTTPS-only的URLSession
        let config = URLSessionConfiguration.default
        config.tlsMinimumSupportedProtocolVersion = .TLSv12
        config.tlsMaximumSupportedProtocolVersion = .TLSv13
        
        // 设置安全传输策略
        config.httpShouldUsePipelining = false
        config.httpShouldSetCookies = false
        config.httpCookieAcceptPolicy = .never
        
        session = URLSession(configuration: config)
        
        setupNetworkMonitoring()
        loadSettings()
    }
    
    // MARK: - 设置网络监控
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateConnectionStatus(path)
            }
        }
        networkMonitor.start(queue: queue)
    }
    
    // MARK: - 更新连接状态
    private func updateConnectionStatus(_ path: NWPath) {
        connectionStats.isConnected = path.status == .satisfied
        connectionStats.connectionType = getConnectionType(path)
        connectionStats.isSecure = path.isExpensive == false
    }
    
    // MARK: - 获取连接类型
    private func getConnectionType(_ path: NWPath) -> String {
        if path.usesInterfaceType(.wifi) {
            return "WiFi"
        } else if path.usesInterfaceType(.cellular) {
            return "Cellular"
        } else if path.usesInterfaceType(.wiredEthernet) {
            return "Ethernet"
        } else {
            return "Unknown"
        }
    }
    
    // MARK: - 设置管理
    private func loadSettings() {
        let defaults = UserDefaults.standard
        isHTTPSOnly = defaults.bool(forKey: "https_only_enabled")
        certificatePinning = defaults.bool(forKey: "certificate_pinning_enabled")
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(isHTTPSOnly, forKey: "https_only_enabled")
        defaults.set(certificatePinning, forKey: "certificate_pinning_enabled")
    }
    
    // MARK: - 安全的URL请求
    func secureRequest(url: URL, method: String = "GET", headers: [String: String] = [:], body: Data? = nil) async throws -> (Data, URLResponse) {
        guard isHTTPSOnly else {
            return try await performRequest(url: url, method: method, headers: headers, body: body)
        }
        
        // 强制使用HTTPS
        guard let secureURL = ensureHTTPS(url) else {
            throw HTTPSError.insecureURL
        }
        
        return try await performRequest(url: secureURL, method: method, headers: headers, body: body)
    }
    
    // MARK: - 确保HTTPS
    private func ensureHTTPS(_ url: URL) -> URL? {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if components?.scheme == "http" {
            components?.scheme = "https"
            return components?.url
        }
        
        return url
    }
    
    // MARK: - 执行请求
    private func performRequest(url: URL, method: String, headers: [String: String], body: Data?) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        
        // 添加安全头
        var secureHeaders = headers
        secureHeaders["User-Agent"] = "iOSBrowser/1.0 (HTTPS-Only)"
        secureHeaders["Accept"] = "application/json, text/html, */*"
        secureHeaders["Accept-Language"] = "zh-CN,zh;q=0.9,en;q=0.8"
        
        request.allHTTPHeaderFields = secureHeaders
        
        // 设置超时
        request.timeoutInterval = 30.0
        
        do {
            let (data, response) = try await session.data(for: request)
            
            // 验证响应
            try validateResponse(response)
            
            // 更新统计
            updateStats(success: true)
            
            return (data, response)
        } catch {
            updateStats(success: false)
            throw error
        }
    }
    
    // MARK: - 验证响应
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPSError.invalidResponse
        }
        
        // 检查状态码
        guard (200...299).contains(httpResponse.statusCode) else {
            throw HTTPSError.httpError(httpResponse.statusCode)
        }
        
        // 检查内容类型
        if let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") {
            if contentType.contains("text/html") && !contentType.contains("charset=utf-8") {
                throw HTTPSError.invalidContentType
            }
        }
    }
    
    // MARK: - 证书固定
    func validateCertificate(for url: URL) -> Bool {
        guard certificatePinning else { return true }
        
        // 这里可以实现具体的证书固定逻辑
        // 例如检查证书指纹、公钥等
        
        return true
    }
    
    // MARK: - 更新统计
    private func updateStats(success: Bool) {
        DispatchQueue.main.async {
            self.connectionStats.totalRequests += 1
            if success {
                self.connectionStats.successfulRequests += 1
            } else {
                self.connectionStats.failedRequests += 1
            }
        }
    }
    
    // MARK: - 获取连接信息
    func getConnectionInfo() -> ConnectionInfo {
        return ConnectionInfo(
            isConnected: connectionStats.isConnected,
            connectionType: connectionStats.connectionType,
            isSecure: connectionStats.isSecure,
            totalRequests: connectionStats.totalRequests,
            successRate: connectionStats.successRate
        )
    }
    
    // MARK: - 清理资源
    func cleanup() {
        networkMonitor.cancel()
    }
}

// MARK: - 错误类型
enum HTTPSError: Error, LocalizedError {
    case insecureURL
    case invalidResponse
    case httpError(Int)
    case invalidContentType
    case certificateError
    
    var errorDescription: String? {
        switch self {
        case .insecureURL:
            return "不安全的URL，仅支持HTTPS"
        case .invalidResponse:
            return "无效的响应"
        case .httpError(let code):
            return "HTTP错误: \(code)"
        case .invalidContentType:
            return "无效的内容类型"
        case .certificateError:
            return "证书验证失败"
        }
    }
}

// MARK: - 连接统计
struct ConnectionStats {
    var isConnected = false
    var connectionType = "Unknown"
    var isSecure = false
    var totalRequests = 0
    var successfulRequests = 0
    var failedRequests = 0
    
    var successRate: Double {
        guard totalRequests > 0 else { return 0 }
        return Double(successfulRequests) / Double(totalRequests) * 100
    }
}

// MARK: - 连接信息
struct ConnectionInfo {
    let isConnected: Bool
    let connectionType: String
    let isSecure: Bool
    let totalRequests: Int
    let successRate: Double
} 