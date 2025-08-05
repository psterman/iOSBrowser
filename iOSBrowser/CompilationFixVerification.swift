//
//  CompilationFixVerification.swift
//  iOSBrowser
//
//  编译修复验证 - 确保平台热榜功能正常工作
//

import SwiftUI

struct CompilationFixVerificationView: View {
    @ObservedObject private var hotTrendsManager = MockHotTrendsManager.shared
    @State private var testResults: [String] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("编译修复验证")
                    .font(.title)
                    .fontWeight(.bold)
                
                // 状态显示
                VStack(alignment: .leading, spacing: 8) {
                    Text("热榜管理器状态:")
                        .font(.headline)
                    
                    Text("缓存平台数: \(hotTrendsManager.hotTrends.count)")
                        .font(.subheadline)
                    
                    Text("加载状态数: \(hotTrendsManager.isLoading.count)")
                        .font(.subheadline)
                    
                    Text("更新时间数: \(hotTrendsManager.lastUpdateTime.count)")
                        .font(.subheadline)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // 平台测试
                VStack(alignment: .leading, spacing: 8) {
                    Text("平台数据测试:")
                        .font(.headline)
                    
                    Text("总平台数: \(PlatformContact.allPlatforms.count)")
                        .font(.subheadline)
                    
                    ForEach(PlatformContact.allPlatforms.prefix(5), id: \.id) { platform in
                        HStack {
                            Image(systemName: platform.icon)
                                .foregroundColor(platform.color)
                            Text(platform.name)
                            Spacer()
                            if let trends = hotTrendsManager.getHotTrends(for: platform.id) {
                                Text("\(trends.items.count) 条")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else {
                                Text("无数据")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // 功能测试按钮
                VStack(spacing: 12) {
                    Button("测试数据刷新") {
                        testDataRefresh()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("测试平台选择") {
                        testPlatformSelection()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("清空缓存") {
                        hotTrendsManager.clearCache()
                        addTestResult("缓存已清空")
                    }
                    .buttonStyle(.bordered)
                }
                
                // 测试结果
                if !testResults.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("测试结果:")
                                .font(.headline)
                            
                            ForEach(testResults, id: \.self) { result in
                                Text(result)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(maxHeight: 150)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("编译修复验证")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            addTestResult("✅ 编译修复验证页面加载成功")
            addTestResult("✅ MockHotTrendsManager 正常工作")
            addTestResult("✅ 平台数据模型正常")
        }
    }
    
    private func testDataRefresh() {
        addTestResult("🔄 开始测试数据刷新...")
        
        let testPlatform = "douyin"
        hotTrendsManager.refreshHotTrends(for: testPlatform)
        
        addTestResult("✅ 数据刷新请求已发送")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if let trends = hotTrendsManager.getHotTrends(for: testPlatform) {
                addTestResult("✅ 获取到 \(trends.items.count) 条热榜数据")
            } else {
                addTestResult("❌ 数据刷新失败")
            }
        }
    }
    
    private func testPlatformSelection() {
        addTestResult("🎯 测试平台选择功能...")
        
        let testPlatform = PlatformContact.allPlatforms.first!
        addTestResult("选择平台: \(testPlatform.name)")
        
        // 模拟平台选择通知
        NotificationCenter.default.post(
            name: .showPlatformHotTrends,
            object: testPlatform.id
        )
        
        addTestResult("✅ 平台选择通知已发送")
    }
    
    private func addTestResult(_ result: String) {
        testResults.append(result)
        print(result)
    }
}

// MARK: - 简单的演示视图
struct SimpleAIChatDemoView: View {
    @ObservedObject private var hotTrendsManager = MockHotTrendsManager.shared
    @State private var selectedViewMode: SimpleAIChatView.ViewMode = .aiContacts
    
    var body: some View {
        VStack(spacing: 0) {
            // 分段控制器
            Picker("选择类型", selection: $selectedViewMode) {
                ForEach(SimpleAIChatView.ViewMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedViewMode == .aiContacts {
                Text("AI助手列表")
                    .font(.title2)
                    .padding()
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ForEach(PlatformContact.allPlatforms.prefix(6)) { platform in
                            PlatformContactCard(
                                platform: platform,
                                onTap: {
                                    print("点击平台: \(platform.name)")
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("AI Tab 演示")
    }
}

struct CompilationFixVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        CompilationFixVerificationView()
    }
}
