//
//  ChatContainerView.swift
//  iOSBrowser
//
//  聊天容器视图 - 用于tab中显示聊天界面
//

import SwiftUI

struct ChatContainerView: View {
    @State private var selectedAssistant: String = "deepseek"
    @State private var showingChat = false
    @State private var targetContact: AIContact?
    
    var body: some View {
        NavigationView {
            VStack {
                if showingChat, let contact = targetContact {
                    // 显示聊天界面
                    ChatView(contact: contact)
                } else {
                    // 显示AI助手选择界面
                    VStack(spacing: 20) {
                        Text("选择AI助手开始聊天")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            ForEach(getSampleAIAssistants(), id: \.id) { assistant in
                                Button(action: {
                                    startChatWith(assistant: assistant.id)
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: assistant.icon)
                                            .font(.system(size: 32))
                                            .foregroundColor(assistant.color)
                                        
                                        Text(assistant.name)
                                            .font(.headline)
                                            .fontWeight(.medium)
                                        
                                        Text(assistant.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("AI聊天")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(NotificationCenter.default.publisher(for: .openDirectChat)) { notification in
                if let data = notification.object as? [String: String],
                   let assistantId = data["assistant"] {
                    startChatWith(assistant: assistantId)
                }
            }
        }
    }
    
    private func startChatWith(assistant: String) {
        if let contact = findAIContact(by: assistant) {
            targetContact = contact
            showingChat = true
        }
    }
    
    private func findAIContact(by id: String) -> AIContact? {
        // 精准的AI联系人映射
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
            apiKey: "",
            model: "default",
            systemPrompt: "你是\(name)，一个专业的AI助手。请用中文回答问题，提供准确和有用的信息。",
            temperature: 0.7,
            maxTokens: 2000,
            isEnabled: true
        )
    }
    
    private func getSampleAIAssistants() -> [WidgetAIAssistant] {
        return [
            WidgetAIAssistant(id: "deepseek", name: "DeepSeek", icon: "brain.head.profile", color: .purple, description: "专业编程助手"),
            WidgetAIAssistant(id: "qwen", name: "通义千问", icon: "cloud.fill", color: .cyan, description: "阿里云AI"),
            WidgetAIAssistant(id: "chatglm", name: "智谱清言", icon: "lightbulb.fill", color: .yellow, description: "清华智谱AI"),
            WidgetAIAssistant(id: "moonshot", name: "Kimi", icon: "moon.stars.fill", color: .orange, description: "月之暗面")
        ]
    }
}

// 临时的WidgetAIAssistant结构（如果不存在的话）
struct WidgetAIAssistant {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let description: String
}
