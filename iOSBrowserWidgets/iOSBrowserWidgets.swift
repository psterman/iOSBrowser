//
//  iOSBrowserWidgets.swift
//  iOSBrowserWidgets
//
//  统一小组件扩展 - 使用用户配置数据，彻底删除硬编码
//

import WidgetKit
import SwiftUI

// MARK: - 统一小组件包入口
@main
struct iOSBrowserWidgetExtension: WidgetBundle {
    var body: some Widget {
        UserConfigurableSearchWidget()
        UserConfigurableAppWidget()
        UserConfigurableAIWidget()
        UserConfigurableQuickActionWidget()
    }
}

// MARK: - 统一数据管理器（使用共享存储）
class UserConfigWidgetDataManager {
    static let shared = UserConfigWidgetDataManager()
    private let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

    private init() {}

    // MARK: - 获取用户配置的数据
    func getUserSelectedSearchEngines() -> [String] {
        let engines = sharedDefaults?.stringArray(forKey: "widget_search_engines") ?? ["baidu", "google"]
        print("🔍 小组件读取搜索引擎: \(engines)")
        return engines
    }
    
    func getUserSelectedApps() -> [UserWidgetAppData] {
        let selectedAppIds = sharedDefaults?.stringArray(forKey: "widget_apps") ?? ["taobao", "zhihu", "douyin"]
        let allApps = loadAppsData()
        let userApps = allApps.filter { selectedAppIds.contains($0.id) }
        print("📱 小组件读取应用: \(userApps.map { $0.name })")
        return userApps
    }
    
    func getUserSelectedAIAssistants() -> [UserWidgetAIData] {
        let selectedAIIds = sharedDefaults?.stringArray(forKey: "widget_ai_assistants") ?? ["deepseek", "qwen"]
        let allAI = loadAIData()
        let userAI = allAI.filter { selectedAIIds.contains($0.id) }
        print("🤖 小组件读取AI助手: \(userAI.map { $0.name })")
        return userAI
    }
    
    func getUserSelectedQuickActions() -> [String] {
        let actions = sharedDefaults?.stringArray(forKey: "widget_quick_actions") ?? ["search", "bookmark"]
        print("⚡ 小组件读取快捷操作: \(actions)")
        return actions
    }
    
    // MARK: - 加载完整数据
    private func loadAppsData() -> [UserWidgetAppData] {
        if let appsData = sharedDefaults?.data(forKey: "unified_apps_data"),
           let decodedApps = try? JSONDecoder().decode([UnifiedAppData].self, from: appsData) {
            print("📊 从共享存储加载应用数据: \(decodedApps.count) 个")
            return decodedApps.map { app in
                UserWidgetAppData(
                    id: app.id,
                    name: app.name,
                    icon: app.icon,
                    colorName: app.colorName,
                    category: app.category
                )
            }
        }
        
        print("⚠️ 使用默认应用数据")
        // 默认应用数据
        return [
            UserWidgetAppData(id: "taobao", name: "淘宝", icon: "bag.fill", colorName: "orange", category: "购物"),
            UserWidgetAppData(id: "zhihu", name: "知乎", icon: "bubble.left.and.bubble.right.fill", colorName: "blue", category: "社交"),
            UserWidgetAppData(id: "douyin", name: "抖音", icon: "music.note", colorName: "black", category: "视频")
        ]
    }
    
    private func loadAIData() -> [UserWidgetAIData] {
        if let aiData = sharedDefaults?.data(forKey: "unified_ai_data"),
           let decodedAI = try? JSONDecoder().decode([UnifiedAIData].self, from: aiData) {
            print("📊 从共享存储加载AI数据: \(decodedAI.count) 个")
            return decodedAI.map { ai in
                UserWidgetAIData(
                    id: ai.id,
                    name: ai.name,
                    icon: ai.icon,
                    colorName: ai.colorName,
                    description: ai.description
                )
            }
        }
        
        print("⚠️ 使用默认AI数据")
        // 默认AI数据
        return [
            UserWidgetAIData(id: "deepseek", name: "DeepSeek", icon: "brain.head.profile", colorName: "purple", description: "专业编程助手"),
            UserWidgetAIData(id: "qwen", name: "通义千问", icon: "cloud.fill", colorName: "cyan", description: "阿里云AI")
        ]
    }
}

