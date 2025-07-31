#!/bin/bash

# 测试UserDefaults保存功能的脚本

echo "🧪🧪🧪 测试UserDefaults数据保存 🧪🧪🧪"

# 创建一个简单的测试脚本来验证UserDefaults保存
cat > iOSBrowser/test_userdefaults_simple.swift << 'EOF'
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
EOF

echo "✅ 创建了UserDefaults测试脚本"

# 检查主应用的保存逻辑
echo ""
echo "📱 检查主应用UserDefaults保存逻辑..."

echo "1. 检查是否保存到正确的键名:"
if grep -q "defaults.set.*iosbrowser_engines" iOSBrowser/ContentView.swift; then
    echo "✅ 保存搜索引擎到 iosbrowser_engines"
else
    echo "❌ 未找到搜索引擎保存逻辑"
fi

if grep -q "defaults.set.*iosbrowser_apps" iOSBrowser/ContentView.swift; then
    echo "✅ 保存应用到 iosbrowser_apps"
else
    echo "❌ 未找到应用保存逻辑"
fi

if grep -q "defaults.set.*iosbrowser_ai" iOSBrowser/ContentView.swift; then
    echo "✅ 保存AI助手到 iosbrowser_ai"
else
    echo "❌ 未找到AI助手保存逻辑"
fi

if grep -q "defaults.set.*iosbrowser_actions" iOSBrowser/ContentView.swift; then
    echo "✅ 保存快捷操作到 iosbrowser_actions"
else
    echo "❌ 未找到快捷操作保存逻辑"
fi

echo ""
echo "2. 检查同步调用:"
if grep -q "defaults.synchronize()" iOSBrowser/ContentView.swift; then
    echo "✅ 找到同步调用"
else
    echo "❌ 未找到同步调用"
fi

echo ""
echo "3. 检查小组件读取逻辑:"
if grep -q "UserDefaults.standard.stringArray.*iosbrowser_engines" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件读取搜索引擎"
else
    echo "❌ 小组件未读取搜索引擎"
fi

if grep -q "UserDefaults.standard.stringArray.*iosbrowser_apps" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件读取应用"
else
    echo "❌ 小组件未读取应用"
fi

if grep -q "UserDefaults.standard.stringArray.*iosbrowser_ai" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件读取AI助手"
else
    echo "❌ 小组件未读取AI助手"
fi

if grep -q "UserDefaults.standard.stringArray.*iosbrowser_actions" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件读取快捷操作"
else
    echo "❌ 小组件未读取快捷操作"
fi

echo ""
echo "🧪🧪🧪 测试完成 🧪🧪🧪"

echo ""
echo "💡 建议的修复方案:"
echo "1. 由于App Groups未配置，应该完全依赖UserDefaults.standard"
echo "2. 修改小组件代码，优先从UserDefaults.standard读取"
echo "3. 确保主应用正确保存到UserDefaults.standard"
echo "4. 移除App Groups相关代码，简化数据同步逻辑"
