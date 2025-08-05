//
//  AddContactView.swift
//  iOSBrowser
//
//  联系人添加界面 - 支持AI联系人和RSS联系人
//

import SwiftUI

struct AddContactView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedContactType: ContactType = .ai
    @State private var showingAIForm = false
    @State private var showingRSSForm = false
    
    enum ContactType: String, CaseIterable {
        case ai = "AI助手"
        case rss = "RSS订阅"
        
        var icon: String {
            switch self {
            case .ai: return "brain.head.profile"
            case .rss: return "antenna.radiowaves.left.and.right"
            }
        }
        
        var description: String {
            switch self {
            case .ai: return "添加自定义AI助手，配置API进行对话"
            case .rss: return "添加RSS订阅源，获取最新内容更新"
            }
        }
        
        var color: Color {
            switch self {
            case .ai: return .blue
            case .rss: return .orange
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 标题区域
                VStack(spacing: 16) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.themeGreen)
                    
                    Text("添加联系人")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("选择要添加的联系人类型")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                .padding(.bottom, 40)
                
                // 联系人类型选择
                VStack(spacing: 20) {
                    ForEach(ContactType.allCases, id: \.self) { type in
                        ContactTypeCard(
                            type: type,
                            isSelected: selectedContactType == type,
                            onTap: {
                                selectedContactType = type
                                switch type {
                                case .ai:
                                    showingAIForm = true
                                case .rss:
                                    showingRSSForm = true
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // 底部说明
                VStack(spacing: 8) {
                    Text("💡 提示")
                        .font(.headline)
                        .foregroundColor(.themeGreen)
                    
                    Text("AI助手需要配置API密钥才能使用\nRSS订阅会定期检查更新并推送通知")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .sheet(isPresented: $showingAIForm) {
            AddAIContactView()
        }
        .sheet(isPresented: $showingRSSForm) {
            AddRSSContactView()
        }
    }
}

struct ContactTypeCard: View {
    let type: AddContactView.ContactType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 图标
                ZStack {
                    Circle()
                        .fill(type.color)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: type.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                // 信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(type.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // 箭头
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? type.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - AI联系人添加表单
struct AddAIContactView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var contactsManager = SimpleContactsManager.shared
    @StateObject private var apiManager = APIConfigManager.shared
    
    @State private var name = ""
    @State private var description = ""
    @State private var apiEndpoint = ""
    @State private var apiKey = ""
    @State private var model = ""
    @State private var selectedColor = Color.blue
    @State private var selectedIcon = "brain.head.profile"
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let availableColors: [Color] = [
        .blue, .green, .orange, .red, .purple, .pink, .cyan, .yellow, .indigo
    ]
    
    private let availableIcons = [
        "brain.head.profile", "bubble.left.and.bubble.right.fill", "cpu", "gear",
        "star.fill", "heart.fill", "bolt.fill", "cloud.fill", "diamond.fill"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("AI助手名称", text: $name)
                    TextField("描述", text: $description)
                    
                    // 颜色选择
                    VStack(alignment: .leading, spacing: 8) {
                        Text("主题颜色")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(availableColors.indices, id: \.self) { index in
                                Circle()
                                    .fill(availableColors[index])
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == availableColors[index] ? Color.primary : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        selectedColor = availableColors[index]
                                    }
                            }
                        }
                    }
                    
                    // 图标选择
                    VStack(alignment: .leading, spacing: 8) {
                        Text("图标")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? selectedColor : .secondary)
                                    .frame(width: 30, height: 30)
                                    .background(
                                        Circle()
                                            .fill(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.clear)
                                    )
                                    .onTapGesture {
                                        selectedIcon = icon
                                    }
                            }
                        }
                    }
                }
                
                Section(header: Text("API配置")) {
                    TextField("API地址", text: $apiEndpoint)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    TextField("模型名称", text: $model)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("API密钥", text: $apiKey)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("预览")) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(selectedColor)
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: selectedIcon)
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(name.isEmpty ? "AI助手名称" : name)
                                .font(.headline)
                                .fontWeight(.medium)
                            
                            Text(description.isEmpty ? "AI助手描述" : description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("添加AI助手")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    saveAIContact()
                }
                .disabled(name.isEmpty || apiEndpoint.isEmpty || apiKey.isEmpty)
            )
        }
        .alert("提示", isPresented: $showingAlert) {
            Button("确定") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveAIContact() {
        // 生成唯一ID
        let contactId = "custom_ai_\(UUID().uuidString.prefix(8))"
        
        // 创建AI联系人
        let newContact = AIContact(
            id: contactId,
            name: name,
            description: description,
            model: model.isEmpty ? "default" : model,
            avatar: selectedIcon,
            isOnline: true,
            apiEndpoint: apiEndpoint,
            requiresApiKey: true,
            supportedFeatures: [.textGeneration, .codeGeneration],
            color: selectedColor
        )
        
        // 保存API密钥
        apiManager.setAPIKey(apiKey, for: contactId)
        
        // 启用联系人
        contactsManager.setContactEnabled(contactId, enabled: true)
        
        // 保存自定义联系人信息
        saveCustomContact(newContact)
        
        alertMessage = "AI助手 '\(name)' 添加成功！"
        showingAlert = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func saveCustomContact(_ contact: AIContact) {
        var customContacts = getCustomContacts()
        customContacts.append(contact)
        
        if let data = try? JSONEncoder().encode(customContacts) {
            UserDefaults.standard.set(data, forKey: "custom_ai_contacts")
        }
    }
    
    private func getCustomContacts() -> [AIContact] {
        guard let data = UserDefaults.standard.data(forKey: "custom_ai_contacts"),
              let contacts = try? JSONDecoder().decode([AIContact].self, from: data) else {
            return []
        }
        return contacts
    }
}

// MARK: - RSS联系人添加表单
struct AddRSSContactView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var contactsManager = SimpleContactsManager.shared

    @State private var selectedTab = 0
    @State private var customName = ""
    @State private var customURL = ""
    @State private var customDescription = ""
    @State private var selectedPresetRSS: PresetRSSSource?
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 标签切换
                Picker("RSS类型", selection: $selectedTab) {
                    Text("预设RSS").tag(0)
                    Text("自定义RSS").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if selectedTab == 0 {
                    PresetRSSView(selectedRSS: $selectedPresetRSS)
                } else {
                    CustomRSSView(
                        name: $customName,
                        url: $customURL,
                        description: $customDescription
                    )
                }
            }
            .navigationTitle("添加RSS订阅")
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    saveRSSContact()
                }
                .disabled(!canSave)
            )
        }
        .alert("提示", isPresented: $showingAlert) {
            Button("确定") { }
        } message: {
            Text(alertMessage)
        }
    }

    private var canSave: Bool {
        if selectedTab == 0 {
            return selectedPresetRSS != nil
        } else {
            return !customName.isEmpty && !customURL.isEmpty
        }
    }

    private func saveRSSContact() {
        let contactId: String
        let name: String
        let description: String
        let rssURL: String

        if selectedTab == 0, let preset = selectedPresetRSS {
            contactId = "rss_\(preset.id)"
            name = preset.name
            description = preset.description
            rssURL = preset.url
        } else {
            contactId = "custom_rss_\(UUID().uuidString.prefix(8))"
            name = customName
            description = customDescription.isEmpty ? "自定义RSS订阅" : customDescription
            rssURL = customURL
        }

        // 创建RSS联系人
        let rssContact = AIContact(
            id: contactId,
            name: name,
            description: description,
            model: "rss-feed",
            avatar: "antenna.radiowaves.left.and.right",
            isOnline: true,
            apiEndpoint: rssURL,
            requiresApiKey: false,
            supportedFeatures: [.hotTrends],
            color: .orange
        )

        // 启用联系人
        contactsManager.setContactEnabled(contactId, enabled: true)

        // 保存RSS联系人信息
        saveRSSContactInfo(rssContact, rssURL: rssURL)

        alertMessage = "RSS订阅 '\(name)' 添加成功！"
        showingAlert = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func saveRSSContactInfo(_ contact: AIContact, rssURL: String) {
        // 保存RSS联系人到自定义列表
        var customRSSContacts = getCustomRSSContacts()
        customRSSContacts.append(contact)

        if let data = try? JSONEncoder().encode(customRSSContacts) {
            UserDefaults.standard.set(data, forKey: "custom_rss_contacts")
        }

        // 保存RSS URL映射
        var rssURLs = getRSSURLs()
        rssURLs[contact.id] = rssURL

        if let data = try? JSONEncoder().encode(rssURLs) {
            UserDefaults.standard.set(data, forKey: "rss_urls")
        }
    }

    private func getCustomRSSContacts() -> [AIContact] {
        guard let data = UserDefaults.standard.data(forKey: "custom_rss_contacts"),
              let contacts = try? JSONDecoder().decode([AIContact].self, from: data) else {
            return []
        }
        return contacts
    }

    private func getRSSURLs() -> [String: String] {
        guard let data = UserDefaults.standard.data(forKey: "rss_urls"),
              let urls = try? JSONDecoder().decode([String: String].self, from: data) else {
            return [:]
        }
        return urls
    }
}

// MARK: - 预设RSS视图
struct PresetRSSView: View {
    @Binding var selectedRSS: PresetRSSSource?

    var body: some View {
        List {
            ForEach(PresetRSSCategories.allCategories, id: \.name) { category in
                Section(header: Text(category.name)) {
                    ForEach(category.sources, id: \.id) { source in
                        RSSSourceRow(
                            source: source,
                            isSelected: selectedRSS?.id == source.id,
                            onTap: {
                                selectedRSS = source
                            }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - 自定义RSS视图
struct CustomRSSView: View {
    @Binding var name: String
    @Binding var url: String
    @Binding var description: String

    var body: some View {
        Form {
            Section(header: Text("RSS信息")) {
                TextField("RSS名称", text: $name)
                TextField("RSS地址", text: $url)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                TextField("描述（可选）", text: $description)
            }

            Section(header: Text("示例")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("RSS地址示例：")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("https://feeds.bbci.co.uk/news/rss.xml")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                }
            }
        }
    }
}

// MARK: - RSS源行组件
struct RSSSourceRow: View {
    let source: PresetRSSSource
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(source.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(source.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.themeGreen)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddContactView_Previews: PreviewProvider {
    static var previews: some View {
        AddContactView()
    }
}
