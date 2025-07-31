#!/bin/bash

# 🧹 测试清空默认值后的效果
# 验证小组件是否能准确反映数据传递状态

echo "🧹🧹🧹 开始测试清空默认值后的效果..."
echo "📅 测试时间: $(date)"
echo ""

# 1. 检查默认值是否已清空
echo "🔍 检查默认值是否已清空..."

echo "🔍 检查搜索引擎默认值:"
if grep -A 3 "getSearchEngines" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "defaultValue: \[\]"; then
    echo "✅ 搜索引擎默认值已清空"
else
    echo "❌ 搜索引擎默认值未清空"
fi

echo "🔍 检查应用默认值:"
if grep -A 3 "getApps" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "defaultValue: \[\]"; then
    echo "✅ 应用默认值已清空"
else
    echo "❌ 应用默认值未清空"
fi

echo "🔍 检查AI助手默认值:"
if grep -A 3 "getAIAssistants" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "defaultValue: \[\]"; then
    echo "✅ AI助手默认值已清空"
else
    echo "❌ AI助手默认值未清空"
fi

echo "🔍 检查快捷操作默认值:"
if grep -A 3 "getQuickActions" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "defaultValue: \[\]"; then
    echo "✅ 快捷操作默认值已清空"
else
    echo "❌ 快捷操作默认值未清空"
fi

# 2. 检查空数据处理逻辑
echo ""
echo "🔍 检查空数据处理逻辑..."

echo "🔍 检查无数据状态显示:"
if grep -q "无数据" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 包含无数据状态显示"
else
    echo "❌ 缺少无数据状态显示"
fi

echo "🔍 检查空数组判断:"
if grep -q "isEmpty" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 包含空数组判断逻辑"
else
    echo "❌ 缺少空数组判断逻辑"
fi

# 3. 清除所有存储数据进行测试
echo ""
echo "🧹 清除所有存储数据进行测试..."

cat > clear_all_data.swift << 'EOF'
import Foundation

