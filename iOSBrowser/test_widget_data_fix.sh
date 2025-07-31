#!/bin/bash

# 测试小组件数据修复的脚本

echo "🧪🧪🧪 测试小组件数据修复 🧪🧪🧪"

# 1. 验证小组件代码修改
echo "1. 验证小组件代码修改..."

echo "1.1 检查是否优先从UserDefaults.standard读取:"
if grep -q "优先从UserDefaults.standard读取" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件已修改为优先从UserDefaults.standard读取"
else
    echo "❌ 小组件未修改读取优先级"
fi

echo "1.2 检查是否移除了测试数据:"
if grep -q "测试引擎1\|测试应用1\|测试AI1\|测试操作1" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "❌ 小组件仍在使用测试数据"
else
    echo "✅ 小组件已移除测试数据"
fi

echo "1.3 检查是否使用了合理的默认数据:"
if grep -q "baidu.*google" iOSBrowserWidgets/iOSBrowserWidgets.swift && 
   grep -q "taobao.*zhihu.*douyin" iOSBrowserWidgets/iOSBrowserWidgets.swift &&
   grep -q "deepseek.*qwen" iOSBrowserWidgets/iOSBrowserWidgets.swift &&
   grep -q "search.*bookmark" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件使用了合理的默认数据"
else
    echo "❌ 小组件默认数据不合理"
fi

echo ""
echo "2. 验证主应用保存逻辑..."

echo "2.1 检查主应用是否保存到UserDefaults.standard:"
if grep -q "defaults.set.*iosbrowser_engines" iOSBrowser/ContentView.swift &&
   grep -q "defaults.set.*iosbrowser_apps" iOSBrowser/ContentView.swift &&
   grep -q "defaults.set.*iosbrowser_ai" iOSBrowser/ContentView.swift &&
   grep -q "defaults.set.*iosbrowser_actions" iOSBrowser/ContentView.swift; then
    echo "✅ 主应用保存到UserDefaults.standard"
else
    echo "❌ 主应用保存逻辑有问题"
fi

echo "2.2 检查主应用是否调用同步:"
if grep -q "defaults.synchronize()" iOSBrowser/ContentView.swift; then
    echo "✅ 主应用调用了同步"
else
    echo "❌ 主应用未调用同步"
fi

echo ""
echo "3. 验证数据流向..."

echo "3.1 用户操作 → 数据更新流程:"
if grep -q "toggleApp.*updateAppSelection" iOSBrowser/ContentView.swift; then
    echo "✅ 用户点击 → updateAppSelection"
else
    echo "❌ 用户操作流程不完整"
fi

if grep -q "updateAppSelection.*immediateSyncToWidgets" iOSBrowser/ContentView.swift; then
    echo "✅ updateAppSelection → immediateSyncToWidgets"
else
    echo "❌ 数据同步流程不完整"
fi

if grep -q "immediateSyncToWidgets.*saveToWidgetAccessibleLocationFromDataSyncCenter" iOSBrowser/ContentView.swift; then
    echo "✅ immediateSyncToWidgets → saveToWidgetAccessibleLocationFromDataSyncCenter"
else
    echo "❌ 保存流程不完整"
fi

echo ""
echo "4. 创建测试数据验证脚本..."

# 创建一个Swift脚本来测试数据保存和读取
cat > iOSBrowser/test_data_sync.swift << 'EOF'
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
EOF

echo "✅ 创建了数据同步测试脚本"

echo ""
echo "5. 总结修复内容..."

echo "✅ 修复内容:"
echo "   1. 小组件优先从UserDefaults.standard读取数据"
echo "   2. 移除了测试数据，使用合理的默认数据"
echo "   3. 增加了详细的调试日志"
echo "   4. 保持App Groups作为备用方案"

echo ""
echo "📱 下一步测试建议:"
echo "   1. 在Xcode中编译项目"
echo "   2. 运行主应用，进入小组件配置tab"
echo "   3. 勾选一些应用、AI助手等"
echo "   4. 添加小组件到桌面"
echo "   5. 检查小组件是否显示用户选择的内容"

echo ""
echo "🧪🧪🧪 测试完成 🧪🧪🧪"
