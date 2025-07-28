//
//  SimpleAIChatView.swift
//  iOSBrowser
//
//  简单的AI聊天视图 - 专门用于深度链接直接聊天
//

import SwiftUI

struct SimpleAIChatView: View {
    @State private var showingDirectChat = false
    @State private var selectedAssistantId = "deepseek"
    @State private var currentContact: AIContact?
    
    var body: some View {
        NavigationView {
            Group {
                if showingDirectChat, let contact = currentContact {
                    // 显示直接聊天界面
                    ChatView(contact: contact)
                        .navigationBarHidden(false)
                } else {
                    // 显示AI助手选择界面
                    AIAssistantSelectionView(onAssistantSelected: { assistantId in
                        startDirectChat(with: assistantId)
                    })
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showAIAssistant)) { notification in
            if let assistantId = notification.object as? String {
                startDirectChat(with: assistantId)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .startAIConversation)) { notification in
            if let data = notification.object as? [String: String],
               let assistantId = data["assistantId"],
               let initialMessage = data["initialMessage"] {
                startDirectChatWithMessage(assistantId: assistantId, message: initialMessage)
            }
        }
    }

    private func startDirectChatWithMessage(assistantId: String, message: String) {
        selectedAssistantId = assistantId

        // 创建AI联系人
        if let contact = createAIContact(for: assistantId) {
            currentContact = contact
            showingDirectChat = true

            // 延迟一下，等待聊天界面加载完成后自动发送消息
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("🤖 开始与\(contact.name)的对话，初始消息: \(message)")
                // 这里可以添加自动发送消息的逻辑
                // 例如：自动填入消息到输入框或直接发送
            }
        }
    }

    private func startDirectChat(with assistantId: String) {
        selectedAssistantId = assistantId
        
        // 创建AI联系人
        if let contact = createAIContact(for: assistantId) {
            currentContact = contact
            showingDirectChat = true
        }
    }
    
    private func createAIContact(for assistantId: String) -> AIContact? {
        let assistantMapping: [String: (String, String, String, String)] = [
            "deepseek": ("DeepSeek", "专业编程助手", "https://api.deepseek.com", "deepseek-chat"),
            "qwen": ("通义千问", "阿里云AI助手", "https://dashscope.aliyuncs.com", "qwen-max"),
            "chatglm": ("智谱清言", "清华智谱AI", "https://open.bigmodel.cn", "glm-4"),
            "moonshot": ("Kimi", "月之暗面AI", "https://api.moonshot.cn", "moonshot-v1-128k"),
            "claude": ("Claude", "智能助手", "https://api.anthropic.com", "claude-3-5-sonnet"),
            "gpt": ("ChatGPT", "对话AI", "https://api.openai.com/v1", "gpt-4o")
        ]
        
        guard let (name, description, apiUrl, model) = assistantMapping[assistantId] else {
            print("❌ 未找到AI助手: \(assistantId)")
            return nil
        }
        
        print("✅ 创建AI联系人: \(name)")
        
        return AIContact(
            id: assistantId,
            name: name,
            description: description,
            model: model,
            avatar: "brain.head.profile",
            isOnline: true,
            apiEndpoint: apiUrl,
            requiresApiKey: true,
            supportedFeatures: [.textGeneration, .codeGeneration],
            color: .purple
        )
    }
}

struct AIAssistantSelectionView: View {
    let onAssistantSelected: (String) -> Void
    
    private let assistants = [
        ("deepseek", "DeepSeek", "brain.head.profile", Color.purple, "专业编程助手"),
        ("qwen", "通义千问", "cloud.fill", Color.cyan, "阿里云AI"),
        ("chatglm", "智谱清言", "lightbulb.fill", Color.yellow, "清华智谱AI"),
        ("moonshot", "Kimi", "moon.stars.fill", Color.orange, "月之暗面"),
        ("claude", "Claude", "c.circle.fill", Color.blue, "智能助手"),
        ("gpt", "ChatGPT", "g.circle.fill", Color.green, "对话AI")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("选择AI助手开始聊天")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(assistants, id: \.0) { assistant in
                    Button(action: {
                        onAssistantSelected(assistant.0)
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: assistant.2)
                                .font(.system(size: 40))
                                .foregroundColor(assistant.3)
                            
                            Text(assistant.1)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text(assistant.4)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("AI助手")
        .navigationBarTitleDisplayMode(.inline)
    }
}