// MARK: - 小组件数据结构
struct UserWidgetAppData: Codable {
    let id: String
    let name: String
    let icon: String
    let colorName: String
    let category: String
    
    var color: Color {
        switch colorName {
        case "orange": return .orange
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "pink": return .pink
        case "purple": return .purple
        case "cyan": return .cyan
        case "gray": return .gray
        case "black": return .black
        default: return .blue
        }
    }
}

struct UserWidgetAIData: Codable {
    let id: String
    let name: String
    let icon: String
    let colorName: String
    let description: String
    
    var color: Color {
        switch colorName {
        case "orange": return .orange
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "pink": return .pink
        case "purple": return .purple
        case "cyan": return .cyan
        case "gray": return .gray
        case "indigo": return .indigo
        default: return .blue
        }
    }
}

// 需要引用主应用中的数据结构
struct UnifiedAppData: Codable {
    let id: String
    let name: String
    let icon: String
    let colorName: String
    let category: String
}

struct UnifiedAIData: Codable {
    let id: String
    let name: String
    let icon: String
    let colorName: String
    let description: String
    let apiEndpoint: String
}

// MARK: - 用户配置搜索小组件
struct UserConfigurableSearchWidget: Widget {
    let kind: String = "UserConfigurableSearchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UserSearchProvider()) { entry in
            UserSearchWidgetView(entry: entry)
        }
        .configurationDisplayName("个性化搜索")
        .description("显示您选择的搜索引擎")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - 用户配置应用小组件
struct UserConfigurableAppWidget: Widget {
    let kind: String = "UserConfigurableAppWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UserAppProvider()) { entry in
            UserAppWidgetView(entry: entry)
        }
        .configurationDisplayName("个性化应用")
        .description("显示您选择的应用")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - 用户配置AI小组件
struct UserConfigurableAIWidget: Widget {
    let kind: String = "UserConfigurableAIWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UserAIProvider()) { entry in
            UserAIWidgetView(entry: entry)
        }
        .configurationDisplayName("个性化AI助手")
        .description("显示您选择的AI助手")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - 用户配置快捷操作小组件
struct UserConfigurableQuickActionWidget: Widget {
    let kind: String = "UserConfigurableQuickActionWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UserQuickActionProvider()) { entry in
            UserQuickActionWidgetView(entry: entry)
        }
        .configurationDisplayName("个性化快捷操作")
        .description("显示您选择的快捷操作")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - 用户配置数据提供者
struct UserSearchProvider: TimelineProvider {
    func placeholder(in context: Context) -> UserSearchEntry {
        let engines = UserConfigWidgetDataManager.shared.getUserSelectedSearchEngines()
        return UserSearchEntry(date: Date(), searchEngines: engines)
    }

