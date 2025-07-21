//
//  AIContactsView.swift
//  iOSBrowser
//
//  Created by LZH on 2025/7/19.
//

import SwiftUI
import UIKit

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

struct ChatMessage: Identifiable {
    let id: String
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    var status: MessageStatus
    var actions: [MessageAction] = []
}

enum MessageStatus {
    case sending
    case sent
    case delivered
    case failed
}

enum MessageAction: CaseIterable {
    case forward
    case share
    case edit
    case delete
    case favorite
    case quote

    var icon: String {
        switch self {
        case .forward: return "arrowshape.turn.up.right"
        case .share: return "square.and.arrow.up"
        case .edit: return "pencil"
        case .delete: return "trash"
        case .favorite: return "heart"
        case .quote: return "quote.bubble"
        }
    }

    var title: String {
        switch self {
        case .forward: return "转发"
        case .share: return "分享"
        case .edit: return "编辑"
        case .delete: return "删除"
        case .favorite: return "收藏"
        case .quote: return "引用"
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
        AIContact(id: "spark", name: "讯飞星火", description: "科大讯飞认知大模型", model: "spark-max", avatar: "sparkles", isOnline: true, apiEndpoint: "https://spark-api.xf-yun.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .orange),
        AIContact(id: "baichuan", name: "百川智能", description: "百川大模型，企业级应用", model: "baichuan2-turbo", avatar: "mountain.2.fill", isOnline: true, apiEndpoint: "https://api.baichuan-ai.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .brown),
        AIContact(id: "minimax", name: "MiniMax", description: "海螺AI，ABAB系列模型", model: "abab6.5-chat", avatar: "waveform", isOnline: true, apiEndpoint: "https://api.minimax.chat", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .mint),

        // 🌐 硅基流动提供的千问模型
        AIContact(id: "siliconflow-qwen", name: "千问-硅基流动", description: "硅基流动提供的通义千问模型", model: "Qwen/Qwen2.5-72B-Instruct", avatar: "cloud.fill", isOnline: true, apiEndpoint: "https://api.siliconflow.cn", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .cyan),

        // 🌍 国际主流AI服务商（都有可购买的API）
        AIContact(id: "openai", name: "ChatGPT", description: "OpenAI的GPT-4o模型", model: "gpt-4o", avatar: "bubble.left.and.bubble.right", isOnline: true, apiEndpoint: "https://api.openai.com/v1", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration, .translation, .summarization], color: .green),
        AIContact(id: "claude", name: "Claude", description: "Anthropic的Claude-3.5-Sonnet", model: "claude-3-5-sonnet", avatar: "sparkles", isOnline: true, apiEndpoint: "https://api.anthropic.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration, .translation, .summarization], color: .indigo),
        AIContact(id: "gemini", name: "Gemini", description: "Google的多模态AI", model: "gemini-pro", avatar: "diamond.fill", isOnline: true, apiEndpoint: "https://generativelanguage.googleapis.com", requiresApiKey: true, supportedFeatures: [.textGeneration, .imageGeneration, .codeGeneration], color: .blue),

        // ⚡ 高性能推理服务（都有可购买的API）
        AIContact(id: "groq", name: "Groq", description: "超高速推理，Llama3模型", model: "llama3-70b-8192", avatar: "bolt.fill", isOnline: true, apiEndpoint: "https://api.groq.com/openai/v1", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .mint),
        AIContact(id: "together", name: "Together AI", description: "开源模型推理平台", model: "meta-llama/Llama-3.1-70B-Instruct", avatar: "link", isOnline: true, apiEndpoint: "https://api.together.xyz", requiresApiKey: true, supportedFeatures: [.textGeneration, .codeGeneration], color: .teal),
        AIContact(id: "perplexity", name: "Perplexity", description: "AI搜索引擎，实时联网", model: "llama-3-sonar-large-32k-online", avatar: "magnifyingglass.circle.fill", isOnline: true, apiEndpoint: "https://api.perplexity.ai", requiresApiKey: true, supportedFeatures: [.textGeneration, .search], color: .pink),

        // 🎨 专业AI创作工具（都有可购买的API）
        AIContact(id: "dalle", name: "DALL-E", description: "OpenAI图像生成", model: "dall-e-3", avatar: "photo.artframe", isOnline: true, apiEndpoint: "https://api.openai.com/v1", requiresApiKey: true, supportedFeatures: [.imageGeneration], color: .green),
        AIContact(id: "stablediffusion", name: "Stable Diffusion", description: "Stability AI图像生成", model: "stable-diffusion-xl", avatar: "paintbrush.fill", isOnline: true, apiEndpoint: "https://api.stability.ai", requiresApiKey: true, supportedFeatures: [.imageGeneration], color: .pink),
        AIContact(id: "elevenlabs", name: "ElevenLabs", description: "AI语音合成", model: "eleven-multilingual-v2", avatar: "speaker.wave.3.fill", isOnline: true, apiEndpoint: "https://api.elevenlabs.io", requiresApiKey: true, supportedFeatures: [.audioGeneration], color: .blue),
        AIContact(id: "whisper", name: "Whisper", description: "OpenAI语音识别", model: "whisper-1", avatar: "mic.fill", isOnline: true, apiEndpoint: "https://api.openai.com/v1", requiresApiKey: true, supportedFeatures: [.audioGeneration], color: .cyan),

        // 🔧 本地部署（免费选项）
        AIContact(id: "ollama", name: "Ollama", description: "本地运行开源模型", model: "llama3.1", avatar: "server.rack", isOnline: false, apiEndpoint: "http://localhost:11434", requiresApiKey: false, supportedFeatures: [.textGeneration, .codeGeneration], color: .gray)
    ]

    @State private var searchText = ""
    @State private var isRefreshing = false
    @State private var selectedContact: AIContact?
    @State private var showingChat = false
    @State private var showingAPIConfig = false
    @State private var selectedContactForAPI: AIContact?
    @State private var showingAPIConfigForContact = false

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
                    ContactRowView(
                        contact: contact,
                        hasAPIKey: apiManager.hasAPIKey(for: contact.id),
                        isPinned: apiManager.isPinned(contact.id),
                        onTap: { handleContactTap(contact) },
                        onPin: { apiManager.setPinned(contact.id, pinned: !apiManager.isPinned(contact.id)) },
                        onHide: { apiManager.setHidden(contact.id, hidden: true) },
                        onConfigAPI: {
                            selectedContactForAPI = contact
                            showingAPIConfigForContact = true
                        }
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    await refreshContacts()
                }
            }
            .navigationTitle("AI联系人")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("显示全部") {
                    // 重置所有隐藏状态，显示所有联系人
                    for contact in contacts {
                        apiManager.setHidden(contact.id, hidden: false)
                    }
                },
                trailing: Button(action: {
                    showingAPIConfig = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.blue)
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle()) // 确保在iPad上也使用推入式导航
        .fullScreenCover(isPresented: $showingChat) {
            if let contact = selectedContact {
                NavigationView {
                    ChatView(contact: contact)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarItems(leading: Button("返回") {
                            showingChat = false
                        })
                }
            }
        }
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

    private func handleContactTap(_ contact: AIContact) {
        // 对于不需要API密钥的联系人，直接进入聊天
        if !contact.requiresApiKey {
            selectedContact = contact
            showingChat = true
            return
        }

        // 对于需要API密钥的联系人，检查是否已配置
        if apiManager.hasAPIKey(for: contact.id) {
            selectedContact = contact
            showingChat = true
        } else {
            // 显示API配置提示
            let alert = UIAlertController(
                title: "需要配置API密钥",
                message: "使用\(contact.name)需要先配置API密钥。是否前往设置？",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            alert.addAction(UIAlertAction(title: "去设置", style: .default) { _ in
                showingAPIConfig = true
            })

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(alert, animated: true)
            }
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
    let onTap: () -> Void
    let onPin: () -> Void
    let onHide: () -> Void
    let onConfigAPI: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            ContactRowContent(contact: contact, hasAPIKey: hasAPIKey, isPinned: isPinned)
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

                Text(contact.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

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
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - ChatViewModel
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    private var webViewModel: WebViewModel?

    func configureForContact(_ contact: AIContact) {
        // 这里可以根据联系人配置特定的AI引擎
        webViewModel = WebViewModel()
    }

    func addMessage(_ message: ChatMessage) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            messages.append(message)
        }
    }

    func clearMessages() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            messages.removeAll()
        }
    }

    func sendToAI(message: String, contact: AIContact) {
        isLoading = true

        // 模拟AI回复（这里应该集成实际的AI API）
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let aiResponse = ChatMessage(
                id: UUID().uuidString,
                content: self.generateAIResponse(for: message, contact: contact),
                isFromUser: false,
                timestamp: Date(),
                status: .delivered,
                actions: MessageAction.allCases
            )

            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                self.messages.append(aiResponse)
                self.isLoading = false
            }
        }
    }

    private func generateAIResponse(for message: String, contact: AIContact) -> String {
        // 这里应该调用实际的AI API
        // 目前返回模拟回复
        return """
        感谢您的提问！作为\(contact.name)，我很乐意为您解答。

        **关于您的问题：**
        \(message)

        **我的回复：**
        这是一个很好的问题。基于我的分析，我建议您考虑以下几个方面：

        1. **首先**，需要明确问题的核心
        2. **其次**，分析可能的解决方案
        3. **最后**，选择最适合的方法

        > 💡 **提示**：如果您需要更详细的解释，请随时告诉我！

        希望这个回答对您有帮助。还有其他问题吗？
        """
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
                            MessageBubble(message: message, contact: contact)
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
        .navigationTitle(contact.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .navigationBarItems(
            trailing: HStack(spacing: 16) {
                // 在线状态指示器
                if contact.isOnline {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("在线")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                Button(action: {
                    showingMoreOptions = true
                }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                }
            }
        )
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

        chatViewModel.addMessage(userMessage)

        let messageToSend = messageText
        messageText = ""
        isTyping = false

        // 发送到AI
        chatViewModel.sendToAI(message: messageToSend, contact: contact)
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

    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                UserMessageBubble(message: message)
            } else {
                AIMessageBubble(message: message, contact: contact, showActions: $showActions)
                Spacer()
            }
        }
    }
}

