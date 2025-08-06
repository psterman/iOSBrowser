import SwiftUI
import WidgetKit

struct WidgetConfigView: View {
    @State private var selectedTab = 0
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 标签选择器
            Picker("配置类型", selection: $selectedTab) {
                Text("搜索引擎").tag(0)
                Text("应用").tag(1)
                Text("AI助手").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // 内容区域
            TabView(selection: $selectedTab) {
                // 搜索引擎配置
                SearchEngineConfigView()
                    .tag(0)
                
                // 应用配置
                AppConfigView()
                    .tag(1)
                
                // AI助手配置
                AIAssistantConfigView()
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // 底部按钮
            Button(action: {
                // 强制刷新小组件
                if #available(iOS 14.0, *) {
                    WidgetCenter.shared.reloadAllTimelines()
                    showAlert(message: "小组件已刷新")
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise.circle.fill")
                    Text("刷新小组件")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            }
            .padding()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("提示"), message: Text(alertMessage), dismissButton: .default(Text("确定")))
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }
}

// MARK: - 搜索引擎配置视图
struct SearchEngineConfigView: View {
    @State private var engines = ["baidu", "google", "bing", "duckduckgo"]
    @State private var selectedEngines = Set<String>()
    
    var body: some View {
        List {
            ForEach(engines, id: \.self) { engine in
                HStack {
                    Text(engine.capitalized)
                    Spacer()
                    if selectedEngines.contains(engine) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedEngines.contains(engine) {
                        selectedEngines.remove(engine)
                    } else {
                        selectedEngines.insert(engine)
                    }
                    saveEngines()
                }
            }
        }
        .onAppear {
            loadEngines()
        }
    }
    
    private func loadEngines() {
        if let saved = UserDefaults.standard.stringArray(forKey: "iosbrowser_engines") {
            selectedEngines = Set(saved)
        }
    }
    
    private func saveEngines() {
        UserDefaults.standard.set(Array(selectedEngines), forKey: "iosbrowser_engines")
    }
}

// MARK: - 应用配置视图
struct AppConfigView: View {
    @State private var apps = [
        ("taobao", "淘宝", "cart.fill", Color.orange),
        ("zhihu", "知乎", "questionmark.circle.fill", Color.blue),
        ("douyin", "抖音", "play.circle.fill", Color.red),
        ("weibo", "微博", "flame.fill", Color.orange),
        ("bilibili", "哔哩哔哩", "tv.fill", Color.pink)
    ]
    @State private var selectedApps = Set<String>()
    
    var body: some View {
        List {
            ForEach(apps, id: \.0) { app in
                HStack {
                    Image(systemName: app.2)
                        .foregroundColor(app.3)
                    Text(app.1)
                    Spacer()
                    if selectedApps.contains(app.0) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedApps.contains(app.0) {
                        selectedApps.remove(app.0)
                    } else {
                        selectedApps.insert(app.0)
                    }
                    saveApps()
                }
            }
        }
        .onAppear {
            loadApps()
        }
    }
    
    private func loadApps() {
        if let saved = UserDefaults.standard.stringArray(forKey: "iosbrowser_apps") {
            selectedApps = Set(saved)
        }
    }
    
    private func saveApps() {
        UserDefaults.standard.set(Array(selectedApps), forKey: "iosbrowser_apps")
    }
}

// MARK: - AI助手配置视图
struct AIAssistantConfigView: View {
    @State private var assistants = [
        ("deepseek", "DeepSeek", "brain.head.profile", Color.purple),
        ("qwen", "通义千问", "cloud.fill", Color.cyan),
        ("chatglm", "智谱清言", "lightbulb.fill", Color.yellow),
        ("moonshot", "Kimi", "moon.stars.fill", Color.orange),
        ("claude", "Claude", "c.circle.fill", Color.blue),
        ("gpt", "ChatGPT", "g.circle.fill", Color.green)
    ]
    @State private var selectedAssistants = Set<String>()
    
    var body: some View {
        List {
            ForEach(assistants, id: \.0) { assistant in
                HStack {
                    Image(systemName: assistant.2)
                        .foregroundColor(assistant.3)
                    Text(assistant.1)
                    Spacer()
                    if selectedAssistants.contains(assistant.0) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedAssistants.contains(assistant.0) {
                        selectedAssistants.remove(assistant.0)
                    } else {
                        selectedAssistants.insert(assistant.0)
                    }
                    saveAssistants()
                }
            }
        }
        .onAppear {
            loadAssistants()
        }
    }
    
    private func loadAssistants() {
        if let saved = UserDefaults.standard.stringArray(forKey: "iosbrowser_ai") {
            selectedAssistants = Set(saved)
        }
    }
    
    private func saveAssistants() {
        UserDefaults.standard.set(Array(selectedAssistants), forKey: "iosbrowser_ai")
    }
} 