import WidgetKit
import SwiftUI

// 🔧 最小化工作小组件
// 确保基础功能正常工作

// MARK: - 数据管理器（简化版）
class SimpleWidgetDataManager {
    static let shared = SimpleWidgetDataManager()
    
    private init() {}
    
    // 简化的数据读取，确保总是有数据返回
    func getSearchEngines() -> [String] {
        print("🔧 [SimpleWidget] 读取搜索引擎数据")
        
        // 1. 尝试从App Groups读取
        if let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared") {
            sharedDefaults.synchronize()
            let data = sharedDefaults.stringArray(forKey: "widget_search_engines") ?? []
            if !data.isEmpty {
                print("🔧 [SimpleWidget] App Groups读取成功: \(data)")
                return data
            }
        }
        
        // 2. 尝试从UserDefaults读取
        UserDefaults.standard.synchronize()
        let data = UserDefaults.standard.stringArray(forKey: "iosbrowser_engines") ?? []
        if !data.isEmpty {
            print("🔧 [SimpleWidget] UserDefaults读取成功: \(data)")
            return data
        }
        
        // 3. 返回硬编码的测试数据，确保小组件有内容显示
        let testData = ["测试引擎1", "测试引擎2", "测试引擎3", "测试引擎4"]
        print("🔧 [SimpleWidget] 使用测试数据: \(testData)")
        return testData
    }
    
    func getApps() -> [String] {
        print("🔧 [SimpleWidget] 读取应用数据")
        
        if let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared") {
            sharedDefaults.synchronize()
            let data = sharedDefaults.stringArray(forKey: "widget_apps") ?? []
            if !data.isEmpty {
                print("🔧 [SimpleWidget] App Groups读取成功: \(data)")
                return data
            }
        }
        
        UserDefaults.standard.synchronize()
        let data = UserDefaults.standard.stringArray(forKey: "iosbrowser_apps") ?? []
        if !data.isEmpty {
            print("🔧 [SimpleWidget] UserDefaults读取成功: \(data)")
            return data
        }
        
        let testData = ["测试应用1", "测试应用2", "测试应用3", "测试应用4"]
        print("🔧 [SimpleWidget] 使用测试数据: \(testData)")
        return testData
    }
    
    func getAIAssistants() -> [String] {
        print("🔧 [SimpleWidget] 读取AI助手数据")
        
        if let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared") {
            sharedDefaults.synchronize()
            let data = sharedDefaults.stringArray(forKey: "widget_ai_assistants") ?? []
            if !data.isEmpty {
                print("🔧 [SimpleWidget] App Groups读取成功: \(data)")
                return data
            }
        }
        
        UserDefaults.standard.synchronize()
        let data = UserDefaults.standard.stringArray(forKey: "iosbrowser_ai") ?? []
        if !data.isEmpty {
            print("🔧 [SimpleWidget] UserDefaults读取成功: \(data)")
            return data
        }
        
        let testData = ["测试AI1", "测试AI2", "测试AI3", "测试AI4"]
        print("🔧 [SimpleWidget] 使用测试数据: \(testData)")
        return testData
    }
    
    func getQuickActions() -> [String] {
        print("🔧 [SimpleWidget] 读取快捷操作数据")
        
        if let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared") {
            sharedDefaults.synchronize()
            let data = sharedDefaults.stringArray(forKey: "widget_quick_actions") ?? []
            if !data.isEmpty {
                print("🔧 [SimpleWidget] App Groups读取成功: \(data)")
                return data
            }
        }
        
        UserDefaults.standard.synchronize()
        let data = UserDefaults.standard.stringArray(forKey: "iosbrowser_actions") ?? []
        if !data.isEmpty {
            print("🔧 [SimpleWidget] UserDefaults读取成功: \(data)")
            return data
        }
        
        let testData = ["测试操作1", "测试操作2", "测试操作3", "测试操作4"]
        print("🔧 [SimpleWidget] 使用测试数据: \(testData)")
        return testData
    }
}

// MARK: - Entry定义
struct SearchEngineEntry: TimelineEntry {
    let date: Date
    let engines: [String]
}

struct AppEntry: TimelineEntry {
    let date: Date
    let apps: [String]
}

struct AIEntry: TimelineEntry {
    let date: Date
    let assistants: [String]
}

struct QuickActionEntry: TimelineEntry {
    let date: Date
    let actions: [String]
}

