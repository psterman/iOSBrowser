import Foundation

print("🧪 免费开发者数据同步测试")

// 模拟用户在主应用中的选择
let testEngines = ["baidu", "google", "bing"]
let testApps = ["taobao", "wechat", "douyin"]
let testAI = ["deepseek", "chatgpt"]
let testActions = ["search", "bookmark", "history"]

print("🧪 保存测试数据到UserDefaults.standard...")

let defaults = UserDefaults.standard

// 保存数据（使用小组件期望的键名）
defaults.set(testEngines, forKey: "iosbrowser_engines")
defaults.set(testApps, forKey: "iosbrowser_apps")
defaults.set(testAI, forKey: "iosbrowser_ai")
defaults.set(testActions, forKey: "iosbrowser_actions")

// 强制同步
let syncResult = defaults.synchronize()
print("🧪 数据同步结果: \(syncResult)")

// 验证保存结果
print("🧪 验证保存的数据:")
print("   搜索引擎: \(defaults.stringArray(forKey: "iosbrowser_engines") ?? [])")
print("   应用: \(defaults.stringArray(forKey: "iosbrowser_apps") ?? [])")
print("   AI助手: \(defaults.stringArray(forKey: "iosbrowser_ai") ?? [])")
print("   快捷操作: \(defaults.stringArray(forKey: "iosbrowser_actions") ?? [])")

print("🧪 测试完成！现在可以检查小组件是否显示这些数据")
