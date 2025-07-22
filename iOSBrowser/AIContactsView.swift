//
//  AIContactsView.swift
//  iOSBrowser
//
//  Created by LZH on 2025/7/19.
//

import SwiftUI
import UIKit

// 收藏消息数据结构
struct FavoriteMessage: Identifiable, Codable {
    let id: String
    let content: String
    let contactName: String
    let contactId: String
    let timestamp: Date
    let isFromUser: Bool

    init(from message: ChatMessage, contactName: String, contactId: String) {
        self.id = message.id
        self.content = message.content
        self.contactName = contactName
        self.contactId = contactId
        self.timestamp = message.timestamp
        self.isFromUser = message.isFromUser
    }
}

// 收藏管理器
class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()

    @Published var favorites: [FavoriteMessage] = []

    private init() {
        loadFavorites()
    }

    func addFavorite(_ message: ChatMessage, contactName: String, contactId: String) {
        let favorite = FavoriteMessage(from: message, contactName: contactName, contactId: contactId)
        favorites.append(favorite)
        saveFavorites()
    }

    func removeFavorite(_ messageId: String) {
        favorites.removeAll { $0.id == messageId }
        saveFavorites()
    }

    func isFavorite(_ messageId: String) -> Bool {
        return favorites.contains { $0.id == messageId }
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: "favoriteMessages")
        }
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: "favoriteMessages"),
           let savedFavorites = try? JSONDecoder().decode([FavoriteMessage].self, from: data) {
            favorites = savedFavorites
        }
    }
}

// API配置管理器
class APIConfigManager: ObservableObject {
    static let shared = APIConfigManager()

    @Published var apiKeys: [String: String] = [:]
    @Published var pinnedContacts: Set<String> = []
    @Published var hiddenContacts: Set<String> = []

    private init() {
        loadAPIKeys()
        loadContactSettings()
    }

    func setAPIKey(for serviceId: String, key: String) {
        apiKeys[serviceId] = key
        UserDefaults.standard.set(key, forKey: "api_key_\(serviceId)")
    }

    func getAPIKey(for serviceId: String) -> String? {
        return apiKeys[serviceId]
    }

    func hasAPIKey(for serviceId: String) -> Bool {
        guard let key = apiKeys[serviceId] else { return false }
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedKey.isEmpty && trimmedKey.count > 10 // API密钥通常比较长
    }

    func removeAPIKey(for serviceId: String) {
        apiKeys[serviceId] = nil
        UserDefaults.standard.removeObject(forKey: "api_key_\(serviceId)")
    }

    // 置顶管理
    func isPinned(_ contactId: String) -> Bool {
        return pinnedContacts.contains(contactId)
    }

    func setPinned(_ contactId: String, pinned: Bool) {
        if pinned {
            pinnedContacts.insert(contactId)
        } else {
            pinnedContacts.remove(contactId)
        }
        savePinnedContacts()
    }

    // 隐藏管理
    func isHidden(_ contactId: String) -> Bool {
        return hiddenContacts.contains(contactId)
    }

    func setHidden(_ contactId: String, hidden: Bool) {
        if hidden {
            hiddenContacts.insert(contactId)
        } else {
            hiddenContacts.remove(contactId)
        }
        saveHiddenContacts()
    }

    private func loadAPIKeys() {
        let allKeys = [
            // 国内AI服务商
            "deepseek", "qwen", "chatglm", "moonshot", "doubao", "wenxin", "spark", "baichuan", "minimax",
            // 硅基流动
            "siliconflow-qwen",
            // 国际AI服务商
            "openai", "claude", "gemini",
            // 高性能推理
            "groq", "together", "perplexity",
            // 专业工具
            "dalle", "stablediffusion", "elevenlabs", "whisper",
            // 本地部署
            "ollama"
        ]

        for key in allKeys {
            if let apiKey = UserDefaults.standard.string(forKey: "api_key_\(key)") {
                apiKeys[key] = apiKey
            }
        }
    }

    private func loadContactSettings() {
        if let pinnedData = UserDefaults.standard.data(forKey: "pinned_contacts"),
           let pinned = try? JSONDecoder().decode(Set<String>.self, from: pinnedData) {
            pinnedContacts = pinned
        }

        if let hiddenData = UserDefaults.standard.data(forKey: "hidden_contacts"),
           let hidden = try? JSONDecoder().decode(Set<String>.self, from: hiddenData) {
            hiddenContacts = hidden
        }
    }

    private func savePinnedContacts() {
        if let data = try? JSONEncoder().encode(pinnedContacts) {
            UserDefaults.standard.set(data, forKey: "pinned_contacts")
        }
    }

    private func saveHiddenContacts() {
        if let data = try? JSONEncoder().encode(hiddenContacts) {
            UserDefaults.standard.set(data, forKey: "hidden_contacts")
        }
    }
}

struct AIContact {
    let id: String
    let name: String
    let description: String
    let model: String
    let avatar: String
    let isOnline: Bool
    let apiEndpoint: String?
    let requiresApiKey: Bool
    let supportedFeatures: [AIFeature]
    let color: Color
}

enum AIFeature: String, CaseIterable {
    case textGeneration = "文本生成"
    case imageGeneration = "图像生成"
    case videoGeneration = "视频生成"
    case audioGeneration = "语音合成"
    case codeGeneration = "代码生成"
    case translation = "翻译"
    case summarization = "摘要"
    case search = "搜索"
}

struct ChatMessage: Identifiable, Codable {
    let id: String
    var content: String // 改为var以支持编辑
    let isFromUser: Bool
    let timestamp: Date
    var status: MessageStatus
    var actions: [MessageAction]
    var isHistorical: Bool = false // 标识是否为历史消息 = []
}

enum MessageStatus: Codable {
    case sending
    case sent
    case delivered
    case failed
}

