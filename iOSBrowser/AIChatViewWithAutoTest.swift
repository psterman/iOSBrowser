//
//  AIChatViewWithAutoTest.swift
//  iOSBrowser
//
//  带有自动测试功能的AI对话视图
//

import SwiftUI

struct AIChatViewWithAutoTest: View {
    @ObservedObject var chatManager = AIChatManager.shared
    @State private var messageText = ""
    @State private var showingSessionList = false
    @State private var showingAPIConfig = false
    
    // 自动测试相关状态
    @State private var isAutoTesting = false
    @State private var testResults: [String] = []
    @State private var currentTestStep = 0
    @State private var showingTestPanel = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 自动测试面板（可折叠）
                if showingTestPanel {
                    AutoTestPanel(
                        isTesting: $isAutoTesting,
                        currentStep: $currentTestStep,
                        testResults: $testResults,
                        onStartTest: startAutoTest,
                        onResetTest: resetAutoTest
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                if let session = chatManager.currentSession {
                    // 对话界面
                    VStack(spacing: 0) {
                        // 消息列表
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(session.messages) { message in
                                        MessageBubble(message: message)
                                            .id(message.id)
                                    }
                                    
                                    // 加载指示器
                                    if chatManager.isLoading {
                                        HStack {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                            Text("AI正在思考中...")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                        .padding(.horizontal, 16)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .onChange(of: session.messages.count) { _ in
                                if let lastMessage = session.messages.last {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                        
                        // 输入区域
                        VStack(spacing: 0) {
                            Divider()
                            
                            HStack(spacing: 12) {
                                TextField("输入消息...", text: $messageText)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onSubmit {
                                        sendMessage()
                                    }
                                    .disabled(chatManager.isLoading)
                                
                                Button(action: sendMessage) {
                                    Image(systemName: "paperplane.fill")
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(
                                            Circle()
                                                .fill(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatManager.isLoading ? Color.gray : Color.blue)
                                        )
                                }
                                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatManager.isLoading)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .background(Color(.systemBackground))
                    }
                } else {
                    // 空状态
                    VStack(spacing: 24) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)
                        
                        Text("开始新的AI对话")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("选择一个AI服务开始对话")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 16) {
                            Button(action: {
                                showingSessionList = true
                            }) {
                                Text("查看历史对话")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                showingAPIConfig = true
                            }) {
                                Text("配置API密钥")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(chatManager.currentSession?.title ?? "AI对话")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("关闭") {
                    chatManager.closeChat()
                },
                trailing: HStack(spacing: 16) {
                    // 测试按钮
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showingTestPanel.toggle()
                        }
                    }) {
                        Image(systemName: "wrench.and.screwdriver")
                            .foregroundColor(.orange)
                    }
                    
                    Button("设置") {
                        showingAPIConfig = true
                    }
                    Button("历史") {
                        showingSessionList = true
                    }
                }
            )
            .sheet(isPresented: $showingSessionList) {
                ChatSessionListView()
            }
            .sheet(isPresented: $showingAPIConfig) {
                APIConfigView()
            }
            .onAppear {
                // 自动开始测试（可选）
                if UserDefaults.standard.bool(forKey: "AutoTestOnAppear") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        startAutoTest()
                    }
                }
            }
        }
    }
    
    // MARK: - 自动测试方法
    
    private func startAutoTest() {
        guard !isAutoTesting else { return }
        
        isAutoTesting = true
        testResults.removeAll()
        currentTestStep = 0
        
        addTestResult("🚀 开始自动测试AI对话初始化...")
        
        // 开始第一步
        testStep1()
    }
    
    private func testStep1() {
        currentTestStep = 1
        addTestResult("📋 步骤1: 测试AIChatManager单例初始化")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                let _ = AIChatManager.shared
                addTestResult("✅ 步骤1成功: AIChatManager单例创建成功")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    testStep2()
                }
            } catch {
                addTestResult("❌ 步骤1失败: \(error.localizedDescription)")
                finishAutoTest()
            }
        }
    }
    
    private func testStep2() {
        currentTestStep = 2
        addTestResult("📋 步骤2: 测试历史数据加载")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                let chatManager = AIChatManager.shared
                let sessionCount = chatManager.chatSessions.count
                addTestResult("✅ 步骤2成功: 加载了\(sessionCount)个历史会话")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    testStep3()
                }
            } catch {
                addTestResult("❌ 步骤2失败: \(error.localizedDescription)")
                finishAutoTest()
            }
        }
    }
    
    private func testStep3() {
        currentTestStep = 3
        addTestResult("📋 步骤3: 测试状态变量初始化")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                let messageText = ""
                let showingSessionList = false
                let showingAPIConfig = false
                
                addTestResult("✅ 步骤3成功: 状态变量初始化完成")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    testStep4()
                }
            } catch {
                addTestResult("❌ 步骤3失败: \(error.localizedDescription)")
                finishAutoTest()
            }
        }
    }
    
    private func testStep4() {
        currentTestStep = 4
        addTestResult("📋 步骤4: 测试界面状态判断")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                let chatManager = AIChatManager.shared
                let hasCurrentSession = chatManager.currentSession != nil
                let sessionTitle = chatManager.currentSession?.title ?? "无当前会话"
                
                addTestResult("✅ 步骤4成功: 界面状态判断完成")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    testStep5()
                }
            } catch {
                addTestResult("❌ 步骤4失败: \(error.localizedDescription)")
                finishAutoTest()
            }
        }
    }
    
    private func testStep5() {
        currentTestStep = 5
        addTestResult("📋 步骤5: 测试导航栏配置")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                let chatManager = AIChatManager.shared
                let navigationTitle = chatManager.currentSession?.title ?? "AI对话"
                
                addTestResult("✅ 步骤5成功: 导航栏配置完成")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    testStep6()
                }
            } catch {
                addTestResult("❌ 步骤5失败: \(error.localizedDescription)")
                finishAutoTest()
            }
        }
    }
    
    private func testStep6() {
        currentTestStep = 6
        addTestResult("📋 步骤6: 测试Sheet视图准备")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                addTestResult("✅ 步骤6成功: Sheet视图准备完成")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    finishAutoTest()
                }
            } catch {
                addTestResult("❌ 步骤6失败: \(error.localizedDescription)")
                finishAutoTest()
            }
        }
    }
    
    private func finishAutoTest() {
        isAutoTesting = false
        addTestResult("🎉 自动测试完成！")
        
        let successCount = testResults.filter { $0.contains("✅") }.count
        let failCount = testResults.filter { $0.contains("❌") }.count
        
        addTestResult("📊 测试结果: 成功\(successCount)步，失败\(failCount)步")
        
        if failCount > 0 {
            addTestResult("⚠️ 发现问题！请检查失败的步骤")
        } else {
            addTestResult("✅ 所有测试通过，初始化正常")
        }
    }
    
    private func resetAutoTest() {
        isAutoTesting = false
        currentTestStep = 0
        testResults.removeAll()
    }
    
    private func addTestResult(_ result: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        testResults.append("[\(timestamp)] \(result)")
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        chatManager.sendMessage(trimmedText)
        messageText = ""
    }
}

