//
//  ContentBlockManager.swift
//  iOSBrowser
//
//  内容拦截管理器 - 过滤广告和恶意内容
//

import Foundation
import WebKit

class ContentBlockManager: ObservableObject {
    static let shared = ContentBlockManager()
    
    @Published var isEnabled = true
    @Published var blockAds = true
    @Published var blockTrackers = true
    @Published var blockMalware = true
    @Published var customRules: [String] = []
    
    private let userDefaults = UserDefaults.standard
    
    // 广告过滤规则
    private let adBlockRules = [
        "*://*.doubleclick.net/*",
        "*://*.googleadservices.com/*",
        "*://*.googlesyndication.com/*",
        "*://*.facebook.com/tr/*",
        "*://*.amazon-adsystem.com/*",
        "*://*.adnxs.com/*",
        "*://*.advertising.com/*",
        "*://*.adsystem.com/*",
        "*://*.adtech.com/*",
        "*://*.adtechus.com/*",
        "*://*.advertising.com/*",
        "*://*.adtech.com/*",
        "*://*.adtechus.com/*",
        "*://*.advertising.com/*",
        "*://*.adtech.com/*",
        "*://*.adtechus.com/*",
        "*://*.advertising.com/*",
        "*://*.adtech.com/*",
        "*://*.adtechus.com/*",
        "*://*.advertising.com/*"
    ]
    
    // 追踪器过滤规则
    private let trackerBlockRules = [
        "*://*.google-analytics.com/*",
        "*://*.googletagmanager.com/*",
        "*://*.facebook.com/tr/*",
        "*://*.facebook.com/audience/*",
        "*://*.facebook.com/connect/*",
        "*://*.facebook.com/plugins/*",
        "*://*.facebook.com/sdk/*",
        "*://*.facebook.com/x/*",
        "*://*.facebook.com/audience/*",
        "*://*.facebook.com/connect/*",
        "*://*.facebook.com/plugins/*",
        "*://*.facebook.com/sdk/*",
        "*://*.facebook.com/x/*"
    ]
    
    // 恶意软件过滤规则
    private let malwareBlockRules = [
        "*://*.malware.com/*",
        "*://*.virus.com/*",
        "*://*.phishing.com/*",
        "*://*.scam.com/*",
        "*://*.fake.com/*",
        "*://*.spam.com/*"
    ]
    
    private init() {
        loadSettings()
    }
    
    // MARK: - 设置管理
    func loadSettings() {
        isEnabled = userDefaults.bool(forKey: "content_block_enabled")
        blockAds = userDefaults.bool(forKey: "content_block_ads")
        blockTrackers = userDefaults.bool(forKey: "content_block_trackers")
        blockMalware = userDefaults.bool(forKey: "content_block_malware")
        customRules = userDefaults.stringArray(forKey: "content_block_custom_rules") ?? []
    }
    
    func saveSettings() {
        userDefaults.set(isEnabled, forKey: "content_block_enabled")
        userDefaults.set(blockAds, forKey: "content_block_ads")
        userDefaults.set(blockTrackers, forKey: "content_block_trackers")
        userDefaults.set(blockMalware, forKey: "content_block_malware")
        userDefaults.set(customRules, forKey: "content_block_custom_rules")
    }
    
    // MARK: - 获取所有过滤规则
    func getAllBlockRules() -> [String] {
        var rules: [String] = []
        
        if isEnabled {
            if blockAds {
                rules.append(contentsOf: adBlockRules)
            }
            
            if blockTrackers {
                rules.append(contentsOf: trackerBlockRules)
            }
            
            if blockMalware {
                rules.append(contentsOf: malwareBlockRules)
            }
            
            rules.append(contentsOf: customRules)
        }
        
        return rules
    }
    
    // MARK: - 添加自定义规则
    func addCustomRule(_ rule: String) {
        if !customRules.contains(rule) {
            customRules.append(rule)
            saveSettings()
        }
    }
    
    // MARK: - 移除自定义规则
    func removeCustomRule(_ rule: String) {
        customRules.removeAll { $0 == rule }
        saveSettings()
    }
    
    // MARK: - 检查URL是否被阻止
    func shouldBlockURL(_ url: URL) -> Bool {
        guard isEnabled else { return false }
        
        let urlString = url.absoluteString
        
        // 检查广告规则
        if blockAds {
            for rule in adBlockRules {
                if matchesRule(urlString, rule: rule) {
                    return true
                }
            }
        }
        
        // 检查追踪器规则
        if blockTrackers {
            for rule in trackerBlockRules {
                if matchesRule(urlString, rule: rule) {
                    return true
                }
            }
        }
        
        // 检查恶意软件规则
        if blockMalware {
            for rule in malwareBlockRules {
                if matchesRule(urlString, rule: rule) {
                    return true
                }
            }
        }
        
        // 检查自定义规则
        for rule in customRules {
            if matchesRule(urlString, rule: rule) {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - 规则匹配
    private func matchesRule(_ urlString: String, rule: String) -> Bool {
        // 简单的通配符匹配
        let pattern = rule
            .replacingOccurrences(of: ".", with: "\\.")
            .replacingOccurrences(of: "*", with: ".*")
        
        return urlString.range(of: pattern, options: .regularExpression) != nil
    }
    
    // MARK: - 获取统计信息
    func getBlockingStats() -> BlockingStats {
        // 这里可以添加实际的统计逻辑
        return BlockingStats(
            totalRequests: 1000,
            blockedRequests: 150,
            adsBlocked: 80,
            trackersBlocked: 50,
            malwareBlocked: 20
        )
    }
}

// MARK: - 统计信息结构
struct BlockingStats {
    let totalRequests: Int
    let blockedRequests: Int
    let adsBlocked: Int
    let trackersBlocked: Int
    let malwareBlocked: Int
    
    var blockingPercentage: Double {
        guard totalRequests > 0 else { return 0 }
        return Double(blockedRequests) / Double(totalRequests) * 100
    }
} 