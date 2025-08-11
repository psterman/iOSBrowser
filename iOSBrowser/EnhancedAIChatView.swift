//
//  EnhancedAIChatView.swift
//  iOSBrowser
//
//  增强的AI聊天视图 - 支持平台对话人单独对话
//

import SwiftUI

struct EnhancedAIChatView: View {
    @State private var searchQuery = ""
    @State private var isSearching = false
    @State private var selectedPlatform: String?
    @State private var showingChat = false
    @State private var currentChatPlatform: PlatformContact?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索输入区域
                searchInputSection
                
                // 聚合搜索按钮
                aggregatedSearchSection
                
                Spacer()
            }
            .navigationTitle("AI对话助手")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - 搜索输入区域
    private var searchInputSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                TextField("输入搜索关键词...", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        if let platform = selectedPlatform {
                            startPlatformChat(platformId: platform)
                        }
                    }
                
                Button(action: {
                    if let platform = selectedPlatform {
                        startPlatformChat(platformId: platform)
                    }
                }) {
                    if isSearching {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
                .frame(width: 44, height: 44)
                .background(searchQuery.isEmpty || selectedPlatform == nil ? Color.gray : Color.themeGreen)
                .cornerRadius(8)
                .disabled(searchQuery.isEmpty || selectedPlatform == nil || isSearching)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // 快速搜索建议
            if searchQuery.isEmpty {
                quickSearchSuggestions
            }
        }
    }
    
    // MARK: - 快速搜索建议
    private var quickSearchSuggestions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["热门话题", "科技资讯", "娱乐八卦", "美食推荐", "旅游攻略"], id: \.self) { suggestion in
                    Button(action: {
                        searchQuery = suggestion
                    }) {
                        Text(suggestion)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.themeLightGreen.opacity(0.2))
                            .foregroundColor(.themeGreen)
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - 聚合搜索区域
    private var aggregatedSearchSection: some View {
        VStack(spacing: 12) {
            Divider()
                .padding(.horizontal, 16)
            
            Button(action: {
                // 跳转到聚合搜索页面
                NotificationCenter.default.post(name: .showAggregatedSearch, object: searchQuery)
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.title2)
                        .foregroundColor(.themeGreen)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("聚合搜索")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("在所有平台同时搜索")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - 开始平台对话
    private func startPlatformChat(platformId: String) {
        guard let contact = platformContacts.first(where: { $0.id == platformId }) else { return }
        
        currentChatPlatform = contact
        showingChat = true
    }
}

// MARK: - 平台对话人卡片
struct PlatformContactCard: View {
    let contact: PlatformContact
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: contact.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : contact.color)
                
                Text(contact.name)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
                
                Text(contact.description)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? contact.color : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 平台对话视图
struct PlatformChatView: View {
    let platform: PlatformContact
    let initialQuery: String
    
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isLoading = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
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
                                Text("\(platform.name)正在思考...")
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
                    TextField("输入消息...", text: $inputText, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(1...4)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(inputText.isEmpty ? .gray : .blue)
                            .font(.title2)
                    }
                    .disabled(inputText.isEmpty || isLoading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .navigationTitle(platform.name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("返回") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            if !initialQuery.isEmpty {
                inputText = initialQuery
                sendMessage()
            } else {
                addWelcomeMessage()
            }
        }
    }
    
    private func addWelcomeMessage() {
        let welcomeMessage = ChatMessage(
            id: UUID(),
            content: "你好！我是\(platform.name)，可以帮你搜索\(platform.description)。请告诉我你想搜索什么内容？",
            isUser: false,
            timestamp: Date()
        )
        messages.append(welcomeMessage)
    }
    
    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(
            id: UUID(),
            content: inputText,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        let query = inputText
        inputText = ""
        isLoading = true
        
        // TODO: 这里应该调用真实的平台API
        // 目前显示占位符消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let response = generatePlatformResponse(query: query)
            let aiMessage = ChatMessage(
                id: UUID(),
                content: response,
                isUser: false,
                timestamp: Date()
            )
            messages.append(aiMessage)
            isLoading = false
        }
    }
    
    private func generatePlatformResponse(query: String) -> String {
        let prompt = platform.searchPrompt.replacingOccurrences(of: "{query}", with: query)
        
        // TODO: 这里应该调用真实的平台API
        // 目前显示占位符消息
        return "🔍 正在搜索"\(query)"的相关内容，请稍等..."
    }
}

// MARK: - 聊天消息行
struct ChatMessageRow: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    
                    Text(formatTime(message.timestamp))
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

// MARK: - 数据模型
struct PlatformContact: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let description: String
    let searchPrompt: String
    
    // 静态平台列表 - 仅保留AI对话相关平台
    static let allPlatforms: [PlatformContact] = [
        PlatformContact(
            id: "ai_chat",
            name: "AI对话",
            icon: "brain.head.profile",
            color: .blue,
            description: "智能AI助手对话",
            searchPrompt: "请帮我回答关于{query}的问题"
        ),
        PlatformContact(
            id: "ai_assistant",
            name: "AI助手",
            icon: "person.badge.plus",
            color: .green,
            description: "专业AI助手服务",
            searchPrompt: "我需要{query}方面的帮助"
        )
    ]
}

struct ChatMessage: Identifiable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
}

// MARK: - 通知扩展
extension Notification.Name {
    static let showAggregatedSearch = Notification.Name("showAggregatedSearch")
} 