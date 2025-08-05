//
//  HotTrendsTest.swift
//  iOSBrowser
//
//  热榜功能测试文件
//

import Foundation
import SwiftUI

struct HotTrendsTestView: View {
    @StateObject private var hotTrendsManager = HotTrendsManager.shared
    @State private var testResults: [String] = []
    @State private var isRunningTests = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("热榜功能测试")
                    .font(.title)
                    .fontWeight(.bold)
                
                Button(action: runTests) {
                    HStack {
                        if isRunningTests {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isRunningTests ? "测试中..." : "开始测试")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isRunningTests)
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(testResults, id: \.self) { result in
                            Text(result)
                                .font(.system(.caption, design: .monospaced))
                                .padding(.horizontal)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("测试")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func runTests() {
        isRunningTests = true
        testResults.removeAll()
        
        Task {
            await performTests()
            await MainActor.run {
                isRunningTests = false
            }
        }
    }
    
    private func performTests() async {
        addTestResult("🚀 开始热榜功能测试")
        
        // 测试1: 平台配置测试
        await testPlatformConfiguration()
        
        // 测试2: 数据获取测试
        await testDataFetching()
        
        // 测试3: 缓存机制测试
        await testCaching()
        
        // 测试4: 界面组件测试
        await testUIComponents()
        
        addTestResult("✅ 所有测试完成")
    }
    
    private func testPlatformConfiguration() async {
        addTestResult("\n📋 测试1: 平台配置")
        
        let platforms = PlatformContact.allPlatforms
        addTestResult("- 平台数量: \(platforms.count)")
        
        for platform in platforms {
            let hasIcon = !platform.icon.isEmpty
            let hasName = !platform.name.isEmpty
            let hasDescription = !platform.description.isEmpty
            
            let status = hasIcon && hasName && hasDescription ? "✅" : "❌"
            addTestResult("- \(platform.name): \(status)")
        }
    }
    
    private func testDataFetching() async {
        addTestResult("\n🔄 测试2: 数据获取")
        
        let testPlatforms = ["douyin", "xiaohongshu", "bilibili"]
        
        for platform in testPlatforms {
            addTestResult("- 测试 \(platform) 数据获取...")
            
            await MainActor.run {
                hotTrendsManager.refreshHotTrends(for: platform)
            }
            
            // 等待数据加载
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            await MainActor.run {
                if let trends = hotTrendsManager.getHotTrends(for: platform) {
                    addTestResult("  ✅ 获取到 \(trends.items.count) 条数据")
                } else {
                    addTestResult("  ❌ 数据获取失败")
                }
            }
        }
    }
    
    private func testCaching() async {
        addTestResult("\n💾 测试3: 缓存机制")
        
        let testPlatform = "douyin"
        
        // 测试缓存写入
        await MainActor.run {
            hotTrendsManager.refreshHotTrends(for: testPlatform)
        }
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            if let updateTime = hotTrendsManager.lastUpdateTime[testPlatform] {
                addTestResult("- ✅ 缓存时间记录: \(updateTime)")
            } else {
                addTestResult("- ❌ 缓存时间记录失败")
            }
            
            let shouldUpdate = hotTrendsManager.shouldUpdate(platform: testPlatform)
            addTestResult("- 是否需要更新: \(shouldUpdate ? "是" : "否")")
        }
    }
    
    private func testUIComponents() async {
        addTestResult("\n🎨 测试4: 界面组件")
        
        let platforms = PlatformContact.allPlatforms.prefix(3)
        
        for platform in platforms {
            // 测试平台卡片数据
            let hasValidIcon = !platform.icon.isEmpty
            let hasValidColor = true // Color总是有效的
            let hasValidDescription = !platform.description.isEmpty
            
            let status = hasValidIcon && hasValidColor && hasValidDescription ? "✅" : "❌"
            addTestResult("- \(platform.name) 卡片: \(status)")
        }
        
        // 测试热榜项目显示
        await MainActor.run {
            if let trends = hotTrendsManager.getHotTrends(for: "douyin") {
                let firstItem = trends.items.first
                let hasValidRank = firstItem?.rank ?? 0 > 0
                let hasValidTitle = !(firstItem?.title.isEmpty ?? true)
                
                let status = hasValidRank && hasValidTitle ? "✅" : "❌"
                addTestResult("- 热榜项目显示: \(status)")
            }
        }
    }
    
    @MainActor
    private func addTestResult(_ result: String) {
        testResults.append(result)
        print(result)
    }
}

// MARK: - 性能监控扩展
extension HotTrendsManager {
    func getPerformanceStats() -> [String: Any] {
        return [
            "cached_platforms": hotTrends.keys.count,
            "loading_platforms": isLoading.filter { $0.value }.keys.count,
            "last_update_count": lastUpdateTime.count,
            "memory_usage": hotTrends.values.reduce(0) { $0 + $1.items.count }
        ]
    }
    
    func clearCache() {
        hotTrends.removeAll()
        lastUpdateTime.removeAll()
        UserDefaults.standard.removeObject(forKey: "cached_hot_trends")
        UserDefaults.standard.removeObject(forKey: "last_update_times")
        print("🗑️ 热榜缓存已清空")
    }
}
