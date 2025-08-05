//
//  ContactsManagementView.swift
//  iOSBrowser
//
//  综合联系人管理界面 - 管理AI助手和平台联系人的启用状态
//

import SwiftUI

struct ContactsManagementView: View {
    @StateObject private var apiManager = APIConfigManager.shared
    @StateObject private var contactsManager = ContactsManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedCategory: ContactCategory = .all
    @State private var searchText = ""
    
    enum ContactCategory: String, CaseIterable {
        case all = "全部"
        case aiAssistants = "AI助手"
        case platforms = "内容平台"
        case enabled = "已启用"
        case needsConfig = "需要配置"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 分类选择器
                CategorySelector()
                
                // 搜索栏
                SearchBar()
                
                // 联系人列表
                ContactsList()
            }
            .navigationTitle("联系人管理")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("关闭") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("重置") {
                    showResetAlert()
                }
            )
        }
        .onAppear {
            contactsManager.loadContactSettings()
        }
    }
    
    // MARK: - 分类选择器
    private func CategorySelector() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ContactCategory.allCases, id: \.self) { category in
                    CategoryButton(category: category)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private func CategoryButton(category: ContactCategory) -> some View {
        Button(action: {
            selectedCategory = category
        }) {
            HStack(spacing: 4) {
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                // 显示数量
                Text("(\(getContactCount(for: category)))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(selectedCategory == category ? Color.blue : Color(.systemGray5))
            .foregroundColor(selectedCategory == category ? .white : .primary)
            .cornerRadius(8)
        }
    }
    
    // MARK: - 搜索栏
    private func SearchBar() -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("搜索联系人...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // MARK: - 联系人列表
    private func ContactsList() -> some View {
        List {
            ForEach(filteredContacts, id: \.id) { contact in
                ContactManagementRow(contact: contact)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // MARK: - 联系人管理行
    private func ContactManagementRow(contact: UnifiedContact) -> some View {
        HStack(spacing: 12) {
            // 联系人图标
            Image(systemName: contact.avatar)
                .font(.system(size: 24))
                .foregroundColor(contact.color)
                .frame(width: 40, height: 40)
                .background(contact.color.opacity(0.1))
                .clipShape(Circle())
            
            // 联系人信息
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(contact.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // 状态标签
                HStack(spacing: 8) {
                    ContactStatusLabel(contact: contact)
                    
                    if contact.isPlatform {
                        Text("内容平台")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    } else {
                        Text("AI助手")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            // 启用开关
            Toggle("", isOn: Binding(
                get: { contactsManager.isContactEnabled(contact.id) },
                set: { enabled in
                    contactsManager.setContactEnabled(contact.id, enabled: enabled)
                }
            ))
            .toggleStyle(SwitchToggleStyle())
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - 联系人状态标签
    private func ContactStatusLabel(contact: UnifiedContact) -> some View {
        Group {
            if contact.isPlatform {
                // 平台联系人总是可用
                Label("可用", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            } else {
                // AI助手需要检查API配置
                if apiManager.hasAPIKey(for: contact.id) {
                    Label("已配置", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Label("需要配置API", systemImage: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
    }
    
    // MARK: - 数据处理
    private var filteredContacts: [UnifiedContact] {
        let allContacts = contactsManager.getAllContacts()
        
        var filtered = allContacts
        
        // 按分类过滤
        switch selectedCategory {
        case .all:
            break
        case .aiAssistants:
            filtered = filtered.filter { !$0.isPlatform }
        case .platforms:
            filtered = filtered.filter { $0.isPlatform }
        case .enabled:
            filtered = filtered.filter { contactsManager.isContactEnabled($0.id) }
        case .needsConfig:
            filtered = filtered.filter { !$0.isPlatform && !apiManager.hasAPIKey(for: $0.id) }
        }
        
        // 按搜索文本过滤
        if !searchText.isEmpty {
            filtered = filtered.filter { contact in
                contact.name.localizedCaseInsensitiveContains(searchText) ||
                contact.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { $0.name < $1.name }
    }
    
    private func getContactCount(for category: ContactCategory) -> Int {
        let allContacts = contactsManager.getAllContacts()
        
        switch category {
        case .all:
            return allContacts.count
        case .aiAssistants:
            return allContacts.filter { !$0.isPlatform }.count
        case .platforms:
            return allContacts.filter { $0.isPlatform }.count
        case .enabled:
            return allContacts.filter { contactsManager.isContactEnabled($0.id) }.count
        case .needsConfig:
            return allContacts.filter { !$0.isPlatform && !apiManager.hasAPIKey(for: $0.id) }.count
        }
    }
    
    private func showResetAlert() {
        // 这里可以添加重置确认对话框
        contactsManager.resetAllSettings()
    }
}

// MARK: - 统一联系人数据模型
struct UnifiedContact: Identifiable {
    let id: String
    let name: String
    let description: String
    let avatar: String
    let color: Color
    let isPlatform: Bool
    let requiresApiKey: Bool
}

// MARK: - 联系人管理器
class ContactsManager: ObservableObject {
    static let shared = ContactsManager()
    
    @Published var enabledContacts: Set<String> = []
    
    private init() {
        loadContactSettings()
    }
    
    func loadContactSettings() {
        if let data = UserDefaults.standard.data(forKey: "enabled_contacts"),
           let contacts = try? JSONDecoder().decode(Set<String>.self, from: data) {
            enabledContacts = contacts
        } else {
            // 默认启用所有平台联系人和一些主要的AI助手
            let defaultEnabled = Set([
                // 平台联系人（默认全部启用）
                "douyin", "xiaohongshu", "wechat_mp", "weixin_channels", "toutiao",
                "bilibili", "youtube", "jike", "baijiahao", "xigua", "ximalaya",
                // 主要AI助手（用户可以选择启用）
                "deepseek", "qwen", "chatglm", "moonshot", "openai", "claude", "gemini"
            ])
            enabledContacts = defaultEnabled
            saveContactSettings()
        }
    }
    
    func saveContactSettings() {
        if let data = try? JSONEncoder().encode(enabledContacts) {
            UserDefaults.standard.set(data, forKey: "enabled_contacts")
        }
    }
    
    func isContactEnabled(_ contactId: String) -> Bool {
        return enabledContacts.contains(contactId)
    }
    
    func setContactEnabled(_ contactId: String, enabled: Bool) {
        if enabled {
            enabledContacts.insert(contactId)
        } else {
            enabledContacts.remove(contactId)
        }
        saveContactSettings()
    }
    
    func resetAllSettings() {
        enabledContacts.removeAll()
        // 重新启用所有平台联系人
        enabledContacts = Set(getAllContacts().filter { $0.isPlatform }.map { $0.id })
        saveContactSettings()
    }
    
    func getAllContacts() -> [UnifiedContact] {
        var contacts: [UnifiedContact] = []
        
        // 添加AI助手
        let aiAssistants = [
            UnifiedContact(id: "deepseek", name: "DeepSeek", description: "专业的AI编程助手", avatar: "brain.head.profile", color: .purple, isPlatform: false, requiresApiKey: true),
            UnifiedContact(id: "qwen", name: "通义千问", description: "阿里云大语言模型", avatar: "cloud.fill", color: .cyan, isPlatform: false, requiresApiKey: true),
            UnifiedContact(id: "chatglm", name: "智谱清言", description: "清华智谱AI", avatar: "lightbulb.fill", color: .yellow, isPlatform: false, requiresApiKey: true),
            UnifiedContact(id: "moonshot", name: "Kimi", description: "月之暗面AI", avatar: "moon.stars.fill", color: .orange, isPlatform: false, requiresApiKey: true),
            UnifiedContact(id: "openai", name: "ChatGPT", description: "OpenAI对话AI", avatar: "bubble.left.and.bubble.right.fill", color: .green, isPlatform: false, requiresApiKey: true),
            UnifiedContact(id: "claude", name: "Claude", description: "Anthropic智能助手", avatar: "sparkles", color: .purple, isPlatform: false, requiresApiKey: true),
            UnifiedContact(id: "gemini", name: "Gemini", description: "Google AI助手", avatar: "diamond.fill", color: .blue, isPlatform: false, requiresApiKey: true),
        ]
        
        // 添加平台联系人
        let platformContacts = [
            UnifiedContact(id: "douyin", name: "抖音", description: "短视频热门内容推送", avatar: "music.note", color: .black, isPlatform: true, requiresApiKey: false),
            UnifiedContact(id: "xiaohongshu", name: "小红书", description: "生活方式热门分享", avatar: "heart.fill", color: .red, isPlatform: true, requiresApiKey: false),
            UnifiedContact(id: "wechat_mp", name: "公众号", description: "微信公众号热文推送", avatar: "bubble.left.and.bubble.right.fill", color: .green, isPlatform: true, requiresApiKey: false),
            UnifiedContact(id: "weixin_channels", name: "视频号", description: "微信视频号热门内容", avatar: "video.fill", color: .green, isPlatform: true, requiresApiKey: false),
            UnifiedContact(id: "toutiao", name: "今日头条", description: "新闻资讯热点推送", avatar: "newspaper.fill", color: .red, isPlatform: true, requiresApiKey: false),
            UnifiedContact(id: "bilibili", name: "B站", description: "哔哩哔哩热门视频", avatar: "tv.fill", color: .pink, isPlatform: true, requiresApiKey: false),
            UnifiedContact(id: "youtube", name: "油管", description: "YouTube热门视频", avatar: "play.rectangle.fill", color: .red, isPlatform: true, requiresApiKey: false),
            UnifiedContact(id: "jike", name: "即刻", description: "即刻热门动态", avatar: "bolt.fill", color: .yellow, isPlatform: true, requiresApiKey: false),
            UnifiedContact(id: "baijiahao", name: "百家号", description: "百度百家号热文", avatar: "doc.text.fill", color: .blue, isPlatform: true, requiresApiKey: false),
            UnifiedContact(id: "xigua", name: "西瓜", description: "西瓜视频热门内容", avatar: "play.circle.fill", color: .green, isPlatform: true, requiresApiKey: false),
            UnifiedContact(id: "ximalaya", name: "喜马拉雅", description: "音频内容热门推荐", avatar: "waveform", color: .orange, isPlatform: true, requiresApiKey: false),
        ]
        
        contacts.append(contentsOf: aiAssistants)
        contacts.append(contentsOf: platformContacts)
        
        return contacts
    }
}

struct ContactsManagementView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsManagementView()
    }
}
