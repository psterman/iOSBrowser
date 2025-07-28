//
//  AIChatTabView.swift
//  iOSBrowser
//
//  AI聊天Tab视图 - 支持直接跳转到聊天界面
//

import SwiftUI

struct AIChatTabView: View {
    @State private var showingDirectChat = false
    @State private var selectedAssistantId = "deepseek"
    @State private var currentContact: AIContact?
    
    var body: some View {
        NavigationView {
            Group {
                if showingDirectChat, let contact = currentContact {
                    // 显示直接聊天界面
                    DirectChatView(assistantId: selectedAssistantId, presetPrompt: nil)
                        .navigationBarHidden(true)
                } else {
                    // 显示AI助手选择界面
                    AIAssistantSelectionView(onAssistantSelected: { assistantId in
                        startDirectChat(with: assistantId)
                    })
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openDirectChat)) { notification in
            if let data = notification.object as? [String: String],
               let assistantId = data["assistant"] {
                startDirectChat(with: assistantId)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showAIAssistant)) { notification in
            if let assistantId = notification.object as? String {
                startDirectChat(with: assistantId)
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
        let assistantMapping: [String: (String, String, String)] = [
            "deepseek": ("DeepSeek", "专业编程助手", "https://api.deepseek.com"),
            "qwen": ("通义千问", "阿里云AI助手", "https://api.qwen.com"),
            "chatglm": ("智谱清言", "清华智谱AI", "https://api.chatglm.com"),
            "moonshot": ("Kimi", "月之暗面AI", "https://api.moonshot.com"),
            "claude": ("Claude", "智能助手", "https://api.claude.com"),
            "gpt": ("ChatGPT", "对话AI", "https://api.openai.com")
        ]
        
        guard let (name, description, apiUrl) = assistantMapping[assistantId] else {
            print("❌ 未找到AI助手: \(assistantId)")
            return nil
        }
        
        print("✅ 创建AI联系人: \(name)")
        
        return AIContact(
            id: UUID(),
            name: name,
            description: description,
            apiUrl: apiUrl,
            apiKey: "",
            model: "default",
            systemPrompt: "你是\(name)，一个专业的AI助手。请用中文回答问题，提供准确和有用的信息。",
            temperature: 0.7,
            maxTokens: 2000,
            isEnabled: true
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
