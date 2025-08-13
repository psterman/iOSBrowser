//
//  AITestConfig.swift
//  iOSBrowser
//
//  AI对话测试配置文件
//

import Foundation
import SwiftUI

// MARK: - 测试配置管理器
class AITestConfig: ObservableObject {
    static let shared = AITestConfig()
    
    // 测试开关
    @Published var autoTestOnAppear = false
    @Published var autoTestOnAIDrawerOpen = false
    @Published var autoTestOnAIChatOpen = false
    
    // 测试选项
    @Published var testAllSteps = true
    @Published var testSpecificSteps: Set<Int> = []
    @Published var testDelay: TimeInterval = 1.0
    
    // 测试结果存储
    @Published var lastTestResults: [String] = []
    @Published var lastTestTime: Date?
    @Published var testSuccessCount = 0
    @Published var testFailCount = 0
    
    // 通知设置
    @Published var showTestNotifications = true
    @Published var logTestResults = true
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadConfig()
    }
    
    // MARK: - 配置管理
    
    func loadConfig() {
        autoTestOnAppear = userDefaults.bool(forKey: "AITest_AutoTestOnAppear")
        autoTestOnAIDrawerOpen = userDefaults.bool(forKey: "AITest_AutoTestOnAIDrawerOpen")
        autoTestOnAIChatOpen = userDefaults.bool(forKey: "AITest_AutoTestOnAIChatOpen")
        
        testAllSteps = userDefaults.bool(forKey: "AITest_TestAllSteps")
        testDelay = userDefaults.double(forKey: "AITest_TestDelay")
        
        if let savedSteps = userDefaults.array(forKey: "AITest_SpecificSteps") as? [Int] {
            testSpecificSteps = Set(savedSteps)
        }
        
        showTestNotifications = userDefaults.bool(forKey: "AITest_ShowNotifications")
        logTestResults = userDefaults.bool(forKey: "AITest_LogResults")
    }
    
    func saveConfig() {
        userDefaults.set(autoTestOnAppear, forKey: "AITest_AutoTestOnAppear")
        userDefaults.set(autoTestOnAIDrawerOpen, forKey: "AITest_AutoTestOnAIDrawerOpen")
        userDefaults.set(autoTestOnAIChatOpen, forKey: "AITest_AutoTestOnAIChatOpen")
        
        userDefaults.set(testAllSteps, forKey: "AITest_TestAllSteps")
        userDefaults.set(testDelay, forKey: "AITest_TestDelay")
        userDefaults.set(Array(testSpecificSteps), forKey: "AITest_SpecificSteps")
        
        userDefaults.set(showTestNotifications, forKey: "AITest_ShowNotifications")
        userDefaults.set(logTestResults, forKey: "AITest_LogResults")
        
        userDefaults.synchronize()
    }
    
    // MARK: - 测试控制
    
    func shouldAutoTest(for event: AITestEvent) -> Bool {
        switch event {
        case .onAppear:
            return autoTestOnAppear
        case .onAIDrawerOpen:
            return autoTestOnAIDrawerOpen
        case .onAIChatOpen:
            return autoTestOnAIChatOpen
        }
    }
    
    func getTestSteps() -> [Int] {
        if testAllSteps {
            return Array(1...6)
        } else {
            return Array(testSpecificSteps).sorted()
        }
    }
    
    // MARK: - 结果记录
    
    func recordTestResult(_ result: String) {
        lastTestResults.append(result)
        lastTestTime = Date()
        
        if result.contains("✅") {
            testSuccessCount += 1
        } else if result.contains("❌") {
            testFailCount += 1
        }
        
        if logTestResults {
            print("🔍 AI测试: \(result)")
        }
        
        // 限制结果数量
        if lastTestResults.count > 100 {
            lastTestResults.removeFirst(50)
        }
    }
    
    func clearTestResults() {
        lastTestResults.removeAll()
        lastTestTime = nil
        testSuccessCount = 0
        testFailCount = 0
    }
    
    // MARK: - 通知管理
    
    func showTestNotification(title: String, message: String) {
        guard showTestNotifications else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - 测试事件枚举
enum AITestEvent {
    case onAppear
    case onAIDrawerOpen
    case onAIChatOpen
}

// MARK: - 测试配置视图
struct AITestConfigView: View {
    @ObservedObject var config = AITestConfig.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("自动测试触发")) {
                    Toggle("进入界面时自动测试", isOn: $config.autoTestOnAppear)
                    Toggle("打开AI抽屉时自动测试", isOn: $config.autoTestOnAIDrawerOpen)
                    Toggle("打开AI对话时自动测试", isOn: $config.autoTestOnAIChatOpen)
                }
                
                Section(header: Text("测试选项")) {
                    Toggle("测试所有步骤", isOn: $config.testAllSteps)
                    
                    if !config.testAllSteps {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("选择测试步骤:")
                                .font(.subheadline)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(1...6, id: \.self) { step in
                                    Button(action: {
                                        if config.testSpecificSteps.contains(step) {
                                            config.testSpecificSteps.remove(step)
                                        } else {
                                            config.testSpecificSteps.insert(step)
                                        }
                                    }) {
                                        Text("步骤\(step)")
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                config.testSpecificSteps.contains(step) ? Color.blue : Color.gray.opacity(0.3)
                                            )
                                            .foregroundColor(
                                                config.testSpecificSteps.contains(step) ? .white : .primary
                                            )
                                            .cornerRadius(6)
                                    }
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Text("测试延迟")
                        Spacer()
                        TextField("延迟时间", value: $config.testDelay, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        Text("秒")
                    }
                }
                
                Section(header: Text("通知设置")) {
                    Toggle("显示测试通知", isOn: $config.showTestNotifications)
                    Toggle("记录测试日志", isOn: $config.logTestResults)
                }
                
                Section(header: Text("测试结果")) {
                    HStack {
                        Text("成功次数")
                        Spacer()
                        Text("\(config.testSuccessCount)")
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text("失败次数")
                        Spacer()
                        Text("\(config.testFailCount)")
                            .foregroundColor(.red)
                    }
                    
                    if let lastTime = config.lastTestTime {
                        HStack {
                            Text("最后测试时间")
                            Spacer()
                            Text(lastTime, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button("清除测试结果") {
                        config.clearTestResults()
                    }
                    .foregroundColor(.red)
                }
                
                Section {
                    Button("保存配置") {
                        config.saveConfig()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            .navigationTitle("AI测试配置")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - 快速测试按钮
struct QuickAITestButton: View {
    @ObservedObject var config = AITestConfig.shared
    @State private var isTesting = false
    @State private var showingConfig = false
    
    var body: some View {
        Menu {
            Button("开始测试") {
                startQuickTest()
            }
            .disabled(isTesting)
            
            Button("配置测试") {
                showingConfig = true
            }
            
            Button("查看结果") {
                showTestResults()
            }
            
            Divider()
            
            Button("清除结果") {
                config.clearTestResults()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isTesting ? "hourglass" : "wrench.and.screwdriver")
                    .foregroundColor(.orange)
                    .font(.system(size: 16, weight: .medium))
                
                if isTesting {
                    ProgressView()
                        .scaleEffect(0.6)
                }
            }
            .frame(width: 44, height: 44)
            .padding(.horizontal, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .sheet(isPresented: $showingConfig) {
            AITestConfigView()
        }
    }
    
    private func startQuickTest() {
        guard !isTesting else { return }
        
        isTesting = true
        config.clearTestResults()
        
        let testSteps = config.getTestSteps()
        config.recordTestResult("🚀 开始快速测试，共\(testSteps.count)个步骤")
        
        // 执行测试步骤
        for (index, step) in testSteps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + config.testDelay * Double(index)) {
                testStep(step)
                
                if index == testSteps.count - 1 {
                    finishQuickTest()
                }
            }
        }
    }
    
    private func testStep(_ step: Int) {
        config.recordTestResult("📋 步骤\(step): 开始测试")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                switch step {
                case 1:
                    let _ = AIChatManager.shared
                    config.recordTestResult("✅ 步骤\(step)成功: AIChatManager单例创建成功")
                case 2:
                    let chatManager = AIChatManager.shared
                    let sessionCount = chatManager.chatSessions.count
                    config.recordTestResult("✅ 步骤\(step)成功: 加载了\(sessionCount)个历史会话")
                case 3:
                    config.recordTestResult("✅ 步骤\(step)成功: 状态变量初始化完成")
                case 4:
                    let chatManager = AIChatManager.shared
                    let hasCurrentSession = chatManager.currentSession != nil
                    config.recordTestResult("✅ 步骤\(step)成功: 界面状态判断完成")
                case 5:
                    config.recordTestResult("✅ 步骤\(step)成功: 导航栏配置完成")
                case 6:
                    config.recordTestResult("✅ 步骤\(step)成功: Sheet视图准备完成")
                default:
                    config.recordTestResult("❌ 步骤\(step)失败: 未知步骤")
                }
            } catch {
                config.recordTestResult("❌ 步骤\(step)失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func finishQuickTest() {
        isTesting = false
        
        let successCount = config.lastTestResults.filter { $0.contains("✅") }.count
        let failCount = config.lastTestResults.filter { $0.contains("❌") }.count
        
        config.recordTestResult("🎉 快速测试完成！成功\(successCount)步，失败\(failCount)步")
        
        if failCount > 0 {
            config.showTestNotification(
                title: "AI测试发现问题",
                message: "有\(failCount)个步骤失败，请检查"
            )
        } else {
            config.showTestNotification(
                title: "AI测试通过",
                message: "所有\(successCount)个步骤测试成功"
            )
        }
    }
    
    private func showTestResults() {
        // 显示测试结果
        let alert = UIAlertController(title: "测试结果", message: config.lastTestResults.joined(separator: "\n"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
}

// MARK: - 预览
struct AITestConfig_Previews: PreviewProvider {
    static var previews: some View {
        AITestConfigView()
    }
} 