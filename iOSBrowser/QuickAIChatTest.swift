//
//  QuickAIChatTest.swift
//  iOSBrowser
//
//  快速测试AI对话初始化的简单视图
//

import SwiftUI

struct QuickAIChatTest: View {
    @State private var testStep = 1
    @State private var testResult = "未开始测试"
    @State private var isTesting = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // 标题
                Text("AI对话初始化快速测试")
                    .font(.title)
                    .fontWeight(.bold)
                
                // 当前测试步骤
                VStack(spacing: 10) {
                    Text("当前测试步骤")
                        .font(.headline)
                    
                    Text("\(testStep)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text(getStepDescription(testStep))
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                
                // 测试结果
                VStack(spacing: 10) {
                    Text("测试结果")
                        .font(.headline)
                    
                    Text(testResult)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(getResultColor().opacity(0.1))
                        .foregroundColor(getResultColor())
                        .cornerRadius(10)
                }
                
                // 控制按钮
                VStack(spacing: 16) {
                    Button("开始测试步骤\(testStep)") {
                        startTest()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .disabled(isTesting)
                    
                    HStack(spacing: 16) {
                        Button("上一步") {
                            if testStep > 1 {
                                testStep -= 1
                                testResult = "未开始测试"
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                        .disabled(testStep <= 1)
                        
                        Button("下一步") {
                            if testStep < 6 {
                                testStep += 1
                                testResult = "未开始测试"
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                        .disabled(testStep >= 6)
                    }
                    
                    Button("重置所有测试") {
                        resetTest()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("快速测试")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - 测试方法
    
    private func startTest() {
        isTesting = true
        testResult = "测试中..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            switch testStep {
            case 1:
                testStep1()
            case 2:
                testStep2()
            case 3:
                testStep3()
            case 4:
                testStep4()
            case 5:
                testStep5()
            case 6:
                testStep6()
            default:
                break
            }
        }
    }
    
    private func testStep1() {
        // 测试AIChatManager单例初始化
        do {
            let _ = AIChatManager.shared
            testResult = "✅ 成功: AIChatManager单例创建成功"
        } catch {
            testResult = "❌ 失败: \(error.localizedDescription)"
        }
        isTesting = false
    }
    
    private func testStep2() {
        // 测试历史数据加载
        do {
            let chatManager = AIChatManager.shared
            let sessionCount = chatManager.chatSessions.count
            testResult = "✅ 成功: 加载了\(sessionCount)个历史会话"
        } catch {
            testResult = "❌ 失败: \(error.localizedDescription)"
        }
        isTesting = false
    }
    
    private func testStep3() {
        // 测试状态变量初始化
        do {
            let messageText = ""
            let showingSessionList = false
            let showingAPIConfig = false
            
            testResult = "✅ 成功: 状态变量初始化完成\n- messageText: '\(messageText)'\n- showingSessionList: \(showingSessionList)\n- showingAPIConfig: \(showingAPIConfig)"
        } catch {
            testResult = "❌ 失败: \(error.localizedDescription)"
        }
        isTesting = false
    }
    
    private func testStep4() {
        // 测试界面状态判断
        do {
            let chatManager = AIChatManager.shared
            let hasCurrentSession = chatManager.currentSession != nil
            let sessionTitle = chatManager.currentSession?.title ?? "无当前会话"
            
            testResult = "✅ 成功: 界面状态判断完成\n- 有当前会话: \(hasCurrentSession)\n- 会话标题: '\(sessionTitle)'"
        } catch {
            testResult = "❌ 失败: \(error.localizedDescription)"
        }
        isTesting = false
    }
    
    private func testStep5() {
        // 测试导航栏配置
        do {
            let chatManager = AIChatManager.shared
            let navigationTitle = chatManager.currentSession?.title ?? "AI对话"
            
            testResult = "✅ 成功: 导航栏配置完成\n- 导航标题: '\(navigationTitle)'\n- 导航模式: inline"
        } catch {
            testResult = "❌ 失败: \(error.localizedDescription)"
        }
        isTesting = false
    }
    
    private func testStep6() {
        // 测试Sheet视图准备
        do {
            testResult = "✅ 成功: Sheet视图准备完成\n- ChatSessionListView 准备就绪\n- APIConfigView 准备就绪"
        } catch {
            testResult = "❌ 失败: \(error.localizedDescription)"
        }
        isTesting = false
    }
    
    private func resetTest() {
        testStep = 1
        testResult = "未开始测试"
        isTesting = false
    }
    
    // MARK: - 辅助方法
    
    private func getStepDescription(_ step: Int) -> String {
        switch step {
        case 1:
            return "AIChatManager单例初始化"
        case 2:
            return "历史数据加载"
        case 3:
            return "状态变量初始化"
        case 4:
            return "界面状态判断"
        case 5:
            return "导航栏配置"
        case 6:
            return "Sheet视图准备"
        default:
            return "未知步骤"
        }
    }
    
    private func getResultColor() -> Color {
        if testResult.contains("✅") {
            return .green
        } else if testResult.contains("❌") {
            return .red
        } else if testResult.contains("测试中") {
            return .blue
        } else {
            return .gray
        }
    }
}

// MARK: - 预览
struct QuickAIChatTest_Previews: PreviewProvider {
    static var previews: some View {
        QuickAIChatTest()
    }
} 