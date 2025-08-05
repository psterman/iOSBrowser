//
//  DirectChatView.swift
//  iOSBrowser
//
//  直接跳转到AI聊天页面
//

import SwiftUI

struct DirectChatView: View {
    let assistantId: String
    let presetPrompt: String?
    @State private var contact: AIContact?
    @State private var isLoading = true
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("正在连接AI助手...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else if let contact = contact {
                ChatView(contact: contact, presetPrompt: presetPrompt)
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    
                    Text("AI助手不可用")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("请检查网络连接或稍后重试")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("返回") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
        }
        .onAppear {
            loadAIContact()
        }
    }
    
    private func loadAIContact() {
        // 根据assistantId查找对应的AI联系人
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let foundContact = findAIContact(by: assistantId) {
                contact = foundContact
            }
            isLoading = false
        }
    }
    
    private func findAIContact(by id: String) -> AIContact? {
        // 精准的AI联系人映射，确保与小组件完全一致
        let assistantMapping: [String: (String, String, String, String)] = [
            "deepseek": ("DeepSeek", "专业编程助手", "https://api.deepseek.com", "brain.head.profile"),
            "qwen": ("通义千问", "阿里云AI助手", "https://api.qwen.com", "cloud.fill"),
            "chatglm": ("智谱清言", "清华智谱AI", "https://api.chatglm.com", "lightbulb.fill"),
            "moonshot": ("Kimi", "月之暗面AI", "https://api.moonshot.com", "moon.stars.fill"),
            "claude": ("Claude", "智能助手", "https://api.claude.com", "c.circle.fill"),
            "gpt": ("ChatGPT", "对话AI", "https://api.openai.com", "g.circle.fill")
        ]

        guard let (name, description, apiUrl, icon) = assistantMapping[id] else {
            print("❌ 未找到AI助手: \(id)")
            return nil
        }

        print("✅ 找到AI助手: \(name)")

        return AIContact(
            id: UUID(),
            name: name,
            description: description,
            apiUrl: apiUrl,
            apiKey: "", // 这里应该从设置中获取
            model: "default",
            systemPrompt: "你是\(name)，一个专业的AI助手。请用中文回答问题，提供准确和有用的信息。",
            temperature: 0.7,
            maxTokens: 2000,
            isEnabled: true
        )
    }
}

// MARK: - 增强的ChatView，支持预设提示词
extension ChatView {
    init(contact: AIContact, presetPrompt: String?) {
        self.init(contact: contact)
        
        // 如果有预设提示词，自动发送
        if let prompt = presetPrompt, !prompt.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // 这里需要调用发送消息的方法
                // 由于ChatView的内部实现，我们需要通过通知来实现
                NotificationCenter.default.post(
                    name: .sendPresetPrompt,
                    object: prompt
                )
            }
        }
    }
}

// MARK: - 通知扩展
extension Notification.Name {
    static let sendPresetPrompt = Notification.Name("sendPresetPrompt")
    static let openDirectChat = Notification.Name("openDirectChat")
    static let showPlatformHotTrends = Notification.Name("showPlatformHotTrends")
}

// MARK: - 直接聊天数据模型
struct DirectChatRequest {
    let assistantId: String
    let presetPrompt: String?
    let autoSend: Bool
    
    init(assistantId: String, presetPrompt: String? = nil, autoSend: Bool = false) {
        self.assistantId = assistantId
        self.presetPrompt = presetPrompt
        self.autoSend = autoSend
    }
}