enum MessageAction: CaseIterable, Codable {
    case forward
    case share
    case copy
    case edit
    case delete
    case favorite

    var icon: String {
        switch self {
        case .forward: return "arrowshape.turn.up.right"
        case .share: return "square.and.arrow.up"
        case .copy: return "doc.on.doc"
        case .edit: return "pencil"
        case .delete: return "trash"
        case .favorite: return "heart"
        }
    }

    var title: String {
        switch self {
        case .forward: return "转发"
        case .share: return "分享"
        case .copy: return "复制"
        case .edit: return "编辑"
        case .delete: return "删除"
        case .favorite: return "收藏"
        }
    }
}

struct AIContactsView: View {
    @StateObject private var apiManager = APIConfigManager.shared
    @State private var contacts: [AIContact] = [
        // 🇨🇳 国内主流AI服务商（优先显示，都有可购买的API）
        AIContact(id: "deepseek", name: "DeepSeek", description: "专业的AI编程助手，代码能力强", model: "deepseek-chat", avatar: "brain.head.profile", isOnline: true, apiEndpoint: "https://api.deepseek.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .purple),
        AIContact(id: "qwen", name: "通义千问", description: "阿里云大语言模型，多模态能力", model: "qwen-max", avatar: "cloud.fill", isOnline: true, apiEndpoint: "https://dashscope.aliyuncs.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .translation, .summarization], color: .cyan),
        AIContact(id: "chatglm", name: "智谱清言", description: "清华智谱AI，GLM-4模型", model: "glm-4", avatar: "lightbulb.fill", isOnline: true, apiEndpoint: "https://open.bigmodel.cn", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .yellow),
        AIContact(id: "moonshot", name: "Kimi", description: "月之暗面，超长上下文AI", model: "moonshot-v1-128k", avatar: "moon.stars.fill", isOnline: true, apiEndpoint: "https://api.moonshot.cn", requiresApiKey: true, supportedFeatures: [.textGeneration, .summarization], color: .orange),
        AIContact(id: "doubao", name: "豆包", description: "字节跳动AI助手，多场景应用", model: "doubao-pro-128k", avatar: "leaf.fill", isOnline: true, apiEndpoint: "https://ark.cn-beijing.volces.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .translation], color: .green),
        AIContact(id: "wenxin", name: "文心一言", description: "百度ERNIE大模型", model: "ernie-4.0-turbo", avatar: "doc.text.fill", isOnline: true, apiEndpoint: "https://aip.baidubce.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .translation, .summarization], color: .red),

        // 🌐 硅基流动提供的免费模型
        AIContact(id: "siliconflow-qwen", name: "千问-硅基流动", description: "硅基流动提供的通义千问模型", model: "Qwen/Qwen2.5-72B-Instruct", avatar: "cloud.fill", isOnline: true, apiEndpoint: "https://api.siliconflow.cn", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .cyan),

        // 🌍 国际主流AI服务商
        AIContact(id: "openai", name: "ChatGPT", description: "OpenAI的GPT-4o模型", model: "gpt-4o", avatar: "bubble.left.and.bubble.right", isOnline: true, apiEndpoint: "https://api.openai.com/v1", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration, .translation, .summarization], color: .green),
        AIContact(id: "claude", name: "Claude", description: "Anthropic的Claude-3.5-Sonnet", model: "claude-3-5-sonnet", avatar: "sparkles", isOnline: true, apiEndpoint: "https://api.anthropic.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration, .translation, .summarization], color: .indigo),
        AIContact(id: "gemini", name: "Google Gemini", description: "Google的多模态AI助手", model: "gemini-1.5-pro", avatar: "diamond.fill", isOnline: true, apiEndpoint: "https://generativelanguage.googleapis.com/v1beta", requiresApiKey: true, supportedFeatures: [.textGeneration, .imageGeneration, .codeGeneration], color: .blue),

        // 🤖 专业AI助手（参考Poe）
        AIContact(id: "gpt4-turbo", name: "GPT-4 Turbo", description: "OpenAI最新的GPT-4 Turbo模型", model: "gpt-4-turbo", avatar: "bolt.circle.fill", isOnline: true, apiEndpoint: "https://api.openai.com/v1", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration, .translation, .summarization], color: .purple),
        AIContact(id: "claude-instant", name: "Claude Instant", description: "Anthropic的快速响应模型", model: "claude-instant-1.2", avatar: "timer", isOnline: true, apiEndpoint: "https://api.anthropic.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .mint),
        AIContact(id: "llama-70b", name: "Llama 2 70B", description: "Meta的开源大语言模型", model: "llama-2-70b-chat", avatar: "llama.fill", isOnline: true, apiEndpoint: "https://api.together.xyz", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .orange),
        AIContact(id: "codellama", name: "Code Llama", description: "专门用于代码生成的Llama模型", model: "codellama-34b-instruct", avatar: "chevron.left.forwardslash.chevron.right", isOnline: true, apiEndpoint: "https://api.together.xyz", requiresApiKey: true, supportedFeatures: [.codeGeneration], color: .teal),
        AIContact(id: "mistral-7b", name: "Mistral 7B", description: "Mistral AI的高效模型", model: "mistral-7b-instruct", avatar: "wind", isOnline: true, apiEndpoint: "https://api.together.xyz", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .indigo),

        // 🔧 本地部署（免费选项）
        AIContact(id: "ollama", name: "Ollama", description: "本地运行开源模型", model: "llama3.1", avatar: "server.rack", isOnline: false, apiEndpoint: "http://localhost:11434", requiresApiKey: false, supportedFeatures: [.textGeneration, .codeGeneration], color: .gray)
    ]

    @State private var searchText = ""
    @State private var isRefreshing = false
    @State private var showingAPIConfig = false
    @State private var selectedContactForAPI: AIContact?
    @State private var showingAPIConfigForContact = false
    @State private var showDetailedInfo = false

    var filteredContacts: [AIContact] {
        let baseContacts = searchText.isEmpty ? contacts : contacts.filter { contact in
            contact.name.localizedCaseInsensitiveContains(searchText) ||
            contact.description.localizedCaseInsensitiveContains(searchText)
        }

        // 过滤掉隐藏的联系人
        let visibleContacts = baseContacts.filter { !apiManager.isHidden($0.id) }

        // 按API配置状态和置顶状态排序，但保持原有顺序
        return visibleContacts.sorted { contact1, contact2 in
            let hasAPI1 = apiManager.hasAPIKey(for: contact1.id)
            let hasAPI2 = apiManager.hasAPIKey(for: contact2.id)
            let isPinned1 = apiManager.isPinned(contact1.id)
            let isPinned2 = apiManager.isPinned(contact2.id)

            // 置顶的在最前面
            if isPinned1 != isPinned2 {
                return isPinned1
            }

            // 然后是有API配置的
            if hasAPI1 != hasAPI2 {
                return hasAPI1
            }

            // 最后保持原有的数组顺序（不按名称排序）
            guard let index1 = contacts.firstIndex(where: { $0.id == contact1.id }),
                  let index2 = contacts.firstIndex(where: { $0.id == contact2.id }) else {
                return false
            }
            return index1 < index2
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)

                // 联系人列表
                List(filteredContacts, id: \.id) { contact in
                    if canEnterChat(contact) {
                        NavigationLink(destination: ChatView(contact: contact)) {
                            ContactRowContent(
                                contact: contact,
                                hasAPIKey: apiManager.hasAPIKey(for: contact.id),
                                isPinned: apiManager.isPinned(contact.id),
                                showDetailedInfo: showDetailedInfo
                            )
                        }
                        .contextMenu {
                            Button(action: {
                                apiManager.setPinned(contact.id, pinned: !apiManager.isPinned(contact.id))
                            }) {
                                Label(apiManager.isPinned(contact.id) ? "取消置顶" : "置顶", systemImage: apiManager.isPinned(contact.id) ? "pin.slash" : "pin")
                            }

                            Button(action: {
                                apiManager.setHidden(contact.id, hidden: true)
                            }) {
                                Label("隐藏", systemImage: "eye.slash")
                            }

                            Button(action: {
                                selectedContactForAPI = contact
                                showingAPIConfigForContact = true
                            }) {
                                Label("配置API", systemImage: "key")
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    } else {
                        Button(action: {
                            showAPIConfigAlert(for: contact)
                        }) {
                            ContactRowContent(
                                contact: contact,
                                hasAPIKey: apiManager.hasAPIKey(for: contact.id),
                                isPinned: apiManager.isPinned(contact.id),
                                showDetailedInfo: showDetailedInfo
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(action: {
                                selectedContactForAPI = contact
                                showingAPIConfigForContact = true
                            }) {
                                Label("配置API", systemImage: "key")
                            }

                            Button(action: {
                                apiManager.setPinned(contact.id, pinned: !apiManager.isPinned(contact.id))
                            }) {
                                Label(apiManager.isPinned(contact.id) ? "取消置顶" : "置顶", systemImage: apiManager.isPinned(contact.id) ? "pin.slash" : "pin")
                            }

                            Button(action: {
                                apiManager.setHidden(contact.id, hidden: true)
                            }) {
                                Label("隐藏", systemImage: "eye.slash")
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    await refreshContacts()
                }
            }
            .navigationTitle("AI联系人")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button(showDetailedInfo ? "简洁模式" : "详细信息") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showDetailedInfo.toggle()
                    }
                },
                trailing: HStack(spacing: 16) {
                    NavigationLink(destination: FavoritesView()) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }

                    Button(action: {
                        showingAPIConfig = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.blue)
                    }
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle()) // 确保在iPad上也使用推入式导航
        .sheet(isPresented: $showingAPIConfig) {
            APIConfigView()
        }
        .sheet(isPresented: $showingAPIConfigForContact) {
            if let contact = selectedContactForAPI {
                SingleContactAPIConfigView(contact: contact)
            }
        }
    }

    private func refreshContacts() async {
        isRefreshing = true
        // 模拟网络请求
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // 这里可以添加刷新联系人状态的逻辑
        withAnimation(.spring()) {
            // 更新在线状态等
            for i in contacts.indices {
                contacts[i] = AIContact(
                    id: contacts[i].id,
                    name: contacts[i].name,
                    description: contacts[i].description,
                    model: contacts[i].model,
                    avatar: contacts[i].avatar,
                    isOnline: Bool.random(), // 随机更新在线状态作为演示
                    apiEndpoint: contacts[i].apiEndpoint,
                    requiresApiKey: contacts[i].requiresApiKey,
                    supportedFeatures: contacts[i].supportedFeatures,
                    color: contacts[i].color
                )
            }
        }

        isRefreshing = false
    }

    private func canEnterChat(_ contact: AIContact) -> Bool {
        return !contact.requiresApiKey || apiManager.hasAPIKey(for: contact.id)
    }

    private func showAPIConfigAlert(for contact: AIContact) {
        let alert = UIAlertController(
            title: "需要配置API密钥",
            message: "使用\(contact.name)需要先配置API密钥。是否前往设置？",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "去设置", style: .default) { _ in
            selectedContactForAPI = contact
            showingAPIConfigForContact = true
        })

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("搜索AI助手", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.vertical, 8)
    }
}

// 新的联系人行视图，支持长按菜单
struct ContactRowView: View {
    let contact: AIContact
    let hasAPIKey: Bool
    let isPinned: Bool
    let showDetailedInfo: Bool
    let onTap: () -> Void
    let onPin: () -> Void
    let onHide: () -> Void
    let onConfigAPI: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            ContactRowContent(contact: contact, hasAPIKey: hasAPIKey, isPinned: isPinned, showDetailedInfo: showDetailedInfo)
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(.systemBackground))
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .contextMenu {
            Button(action: onConfigAPI) {
                Label("配置API", systemImage: "key.fill")
            }

            Button(action: onPin) {
                Label(isPinned ? "取消置顶" : "置顶", systemImage: isPinned ? "pin.slash.fill" : "pin.fill")
            }

            Button(action: onHide) {
                Label("隐藏", systemImage: "eye.slash.fill")
            }
        }
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: 50) {
            // 长按开始
        } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
    }
}

struct ContactRowContent: View {
    let contact: AIContact
    let hasAPIKey: Bool
    let isPinned: Bool
    let showDetailedInfo: Bool

    var body: some View {
        HStack(spacing: 12) {
            // 头像
            ZStack {
                let isOnline = contact.requiresApiKey ? hasAPIKey : contact.isOnline
                Circle()
                    .fill(isOnline ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: contact.avatar)
                    .font(.title2)
                    .foregroundColor(isOnline ? .green : .gray)
            }

            // 信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    // 置顶图标
                    if isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }

                    Text(contact.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    // 在线状态
                    let isOnline = contact.requiresApiKey ? hasAPIKey : contact.isOnline
                    Circle()
                        .fill(isOnline ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(isOnline ? 1.0 : 0.8)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isOnline)
                }

                if showDetailedInfo {
                    // 详细信息模式
                    Text(contact.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    HStack {
                        Text("模型: \(contact.model)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        if contact.requiresApiKey {
                            Image(systemName: "key.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }

                    // 支持的功能标签
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(contact.supportedFeatures.prefix(3), id: \.self) { feature in
                                Text(feature.rawValue)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }

                            if contact.supportedFeatures.count > 3 {
                                Text("+\(contact.supportedFeatures.count - 3)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } else {
                    // 简洁模式 - 显示最后一条消息
                    Text(getLastMessage(for: contact.id))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    HStack {
                        Text(getLastMessageTime(for: contact.id))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        if contact.requiresApiKey && !hasAPIKey {
                            Text("需要配置API")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func getLastMessage(for contactId: String) -> String {
        // 这里应该从聊天记录中获取最后一条消息
        // 目前返回默认文本
        let defaultMessages = [
            "deepseek": "准备好为您编写代码了",
            "qwen": "我是通义千问，有什么可以帮您的？",
            "chatglm": "智谱清言为您服务",
            "moonshot": "Kimi可以处理长文本对话",
            "doubao": "豆包助手随时待命"
        ]
        return defaultMessages[contactId] ?? "点击开始对话"
    }

    private func getLastMessageTime(for contactId: String) -> String {
        // 这里应该从聊天记录中获取最后消息时间
        // 目前返回默认时间
        return "刚刚"
    }
}

// MARK: - ChatViewModel
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var favoriteMessages: Set<String> = []
    @Published var filteredMessages: [ChatMessage] = []

    private var webViewModel: WebViewModel?
    private var currentContactId: String = ""

    func configureForContact(_ contact: AIContact) {
        currentContactId = contact.id
        webViewModel = WebViewModel()
        loadMessages(for: contact.id)
        loadFavorites()
        updateFilteredMessages()
    }

    func addMessage(_ message: ChatMessage) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            messages.append(message)
            saveMessages()
            updateFilteredMessages()
        }
    }

    func clearMessages() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            messages.removeAll()
            saveMessages()
            updateFilteredMessages()
        }
    }

    // 加载历史消息
    private func loadMessages(for contactId: String) {
        if let data = UserDefaults.standard.data(forKey: "messages_\(contactId)"),
           let savedMessages = try? JSONDecoder().decode([ChatMessage].self, from: data) {
            // 将历史消息标记为静态显示
            messages = savedMessages.map { message in
                var historicalMessage = message
                historicalMessage.isHistorical = true
                return historicalMessage
            }
        } else {
            messages = []
        }
    }

    // 保存消息
    private func saveMessages() {
        if let data = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(data, forKey: "messages_\(currentContactId)")
        }
    }

    // 加载收藏消息
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: "favorites_\(currentContactId)"),
           let savedFavorites = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteMessages = savedFavorites
        }
    }

    // 保存收藏消息
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteMessages) {
            UserDefaults.standard.set(data, forKey: "favorites_\(currentContactId)")
        }
    }

    // 切换收藏状态
    func toggleFavorite(messageId: String) {
        if favoriteMessages.contains(messageId) {
            favoriteMessages.remove(messageId)
        } else {
            favoriteMessages.insert(messageId)
        }
        saveFavorites()
    }

    // 搜索消息
    func searchMessages() {
        updateFilteredMessages()
    }

    // 更新过滤后的消息
    private func updateFilteredMessages() {
        if searchText.isEmpty {
            filteredMessages = messages
        } else {
            filteredMessages = messages.filter { message in
                message.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    // 删除消息
    func deleteMessage(messageId: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            messages.removeAll { $0.id == messageId }
            saveMessages()
            updateFilteredMessages()
        }
    }

    // 切换收藏状态
    func toggleMessageFavorite(messageId: String) {
        if favoriteMessages.contains(messageId) {
            favoriteMessages.remove(messageId)
        } else {
            favoriteMessages.insert(messageId)
        }
        saveFavorites()
    }

    // 编辑消息
    func editMessage(messageId: String, newContent: String) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            var editedMessage = messages[index]
            editedMessage.content = newContent
            messages[index] = editedMessage
            saveMessages()
            updateFilteredMessages()
        }
    }

    // 获取消息内容用于编辑
    func getMessageContent(messageId: String) -> String {
        return messages.first { $0.id == messageId }?.content ?? ""
    }

    func sendToAI(message: String, contact: AIContact) {
        isLoading = true

        // 检查是否有API密钥
        guard let apiKey = APIConfigManager.shared.getAPIKey(for: contact.id), !apiKey.isEmpty else {
            // 没有API密钥，返回提示信息
            DispatchQueue.main.async {
                let errorResponse = ChatMessage(
                    id: UUID().uuidString,
                    content: "请先在设置中配置\(contact.name)的API密钥。",
                    isFromUser: false,
                    timestamp: Date(),
                    status: .delivered,
                    actions: []
                )

                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    self.messages.append(errorResponse)
                    self.isLoading = false
                }
            }
            return
        }

        // 调用实际的AI API
        callAIAPI(message: message, contact: contact, apiKey: apiKey)
    }

