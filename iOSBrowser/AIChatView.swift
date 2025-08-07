//
//  AIChatView.swift
//  iOSBrowser
//
//  AI对话界面 - 显示和管理AI对话
//

import SwiftUI

struct AIChatView: View {
    @ObservedObject var chatManager = AIChatManager.shared
    @State private var messageText = ""
    @State private var showingSessionList = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
                                
                                Button(action: sendMessage) {
                                    Image(systemName: "paperplane.fill")
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(
                                            Circle()
                                                .fill(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                                        )
                                }
                                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
                trailing: Button("历史") {
                    showingSessionList = true
                }
            )
            .sheet(isPresented: $showingSessionList) {
                ChatSessionListView()
            }
        }
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        chatManager.sendMessage(trimmedText)
        messageText = ""
    }
}

// MARK: - 消息气泡
struct MessageBubble: View {
    let message: AIChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(18)
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(18)
                    
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

// MARK: - 对话会话列表
struct ChatSessionListView: View {
    @ObservedObject var chatManager = AIChatManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                if chatManager.chatSessions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("暂无对话历史")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(chatManager.chatSessions) { session in
                        ChatSessionRow(session: session) {
                            chatManager.continueChat(session: session)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .onDelete(perform: deleteSessions)
                }
            }
            .navigationTitle("对话历史")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("关闭") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func deleteSessions(offsets: IndexSet) {
        for index in offsets {
            let session = chatManager.chatSessions[index]
            chatManager.deleteSession(session)
        }
    }
}

// MARK: - 对话会话行
struct ChatSessionRow: View {
    let session: AIChatSession
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // AI服务图标
                Image(systemName: getAIServiceIcon(session.aiService))
                    .font(.title2)
                    .foregroundColor(getAIServiceColor(session.aiService))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(getAIServiceColor(session.aiService).opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let lastMessage = session.messages.last {
                        Text(lastMessage.content)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Text(formatDate(session.lastUpdated))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(session.messages.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("条消息")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getAIServiceIcon(_ serviceId: String) -> String {
        switch serviceId {
        case "deepseek": return "brain.head.profile"
        case "kimi": return "moon.stars"
        case "doubao": return "bubble.left.and.bubble.right"
        case "wenxin": return "doc.text"
        case "yuanbao": return "diamond"
        case "chatglm": return "lightbulb.fill"
        case "tongyi": return "cloud.fill"
        case "claude": return "sparkles"
        case "chatgpt": return "bubble.left.and.bubble.right.fill"
        default: return "brain.head.profile"
        }
    }
    
    private func getAIServiceColor(_ serviceId: String) -> Color {
        switch serviceId {
        case "deepseek": return .purple
        case "kimi": return .orange
        case "doubao": return .blue
        case "wenxin": return .red
        case "yuanbao": return .pink
        case "chatglm": return .yellow
        case "tongyi": return .cyan
        case "claude": return .indigo
        case "chatgpt": return .green
        default: return .gray
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 