    func getSnapshot(in context: Context, completion: @escaping (UserSearchEntry) -> ()) {
        let engines = UserConfigWidgetDataManager.shared.getUserSelectedSearchEngines()
        let entry = UserSearchEntry(date: Date(), searchEngines: engines)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UserSearchEntry>) -> ()) {
        let currentDate = Date()
        let engines = UserConfigWidgetDataManager.shared.getUserSelectedSearchEngines()
        let entry = UserSearchEntry(date: currentDate, searchEngines: engines)

        print("🔍 UserSearchProvider: 加载用户搜索引擎: \(engines)")

        // 每5分钟更新一次，确保数据及时同步
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct UserAppProvider: TimelineProvider {
    func placeholder(in context: Context) -> UserAppEntry {
        let apps = UserConfigWidgetDataManager.shared.getUserSelectedApps()
        return UserAppEntry(date: Date(), apps: apps)
    }

    func getSnapshot(in context: Context, completion: @escaping (UserAppEntry) -> ()) {
        let apps = UserConfigWidgetDataManager.shared.getUserSelectedApps()
        let entry = UserAppEntry(date: Date(), apps: apps)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UserAppEntry>) -> ()) {
        let currentDate = Date()
        let apps = UserConfigWidgetDataManager.shared.getUserSelectedApps()
        let entry = UserAppEntry(date: currentDate, apps: apps)

        print("📱 UserAppProvider: 加载用户应用: \(apps.map { $0.name })")

        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct UserAIProvider: TimelineProvider {
    func placeholder(in context: Context) -> UserAIEntry {
        let assistants = UserConfigWidgetDataManager.shared.getUserSelectedAIAssistants()
        return UserAIEntry(date: Date(), assistants: assistants)
    }

    func getSnapshot(in context: Context, completion: @escaping (UserAIEntry) -> ()) {
        let assistants = UserConfigWidgetDataManager.shared.getUserSelectedAIAssistants()
        let entry = UserAIEntry(date: Date(), assistants: assistants)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UserAIEntry>) -> ()) {
        let currentDate = Date()
        let assistants = UserConfigWidgetDataManager.shared.getUserSelectedAIAssistants()
        let entry = UserAIEntry(date: currentDate, assistants: assistants)

        print("🤖 UserAIProvider: 加载用户AI助手: \(assistants.map { $0.name })")

        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct UserQuickActionProvider: TimelineProvider {
    func placeholder(in context: Context) -> UserQuickActionEntry {
        let actions = UserConfigWidgetDataManager.shared.getUserSelectedQuickActions()
        return UserQuickActionEntry(date: Date(), actions: actions)
    }

    func getSnapshot(in context: Context, completion: @escaping (UserQuickActionEntry) -> ()) {
        let actions = UserConfigWidgetDataManager.shared.getUserSelectedQuickActions()
        let entry = UserQuickActionEntry(date: Date(), actions: actions)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UserQuickActionEntry>) -> ()) {
        let currentDate = Date()
        let actions = UserConfigWidgetDataManager.shared.getUserSelectedQuickActions()
        let entry = UserQuickActionEntry(date: currentDate, actions: actions)

        print("⚡ UserQuickActionProvider: 加载用户快捷操作: \(actions)")

        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - 用户配置数据模型
struct UserSearchEntry: TimelineEntry {
    let date: Date
    let searchEngines: [String]
}

struct UserAppEntry: TimelineEntry {
    let date: Date
    let apps: [UserWidgetAppData]
}

struct UserAIEntry: TimelineEntry {
    let date: Date
    let assistants: [UserWidgetAIData]
}

struct UserQuickActionEntry: TimelineEntry {
    let date: Date
    let actions: [String]
}

// MARK: - 小组件视图实现

// MARK: - 搜索引擎小组件视图
struct UserSearchWidgetView: View {
    var entry: UserSearchProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallUserSearchView(entry: entry)
        case .systemMedium:
            MediumUserSearchView(entry: entry)
        case .systemLarge:
            LargeUserSearchView(entry: entry)
        default:
            SmallUserSearchView(entry: entry)
        }
    }
}

struct SmallUserSearchView: View {
    let entry: UserSearchEntry

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("搜索")
                    .font(.caption)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "magnifyingglass")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }

            VStack(spacing: 4) {
                ForEach(Array(entry.searchEngines.prefix(2)), id: \.self) { engineId in
                    let info = getSearchEngineInfo(engineId)
                    Link(destination: URL(string: "iosbrowser://search?engine=\(engineId)")!) {
                        HStack(spacing: 6) {
                            Image(systemName: info.icon)
                                .font(.system(size: 12))
                                .foregroundColor(info.color)
                                .frame(width: 16)

                            Text(info.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(info.color.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct MediumUserSearchView: View {
    let entry: UserSearchEntry

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("个性化搜索")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text("\(entry.searchEngines.count) 个引擎")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 8) {
                ForEach(Array(entry.searchEngines.prefix(4)), id: \.self) { engineId in
                    let info = getSearchEngineInfo(engineId)
                    Link(destination: URL(string: "iosbrowser://search?engine=\(engineId)")!) {
                        VStack(spacing: 4) {
                            Image(systemName: info.icon)
                                .font(.system(size: 16))
                                .foregroundColor(info.color)
                            Text(info.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(info.color.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct LargeUserSearchView: View {
    let entry: UserSearchEntry

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("个性化搜索")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("已配置 \(entry.searchEngines.count) 个搜索引擎")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(entry.searchEngines, id: \.self) { engineId in
                    let info = getSearchEngineInfo(engineId)
                    Link(destination: URL(string: "iosbrowser://search?engine=\(engineId)")!) {
                        VStack(spacing: 6) {
                            Image(systemName: info.icon)
                                .font(.system(size: 20))
                                .foregroundColor(info.color)
                            Text(info.name)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(info.color.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - 应用小组件视图
struct UserAppWidgetView: View {
    var entry: UserAppProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallUserAppView(entry: entry)
        case .systemMedium:
            MediumUserAppView(entry: entry)
        case .systemLarge:
            LargeUserAppView(entry: entry)
        default:
            SmallUserAppView(entry: entry)
        }
    }
}

struct SmallUserAppView: View {
    let entry: UserAppEntry

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("应用")
                    .font(.caption)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "app.badge")
                    .font(.caption2)
                    .foregroundColor(.green)
            }

            VStack(spacing: 4) {
                ForEach(Array(entry.apps.prefix(2)), id: \.id) { app in
                    Link(destination: URL(string: "iosbrowser://search?app=\(app.id)")!) {
                        HStack(spacing: 6) {
                            Image(systemName: app.icon)
                                .font(.system(size: 12))
                                .foregroundColor(app.color)
                                .frame(width: 16)

                            Text(app.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(app.color.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct MediumUserAppView: View {
    let entry: UserAppEntry

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("个性化应用")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text("\(entry.apps.count) 个应用")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(Array(entry.apps.prefix(6)), id: \.id) { app in
                    Link(destination: URL(string: "iosbrowser://search?app=\(app.id)")!) {
                        VStack(spacing: 4) {
                            Image(systemName: app.icon)
                                .font(.system(size: 14))
                                .foregroundColor(app.color)
                            Text(app.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(app.color.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct LargeUserAppView: View {
    let entry: UserAppEntry

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("个性化应用")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("已配置 \(entry.apps.count) 个应用")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(entry.apps, id: \.id) { app in
                    Link(destination: URL(string: "iosbrowser://search?app=\(app.id)")!) {
                        VStack(spacing: 6) {
                            Image(systemName: app.icon)
                                .font(.system(size: 18))
                                .foregroundColor(app.color)
                            Text(app.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            Text(app.category)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(app.color.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - AI助手小组件视图
struct UserAIWidgetView: View {
    var entry: UserAIProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallUserAIView(entry: entry)
        case .systemMedium:
            MediumUserAIView(entry: entry)
        case .systemLarge:
            LargeUserAIView(entry: entry)
        default:
            SmallUserAIView(entry: entry)
        }
    }
}

struct SmallUserAIView: View {
    let entry: UserAIEntry

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("AI助手")
                    .font(.caption)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "brain.head.profile")
                    .font(.caption2)
                    .foregroundColor(.purple)
            }

            VStack(spacing: 4) {
                ForEach(Array(entry.assistants.prefix(2)), id: \.id) { ai in
                    Link(destination: URL(string: "iosbrowser://ai?assistant=\(ai.id)")!) {
                        HStack(spacing: 6) {
                            Image(systemName: ai.icon)
                                .font(.system(size: 12))
                                .foregroundColor(ai.color)
                                .frame(width: 16)

                            Text(ai.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(ai.color.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct MediumUserAIView: View {
    let entry: UserAIEntry

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("个性化AI助手")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text("\(entry.assistants.count) 个助手")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                ForEach(entry.assistants, id: \.id) { ai in
                    Link(destination: URL(string: "iosbrowser://ai?assistant=\(ai.id)")!) {
                        VStack(spacing: 6) {
                            Image(systemName: ai.icon)
                                .font(.system(size: 16))
                                .foregroundColor(ai.color)
                            Text(ai.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            Text(ai.description)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(ai.color.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct LargeUserAIView: View {
    let entry: UserAIEntry

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("个性化AI助手")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("已配置 \(entry.assistants.count) 个助手")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(entry.assistants, id: \.id) { ai in
                    Link(destination: URL(string: "iosbrowser://ai?assistant=\(ai.id)")!) {
                        VStack(spacing: 6) {
                            Image(systemName: ai.icon)
                                .font(.system(size: 20))
                                .foregroundColor(ai.color)
                            Text(ai.name)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            Text(ai.description)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(ai.color.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - 快捷操作小组件视图
struct UserQuickActionWidgetView: View {
    var entry: UserQuickActionProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallUserQuickActionView(entry: entry)
        case .systemMedium:
            MediumUserQuickActionView(entry: entry)
        default:
            SmallUserQuickActionView(entry: entry)
        }
    }
}

struct SmallUserQuickActionView: View {
    let entry: UserQuickActionEntry

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("快捷操作")
                    .font(.caption)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "bolt.circle")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }

            VStack(spacing: 4) {
                ForEach(Array(entry.actions.prefix(2)), id: \.self) { action in
                    let info = getQuickActionInfo(action)
                    Link(destination: URL(string: "iosbrowser://action?type=\(action)")!) {
                        HStack(spacing: 6) {
                            Image(systemName: info.icon)
                                .font(.system(size: 12))
                                .foregroundColor(info.color)
                                .frame(width: 16)

                            Text(info.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(info.color.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct MediumUserQuickActionView: View {
    let entry: UserQuickActionEntry

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("个性化快捷操作")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text("\(entry.actions.count) 个操作")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                ForEach(entry.actions, id: \.self) { action in
                    let info = getQuickActionInfo(action)
                    Link(destination: URL(string: "iosbrowser://action?type=\(action)")!) {
                        VStack(spacing: 6) {
                            Image(systemName: info.icon)
                                .font(.system(size: 16))
                                .foregroundColor(info.color)
                            Text(info.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(info.color.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - 辅助函数
func getSearchEngineInfo(_ engineId: String) -> (name: String, icon: String, color: Color) {
    switch engineId {
    case "baidu": return ("百度", "magnifyingglass.circle.fill", .blue)
    case "google": return ("Google", "globe", .red)
    case "bing": return ("必应", "b.circle.fill", .blue)
    case "sogou": return ("搜狗", "s.circle.fill", .orange)
    case "360": return ("360搜索", "360.circle.fill", .green)
    case "duckduckgo": return ("DuckDuckGo", "d.circle.fill", .orange)
    default: return (engineId, "magnifyingglass", .blue)
    }
}

func getQuickActionInfo(_ action: String) -> (name: String, icon: String, color: Color) {
    switch action {
    case "search": return ("快速搜索", "magnifyingglass", .blue)
    case "bookmark": return ("书签管理", "bookmark.fill", .orange)
    case "history": return ("浏览历史", "clock.fill", .green)
    case "ai_chat": return ("AI对话", "brain.head.profile", .purple)
    case "translate": return ("翻译工具", "textformat.abc", .red)
    case "qr_scan": return ("二维码扫描", "qrcode.viewfinder", .cyan)
    case "clipboard": return ("剪贴板", "doc.on.clipboard", .gray)
    case "settings": return ("快速设置", "gearshape.fill", .blue)
    default: return (action, "questionmark", .gray)
    }
}