    private func callAIAPI(message: String, contact: AIContact, apiKey: String) {
        guard let apiEndpoint = contact.apiEndpoint, let url = URL(string: "\(apiEndpoint)/chat/completions") else {
            handleAPIError("无效的API端点")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
            "model": contact.model,
            "messages": [
                [
                    "role": "user",
                    "content": message
                ]
            ],
            "max_tokens": 2000,
            "temperature": 0.7
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            handleAPIError("请求格式错误")
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.handleAPIError("网络错误: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    self?.handleAPIError("没有收到响应数据")
                    return
                }

                self?.parseAPIResponse(data: data)
            }
        }.resume()
    }

    private func parseAPIResponse(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {

                let aiResponse = ChatMessage(
                    id: UUID().uuidString,
                    content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                    isFromUser: false,
                    timestamp: Date(),
                    status: .delivered,
                    actions: MessageAction.allCases
                )

                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    self.messages.append(aiResponse)
                    self.saveMessages()
                    self.updateFilteredMessages()
                }
            } else {
                handleAPIError("响应格式错误")
            }
        } catch {
            handleAPIError("解析响应失败: \(error.localizedDescription)")
        }
    }

    private func handleAPIError(_ errorMessage: String) {
        let errorResponse = ChatMessage(
            id: UUID().uuidString,
            content: "❌ \(errorMessage)\n\n请检查API密钥是否正确，或稍后重试。",
            isFromUser: false,
            timestamp: Date(),
            status: .failed,
            actions: []
        )

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            self.messages.append(errorResponse)
            self.saveMessages()
            self.updateFilteredMessages()
        }
    }
}

