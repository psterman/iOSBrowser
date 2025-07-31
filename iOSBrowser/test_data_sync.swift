import Foundation

print("🧪 开始数据同步测试...")

// 模拟主应用保存数据
let defaults = UserDefaults.standard

let testEngines = ["baidu", "google", "bing"]
let testApps = ["taobao", "zhihu", "douyin", "wechat"]
let testAI = ["deepseek", "qwen", "chatgpt"]
let testActions = ["search", "bookmark", "history"]

print("🧪 主应用保存数据...")
defaults.set(testEngines, forKey: "iosbrowser_engines")
defaults.set(testApps, forKey: "iosbrowser_apps")
defaults.set(testAI, forKey: "iosbrowser_ai")
defaults.set(testActions, forKey: "iosbrowser_actions")

let syncResult = defaults.synchronize()
print("🧪 主应用同步结果: \(syncResult)")

print("🧪 模拟小组件读取数据...")

// 模拟小组件读取逻辑
func simulateWidgetRead(key: String, dataType: String) -> [String] {
    print("🔧 [模拟小组件] 读取\(dataType)数据")
    
    // 1. 优先从UserDefaults.standard读取
    print("🔧 [模拟小组件] 优先从UserDefaults.standard读取...")
    let stdSyncResult = UserDefaults.standard.synchronize()
    print("🔧 [模拟小组件] UserDefaults.standard同步结果: \(stdSyncResult)")

    let data = UserDefaults.standard.stringArray(forKey: key) ?? []
    print("🔧 [模拟小组件] UserDefaults.standard读取结果: \(key) = \(data)")

    if !data.isEmpty {
        print("🔧 [模拟小组件] ✅ UserDefaults读取成功: \(data)")
        return data
    } else {
        print("🔧 [模拟小组件] ⚠️ UserDefaults数据为空")
        return []
    }
}

let readEngines = simulateWidgetRead(key: "iosbrowser_engines", dataType: "搜索引擎")
let readApps = simulateWidgetRead(key: "iosbrowser_apps", dataType: "应用")
let readAI = simulateWidgetRead(key: "iosbrowser_ai", dataType: "AI助手")
let readActions = simulateWidgetRead(key: "iosbrowser_actions", dataType: "快捷操作")

print("🧪 数据同步测试结果:")
print("   搜索引擎: \(testEngines == readEngines ? "✅" : "❌") (\(readEngines))")
print("   应用: \(testApps == readApps ? "✅" : "❌") (\(readApps))")
print("   AI助手: \(testAI == readAI ? "✅" : "❌") (\(readAI))")
print("   快捷操作: \(testActions == readActions ? "✅" : "❌") (\(readActions))")

if testEngines == readEngines && testApps == readApps && testAI == readAI && testActions == readActions {
    print("🎉 数据同步测试成功！小组件应该能正确读取用户配置数据")
} else {
    print("❌ 数据同步测试失败！需要进一步调试")
}
