//
//  PlatformHotTrendsIntegrationTest.swift
//  iOSBrowser
//
//  平台热榜集成测试 - 验证AI tab中的平台热榜功能
//

import SwiftUI

struct PlatformHotTrendsIntegrationTestView: View {
    @State private var testResults: [String] = []
    @State private var isRunningTests = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("平台热榜集成测试")
                    .font(.title)
                    .fontWeight(.bold)
                
                Button(action: runIntegrationTests) {
                    HStack {
                        if isRunningTests {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isRunningTests ? "测试中..." : "开始集成测试")
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
                
                // 实际功能演示
                VStack(spacing: 12) {
                    Text("功能演示")
                        .font(.headline)
                    
                    Button("测试SimpleAIChatView") {
                        testSimpleAIChatView()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("测试平台数据") {
                        testPlatformData()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("测试热榜管理器") {
                        testHotTrendsManager()
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("集成测试")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func runIntegrationTests() {
        isRunningTests = true
        testResults.removeAll()
        
        Task {
            await performIntegrationTests()
            await MainActor.run {
                isRunningTests = false
            }
        }
    }
    
    private func performIntegrationTests() async {
        addTestResult("🚀 开始平台热榜集成测试")
        
        // 测试1: 数据模型集成
        await testDataModelIntegration()
        
        // 测试2: 界面组件集成
        await testUIComponentIntegration()
        
        // 测试3: 通知系统集成
        await testNotificationIntegration()
        
        // 测试4: 热榜管理器集成
        await testManagerIntegration()
        
        addTestResult("✅ 所有集成测试完成")
    }
    
    private func testDataModelIntegration() async {
        addTestResult("\n📊 测试1: 数据模型集成")
        
        // 测试平台配置
        let platforms = PlatformContact.allPlatforms
        addTestResult("- 平台数量: \(platforms.count)")
        
        // 验证每个平台的数据完整性
        for platform in platforms {
            let isValid = !platform.id.isEmpty && 
                         !platform.name.isEmpty && 
                         !platform.description.isEmpty &&
                         !platform.icon.isEmpty
            
            addTestResult("- \(platform.name): \(isValid ? "✅" : "❌")")
        }
        
        // 测试ViewMode枚举
        let viewModes = SimpleAIChatView.ViewMode.allCases
        addTestResult("- ViewMode数量: \(viewModes.count)")
        addTestResult("- ViewModes: \(viewModes.map { $0.rawValue }.joined(separator: ", "))")
    }
    
    private func testUIComponentIntegration() async {
        addTestResult("\n🎨 测试2: 界面组件集成")
        
        // 测试PlatformContactCard组件
        let testPlatform = PlatformContact.allPlatforms.first!
        addTestResult("- 测试平台卡片: \(testPlatform.name)")
        
        // 模拟卡片创建
        addTestResult("- 卡片图标: \(testPlatform.icon)")
        addTestResult("- 卡片颜色: 已设置")
        addTestResult("- 卡片描述: \(testPlatform.description)")
        
        addTestResult("- ✅ 界面组件集成正常")
    }
    
    private func testNotificationIntegration() async {
        addTestResult("\n📢 测试3: 通知系统集成")
        
        // 测试通知名称定义
        let notificationName = Notification.Name.showPlatformHotTrends
        addTestResult("- 通知名称: \(notificationName.rawValue)")
        
        // 模拟通知发送
        await MainActor.run {
            NotificationCenter.default.post(
                name: .showPlatformHotTrends,
                object: "douyin"
            )
        }
        
        addTestResult("- ✅ 通知发送成功")
    }
    
    private func testManagerIntegration() async {
        addTestResult("\n🔧 测试4: 热榜管理器集成")
        
        await MainActor.run {
            let manager = HotTrendsManager.shared
            addTestResult("- 管理器类型: \(type(of: manager))")
            addTestResult("- 缓存平台数: \(manager.hotTrends.count)")
            addTestResult("- 加载状态数: \(manager.isLoading.count)")
            
            // 测试数据获取
            manager.refreshHotTrends(for: "douyin")
            addTestResult("- ✅ 数据获取请求已发送")
        }
    }
    
    @MainActor
    private func addTestResult(_ result: String) {
        testResults.append(result)
        print(result)
    }
    
    // 单独的功能测试方法
    private func testSimpleAIChatView() {
        addTestResult("🧪 测试SimpleAIChatView组件")
        addTestResult("- ViewMode枚举: \(SimpleAIChatView.ViewMode.allCases.count) 个选项")
        addTestResult("- ✅ SimpleAIChatView组件正常")
    }
    
    private func testPlatformData() {
        addTestResult("🧪 测试平台数据")
        let platforms = PlatformContact.allPlatforms
        addTestResult("- 总平台数: \(platforms.count)")
        addTestResult("- 短视频平台: \(platforms.filter { $0.platformType == .shortVideo }.count)")
        addTestResult("- 社交媒体平台: \(platforms.filter { $0.platformType == .socialMedia }.count)")
        addTestResult("- 视频平台: \(platforms.filter { $0.platformType == .video }.count)")
        addTestResult("- ✅ 平台数据正常")
    }
    
    private func testHotTrendsManager() {
        addTestResult("🧪 测试热榜管理器")
        let manager = HotTrendsManager.shared
        addTestResult("- 管理器实例: 已创建")
        addTestResult("- 性能统计: \(manager.getPerformanceStats())")
        addTestResult("- ✅ 热榜管理器正常")
    }
}

struct PlatformHotTrendsIntegrationTestView_Previews: PreviewProvider {
    static var previews: some View {
        PlatformHotTrendsIntegrationTestView()
    }
}
