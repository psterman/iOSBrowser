import Foundation

print("🧪 开始UserDefaults简单测试...")

let defaults = UserDefaults.standard

// 测试数据
let testEngines = ["baidu", "google", "bing"]
let testApps = ["taobao", "zhihu", "douyin"]
let testAI = ["deepseek", "qwen"]
let testActions = ["search", "bookmark"]

print("🧪 保存测试数据...")

// 保存数据
defaults.set(testEngines, forKey: "iosbrowser_engines")
defaults.set(testApps, forKey: "iosbrowser_apps")
defaults.set(testAI, forKey: "iosbrowser_ai")
defaults.set(testActions, forKey: "iosbrowser_actions")

// 强制同步
let syncResult = defaults.synchronize()
print("🧪 同步结果: \(syncResult)")

print("🧪 立即读取验证...")

// 立即读取验证
let readEngines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
let readApps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []
let readAI = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
let readActions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []

print("🧪 读取结果:")
print("   搜索引擎: \(readEngines)")
print("   应用: \(readApps)")
print("   AI助手: \(readAI)")
print("   快捷操作: \(readActions)")

// 验证数据一致性
let enginesMatch = testEngines == readEngines
let appsMatch = testApps == readApps
let aiMatch = testAI == readAI
let actionsMatch = testActions == readActions

print("🧪 数据一致性验证:")
print("   搜索引擎: \(enginesMatch ? "✅" : "❌")")
print("   应用: \(appsMatch ? "✅" : "❌")")
print("   AI助手: \(aiMatch ? "✅" : "❌")")
print("   快捷操作: \(actionsMatch ? "✅" : "❌")")

if enginesMatch && appsMatch && aiMatch && actionsMatch {
    print("🎉 UserDefaults保存和读取功能正常！")
} else {
    print("❌ UserDefaults保存或读取存在问题！")
}

print("🧪 UserDefaults测试完成")
