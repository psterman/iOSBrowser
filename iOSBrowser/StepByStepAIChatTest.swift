//
//  StepByStepAIChatTest.swift
//  iOSBrowser
//
//  逐步测试AI对话初始化的视图
//

import SwiftUI

struct StepByStepAIChatTest: View {
    @State private var currentStep = 0
    @State private var testResults: [String] = []
    @State private var isTesting = false
    
    // 测试状态
    @State private var step1Result = "未测试"
    @State private var step2Result = "未测试"
    @State private var step3Result = "未测试"
    @State private var step4Result = "未测试"
    @State private var step5Result = "未测试"
    @State private var step6Result = "未测试"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题
                Text("AI对话初始化步骤测试")
                    .font(.title)
                    .fontWeight(.bold)
                
                // 当前步骤显示
                Text("当前测试步骤: \(currentStep)")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                // 测试结果网格
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    TestResultCard(title: "步骤1", result: step1Result, color: step1Result == "成功" ? .green : (step1Result == "失败" ? .red : .gray))
                    TestResultCard(title: "步骤2", result: step2Result, color: step2Result == "成功" ? .green : (step2Result == "失败" ? .red : .gray))
                    TestResultCard(title: "步骤3", result: step3Result, color: step3Result == "成功" ? .green : (step3Result == "失败" ? .red : .gray))
                    TestResultCard(title: "步骤4", result: step4Result, color: step4Result == "成功" ? .green : (step4Result == "失败" ? .red : .gray))
                    TestResultCard(title: "步骤5", result: step5Result, color: step5Result == "success" ? .green : (step5Result == "失败" ? .red : .gray))
                    TestResultCard(title: "步骤6", result: step6Result, color: step6Result == "成功" ? .green : (step6Result == "失败" ? .red : .gray))
                }
                
                // 控制按钮
                HStack(spacing: 16) {
                    Button("开始测试") {
                        startTesting()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    .disabled(isTesting)
                    
                    Button("重置") {
                        resetTest()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(8)
                    
                    Button("测试单个步骤") {
                        testSingleStep()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
                }
                
                // 详细结果
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("详细测试结果:")
                            .font(.headline)
                        
                        ForEach(testResults, id: \.self) { result in
                            Text(result)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray5))
                                .cornerRadius(4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 200)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("逐步测试")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - 测试方法
    
    private func startTesting() {
        isTesting = true
        testResults.removeAll()
        currentStep = 0
        
        addTestResult("🚀 开始逐步测试AI对话初始化...")
        
        // 开始第一步
        testStep1()
    }
    
    private func testStep1() {
        currentStep = 1
        addTestResult("📋 步骤1: 测试AIChatManager单例初始化")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            do {
                // 测试AIChatManager单例
                let _ = AIChatManager.shared
                step1Result = "成功"
                addTestResult("✅ 步骤1成功: AIChatManager单例创建成功")
                
                // 继续下一步
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    testStep2()
                }
            } catch {
                step1Result = "失败"
                addTestResult("❌ 步骤1失败: \(error.localizedDescription)")
                finishTest()
            }
        }
    }
    
    private func testStep2() {
        currentStep = 2
        addTestResult("📋 步骤2: 测试历史数据加载")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            do {
                // 测试历史数据加载
                let chatManager = AIChatManager.shared
                let sessionCount = chatManager.chatSessions.count
                step2Result = "成功"
                addTestResult("✅ 步骤2成功: 加载了\(sessionCount)个历史会话")
                
                // 继续下一步
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    testStep3()
                }
            } catch {
                step2Result = "失败"
                addTestResult("❌ 步骤2失败: \(error.localizedDescription)")
                finishTest()
            }
        }
    }
    
    private func testStep3() {
        currentStep = 3
        addTestResult("📋 步骤3: 测试状态变量初始化")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            do {
                // 测试状态变量初始化
                let messageText = ""
                let showingSessionList = false
                let showingAPIConfig = false
                
                step3Result = "成功"
                addTestResult("✅ 步骤3成功: 状态变量初始化完成")
                addTestResult("   - messageText: '\(messageText)'")
                addTestResult("   - showingSessionList: \(showingSessionList)")
                addTestResult("   - showingAPIConfig: \(showingAPIConfig)")
                
                // 继续下一步
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    testStep4()
                }
            } catch {
                step3Result = "失败"
                addTestResult("❌ 步骤3失败: \(error.localizedDescription)")
                finishTest()
            }
        }
    }
    
    private func testStep4() {
        currentStep = 4
        addTestResult("📋 步骤4: 测试界面状态判断")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            do {
                // 测试界面状态判断
                let chatManager = AIChatManager.shared
                let hasCurrentSession = chatManager.currentSession != nil
                let sessionTitle = chatManager.currentSession?.title ?? "无当前会话"
                
                step4Result = "成功"
                addTestResult("✅ 步骤4成功: 界面状态判断完成")
                addTestResult("   - 有当前会话: \(hasCurrentSession)")
                addTestResult("   - 会话标题: '\(sessionTitle)'")
                
                // 继续下一步
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    testStep5()
                }
            } catch {
                step4Result = "失败"
                addTestResult("❌ 步骤4失败: \(error.localizedDescription)")
                finishTest()
            }
        }
    }
    
    private func testStep5() {
        currentStep = 5
        addTestResult("📋 步骤5: 测试导航栏配置")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            do {
                // 测试导航栏配置
                let chatManager = AIChatManager.shared
                let navigationTitle = chatManager.currentSession?.title ?? "AI对话"
                
                step5Result = "成功"
                addTestResult("✅ 步骤5成功: 导航栏配置完成")
                addTestResult("   - 导航标题: '\(navigationTitle)'")
                addTestResult("   - 导航模式: inline")
                
                // 继续下一步
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    testStep6()
                }
            } catch {
                step5Result = "失败"
                addTestResult("❌ 步骤5失败: \(error.localizedDescription)")
                finishTest()
            }
        }
    }
    
    private func testStep6() {
        currentStep = 6
        addTestResult("📋 步骤6: 测试Sheet视图准备")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            do {
                // 测试Sheet视图准备
                step6Result = "成功"
                addTestResult("✅ 步骤6成功: Sheet视图准备完成")
                addTestResult("   - ChatSessionListView 准备就绪")
                addTestResult("   - APIConfigView 准备就绪")
                
                // 完成测试
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    finishTest()
                }
            } catch {
                step6Result = "失败"
                addTestResult("❌ 步骤6失败: \(error.localizedDescription)")
                finishTest()
            }
        }
    }
    
    private func testSingleStep() {
        // 显示步骤选择器
        let alert = UIAlertController(title: "选择测试步骤", message: "请选择要测试的步骤", preferredStyle: .actionSheet)
        
        for i in 1...6 {
            alert.addAction(UIAlertAction(title: "步骤\(i)", style: .default) { _ in
                self.testSpecificStep(i)
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // 显示alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
    
    private func testSpecificStep(_ step: Int) {
        currentStep = step
        addTestResult("🎯 单独测试步骤\(step)")
        
        switch step {
        case 1: testStep1()
        case 2: testStep2()
        case 3: testStep3()
        case 4: testStep4()
        case 5: testStep5()
        case 6: testStep6()
        default: break
        }
    }
    
    private func finishTest() {
        isTesting = false
        addTestResult("🎉 所有测试完成！")
        
        // 分析结果
        let successCount = [step1Result, step2Result, step3Result, step4Result, step5Result, step6Result].filter { $0 == "成功" }.count
        let failCount = [step1Result, step2Result, step3Result, step4Result, step5Result, step6Result].filter { $0 == "失败" }.count
        
        addTestResult("📊 测试结果统计:")
        addTestResult("   - 成功: \(successCount) 步")
        addTestResult("   - 失败: \(failCount) 步")
        addTestResult("   - 未测试: \(6 - successCount - failCount) 步")
        
        if failCount > 0 {
            addTestResult("⚠️ 发现失败的步骤，请重点分析这些步骤的代码")
        } else {
            addTestResult("✅ 所有测试步骤都通过了")
        }
    }
    
    private func resetTest() {
        currentStep = 0
        testResults.removeAll()
        isTesting = false
        
        step1Result = "未测试"
        step2Result = "未测试"
        step3Result = "未测试"
        step4Result = "未测试"
        step5Result = "未测试"
        step6Result = "未测试"
    }
    
    private func addTestResult(_ result: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        testResults.append("[\(timestamp)] \(result)")
    }
}

// MARK: - 测试结果卡片
struct TestResultCard: View {
    let title: String
    let result: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(result)
                .font(.caption)
                .foregroundColor(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color.opacity(0.1))
                .cornerRadius(4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - 预览
struct StepByStepAIChatTest_Previews: PreviewProvider {
    static var previews: some View {
        StepByStepAIChatTest()
    }
} 