// MARK: - Provider定义
struct SearchEngineProvider: TimelineProvider {
    func placeholder(in context: Context) -> SearchEngineEntry {
        print("🔧 [SearchEngineProvider] placeholder被调用")
        return SearchEngineEntry(date: Date(), engines: ["占位符1", "占位符2"])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SearchEngineEntry) -> ()) {
        print("🔧 [SearchEngineProvider] getSnapshot被调用")
        let engines = SimpleWidgetDataManager.shared.getSearchEngines()
        let entry = SearchEngineEntry(date: Date(), engines: engines)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SearchEngineEntry>) -> ()) {
        print("🔧 [SearchEngineProvider] getTimeline被调用")
        let engines = SimpleWidgetDataManager.shared.getSearchEngines()
        let entry = SearchEngineEntry(date: Date(), engines: engines)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct AppProvider: TimelineProvider {
    func placeholder(in context: Context) -> AppEntry {
        print("🔧 [AppProvider] placeholder被调用")
        return AppEntry(date: Date(), apps: ["占位符1", "占位符2"])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AppEntry) -> ()) {
        print("🔧 [AppProvider] getSnapshot被调用")
        let apps = SimpleWidgetDataManager.shared.getApps()
        let entry = AppEntry(date: Date(), apps: apps)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AppEntry>) -> ()) {
        print("🔧 [AppProvider] getTimeline被调用")
        let apps = SimpleWidgetDataManager.shared.getApps()
        let entry = AppEntry(date: Date(), apps: apps)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct AIProvider: TimelineProvider {
    func placeholder(in context: Context) -> AIEntry {
        print("🔧 [AIProvider] placeholder被调用")
        return AIEntry(date: Date(), assistants: ["占位符1", "占位符2"])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AIEntry) -> ()) {
        print("🔧 [AIProvider] getSnapshot被调用")
        let assistants = SimpleWidgetDataManager.shared.getAIAssistants()
        let entry = AIEntry(date: Date(), assistants: assistants)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AIEntry>) -> ()) {
        print("🔧 [AIProvider] getTimeline被调用")
        let assistants = SimpleWidgetDataManager.shared.getAIAssistants()
        let entry = AIEntry(date: Date(), assistants: assistants)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct QuickActionProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickActionEntry {
        print("🔧 [QuickActionProvider] placeholder被调用")
        return QuickActionEntry(date: Date(), actions: ["占位符1", "占位符2"])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (QuickActionEntry) -> ()) {
        print("🔧 [QuickActionProvider] getSnapshot被调用")
        let actions = SimpleWidgetDataManager.shared.getQuickActions()
        let entry = QuickActionEntry(date: Date(), actions: actions)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickActionEntry>) -> ()) {
        print("🔧 [QuickActionProvider] getTimeline被调用")
        let actions = SimpleWidgetDataManager.shared.getQuickActions()
        let entry = QuickActionEntry(date: Date(), actions: actions)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - 简化的View定义
struct SimpleSearchEngineWidgetView: View {
    let entry: SearchEngineEntry
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
                Text("搜索引擎")
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
            }
            
            VStack(spacing: 2) {
                ForEach(Array(entry.engines.prefix(4).enumerated()), id: \.offset) { index, engine in
                    Text(engine)
                        .font(.caption2)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
    }
}

struct SimpleAppWidgetView: View {
    let entry: AppEntry
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "app")
                    .foregroundColor(.green)
                Text("应用")
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
            }
            
            VStack(spacing: 2) {
                ForEach(Array(entry.apps.prefix(4).enumerated()), id: \.offset) { index, app in
                    Text(app)
                        .font(.caption2)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
    }
}

struct SimpleAIWidgetView: View {
    let entry: AIEntry
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "brain")
                    .foregroundColor(.purple)
                Text("AI助手")
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
            }
            
            VStack(spacing: 2) {
                ForEach(Array(entry.assistants.prefix(4).enumerated()), id: \.offset) { index, ai in
                    Text(ai)
                        .font(.caption2)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
    }
}

struct SimpleQuickActionWidgetView: View {
    let entry: QuickActionEntry
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "bolt")
                    .foregroundColor(.orange)
                Text("快捷操作")
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
            }
            
            VStack(spacing: 2) {
                ForEach(Array(entry.actions.prefix(4).enumerated()), id: \.offset) { index, action in
                    Text(action)
                        .font(.caption2)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
    }
}

// MARK: - Widget定义
struct SimpleSearchEngineWidget: Widget {
    let kind: String = "SimpleSearchEngineWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SearchEngineProvider()) { entry in
            SimpleSearchEngineWidgetView(entry: entry)
        }
        .configurationDisplayName("搜索引擎")
        .description("显示搜索引擎选项")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SimpleAppWidget: Widget {
    let kind: String = "SimpleAppWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AppProvider()) { entry in
            SimpleAppWidgetView(entry: entry)
        }
        .configurationDisplayName("应用")
        .description("显示应用选项")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SimpleAIWidget: Widget {
    let kind: String = "SimpleAIWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AIProvider()) { entry in
            SimpleAIWidgetView(entry: entry)
        }
        .configurationDisplayName("AI助手")
        .description("显示AI助手选项")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SimpleQuickActionWidget: Widget {
    let kind: String = "SimpleQuickActionWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickActionProvider()) { entry in
            SimpleQuickActionWidgetView(entry: entry)
        }
        .configurationDisplayName("快捷操作")
        .description("显示快捷操作选项")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget Bundle
@main
struct SimpleWidgetBundle: WidgetBundle {
    var body: some Widget {
        SimpleSearchEngineWidget()
        SimpleAppWidget()
        SimpleAIWidget()
        SimpleQuickActionWidget()
    }
}
