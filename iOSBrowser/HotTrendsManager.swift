//
//  HotTrendsManager.swift
//  iOSBrowser
//
//  平台热榜数据管理器 - 负责获取、解析和缓存各平台热榜数据
//

import Foundation
import SwiftUI
import BackgroundTasks

@objc public class HotTrendsManager: NSObject, ObservableObject {
    static let shared = HotTrendsManager()
    
    @Published var hotTrends: [String: HotTrendsList] = [:]
    @Published var isLoading: [String: Bool] = [:]
    @Published var lastUpdateTime: [String: Date] = [:]
    
    private let cacheExpirationTime: TimeInterval = 30 * 60 // 30分钟缓存
    private let urlSession = URLSession.shared
    private var updateTimer: Timer?
    private let backgroundTaskIdentifier = "com.iosbrowser.hottrends.refresh"

    private init() {
        loadCachedData()
        startPeriodicUpdate()
        setupBackgroundTasks()
    }
    
    // MARK: - 公共接口
    
    /// 获取指定平台的热榜数据
    func getHotTrends(for platform: String) -> HotTrendsList? {
        return hotTrends[platform]
    }
    
    /// 刷新指定平台的热榜数据
    func refreshHotTrends(for platform: String) {
        // 防止重复请求
        guard isLoading[platform] != true else {
            print("⚠️ \(platform) 正在更新中，跳过重复请求")
            return
        }

        Task {
            await fetchHotTrends(for: platform)
        }
    }

    /// 刷新所有平台的热榜数据
    func refreshAllHotTrends() {
        let platforms = PlatformContact.allPlatforms.map { $0.id }

        // 批量更新，限制并发数量
        let semaphore = DispatchSemaphore(value: 3) // 最多3个并发请求

        for platform in platforms {
            Task {
                semaphore.wait()
                defer { semaphore.signal() }

                if shouldUpdate(platform: platform) {
                    await fetchHotTrends(for: platform)
                }
            }
        }
    }
    
    /// 检查数据是否需要更新
    func shouldUpdate(platform: String) -> Bool {
        guard let lastUpdate = lastUpdateTime[platform] else { return true }
        return Date().timeIntervalSince(lastUpdate) > cacheExpirationTime
    }
    
    // MARK: - 数据获取
    
    @MainActor
    private func fetchHotTrends(for platform: String) async {
        let startTime = Date()
        isLoading[platform] = true

        print("🔄 开始获取 \(platform) 热榜数据...")

        do {
            let trends = try await performAPIRequest(for: platform)
            hotTrends[platform] = trends
            lastUpdateTime[platform] = Date()
            saveCachedData()

            let duration = Date().timeIntervalSince(startTime)
            print("✅ 成功获取 \(platform) 热榜数据: \(trends.items.count) 条，耗时: \(String(format: "%.2f", duration))秒")
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            print("❌ 获取 \(platform) 热榜失败: \(error.localizedDescription)，耗时: \(String(format: "%.2f", duration))秒")

            // 如果网络请求失败，返回空数据
            hotTrends[platform] = HotTrendsList(
                platform: platform,
                updateTime: Date(),
                items: [],
                totalCount: 0
            )
            lastUpdateTime[platform] = Date()
            saveCachedData()
        }

        isLoading[platform] = false
    }
    
    private func performAPIRequest(for platform: String) async throws -> HotTrendsList {
        // TODO: 这里应该调用真实的热榜API
        // 目前返回空数据，等待真实API集成
        throw NSError(domain: "HotTrendsManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "API未集成"])
    }
    
    // TODO: 模拟数据生成函数已删除，等待真实API集成
    
    // MARK: - 数据缓存
    
    private func loadCachedData() {
        // 从UserDefaults加载缓存数据
        if let data = UserDefaults.standard.data(forKey: "cached_hot_trends"),
           let cached = try? JSONDecoder().decode([String: HotTrendsList].self, from: data) {
            hotTrends = cached
        }
        
        if let data = UserDefaults.standard.data(forKey: "last_update_times"),
           let times = try? JSONDecoder().decode([String: Date].self, from: data) {
            lastUpdateTime = times
        }
    }
    
    private func saveCachedData() {
        if let data = try? JSONEncoder().encode(hotTrends) {
            UserDefaults.standard.set(data, forKey: "cached_hot_trends")
        }
        
        if let data = try? JSONEncoder().encode(lastUpdateTime) {
            UserDefaults.standard.set(data, forKey: "last_update_times")
        }
    }
    
    // MARK: - 定时更新和后台任务

    private func startPeriodicUpdate() {
        // 停止现有定时器
        updateTimer?.invalidate()

        // 创建新的定时器，每30分钟更新一次
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { _ in
            Task {
                await self.performBackgroundUpdate()
            }
        }

        // 应用启动时立即更新一次
        Task {
            await performBackgroundUpdate()
        }
    }

    private func setupBackgroundTasks() {
        // 注册后台任务
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
            self.handleBackgroundRefresh(task: task as! BGAppRefreshTask)
        }
    }

    private func handleBackgroundRefresh(task: BGAppRefreshTask) {
        // 设置任务过期处理
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        // 执行后台更新
        Task {
            await performBackgroundUpdate()
            task.setTaskCompleted(success: true)

            // 安排下一次后台更新
            scheduleBackgroundRefresh()
        }
    }

    private func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60) // 30分钟后

        try? BGTaskScheduler.shared.submit(request)
    }

    @MainActor
    private func performBackgroundUpdate() async {
        print("🔄 开始后台更新热榜数据")

        let platforms = PlatformContact.allPlatforms.map { $0.id }
        let updateTasks = platforms.map { platform in
            Task {
                if shouldUpdate(platform: platform) {
                    await fetchHotTrends(for: platform)
                }
            }
        }

        // 等待所有更新完成
        for task in updateTasks {
            await task.value
        }

        print("✅ 后台更新完成")
    }

    deinit {
        updateTimer?.invalidate()
    }
}

// MARK: - 热榜数据扩展
extension HotTrendItem {
    var displayRank: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }
    
    var isTopThree: Bool {
        return rank <= 3
    }
}
