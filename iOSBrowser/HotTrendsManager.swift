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

            // 如果网络请求失败，生成模拟数据
            hotTrends[platform] = generateMockData(for: platform)
            lastUpdateTime[platform] = Date()
            saveCachedData()
        }

        isLoading[platform] = false
    }
    
    private func performAPIRequest(for platform: String) async throws -> HotTrendsList {
        // 由于各平台API限制，这里使用模拟数据
        // 在实际应用中，可以集成第三方热榜API服务
        try await Task.sleep(nanoseconds: 1_000_000_000) // 模拟网络延迟
        return generateMockData(for: platform)
    }
    
    // MARK: - 模拟数据生成
    
    private func generateMockData(for platform: String) -> HotTrendsList {
        let platformName = PlatformContact.allPlatforms.first { $0.id == platform }?.name ?? platform
        
        let mockItems = generateMockItems(for: platform, platformName: platformName)
        
        return HotTrendsList(
            platform: platform,
            updateTime: Date(),
            items: mockItems,
            totalCount: mockItems.count
        )
    }
    
    private func generateMockItems(for platform: String, platformName: String) -> [HotTrendItem] {
        let baseItems = getMockItemsForPlatform(platform, platformName: platformName)
        
        return baseItems.enumerated().map { index, item in
            HotTrendItem(
                id: "\(platform)_\(index)",
                title: item.title,
                description: item.description,
                rank: index + 1,
                hotValue: generateHotValue(),
                url: item.url,
                imageURL: nil,
                category: item.category,
                timestamp: Date(),
                platform: platform
            )
        }
    }
    
    private func getMockItemsForPlatform(_ platform: String, platformName: String) -> [(title: String, description: String?, url: String?, category: String?)] {
        switch platform {
        case "douyin":
            return [
                ("今日热门舞蹈挑战", "全网都在跳的新舞蹈", "snssdk1128://aweme/detail/123", "娱乐"),
                ("美食制作教程", "简单易学的家常菜", "snssdk1128://aweme/detail/124", "美食"),
                ("旅行vlog分享", "最美风景推荐", "snssdk1128://aweme/detail/125", "旅行"),
                ("科技产品评测", "最新数码产品体验", "snssdk1128://aweme/detail/126", "科技"),
                ("健身运动指南", "居家健身小技巧", "snssdk1128://aweme/detail/127", "运动")
            ]
        case "xiaohongshu":
            return [
                ("秋冬穿搭指南", "时尚博主推荐搭配", "xhsdiscover://item/123", "时尚"),
                ("护肤心得分享", "敏感肌护肤经验", "xhsdiscover://item/124", "美妆"),
                ("家居装修灵感", "小户型改造案例", "xhsdiscover://item/125", "家居"),
                ("美食探店推荐", "城市隐藏美食", "xhsdiscover://item/126", "美食"),
                ("读书笔记分享", "好书推荐清单", "xhsdiscover://item/127", "读书")
            ]
        case "bilibili":
            return [
                ("游戏实况解说", "热门游戏攻略", "bilibili://video/123", "游戏"),
                ("科普知识讲解", "有趣的科学现象", "bilibili://video/124", "科普"),
                ("动漫剧情解析", "新番推荐", "bilibili://video/125", "动漫"),
                ("音乐翻唱作品", "原创音乐分享", "bilibili://video/126", "音乐"),
                ("学习方法分享", "高效学习技巧", "bilibili://video/127", "学习")
            ]
        case "toutiao":
            return [
                ("科技新闻热点", "最新科技动态", "snssdk141://detail?id=123", "科技"),
                ("社会民生关注", "热点社会事件", "snssdk141://detail?id=124", "社会"),
                ("财经市场分析", "股市行情解读", "snssdk141://detail?id=125", "财经"),
                ("体育赛事报道", "最新比赛结果", "snssdk141://detail?id=126", "体育"),
                ("娱乐八卦新闻", "明星动态追踪", "snssdk141://detail?id=127", "娱乐")
            ]
        default:
            return [
                ("\(platformName)热门内容1", "精彩内容推荐", nil, "推荐"),
                ("\(platformName)热门内容2", "用户喜爱内容", nil, "热门"),
                ("\(platformName)热门内容3", "今日必看内容", nil, "精选"),
                ("\(platformName)热门内容4", "编辑推荐内容", nil, "推荐"),
                ("\(platformName)热门内容5", "社区热议话题", nil, "讨论")
            ]
        }
    }
    
    private func generateHotValue() -> String {
        let values = ["🔥 热度爆表", "📈 持续上升", "⭐ 编辑推荐", "💬 热议中", "🎯 精选内容"]
        return values.randomElement() ?? "🔥 热门"
    }
    
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
