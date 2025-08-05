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
    @State private var showingHotTrends = false
    @State private var selectedPlatformId: String?
    
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
        .onReceive(NotificationCenter.default.publisher(for: .showPlatformHotTrends)) { notification in
            if let platformId = notification.object as? String {
                selectedPlatformId = platformId
                showingHotTrends = true
            }
        }
        .sheet(isPresented: $showingHotTrends) {
            if let platformId = selectedPlatformId {
                HotTrendsView(platformId: platformId)
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
    @StateObject private var hotTrendsManager = HotTrendsManager.shared
    @State private var selectedCategory: AssistantCategory = .aiAssistants

    enum AssistantCategory: String, CaseIterable {
        case aiAssistants = "AI助手"
        case platformContacts = "平台热榜"
    }

    private let assistants = [
        ("deepseek", "DeepSeek", "brain.head.profile", Color.purple, "专业编程助手"),
        ("qwen", "通义千问", "cloud.fill", Color.cyan, "阿里云AI"),
        ("chatglm", "智谱清言", "lightbulb.fill", Color.yellow, "清华智谱AI"),
        ("moonshot", "Kimi", "moon.stars.fill", Color.orange, "月之暗面"),
        ("claude", "Claude", "c.circle.fill", Color.blue, "智能助手"),
        ("gpt", "ChatGPT", "g.circle.fill", Color.green, "对话AI")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 分类选择器
            Picker("选择类型", selection: $selectedCategory) {
                ForEach(AssistantCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.top)

            ScrollView {
                VStack(spacing: 20) {
                    Text(selectedCategory == .aiAssistants ? "选择AI助手开始聊天" : "选择平台查看热榜")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)

                    if selectedCategory == .aiAssistants {
                        // AI助手网格
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
                    } else {
                        // 平台热榜网格
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            ForEach(PlatformContact.allPlatforms) { platform in
                                PlatformContactCard(
                                    platform: platform,
                                    onTap: {
                                        handlePlatformSelection(platform)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 100)
                }
            }
        }
        .navigationTitle(selectedCategory.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // 初始化时获取热榜数据
            hotTrendsManager.refreshAllHotTrends()
        }
    }

    private func handlePlatformSelection(_ platform: PlatformContact) {
        // 处理平台选择，显示热榜内容
        print("🎯 选择平台: \(platform.name)")

        // 这里可以导航到热榜详情页面或者直接打开应用
        if let scheme = platform.deepLinkScheme,
           let url = URL(string: scheme) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                // 如果应用未安装，可以跳转到App Store或显示热榜内容
                showHotTrendsForPlatform(platform)
            }
        } else {
            showHotTrendsForPlatform(platform)
        }
    }

    private func showHotTrendsForPlatform(_ platform: PlatformContact) {
        // 显示平台热榜内容
        // 这里可以通过通知或导航到专门的热榜页面
        NotificationCenter.default.post(
            name: .showPlatformHotTrends,
            object: platform.id
        )
    }
}

// MARK: - 平台联系人卡片
struct PlatformContactCard: View {
    let platform: PlatformContact
    let onTap: () -> Void
    @StateObject private var hotTrendsManager = HotTrendsManager.shared

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // 平台图标
                Image(systemName: platform.icon)
                    .font(.system(size: 40))
                    .foregroundColor(platform.color)

                // 平台名称
                Text(platform.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                // 平台描述
                Text(platform.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                // 热榜状态指示器
                HStack(spacing: 4) {
                    Circle()
                        .fill(hotTrendsManager.isLoading[platform.id] == true ? Color.orange : Color.green)
                        .frame(width: 6, height: 6)

                    Text(hotTrendsManager.isLoading[platform.id] == true ? "更新中" : "已更新")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .overlay(
                // 热榜数量徽章
                Group {
                    if let trends = hotTrendsManager.getHotTrends(for: platform.id) {
                        Text("\(trends.items.count)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 8, y: -8)
                    }
                }
                , alignment: .topTrailing
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 通知扩展
extension Notification.Name {
    static let showPlatformHotTrends = Notification.Name("showPlatformHotTrends")
}