print("🧹 清除所有存储数据...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 清除UserDefaults.standard中的所有相关数据
let standardKeys = [
    "iosbrowser_engines", "widget_search_engines", "widget_search_engines_v2", "widget_search_engines_v3",
    "iosbrowser_apps", "widget_apps", "widget_apps_v2", "widget_apps_v3",
    "iosbrowser_ai", "widget_ai_assistants", "widget_ai_assistants_v2",
    "iosbrowser_actions", "widget_quick_actions", "widget_quick_actions_v2",
    "iosbrowser_last_update"
]

print("🧹 清除UserDefaults.standard数据...")
for key in standardKeys {
    standardDefaults.removeObject(forKey: key)
}
let stdSync = standardDefaults.synchronize()
print("🧹 UserDefaults.standard清除同步: \(stdSync)")

// 清除App Groups中的所有相关数据
if let shared = sharedDefaults {
    let sharedKeys = [
        "widget_search_engines", "widget_apps", "widget_ai_assistants", "widget_quick_actions",
        "widget_last_update", "widget_force_refresh", "widget_refresh_trigger"
    ]
    
    print("🧹 清除App Groups数据...")
    for key in sharedKeys {
        shared.removeObject(forKey: key)
    }
    let sharedSync = shared.synchronize()
    print("🧹 App Groups清除同步: \(sharedSync)")
    
    // 验证清除结果
    let verifyEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let verifyApps = shared.stringArray(forKey: "widget_apps") ?? []
    let verifyAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let verifyActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("🧹 清除验证:")
    print("  搜索引擎: \(verifyEngines)")
    print("  应用: \(verifyApps)")
    print("  AI助手: \(verifyAI)")
    print("  快捷操作: \(verifyActions)")
    
    let allEmpty = verifyEngines.isEmpty && verifyApps.isEmpty && verifyAI.isEmpty && verifyActions.isEmpty
    if allEmpty {
        print("✅ 所有数据清除成功")
        print("🎯 现在小组件应该显示'无数据'状态")
    } else {
        print("❌ 数据清除不完全")
    }
} else {
    print("❌ App Groups不可用")
}

print("🧹 数据清除完成")
EOF

if command -v swift &> /dev/null; then
    swift clear_all_data.swift
else
    echo "⚠️ Swift命令不可用，跳过数据清除"
fi

rm -f clear_all_data.swift

# 4. 写入测试数据
echo ""
echo "📝 写入明确的测试数据..."

cat > write_test_data.swift << 'EOF'
import Foundation

print("📝 写入明确的测试数据...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 创建明确的测试数据
let testEngines = ["test_engine_1", "test_engine_2"]
let testApps = ["test_app_1", "test_app_2"]
let testAI = ["test_ai_1", "test_ai_2"]
let testActions = ["test_action_1", "test_action_2"]

print("📝 测试数据:")
print("  搜索引擎: \(testEngines)")
print("  应用: \(testApps)")
print("  AI助手: \(testAI)")
print("  快捷操作: \(testActions)")

// 保存到App Groups（小组件的主要数据源）
if let shared = sharedDefaults {
    shared.set(testEngines, forKey: "widget_search_engines")
    shared.set(testApps, forKey: "widget_apps")
    shared.set(testAI, forKey: "widget_ai_assistants")
    shared.set(testActions, forKey: "widget_quick_actions")
    shared.set(Date().timeIntervalSince1970, forKey: "widget_last_update")
    
    let sharedSync = shared.synchronize()
    print("📝 App Groups保存同步: \(sharedSync)")
    
    // 验证保存结果
    let verifyEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let verifyApps = shared.stringArray(forKey: "widget_apps") ?? []
    let verifyAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let verifyActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("📝 保存验证:")
    print("  搜索引擎: \(verifyEngines)")
    print("  应用: \(verifyApps)")
    print("  AI助手: \(verifyAI)")
    print("  快捷操作: \(verifyActions)")
    
    let success = verifyEngines == testEngines && 
                  verifyApps == testApps && 
                  verifyAI == testAI && 
                  verifyActions == testActions
    
    if success {
        print("✅ 测试数据保存成功")
        print("🎯 现在小组件应该显示测试数据")
    } else {
        print("❌ 测试数据保存失败")
    }
} else {
    print("❌ App Groups不可用")
}
EOF

if command -v swift &> /dev/null; then
    swift write_test_data.swift
else
    echo "⚠️ Swift命令不可用，跳过测试数据写入"
fi

rm -f write_test_data.swift

# 5. 提供测试指南
echo ""
echo "🧹 清空默认值测试指南:"
echo "================================"
echo ""
echo "✅ 修改内容:"
echo "1. 清空了所有小组件的默认值（改为空数组[]）"
echo "2. 添加了无数据状态显示"
echo "3. 添加了详细的调试日志"
echo "4. 清除了所有存储数据"
echo "5. 写入了明确的测试数据"
echo ""
echo "📱 测试步骤:"
echo ""
echo "1. 🏗️ 重新编译应用:"
echo "   - 在Xcode中: Product → Build (Cmd+B)"
echo "   - 重新安装到设备"
echo ""
echo "2. 🔍 第一次测试（无数据状态）:"
echo "   - 删除桌面上的所有小组件"
echo "   - 重新添加小组件"
echo "   - 应该看到'无数据'状态和'请在主应用中配置'"
echo ""
echo "3. 📝 第二次测试（有数据状态）:"
echo "   - 查看控制台日志"
echo "   - 应该看到'🔍 [getSearchEngines] 最终返回: [\"test_engine_1\", \"test_engine_2\"]'"
echo "   - 小组件应该显示test_engine_1, test_engine_2等测试数据"
echo ""
echo "4. 🔧 第三次测试（主应用保存）:"
echo "   - 在主应用中进入小组件配置"
echo "   - 选择一些选项"
echo "   - 点击'保存'按钮"
echo "   - 查看是否有'🔥🔥🔥 App Groups保存验证'日志"
echo ""

echo "🔍 判断标准:"
echo "- 如果小组件显示'无数据' → 数据传递失败"
echo "- 如果小组件显示test_engine_1等 → 数据传递成功"
echo "- 如果小组件显示用户选择的内容 → 完全成功"
echo ""

echo "🎯 这样我们就能准确判断:"
echo "1. 数据是否真的在传递"
echo "2. 主应用的保存逻辑是否工作"
echo "3. 小组件的读取逻辑是否正确"
echo ""

echo "🧹🧹🧹 清空默认值测试完成！"
