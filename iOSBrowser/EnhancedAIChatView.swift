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
    
    // 平台对话人配置
    private let platformContacts: [PlatformContact] = [
        PlatformContact(
            id: "bilibili",
            name: "B站助手",
            icon: "tv.fill",
            color: Color(red: 0.2, green: 0.7, blue: 0.3),
            description: "B站视频搜索和推荐助手",
            searchPrompt: "请帮我搜索B站上关于{query}的视频内容，并提供相关推荐"
        ),
        PlatformContact(
            id: "toutiao",
            name: "头条助手",
            icon: "newspaper.fill",
            color: Color(red: 1.0, green: 0.2, blue: 0.2),
            description: "今日头条资讯搜索助手",
            searchPrompt: "请帮我搜索今日头条上关于{query}的新闻资讯"
        ),
        PlatformContact(
            id: "wechat_mp",
            name: "公众号助手",
            icon: "message.circle.fill",
            color: Color(red: 0.0, green: 0.8, blue: 0.2),
            description: "微信公众号文章搜索助手",
            searchPrompt: "请帮我搜索微信公众号中关于{query}的文章内容"
        ),
        PlatformContact(
            id: "ximalaya",
            name: "喜马拉雅助手",
            icon: "headphones",
            color: Color(red: 1.0, green: 0.4, blue: 0.0),
            description: "喜马拉雅音频搜索助手",
            searchPrompt: "请帮我搜索喜马拉雅上关于{query}的音频内容"
        ),
        PlatformContact(
            id: "xiaohongshu",
            name: "小红书助手",
            icon: "heart.fill",
            color: Color(red: 1.0, green: 0.2, blue: 0.4),
            description: "小红书内容搜索助手",
            searchPrompt: "请帮我搜索小红书上关于{query}的笔记和推荐"
        ),
        PlatformContact(
            id: "zhihu",
            name: "知乎助手",
            icon: "bubble.left.and.bubble.right.fill",
            color: Color(red: 0.0, green: 0.5, blue: 1.0),
            description: "知乎问答搜索助手",
            searchPrompt: "请帮我搜索知乎上关于{query}的问题和回答"
        ),
        PlatformContact(
            id: "douyin",
            name: "抖音助手",
            icon: "music.note",
            color: Color(red: 0.0, green: 0.0, blue: 0.0),
            description: "抖音视频搜索助手",
            searchPrompt: "请帮我搜索抖音上关于{query}的视频内容"
        ),
        PlatformContact(
            id: "weibo",
            name: "微博助手",
            icon: "at",
            color: Color(red: 1.0, green: 0.3, blue: 0.3),
            description: "微博话题搜索助手",
            searchPrompt: "请帮我搜索微博上关于{query}的话题和讨论"
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索输入区域
                searchInputSection
                
                // 平台对话人选择区域
                platformContactsSection
                
                // 聚合搜索按钮
                aggregatedSearchSection
                
                Spacer()
            }
            .navigationTitle("AI对话助手")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingChat) {
                if let platform = currentChatPlatform {
                    PlatformChatView(platform: platform, initialQuery: searchQuery)
                }
            }
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
    
    // MARK: - 平台对话人选择区域
    private var platformContactsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择对话平台")
                .font(.headline)
                .padding(.horizontal, 16)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(platformContacts) { contact in
                    PlatformContactCard(
                        contact: contact,
                        isSelected: selectedPlatform == contact.id
                    ) {
                        selectedPlatform = contact.id
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
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
        
        // 模拟AI回复
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
        
        // 模拟不同平台的回复风格
        switch platform.id {
        case "bilibili":
            return "🎬 在B站上搜索"\(query)"，我找到了以下相关内容：\n\n• 热门视频推荐\n• 相关UP主推荐\n• 播放量较高的内容\n\n建议你可以直接打开B站应用查看详细内容！"
        case "toutiao":
            return "📰 在今日头条上搜索"\(query)"，我发现了这些新闻资讯：\n\n• 最新相关新闻\n• 热门话题讨论\n• 专家观点分析\n\n建议你打开今日头条应用获取最新资讯！"
        case "wechat_mp":
            return "📱 在微信公众号中搜索"\(query)"，我找到了这些文章：\n\n• 深度分析文章\n• 行业专家观点\n• 实用指南内容\n\n建议你通过微信搜索功能查看详细内容！"
        case "ximalaya":
            return "🎧 在喜马拉雅上搜索"\(query)"，我发现了这些音频内容：\n\n• 相关播客节目\n• 有声书推荐\n• 音频课程\n\n建议你打开喜马拉雅应用收听相关内容！"
        case "xiaohongshu":
            return "💄 在小红书上搜索"\(query)"，我找到了这些笔记：\n\n• 用户分享经验\n• 产品推荐\n• 生活技巧\n\n建议你打开小红书应用查看更多内容！"
        case "zhihu":
            return "🤔 在知乎上搜索"\(query)"，我发现了这些问答：\n\n• 相关问题讨论\n• 专业回答\n• 用户经验分享\n\n建议你打开知乎应用查看详细讨论！"
        case "douyin":
            return "🎵 在抖音上搜索"\(query)"，我找到了这些视频：\n\n• 热门短视频\n• 相关话题挑战\n• 用户创作内容\n\n建议你打开抖音应用观看精彩视频！"
        case "weibo":
            return "📢 在微博上搜索"\(query)"，我发现了这些话题：\n\n• 热门话题讨论\n• 用户观点分享\n• 实时动态更新\n\n建议你打开微博应用参与讨论！"
        default:
            return "🔍 我正在搜索"\(query)"的相关内容，请稍等..."
        }
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