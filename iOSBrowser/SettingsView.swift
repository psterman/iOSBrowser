//
//  SettingsView.swift
//  iOSBrowser
//
//  Created by LZH on 2025/7/19.
//

import SwiftUI
import WebKit

struct SettingsView: View {
    @State private var apiKeys: [String: String] = [:]
    @State private var showingAPIKeyEditor = false
    @State private var selectedProvider = ""
    @State private var darkModeEnabled = false
    @State private var notificationsEnabled = true
    @State private var autoSaveBookmarks = true
    @State private var clearCacheOnExit = false
    
    private let providers = [
        ("deepseek", "DeepSeek", "brain.head.profile"),
        ("openai", "OpenAI", "bubble.left.and.bubble.right"),
        ("groq", "Groq", "bolt.fill"),
        ("claude", "Claude", "sparkles"),
        ("gemini", "Gemini", "diamond.fill")
    ]
    
    var body: some View {
        NavigationView {
            List {
                // 用户信息部分
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("用户")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("iOS浏览器用户")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // AI API 设置
                Section("AI API 配置") {
                    ForEach(providers, id: \.0) { provider in
                        APIKeyRow(
                            providerID: provider.0,
                            providerName: provider.1,
                            icon: provider.2,
                            hasKey: !(apiKeys[provider.0] ?? "").isEmpty
                        ) {
                            selectedProvider = provider.0
                            showingAPIKeyEditor = true
                        }
                    }
                }
                
                // 应用设置
                Section("应用设置") {
                    Toggle("深色模式", isOn: $darkModeEnabled)
                        .onChange(of: darkModeEnabled) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "darkModeEnabled")
                            // 应用深色模式设置
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                windowScene.windows.first?.overrideUserInterfaceStyle = newValue ? .dark : .light
                            }
                        }

                    Toggle("推送通知", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "notificationsEnabled")
                            // 这里可以添加推送通知的设置逻辑
                        }

                    Toggle("自动保存书签", isOn: $autoSaveBookmarks)
                        .onChange(of: autoSaveBookmarks) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "autoSaveBookmarks")
                        }

                    Toggle("退出时清除缓存", isOn: $clearCacheOnExit)
                        .onChange(of: clearCacheOnExit) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "clearCacheOnExit")
                        }
                }
                
                // 浏览器设置
                Section("浏览器设置") {
                    NavigationLink("搜索引擎") {
                        SearchEngineSettingsView()
                    }
                    
                    NavigationLink("隐私与安全") {
                        PrivacySettingsView()
                    }
                    
                    Button("清除浏览数据") {
                        clearBrowsingData()
                    }
                    .foregroundColor(.red)
                }
                
                // 关于
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink("帮助与支持") {
                        HelpView()
                    }
                    
                    NavigationLink("隐私政策") {
                        PrivacyPolicyView()
                    }
                }
            }
            .navigationTitle("设置")
            .onAppear {
                loadAPIKeys()
                loadSettings()
            }
            .sheet(isPresented: $showingAPIKeyEditor) {
                APIKeyEditorView(
                    providerID: selectedProvider,
                    providerName: providers.first { $0.0 == selectedProvider }?.1 ?? "",
                    currentKey: apiKeys[selectedProvider] ?? ""
                ) { newKey in
                    apiKeys[selectedProvider] = newKey
                    saveAPIKey(providerID: selectedProvider, key: newKey)
                }
            }
        }
    }
    
    private func loadAPIKeys() {
        for provider in providers {
            if let key = UserDefaults.standard.string(forKey: "apiKey_\(provider.0)") {
                apiKeys[provider.0] = key
            }
        }
    }
    
    private func saveAPIKey(providerID: String, key: String) {
        UserDefaults.standard.set(key, forKey: "apiKey_\(providerID)")
    }
    
    private func loadSettings() {
        // 加载设置，如果没有设置过则使用默认值
        if UserDefaults.standard.object(forKey: "darkModeEnabled") != nil {
            darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        } else {
            darkModeEnabled = false
        }

        if UserDefaults.standard.object(forKey: "notificationsEnabled") != nil {
            notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        } else {
            notificationsEnabled = true
        }

        if UserDefaults.standard.object(forKey: "autoSaveBookmarks") != nil {
            autoSaveBookmarks = UserDefaults.standard.bool(forKey: "autoSaveBookmarks")
        } else {
            autoSaveBookmarks = true
        }

        if UserDefaults.standard.object(forKey: "clearCacheOnExit") != nil {
            clearCacheOnExit = UserDefaults.standard.bool(forKey: "clearCacheOnExit")
        } else {
            clearCacheOnExit = false
        }
    }
    
    private func clearBrowsingData() {
        let alert = UIAlertController(
            title: "清除浏览数据",
            message: "这将清除所有浏览历史、缓存和Cookie。此操作无法撤销。",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "清除", style: .destructive) { _ in
            // 清除URL缓存
            URLCache.shared.removeAllCachedResponses()

            // 清除Cookie
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

            // 清除书签（如果用户选择）
            UserDefaults.standard.removeObject(forKey: "bookmarks")

            // 清除WebView数据
            let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
            let date = Date(timeIntervalSince1970: 0)
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: date) {
                DispatchQueue.main.async {
                    // 显示清除完成的提示
                    let successAlert = UIAlertController(
                        title: "清除完成",
                        message: "浏览数据已成功清除",
                        preferredStyle: .alert
                    )
                    successAlert.addAction(UIAlertAction(title: "确定", style: .default))

                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowScene.windows.first?.rootViewController?.present(successAlert, animated: true)
                    }
                }
            }
        })

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(alert, animated: true)
        }
    }
}

struct APIKeyRow: View {
    let providerID: String
    let providerName: String
    let icon: String
    let hasKey: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(providerName)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(hasKey ? "已配置" : "未配置")
                        .font(.caption)
                        .foregroundColor(hasKey ? .green : .orange)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct APIKeyEditorView: View {
    let providerID: String
    let providerName: String
    @State private var apiKey: String
    let onSave: (String) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    init(providerID: String, providerName: String, currentKey: String, onSave: @escaping (String) -> Void) {
        self.providerID = providerID
        self.providerName = providerName
        self._apiKey = State(initialValue: currentKey)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("配置 \(providerName) API Key")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("请输入您的 \(providerName) API Key。这将用于访问 \(providerName) 的服务。")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key")
                        .font(.headline)
                    
                    SecureField("输入API Key", text: $apiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Text("您的API Key将安全地存储在设备本地，不会上传到任何服务器。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    onSave(apiKey)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// 占位符视图
struct SearchEngineSettingsView: View {
    var body: some View {
        Text("搜索引擎设置")
            .navigationTitle("搜索引擎")
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        Text("隐私与安全设置")
            .navigationTitle("隐私与安全")
    }
}

struct HelpView: View {
    var body: some View {
        Text("帮助与支持")
            .navigationTitle("帮助")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        Text("隐私政策")
            .navigationTitle("隐私政策")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