struct ChatView: View {
    let contact: AIContact
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var messageText = ""
    @State private var isTyping = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var showingMoreOptions = false
    @State private var showingSearchView = false
    @State private var editingMessageId: String? = nil
    @State private var editingText: String = ""
    @State private var showingAIEditPopup = false
    @State private var aiEditingContent: String = ""

    var body: some View {
        VStack(spacing: 0) {

            // 聊天消息列表
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // 欢迎消息
                        if chatViewModel.messages.isEmpty {
                            WelcomeMessage(contact: contact)
                                .id("welcome")
                        }

                        ForEach(chatViewModel.messages) { message in
                            MessageBubble(
                                message: message,
                                contact: contact,
                                onDelete: { messageId in
                                    chatViewModel.deleteMessage(messageId: messageId)
                                },
                                onEdit: { messageId in
                                    startEditingMessage(messageId)
                                }
                            )
                            .id(message.id)
                        }

                        if chatViewModel.isLoading {
                            TypingIndicator()
                                .id("typing")
                        }
                    }
                    .padding()
                    .padding(.bottom, keyboardHeight > 0 ? 0 : 20)
                }
                .onChange(of: chatViewModel.messages.count) { _ in
                    withAnimation(.easeOut(duration: 0.3)) {
                        if let lastMessage = chatViewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: chatViewModel.isLoading) { isLoading in
                    if isLoading {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo("typing", anchor: .bottom)
                        }
                    }
                }
                .onChange(of: keyboardHeight) { height in
                    if height > 0 {
                        withAnimation(.easeOut(duration: 0.3)) {
                            if let lastMessage = chatViewModel.messages.last {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            } else {
                                proxy.scrollTo("welcome", anchor: .bottom)
                            }
                        }
                    }
                }
            }

            // 输入框
            ChatInputView(
                messageText: $messageText,
                isTyping: $isTyping,
                onSend: {
                    sendMessage()
                }
            )
        }

        .onAppear {
            chatViewModel.configureForContact(contact)
            setupKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
        .actionSheet(isPresented: $showingMoreOptions) {
            ActionSheet(
                title: Text("更多选项"),
                buttons: [
                    .default(Text("清空聊天记录")) {
                        chatViewModel.clearMessages()
                    },
                    .default(Text("导出聊天记录")) {
                        // 导出功能
                    },
                    .cancel(Text("取消"))
                ]
            )
        }
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.bottom)
        .gesture(
            DragGesture()
                .onEnded { value in
                    // 支持右滑返回手势
                    if value.translation.width > 100 && abs(value.translation.height) < 50 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
        .sheet(isPresented: $showingSearchView) {
            ChatSearchView(chatViewModel: chatViewModel)
        }
        .sheet(isPresented: $showingAIEditPopup) {
            AIEditPopupView(content: $aiEditingContent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationTitle(contact.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: HStack(spacing: 16) {
                Button(action: {
                    showingSearchView = true
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundColor(.blue)
                }

                Button(action: {
                    showingMoreOptions = true
                }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        )
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = ChatMessage(
            id: UUID().uuidString,
            content: messageText,
            isFromUser: true,
            timestamp: Date(),
            status: .sent,
            actions: []
        )

        chatViewModel.addMessage(userMessage)

        let messageToSend = messageText
        messageText = ""
        isTyping = false

        // 发送到AI
        chatViewModel.sendToAI(message: messageToSend, contact: contact)
    }

    private func startEditingMessage(_ messageId: String) {
        if let message = chatViewModel.messages.first(where: { $0.id == messageId }) {
            if message.isFromUser {
                // 用户消息：直接编辑
                editingMessageId = messageId
                editingText = message.content
                messageText = editingText
            } else {
                // AI消息：弹窗编辑
                aiEditingContent = message.content
                showingAIEditPopup = true
            }
        }
    }

    private func saveEditedMessage() {
        guard let messageId = editingMessageId else { return }

        let newContent = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !newContent.isEmpty {
            chatViewModel.editMessage(messageId: messageId, newContent: newContent)
        }

        editingMessageId = nil
        editingText = ""
        messageText = ""
    }

    private func cancelEditing() {
        editingMessageId = nil
        editingText = ""
        messageText = ""
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeOut(duration: 0.3)) {
                    keyboardHeight = keyboardFrame.height
                }
            }
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation(.easeOut(duration: 0.3)) {
                keyboardHeight = 0
            }
        }
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

struct WelcomeMessage: View {
    let contact: AIContact

    var body: some View {
        VStack(spacing: 16) {
            // AI头像
            Image(systemName: contact.avatar)
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .frame(width: 100, height: 100)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())

            VStack(spacing: 8) {
                Text("你好！我是 \(contact.name)")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(contact.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Text("有什么我可以帮助你的吗？")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - UI Components
struct MessageBubble: View {
    let message: ChatMessage
    let contact: AIContact
    @State private var showActions = false
    let onDelete: (String) -> Void
    let onEdit: (String) -> Void

    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                UserMessageBubble(message: message, onEdit: onEdit)
            } else {
                AIMessageBubble(
                    message: message,
                    contact: contact,
                    showActions: $showActions,
                    onDelete: onDelete,
                    onEdit: onEdit
                )
                Spacer()
            }
        }
    }
}

struct UserMessageBubble: View {
    let message: ChatMessage
    let onEdit: (String) -> Void
    @State private var showActions = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(message.content)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(18)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                .onTapGesture {
                    withAnimation(.spring()) {
                        showActions.toggle()
                    }
                }

            HStack(spacing: 4) {
                Text(timeString(from: message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)

                StatusIcon(status: message.status)
            }

            // 用户消息操作按钮
            if showActions {
                HStack(spacing: 12) {
                    Button(action: {
                        UIPasteboard.general.string = message.content
                        showActions = false
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 16))
                            Text("复制")
                                .font(.caption2)
                        }
                        .foregroundColor(.blue)
                    }

                    Button(action: {
                        onEdit(message.id)
                        showActions = false
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.system(size: 16))
                            Text("编辑")
                                .font(.caption2)
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AIMessageBubble: View {
    let message: ChatMessage
    let contact: AIContact
    @Binding var showActions: Bool
    @State private var animatedContent = ""
    @State private var currentIndex = 0
    let onDelete: (String) -> Void
    let onEdit: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                // AI头像
                Image(systemName: contact.avatar)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 32, height: 32)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // 消息内容（支持Markdown和文本选择）
                    Text(animatedContent)
                        .textSelection(.enabled)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(18)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                        .onAppear {
                            if message.isHistorical {
                                // 历史消息直接显示完整内容
                                animatedContent = message.content
                            } else {
                                // 新消息播放打字动画
                                startTypingAnimation()
                            }
                        }

                    Text(timeString(from: message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // 操作按钮
            if !message.actions.isEmpty {
                MessageActionsView(
                    message: message,
                    contact: contact,
                    showActions: $showActions,
                    onDelete: onDelete,
                    onEdit: onEdit
                )
            }
        }
    }

    private func startTypingAnimation() {
        animatedContent = ""
        currentIndex = 0

        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if currentIndex < message.content.count {
                let index = message.content.index(message.content.startIndex, offsetBy: currentIndex)
                animatedContent += String(message.content[index])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct MarkdownText: View {
    let content: String

    init(_ content: String) {
        self.content = content
    }

    var body: some View {
        // 简单的Markdown渲染（这里可以使用更完整的Markdown库）
        Text(parseMarkdown(content))
            .textSelection(.enabled)
    }

    private func parseMarkdown(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)

        // 简单的粗体处理
        let boldPattern = "\\*\\*(.*?)\\*\\*"
        if let regex = try? NSRegularExpression(pattern: boldPattern) {
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            for match in matches.reversed() {
                if let range = Range(match.range, in: text) {
                    let boldText = String(text[range])
                    let cleanText = boldText.replacingOccurrences(of: "**", with: "")
                    if let attrRange = Range(match.range, in: attributedString) {
                        attributedString.replaceSubrange(attrRange, with: AttributedString(cleanText))
                        if let newRange = attributedString.range(of: cleanText) {
                            attributedString[newRange].font = .body.bold()
                        }
                    }
                }
            }
        }

        return attributedString
    }
}

struct MessageActionsView: View {
    let message: ChatMessage
    let contact: AIContact
    @Binding var showActions: Bool
    @State private var selectedAction: MessageAction?
    let onDelete: (String) -> Void
    let onEdit: (String) -> Void
    @StateObject private var favoritesManager = FavoritesManager.shared

    var body: some View {
        VStack(spacing: 8) {
            // 主要操作按钮（始终显示）
            HStack(spacing: 12) {
                // 复制按钮
                ActionButton(action: .copy) {
                    copyMessage()
                }

                // 转发按钮
                ActionButton(action: .forward) {
                    handleAction(.forward)
                }

                // 收藏按钮
                Button(action: {
                    toggleFavorite()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: favoritesManager.isFavorite(message.id) ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundColor(favoritesManager.isFavorite(message.id) ? .red : .blue)

                        Text(favoritesManager.isFavorite(message.id) ? "已收藏" : "收藏")
                            .font(.caption2)
                            .foregroundColor(favoritesManager.isFavorite(message.id) ? .red : .blue)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())

                // 编辑按钮（AI回复）
                if !message.isFromUser {
                    ActionButton(action: .edit) {
                        onEdit(message.id)
                    }
                }

                Spacer()

                // 更多操作按钮（显示删除等）
                Button(action: {
                    withAnimation(.spring()) {
                        showActions.toggle()
                    }
                }) {
                    Image(systemName: showActions ? "chevron.up" : "ellipsis")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
            .padding(.leading, 40) // 对齐AI头像

            // 扩展操作按钮（点击更多后显示）
            if showActions {
                HStack(spacing: 8) {
                    // 删除按钮
                    ActionButton(action: .delete) {
                        showDeleteConfirmation()
                    }

                    // 分享按钮
                    ActionButton(action: .share) {
                        handleAction(.share)
                    }

                    Spacer()
                }
                .padding(.leading, 40)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }

    private func handleAction(_ action: MessageAction) {
        selectedAction = action

        withAnimation(.easeInOut(duration: 0.2)) {
            // 这里添加具体的操作逻辑
            switch action {
            case .forward:
                forwardMessage()
            case .share:
                shareMessage()
            case .copy:
                copyMessage()
            case .edit:
                if message.isFromUser {
                    onEdit(message.id)
                }
            case .delete:
                showDeleteConfirmation()
            case .favorite:
                toggleFavorite()
            }
        }
    }

    private func copyMessage() {
        UIPasteboard.general.string = message.content
        showToast("已复制到剪贴板")
    }

    private func shareMessage() {
        let activityVC = UIActivityViewController(
            activityItems: [message.content],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(activityVC, animated: true)
        }
    }

    private func forwardMessage() {
        // 转发消息到其他联系人
        shareMessage() // 暂时使用分享功能
    }

    private func editMessage() {
        // 编辑消息（对于用户消息）
        if message.isFromUser {
            // 可以实现编辑功能
            showToast("编辑功能开发中")
        }
    }

    private func showDeleteConfirmation() {
        showAlert(title: "删除消息", message: "确定要删除这条消息吗？") {
            onDelete(message.id)
        }
    }

    private func toggleFavorite() {
        if favoritesManager.isFavorite(message.id) {
            favoritesManager.removeFavorite(message.id)
            showToast("已取消收藏")
        } else {
            favoritesManager.addFavorite(message, contactName: contact.name, contactId: contact.id)
            showToast("已添加到收藏")
        }
    }


    private func showToast(_ message: String) {
        // 简单的提示实现
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                alert.dismiss(animated: true)
            }
        }
    }

    private func showAlert(title: String, message: String, action: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .destructive) { _ in action() })

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(alert, animated: true)
        }
    }
}

struct ActionButton: View {
    let action: MessageAction
    let onTap: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                onTap()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: action.icon)
                    .font(.system(size: 16))
                    .foregroundColor(.blue)

                Text(action.title)
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatusIcon: View {
    let status: MessageStatus

    var body: some View {
        Group {
            switch status {
            case .sending:
                Image(systemName: "clock")
                    .foregroundColor(.orange)
            case .sent:
                Image(systemName: "checkmark")
                    .foregroundColor(.gray)
            case .delivered:
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.blue)
            case .failed:
                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(.red)
            }
        }
        .font(.caption2)
    }
}

struct TypingIndicator: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "brain.head.profile")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())

            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animating ? 1.0 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animating
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(18)

            Spacer()
        }
        .onAppear {
            animating = true
        }
    }
}

struct ChatInputView: View {
    @Binding var messageText: String
    @Binding var isTyping: Bool
    let onSend: () -> Void
    @State private var isSending = false

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 12) {
                // 输入框
                HStack {
                    TextField("输入消息...", text: $messageText, axis: .vertical)
                        .textFieldStyle(PlainTextFieldStyle())
                        .lineLimit(1...5)
                        .onSubmit {
                            if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                onSend()
                            }
                        }
                        .onChange(of: messageText) { _ in
                            isTyping = !messageText.isEmpty
                        }

                    if !messageText.isEmpty {
                        Button(action: {
                            messageText = ""
                            isTyping = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(20)

                // 发送按钮
                Button(action: {
                    withAnimation(.spring()) {
                        isSending = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onSend()
                        withAnimation(.spring()) {
                            isSending = false
                        }
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.gray
                            : Color.blue
                        )
                        .clipShape(Circle())
                        .scaleEffect(isSending ? 0.8 : 1.0)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }
}

// API配置界面
struct APIConfigView: View {
    @StateObject private var apiManager = APIConfigManager.shared
    @Environment(\.presentationMode) var presentationMode

    let services = [
        // 国内AI服务商（优先显示）
        ("deepseek", "DeepSeek"),
        ("qwen", "通义千问"),
        ("chatglm", "智谱清言"),
        ("moonshot", "Kimi"),
        ("doubao", "豆包"),
        ("wenxin", "文心一言"),
        ("spark", "讯飞星火"),
        ("baichuan", "百川智能"),
        ("minimax", "MiniMax"),
        // 硅基流动
        ("siliconflow-qwen", "千问-硅基流动"),
        // 国际AI服务商
        ("openai", "OpenAI ChatGPT"),
        ("claude", "Anthropic Claude"),
        ("gemini", "Google Gemini"),
        // 高性能推理
        ("groq", "Groq"),
        ("together", "Together AI"),
        ("perplexity", "Perplexity"),
        // 专业工具
        ("dalle", "DALL-E"),
        ("stablediffusion", "Stable Diffusion"),
        ("elevenlabs", "ElevenLabs"),
        ("whisper", "Whisper")
    ]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("AI服务API配置")) {
                    ForEach(services, id: \.0) { serviceId, serviceName in
                        APIConfigRow(
                            serviceId: serviceId,
                            serviceName: serviceName,
                            apiKey: Binding(
                                get: { apiManager.apiKeys[serviceId] ?? "" },
                                set: { apiManager.setAPIKey(for: serviceId, key: $0) }
                            )
                        )
                    }
                }

                Section(footer: Text("API密钥将安全存储在本地设备上。请从各AI服务商官网获取API密钥。")) {
                    EmptyView()
                }
            }
            .navigationTitle("API配置")
            .navigationBarItems(
                leading: Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct APIConfigRow: View {
    let serviceId: String
    let serviceName: String
    @Binding var apiKey: String
    @State private var isSecure = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(serviceName)
                    .font(.headline)

                Spacer()

                if !apiKey.isEmpty {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }

            HStack {
                Group {
                    if isSecure {
                        SecureField("输入API密钥", text: $apiKey)
                    } else {
                        TextField("输入API密钥", text: $apiKey)
                    }
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    isSecure.toggle()
                }) {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// 单个联系人的API配置视图
struct SingleContactAPIConfigView: View {
    let contact: AIContact
    @StateObject private var apiManager = APIConfigManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var apiKey: String = ""
    @State private var isSecure = true

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 联系人信息
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(contact.color)
                            .frame(width: 80, height: 80)

                        Image(systemName: contact.avatar)
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }

                    Text(contact.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(contact.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)

                // API配置
                VStack(alignment: .leading, spacing: 16) {
                    Text("API密钥配置")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("API密钥")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack {
                            Group {
                                if isSecure {
                                    SecureField("输入API密钥", text: $apiKey)
                                } else {
                                    TextField("输入API密钥", text: $apiKey)
                                }
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                            Button(action: {
                                isSecure.toggle()
                            }) {
                                Image(systemName: isSecure ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    if let endpoint = contact.apiEndpoint {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("API端点")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text(endpoint)
                                .font(.caption)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // 保存按钮
                Button(action: {
                    apiManager.setAPIKey(for: contact.id, key: apiKey)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("保存配置")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(apiKey.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(apiKey.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationTitle("API配置")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            apiKey = apiManager.getAPIKey(for: contact.id) ?? ""
        }
    }
}

// 聊天搜索视图
struct ChatSearchView: View {
    @ObservedObject var chatViewModel: ChatViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""

    var filteredMessages: [ChatMessage] {
        if searchText.isEmpty {
            return chatViewModel.messages
        } else {
            return chatViewModel.messages.filter { message in
                message.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // 搜索框
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("搜索聊天记录", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())

                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // 搜索结果
                if filteredMessages.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)

                        Text(searchText.isEmpty ? "输入关键词搜索聊天记录" : "没有找到相关消息")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredMessages) { message in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(message.isFromUser ? "我" : "AI")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(message.isFromUser ? .blue : .green)

                                Spacer()

                                Text(message.timestamp, style: .time)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Text(message.content)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Spacer()
            }
            .navigationTitle("搜索聊天记录")
            .navigationBarItems(
                trailing: Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// 收藏视图
struct FavoritesView: View {
    @StateObject private var favoritesManager = FavoritesManager.shared
    @State private var searchText = ""

    var filteredFavorites: [FavoriteMessage] {
        if searchText.isEmpty {
            return favoritesManager.favorites.sorted { $0.timestamp > $1.timestamp }
        } else {
            return favoritesManager.favorites
                .filter { $0.content.localizedCaseInsensitiveContains(searchText) }
                .sorted { $0.timestamp > $1.timestamp }
        }
    }

    var body: some View {
        VStack {
            if favoritesManager.favorites.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)

                    Text("暂无收藏")
                        .font(.title2)
                        .foregroundColor(.gray)

                    Text("在AI聊天中点击收藏按钮来收藏重要消息")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredFavorites) { favorite in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(favorite.contactName)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)

                                Spacer()

                                Text(favorite.timestamp, style: .relative)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Text(favorite.content)
                                .font(.body)
                                .foregroundColor(.primary)
                                .lineLimit(nil)

                            HStack {
                                Text(favorite.isFromUser ? "我" : "AI")
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(favorite.isFromUser ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
                                    .cornerRadius(4)

                                Spacer()

                                Button(action: {
                                    UIPasteboard.general.string = favorite.content
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }

                                Button(action: {
                                    favoritesManager.removeFavorite(favorite.id)
                                }) {
                                    Image(systemName: "heart.fill")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let favorite = filteredFavorites[index]
                            favoritesManager.removeFavorite(favorite.id)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "搜索收藏内容")
            }
        }
        .navigationTitle("我的收藏")
        .navigationBarTitleDisplayMode(.large)
    }
}

// AI回复编辑弹窗
struct AIEditPopupView: View {
    @Binding var content: String
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedText: String = ""
    @State private var showingCopyConfirmation = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("AI回复内容")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("长按选择文本进行复制")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ScrollView {
                        Text(content)
                            .textSelection(.enabled)
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .frame(maxHeight: 400)
                }

                VStack(spacing: 12) {
                    Button(action: {
                        UIPasteboard.general.string = content
                        showingCopyConfirmation = true

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showingCopyConfirmation = false
                        }
                    }) {
                        HStack {
                            Image(systemName: showingCopyConfirmation ? "checkmark" : "doc.on.doc")
                            Text(showingCopyConfirmation ? "已复制全部内容" : "复制全部内容")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(showingCopyConfirmation ? Color.green : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(showingCopyConfirmation)

                    Text("提示：您可以长按文本选择部分内容进行复制")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding(24)
            .navigationTitle("编辑AI回复")
            .navigationBarItems(
                trailing: Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct AIContactsView_Previews: PreviewProvider {
    static var previews: some View {
        AIContactsView()
    }
}
