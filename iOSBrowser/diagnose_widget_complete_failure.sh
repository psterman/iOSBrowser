#!/bin/bash

# 🚨 诊断小组件完全同步失败问题
# 分析为什么所有小组件都显示默认值而不是用户配置

echo "🚨🚨🚨 开始诊断小组件完全同步失败问题..."
echo "📅 诊断时间: $(date)"
echo ""

# 1. 验证主应用数据保存状态
echo "💾 验证主应用数据保存状态..."

cat > check_main_app_data.swift << 'EOF'
import Foundation

print("🔍 检查主应用数据保存状态...")

let defaults = UserDefaults.standard
defaults.synchronize()

// 检查所有数据类型
let engines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
let apps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []
let ai = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
let actions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []
let lastUpdate = defaults.double(forKey: "iosbrowser_last_update")

print("📱 主应用UserDefaults数据:")
print("  搜索引擎 (iosbrowser_engines): \(engines)")
print("  应用 (iosbrowser_apps): \(apps)")
print("  AI助手 (iosbrowser_ai): \(ai)")
print("  快捷操作 (iosbrowser_actions): \(actions)")
print("  最后更新: \(Date(timeIntervalSince1970: lastUpdate))")

// 检查备用键
let enginesV2 = defaults.stringArray(forKey: "widget_search_engines_v2") ?? []
let appsV2 = defaults.stringArray(forKey: "widget_apps_v2") ?? []
let aiV2 = defaults.stringArray(forKey: "widget_ai_assistants_v2") ?? []

print("📱 备用键数据:")
print("  搜索引擎v2: \(enginesV2)")
print("  应用v2: \(appsV2)")
print("  AI助手v2: \(aiV2)")

// 分析问题
let hasMainData = !engines.isEmpty || !apps.isEmpty || !ai.isEmpty || !actions.isEmpty
let hasBackupData = !enginesV2.isEmpty || !appsV2.isEmpty || !aiV2.isEmpty

print("📊 数据状态分析:")
print("  主键有数据: \(hasMainData)")
print("  备用键有数据: \(hasBackupData)")

if !hasMainData && !hasBackupData {
    print("🚨 严重问题: 所有UserDefaults键都为空!")
    print("🚨 这说明主应用根本没有保存用户配置")
} else if hasMainData {
    print("✅ 主键有数据，小组件应该能读取到")
} else if hasBackupData {
    print("⚠️ 只有备用键有数据，检查小组件是否读取备用键")
}

// 检查默认值对比
let defaultEngines = ["baidu", "google"]
let defaultApps = ["taobao", "zhihu", "douyin"]
let defaultAI = ["deepseek", "qwen"]

print("🎯 与默认值对比:")
print("  搜索引擎: \(engines == defaultEngines ? "使用默认值" : "已自定义")")
print("  应用: \(apps == defaultApps ? "使用默认值" : "已自定义")")
print("  AI助手: \(ai == defaultAI ? "使用默认值" : "已自定义")")
EOF

if command -v swift &> /dev/null; then
    swift check_main_app_data.swift
else
    echo "⚠️ Swift命令不可用，跳过主应用数据检查"
fi

rm -f check_main_app_data.swift

# 2. 检查小组件的所有数据读取方法
echo ""
echo "📱 检查小组件的所有数据读取方法..."

echo "🔍 检查getUserSelectedSearchEngines:"
if grep -A 20 "func getUserSelectedSearchEngines" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "iosbrowser_engines"; then
    echo "✅ 搜索引擎读取iosbrowser_engines"
else
    echo "❌ 搜索引擎未读取iosbrowser_engines"
fi

echo "🔍 检查getUserSelectedApps:"
if grep -A 20 "func getUserSelectedApps" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "iosbrowser_apps"; then
    echo "✅ 应用读取iosbrowser_apps"
else
    echo "❌ 应用未读取iosbrowser_apps"
fi

echo "🔍 检查getUserSelectedAIAssistants:"
if grep -A 20 "func getUserSelectedAIAssistants" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "iosbrowser_ai"; then
    echo "✅ AI助手读取iosbrowser_ai"
else
    echo "❌ AI助手未读取iosbrowser_ai"
fi

# 3. 检查小组件的默认值设置
echo ""
echo "🎯 检查小组件的默认值设置..."

echo "🔍 搜索引擎默认值:"
if grep -A 30 "func getUserSelectedSearchEngines" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "baidu.*google"; then
    echo "⚠️ 搜索引擎有默认值设置"
    grep -n "baidu.*google" iOSBrowserWidgets/iOSBrowserWidgets.swift | head -3
else
    echo "✅ 搜索引擎没有硬编码默认值"
fi

echo "🔍 应用默认值:"
if grep -A 30 "func getUserSelectedApps" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "taobao.*zhihu.*douyin"; then
    echo "⚠️ 应用有默认值设置"
    grep -n "taobao.*zhihu.*douyin" iOSBrowserWidgets/iOSBrowserWidgets.swift | head -3
