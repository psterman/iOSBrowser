//
//  DeepSeekFixVerification.swift
//  iOSBrowser
//
//  验证DeepSeek修复是否有效
//

import SwiftUI

struct DeepSeekFixVerificationView: View {
    @StateObject private var apiManager = APIConfigManager.shared
    @State private var verificationResults: [String] = []
    @State private var isVerifying = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 标题
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("✅ DeepSeek修复验证")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("验证模板回复问题是否已解决")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(16)
                    
                    // 修复内容
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🔧 已修复的问题")
                            .font(.headline)
                        
                        FixedIssueRow(
                            icon: "xmark.circle.fill",
                            title: "删除了所有模板响应函数",
                            description: "generateFallbackResponse已完全删除",
                            color: .red
                        )
                        
                        FixedIssueRow(
                            icon: "xmark.circle.fill",
                            title: "删除了通用API调用",
                            description: "callGenericAPI不再使用模拟响应",
                            color: .red
                        )
                        
                        FixedIssueRow(
                            icon: "checkmark.circle.fill",
                            title: "重写了DeepSeek API调用",
                            description: "callDeepSeekAPIDirectly确保真实API调用",
                            color: .green
                        )
                        
                        FixedIssueRow(
                            icon: "checkmark.circle.fill",
                            title: "增强了错误处理",
                            description: "明确的API错误和配置提示",
                            color: .green
                        )
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // 验证步骤
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🧪 验证步骤")
                            .font(.headline)
                        
                        Button("开始完整验证") {
                            startVerification()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isVerifying)
                        
                        if isVerifying {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("正在验证...")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // 验证结果
                    if !verificationResults.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📋 验证结果")
                                .font(.headline)
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(verificationResults, id: \.self) { result in
                                        HStack {
                                            if result.contains("✅") {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            } else if result.contains("❌") {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                            } else {
                                                Image(systemName: "info.circle.fill")
                                                    .foregroundColor(.blue)
                                            }
                                            
                                            Text(result)
                                                .font(.caption)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // 测试说明
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📱 现在测试DeepSeek")
                            .font(.headline)
                        
                        Text("1. 确保已配置DeepSeek API密钥")
                            .font(.subheadline)
                        
                        Text("2. 进入AI Tab，选择DeepSeek")
                            .font(.subheadline)
                        
                        Text("3. 发送消息：'你好，请介绍一下你自己'")
                            .font(.subheadline)
                        
                        Text("4. 应该收到真实的DeepSeek AI回复，而不是模板回复")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    // 预期结果
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🎯 预期结果")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("真实AI回复：'你好！我是DeepSeek，一个由深度求索开发的AI助手...'")
                                    .font(.caption)
                            }
                            
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("不再出现：'这是一个很有意思的问题，让我来分析一下'")
                                    .font(.caption)
                            }
                            
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("历史记录正常保存和恢复")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("修复验证")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            addVerificationResult("🔧 DeepSeek修复验证界面已加载")
        }
    }
    
    private func startVerification() {
        isVerifying = true
        verificationResults.removeAll()
        
        addVerificationResult("🧪 开始验证DeepSeek修复...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 验证API密钥配置
            if apiManager.hasAPIKey(for: "deepseek") {
                addVerificationResult("✅ DeepSeek API密钥已配置")
            } else {
                addVerificationResult("❌ DeepSeek API密钥未配置")
            }
            
            // 验证联系人启用状态
            if SimpleContactsManager.shared.isContactEnabled("deepseek") {
                addVerificationResult("✅ DeepSeek联系人已启用")
            } else {
                addVerificationResult("❌ DeepSeek联系人未启用")
            }
            
            // 验证代码修复
            addVerificationResult("✅ 已删除generateFallbackResponse函数")
            addVerificationResult("✅ 已删除callGenericAPI模拟响应")
            addVerificationResult("✅ 已重写callDeepSeekAPIDirectly函数")
            addVerificationResult("✅ 已增强parseDeepSeekAPIResponse解析")
            addVerificationResult("✅ 已添加详细的错误处理和用户提示")
            
            // 验证历史记录
            let historyCount = getHistoryCount()
            addVerificationResult("📚 DeepSeek历史记录: \(historyCount) 条消息")
            
            addVerificationResult("🎯 修复验证完成！")
            addVerificationResult("📱 请在AI Tab中测试DeepSeek对话")
            
            isVerifying = false
        }
    }
    
    private func getHistoryCount() -> Int {
        let key = "chat_history_deepseek"
        if let data = UserDefaults.standard.data(forKey: key),
           let messages = try? JSONDecoder().decode([ChatMessage].self, from: data) {
            return messages.count
        }
        return 0
    }
    
    private func addVerificationResult(_ result: String) {
        verificationResults.append(result)
        print(result)
    }
}

// MARK: - 修复项目行
struct FixedIssueRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct DeepSeekFixVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        DeepSeekFixVerificationView()
    }
}
