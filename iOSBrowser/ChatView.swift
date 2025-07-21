//
//  ChatView.swift
//  iOSBrowser
//
//  Created by LZH on 2025/7/20.
//

import SwiftUI

struct ChatView: View {
    let contact: AIContact
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isLoading = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // 聊天消息列表
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        ChatMessageRow(message: message)
                    }
                    
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("AI正在思考...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            
            Divider()
            
            // 输入区域
            HStack(spacing: 12) {
                TextField("输入消息...", text: $messageText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...4)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(messageText.isEmpty ? .gray : .blue)
                        .font(.title2)
                }
                .disabled(messageText.isEmpty || isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationTitle(contact.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // 添加欢迎消息
            if messages.isEmpty {
                messages.append(ChatMessage(
                    id: UUID().uuidString,
                    content: "你好！我是\(contact.name)，\(contact.description)。有什么可以帮助你的吗？",
                    isFromUser: false,
                    timestamp: Date(),
                    status: .sent
                ))
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(
            id: UUID().uuidString,
            content: messageText,
            isFromUser: true,
            timestamp: Date(),
            status: .sent
        )
        
        messages.append(userMessage)
        let currentMessage = messageText
        messageText = ""
        isLoading = true
        
        // 模拟AI响应
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let aiResponse = ChatMessage(
                id: UUID().uuidString,
                content: generateAIResponse(for: currentMessage),
                isFromUser: false,
                timestamp: Date(),
                status: .sent
            )
            messages.append(aiResponse)
            isLoading = false
        }
    }
    
    private func generateAIResponse(for message: String) -> String {
        // 简单的模拟响应
        let responses = [
            "这是一个很有趣的问题！让我来帮你分析一下...",
            "根据我的理解，\(message.prefix(20))... 这个问题可以从多个角度来看。",
            "感谢你的提问！关于这个话题，我建议...",
            "这确实是个值得深入思考的问题。我的看法是...",
            "让我为你详细解释一下这个概念..."
        ]
        
        return responses.randomElement() ?? "抱歉，我现在无法处理这个请求。请稍后再试。"
    }
}



struct ChatMessageRow: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(18)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(18)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView(contact: AIContact(
                id: "test",
                name: "测试AI",
                description: "测试用AI助手",
                model: "test-model",
                avatar: "brain.head.profile",
                isOnline: true,
                apiEndpoint: "https://api.test.com",
                requiresApiKey: true,
                supportedFeatures: [.textGeneration]
            ))
        }
    }
}