struct UserMessageBubble: View {
    let message: ChatMessage

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(message.content)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(18)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)

            HStack(spacing: 4) {
                Text(timeString(from: message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)

                StatusIcon(status: message.status)
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

                    // 消息内容（支持Markdown）
                    MarkdownText(animatedContent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(18)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                        .onAppear {
                            startTypingAnimation()
                        }

                    Text(timeString(from: message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // 操作按钮
            if !message.actions.isEmpty {
                MessageActionsView(message: message, showActions: $showActions)
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
    @Binding var showActions: Bool
    @State private var selectedAction: MessageAction?

    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                withAnimation(.spring()) {
                    showActions.toggle()
                }
            }) {
                Image(systemName: showActions ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            if showActions {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(message.actions, id: \.self) { action in
                            ActionButton(action: action) {
                                handleAction(action)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(.leading, 40) // 对齐AI头像
    }

    private func handleAction(_ action: MessageAction) {
        selectedAction = action

        withAnimation(.easeInOut(duration: 0.2)) {
            // 这里添加具体的操作逻辑
            switch action {
            case .forward:
                // 转发逻辑
                break
            case .share:
                shareMessage()
            case .edit:
                // 编辑逻辑
                break
            case .delete:
                // 删除逻辑
                break
            case .favorite:
                // 收藏逻辑
                break
            case .quote:
                // 引用逻辑
                break
            }
        }
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

struct AIContactsView_Previews: PreviewProvider {
    static var previews: some View {
        AIContactsView()
    }
}
