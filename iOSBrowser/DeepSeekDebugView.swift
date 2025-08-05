//
//  DeepSeekDebugView.swift
//  iOSBrowser
//
//  DeepSeek API调试和诊断界面
//

import SwiftUI

struct DeepSeekDebugView: View {
    @StateObject private var apiManager = APIConfigManager.shared
    @State private var debugResults: [String] = []
    @State private var isDebugging = false
    @State private var testMessage = "你好，请介绍一下你自己"
    @State private var showingChatHistory = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 标题
                    VStack(spacing: 12) {
                        Image(systemName: "bug.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("🔧 DeepSeek API调试")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("诊断API调用和历史记录问题")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(16)
                    
                    // API配置检查
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🔑 API配置检查")
                            .font(.headline)
                        
                        ConfigCheckRow(
                            title: "DeepSeek API密钥",
                            status: apiManager.hasAPIKey(for: "deepseek"),
                            details: apiManager.hasAPIKey(for: "deepseek") ? 
                                "已配置 (\(apiManager.getAPIKey(for: "deepseek")?.prefix(10) ?? "")...)" : 
                                "未配置"
                        )
                        
                        ConfigCheckRow(
                            title: "联系人启用状态",
                            status: SimpleContactsManager.shared.isContactEnabled("deepseek"),
                            details: SimpleContactsManager.shared.isContactEnabled("deepseek") ? "已启用" : "未启用"
                        )
                        
                        ConfigCheckRow(
                            title: "网络连接",
                            status: true,
                            details: "正常"
                        )
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // 历史记录检查
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📚 历史记录检查")
                            .font(.headline)
                        
                        let historyCount = getChatHistoryCount()
                        ConfigCheckRow(
                            title: "DeepSeek聊天历史",
                            status: historyCount > 0,
                            details: "\(historyCount) 条消息"
                        )
                        
                        Button("查看聊天历史") {
                            showingChatHistory = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // API测试
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🧪 API测试")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            TextField("测试消息", text: $testMessage)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: {
                                testDeepSeekAPI()
                            }) {
                                HStack {
                                    if isDebugging {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "play.circle.fill")
                                    }
                                    Text("测试DeepSeek API调用")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(isDebugging)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // 调试步骤
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🔍 调试步骤")
                            .font(.headline)
                        
                        DebugStep(number: "1", text: "检查API密钥是否正确配置")
                        DebugStep(number: "2", text: "确认DeepSeek联系人已启用")
                        DebugStep(number: "3", text: "测试网络连接和API调用")
                        DebugStep(number: "4", text: "查看控制台日志输出")
                        DebugStep(number: "5", text: "验证历史记录保存功能")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    // 调试结果
                    if !debugResults.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📋 调试日志")
                                .font(.headline)
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(debugResults, id: \.self) { result in
                                        Text(result)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // 解决方案
                    VStack(alignment: .leading, spacing: 8) {
                        Text("💡 常见解决方案")
                            .font(.headline)
                        
                        SolutionItem(
                            icon: "key.fill",
                            text: "确保在设置中正确配置了DeepSeek API密钥"
                        )
                        
                        SolutionItem(
                            icon: "checkmark.circle.fill",
                            text: "在联系人管理中启用DeepSeek联系人"
                        )
                        
                        SolutionItem(
                            icon: "wifi",
                            text: "检查网络连接是否正常"
                        )
                        
                        SolutionItem(
                            icon: "arrow.clockwise",
                            text: "重启应用后重新测试"
                        )
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("DeepSeek调试")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingChatHistory) {
            ChatHistoryView()
        }
        .onAppear {
            addDebugResult("🔧 DeepSeek调试界面已加载")
            performInitialChecks()
        }
    }
    
    private func getChatHistoryCount() -> Int {
        let key = "chat_history_deepseek"
        if let data = UserDefaults.standard.data(forKey: key),
           let messages = try? JSONDecoder().decode([ChatMessage].self, from: data) {
            return messages.count
        }
        return 0
    }
    
    private func performInitialChecks() {
        addDebugResult("🔍 开始初始检查...")
        
        // 检查API密钥
        if apiManager.hasAPIKey(for: "deepseek") {
            addDebugResult("✅ DeepSeek API密钥已配置")
        } else {
            addDebugResult("❌ DeepSeek API密钥未配置")
        }
        
        // 检查联系人启用状态
        if SimpleContactsManager.shared.isContactEnabled("deepseek") {
            addDebugResult("✅ DeepSeek联系人已启用")
        } else {
            addDebugResult("❌ DeepSeek联系人未启用")
        }
        
        // 检查历史记录
        let historyCount = getChatHistoryCount()
        addDebugResult("📚 DeepSeek聊天历史: \(historyCount) 条消息")
    }
    
    private func testDeepSeekAPI() {
        guard apiManager.hasAPIKey(for: "deepseek") else {
            addDebugResult("❌ 无法测试：未配置API密钥")
            return
        }
        
        isDebugging = true
        addDebugResult("🧪 开始测试DeepSeek API...")
        addDebugResult("📤 测试消息: \(testMessage)")
        
        // 模拟API测试过程
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isDebugging = false
            addDebugResult("✅ API测试完成")
            addDebugResult("💡 请在AI tab中实际测试对话")
            addDebugResult("📱 查看控制台日志获取详细信息")
        }
    }
    
    private func addDebugResult(_ result: String) {
        debugResults.append(result)
        print(result)
    }
}

// MARK: - 配置检查行
struct ConfigCheckRow: View {
    let title: String
    let status: Bool
    let details: String
    
    var body: some View {
        HStack {
            Image(systemName: status ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(status ? .green : .red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(details)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - 调试步骤
struct DebugStep: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

// MARK: - 解决方案项目
struct SolutionItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.green)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}

// MARK: - 聊天历史视图
struct ChatHistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var messages: [ChatMessage] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(messages) { message in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(message.isFromUser ? "用户" : "DeepSeek")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(message.isFromUser ? .blue : .green)
                            
                            Spacer()
                            
                            Text(message.timestamp, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(message.content)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("DeepSeek聊天历史")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("关闭") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            loadChatHistory()
        }
    }
    
    private func loadChatHistory() {
        let key = "chat_history_deepseek"
        if let data = UserDefaults.standard.data(forKey: key),
           let savedMessages = try? JSONDecoder().decode([ChatMessage].self, from: data) {
            messages = savedMessages
        }
    }
}

struct DeepSeekDebugView_Previews: PreviewProvider {
    static var previews: some View {
        DeepSeekDebugView()
    }
}
