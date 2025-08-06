//
//  WidgetDataManager.swift
//  iOSBrowser
//
//  Created by LZH on 2025/7/19.
//

import Foundation
import WidgetKit

class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let userDefaults = UserDefaults.standard
    private let searchEnginesKey = "iosbrowser_engines"
    private let appsKey = "iosbrowser_apps"
    private let favoritesKey = "iosbrowser_favorites"
    private let recentSearchesKey = "iosbrowser_recent_searches"
    
    private init() {}
    
    func initializeData() {
        print("🔥🔥🔥 WidgetDataManager.initializeData 开始...")
        
        var needsSync = false
        
        // 检查并初始化搜索引擎数据
        if userDefaults.stringArray(forKey: searchEnginesKey)?.isEmpty != false {
            let defaultEngines = ["baidu", "google", "bing", "duckduckgo"]
            userDefaults.set(defaultEngines, forKey: searchEnginesKey)
            print("🔥 初始化: 保存默认搜索引擎 \(defaultEngines)")
            needsSync = true
        }
        
        // 检查并初始化应用数据
        if userDefaults.stringArray(forKey: appsKey)?.isEmpty != false {
            let defaultApps = [
                "taobao", "jd", "pinduoduo", "tmall",
                "zhihu", "weibo", "douyin", "bilibili",
                "youtube", "google", "baidu", "bing"
            ]
            userDefaults.set(defaultApps, forKey: appsKey)
            print("🔥 初始化: 保存默认应用 \(defaultApps)")
            needsSync = true
        }
        
        // 检查并初始化收藏数据
        if userDefaults.stringArray(forKey: favoritesKey)?.isEmpty != false {
            let defaultFavorites = [String]()
            userDefaults.set(defaultFavorites, forKey: favoritesKey)
            print("🔥 初始化: 创建空收藏列表")
            needsSync = true
        }
        
        // 检查并初始化最近搜索数据
        if userDefaults.stringArray(forKey: recentSearchesKey)?.isEmpty != false {
            let defaultSearches = [String]()
            userDefaults.set(defaultSearches, forKey: recentSearchesKey)
            print("🔥 初始化: 创建空最近搜索列表")
            needsSync = true
        }
        
        if needsSync {
            userDefaults.synchronize()
            WidgetCenter.shared.reloadAllTimelines()
            print("🔥 数据初始化完成，已同步到小组件")
        }
        
        print("🔥🔥🔥 WidgetDataManager.initializeData 完成")
    }
    
    // MARK: - 搜索引擎管理
    func getSearchEngines() -> [String] {
        return userDefaults.stringArray(forKey: searchEnginesKey) ?? []
    }
    
    func setSearchEngines(_ engines: [String]) {
        userDefaults.set(engines, forKey: searchEnginesKey)
        userDefaults.synchronize()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - 应用管理
    func getApps() -> [String] {
        return userDefaults.stringArray(forKey: appsKey) ?? []
    }
    
    func setApps(_ apps: [String]) {
        userDefaults.set(apps, forKey: appsKey)
        userDefaults.synchronize()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - 收藏管理
    func getFavorites() -> [String] {
        return userDefaults.stringArray(forKey: favoritesKey) ?? []
    }
    
    func addFavorite(_ url: String) {
        var favorites = getFavorites()
        if !favorites.contains(url) {
            favorites.append(url)
            userDefaults.set(favorites, forKey: favoritesKey)
            userDefaults.synchronize()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func removeFavorite(_ url: String) {
        var favorites = getFavorites()
        if let index = favorites.firstIndex(of: url) {
            favorites.remove(at: index)
            userDefaults.set(favorites, forKey: favoritesKey)
            userDefaults.synchronize()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    // MARK: - 最近搜索管理
    func getRecentSearches() -> [String] {
        return userDefaults.stringArray(forKey: recentSearchesKey) ?? []
    }
    
    func addRecentSearch(_ query: String) {
        var searches = getRecentSearches()
        if let index = searches.firstIndex(of: query) {
            searches.remove(at: index)
        }
        searches.insert(query, at: 0)
        
        // 限制最大数量
        if searches.count > 20 {
            searches = Array(searches.prefix(20))
        }
        
        userDefaults.set(searches, forKey: recentSearchesKey)
        userDefaults.synchronize()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func clearRecentSearches() {
        userDefaults.set([String](), forKey: recentSearchesKey)
        userDefaults.synchronize()
        WidgetCenter.shared.reloadAllTimelines()
    }
} 