//
//  SimpleAIChatView.swift
//  iOSBrowser
//
//  简单的AI聊天视图 - 专门用于深度链接直接聊天
//

import SwiftUI

struct SimpleAIChatView: View {
    @State private var messageText = ""
    @State private var messages: [Message] = []
    @State private var isLoading = false
    
    struct Message: Identifiable {
        let id = UUID()
        let content: String
        let isUser: Bool
        let timestamp = Date()
    }
    
    var body: some View {
        VStack {
            // 消息列表
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                    
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("AI正在思考...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
                .padding()
            }
            
            // 输入区域
            HStack(spacing: 8) {
                TextField("输入消息...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(messageText.isEmpty ? .gray : .green)
                }
                .disabled(messageText.isEmpty || isLoading)
            }
            .padding()
        }
        .navigationTitle("AI聊天")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        // 添加用户消息
        let userMessage = Message(content: trimmedMessage, isUser: true)
        messages.append(userMessage)
        
        // 清空输入框
        messageText = ""
        
        // 显示AI正在处理状态
        isLoading = true
        
        // TODO: 这里应该调用真实的AI API
        // 目前显示占位符消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let aiMessage = Message(content: "正在处理您的请求，请稍候...", isUser: false)
            messages.append(aiMessage)
            isLoading = false
        }
    }
}

struct MessageBubble: View {
    let message: SimpleAIChatView.Message
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
    }
}