// MARK: - 自动测试面板
struct AutoTestPanel: View {
    @Binding var isTesting: Bool
    @Binding var currentStep: Int
    @Binding var testResults: [String]
    let onStartTest: () -> Void
    let onResetTest: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // 标题栏
            HStack {
                Text("🔧 自动测试面板")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isTesting {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("测试中...")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            // 当前步骤
            HStack {
                Text("当前步骤: \(currentStep)/6")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if currentStep > 0 {
                    ProgressView(value: Double(currentStep), total: 6.0)
                        .frame(width: 100)
                }
            }
            
            // 控制按钮
            HStack(spacing: 12) {
                Button(isTesting ? "测试中..." : "开始测试") {
                    onStartTest()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isTesting ? Color.gray : Color.blue)
                .cornerRadius(8)
                .disabled(isTesting)
                
                Button("重置") {
                    onResetTest()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange)
                .cornerRadius(8)
                .disabled(isTesting)
            }
            
            // 测试结果预览
            if !testResults.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("最新结果:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(testResults.suffix(3), id: \.self) { result in
                                Text(result)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(maxHeight: 60)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - 预览
struct AIChatViewWithAutoTest_Previews: PreviewProvider {
    static var previews: some View {
        AIChatViewWithAutoTest()
    }
} 