else
    echo "✅ 应用没有硬编码默认值"
fi

echo "🔍 AI助手默认值:"
if grep -A 30 "func getUserSelectedAIAssistants" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "deepseek.*qwen"; then
    echo "⚠️ AI助手有默认值设置"
    grep -n "deepseek.*qwen" iOSBrowserWidgets/iOSBrowserWidgets.swift | head -3
else
    echo "✅ AI助手没有硬编码默认值"
fi

# 4. 检查App Groups配置
echo ""
echo "🔗 检查App Groups配置..."

echo "🔍 检查主应用是否使用App Groups:"
if grep -q "UserDefaults(suiteName:" iOSBrowser/ContentView.swift; then
    echo "✅ 主应用使用App Groups"
    grep -n "UserDefaults(suiteName:" iOSBrowser/ContentView.swift
else
    echo "❌ 主应用未使用App Groups"
fi

echo "🔍 检查小组件是否使用App Groups:"
if grep -q "UserDefaults(suiteName:" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件使用App Groups"
    grep -n "UserDefaults(suiteName:" iOSBrowserWidgets/iOSBrowserWidgets.swift
else
    echo "❌ 小组件未使用App Groups"
fi

# 5. 模拟小组件数据读取过程
echo ""
echo "🧪 模拟小组件数据读取过程..."

cat > simulate_widget_reading.swift << 'EOF'
import Foundation

print("🔍 模拟小组件数据读取过程...")

// 模拟小组件的数据读取逻辑
let defaults = UserDefaults.standard
defaults.synchronize()

print("🔍 模拟搜索引擎读取:")
var selectedEngines: [String] = []
selectedEngines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
if selectedEngines.isEmpty {
    selectedEngines = defaults.stringArray(forKey: "widget_search_engines_v2") ?? []
}
if selectedEngines.isEmpty {
    selectedEngines = ["baidu", "google"]  // 默认值
}
print("  最终搜索引擎: \(selectedEngines)")

print("🔍 模拟应用读取:")
var selectedApps: [String] = []
selectedApps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []
if selectedApps.isEmpty {
    selectedApps = defaults.stringArray(forKey: "widget_apps_v2") ?? []
}
if selectedApps.isEmpty {
    selectedApps = ["taobao", "zhihu", "douyin"]  // 默认值
}
print("  最终应用: \(selectedApps)")

print("🔍 模拟AI助手读取:")
var selectedAI: [String] = []
selectedAI = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
if selectedAI.isEmpty {
    selectedAI = defaults.stringArray(forKey: "widget_ai_assistants_v2") ?? []
}
if selectedAI.isEmpty {
    selectedAI = ["deepseek", "qwen"]  // 默认值
}
print("  最终AI助手: \(selectedAI)")

print("🎯 小组件最终显示预测:")
print("  搜索引擎: \(selectedEngines.joined(separator: ", "))")
print("  应用: \(selectedApps.joined(separator: ", "))")
print("  AI助手: \(selectedAI.joined(separator: ", "))")

// 检查是否全部为默认值
let allDefault = selectedEngines == ["baidu", "google"] && 
                 selectedApps == ["taobao", "zhihu", "douyin"] && 
                 selectedAI == ["deepseek", "qwen"]

if allDefault {
    print("🚨 问题确认: 小组件将显示所有默认值")
    print("🚨 原因: UserDefaults中没有用户配置数据")
} else {
    print("✅ 小组件应该显示用户配置")
}
EOF

if command -v swift &> /dev/null; then
    swift simulate_widget_reading.swift
else
    echo "⚠️ Swift命令不可用，跳过模拟读取"
fi

rm -f simulate_widget_reading.swift

# 6. 分析可能的根本原因
echo ""
echo "🚨 可能的根本原因分析:"
echo "================================"
echo "1. 数据保存失败 - 主应用配置没有正确保存到UserDefaults"
echo "2. 沙盒隔离 - 小组件扩展无法访问主应用的UserDefaults"
echo "3. App Groups未配置 - 主应用和小组件使用不同的存储空间"
echo "4. 数据读取逻辑错误 - 小组件读取了错误的键或方法"
echo "5. 缓存问题 - 小组件系统缓存了旧的默认值"
echo "6. 权限问题 - 小组件没有权限读取UserDefaults"
echo ""

echo "🔧 建议的解决方案:"
echo "1. 检查App Groups配置是否正确"
echo "2. 确保主应用和小组件使用相同的UserDefaults"
echo "3. 添加App Groups支持"
echo "4. 在小组件中添加更详细的调试日志"
echo "5. 验证数据保存和读取的完整流程"
echo ""

echo "🚨🚨🚨 小组件完全同步失败问题诊断完成！"
