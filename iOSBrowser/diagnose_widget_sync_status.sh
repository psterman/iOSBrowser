#!/bin/bash

# 🔍 诊断小组件数据同步状态
# 检查主应用配置是否正确同步到桌面小组件

echo "🔍🔍🔍 开始诊断小组件数据同步状态..."
echo "📅 诊断时间: $(date)"
echo ""

# 1. 检查主应用的数据保存机制
echo "💾 检查主应用的数据保存机制..."

echo "🔍 检查immediateSyncToWidgets调用:"
if grep -q "immediateSyncToWidgets()" iOSBrowser/ContentView.swift; then
    echo "✅ 找到immediateSyncToWidgets调用"
    
    # 检查在哪些地方调用了
    echo "📋 immediateSyncToWidgets调用位置:"
    grep -n "immediateSyncToWidgets()" iOSBrowser/ContentView.swift | head -5
else
    echo "❌ 未找到immediateSyncToWidgets调用"
fi

echo ""
echo "🔍 检查saveToWidgetAccessibleLocationFromDataSyncCenter方法:"
if grep -A 20 "func saveToWidgetAccessibleLocationFromDataSyncCenter" iOSBrowser/ContentView.swift | grep -q "iosbrowser_engines"; then
    echo "✅ 保存方法包含搜索引擎数据"
else
    echo "❌ 保存方法缺少搜索引擎数据"
fi

if grep -A 20 "func saveToWidgetAccessibleLocationFromDataSyncCenter" iOSBrowser/ContentView.swift | grep -q "iosbrowser_apps"; then
    echo "✅ 保存方法包含应用数据"
else
    echo "❌ 保存方法缺少应用数据"
fi

# 2. 检查小组件的数据读取机制
echo ""
echo "📱 检查小组件的数据读取机制..."

echo "🔍 检查小组件数据管理器:"
if grep -q "UserConfigWidgetDataManager" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 找到小组件数据管理器"
else
    echo "❌ 未找到小组件数据管理器"
fi

echo "🔍 检查小组件读取iosbrowser_engines:"
if grep -q "iosbrowser_engines" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件读取iosbrowser_engines键"
else
    echo "❌ 小组件未读取iosbrowser_engines键"
fi

echo "🔍 检查小组件读取iosbrowser_apps:"
if grep -q "iosbrowser_apps" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件读取iosbrowser_apps键"
else
    echo "❌ 小组件未读取iosbrowser_apps键"
fi

# 3. 检查小组件刷新机制
echo ""
echo "🔄 检查小组件刷新机制..."

echo "🔍 检查WidgetCenter刷新调用:"
if grep -q "WidgetCenter.shared.reloadAllTimelines" iOSBrowser/ContentView.swift; then
    echo "✅ 找到WidgetCenter刷新调用"
else
    echo "❌ 未找到WidgetCenter刷新调用"
fi

echo "🔍 检查特定小组件刷新:"
if grep -q "reloadTimelines(ofKind:" iOSBrowser/ContentView.swift; then
    echo "✅ 找到特定小组件刷新"
    echo "📋 特定小组件刷新列表:"
    grep "reloadTimelines(ofKind:" iOSBrowser/ContentView.swift | sed 's/^[ \t]*/  /'
else
    echo "❌ 未找到特定小组件刷新"
fi

# 4. 验证当前数据状态
echo ""
echo "🧪 验证当前数据状态..."

cat > verify_widget_sync.swift << 'EOF'
import Foundation

print("🔍 验证小组件数据同步状态...")

let defaults = UserDefaults.standard
defaults.synchronize()

// 检查主应用保存的数据
let engines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
let apps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []
let ai = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
let actions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []
let lastUpdate = defaults.double(forKey: "iosbrowser_last_update")

print("📱 主应用保存的数据:")
print("  搜索引擎: \(engines)")
print("  应用: \(apps)")
print("  AI助手: \(ai)")
print("  快捷操作: \(actions)")
print("  最后更新: \(Date(timeIntervalSince1970: lastUpdate))")

// 检查小组件应该读取的数据
print("🔍 小组件应该读取的数据:")
print("  从iosbrowser_engines读取: \(engines)")
print("  从iosbrowser_apps读取: \(apps)")
print("  从iosbrowser_ai读取: \(ai)")
print("  从iosbrowser_actions读取: \(actions)")

// 检查数据是否有效
let hasValidData = !engines.isEmpty || !apps.isEmpty || !ai.isEmpty || !actions.isEmpty
print("📊 数据有效性: \(hasValidData ? "有效" : "无效")")

if hasValidData {
    print("✅ 主应用有用户配置数据，小组件应该能读取到")
    
    // 模拟小组件读取逻辑
    print("🎯 小组件应该显示:")
    if !engines.isEmpty {
        print("  搜索引擎: \(engines.joined(separator: ", "))")
    } else {
        print("  搜索引擎: 默认值 (baidu, google)")
    }
    
    if !apps.isEmpty {
        print("  应用: \(apps.joined(separator: ", "))")
    } else {
        print("  应用: 默认值 (taobao, zhihu, douyin)")
    }
} else {
    print("⚠️ 主应用没有用户配置数据，小组件将显示默认值")
}

// 检查App Groups（如果配置了）
if let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared") {
    print("🔍 检查App Groups共享数据:")
    let sharedEngines = sharedDefaults.stringArray(forKey: "widget_search_engines") ?? []
    let sharedApps = sharedDefaults.stringArray(forKey: "widget_apps") ?? []
    print("  共享搜索引擎: \(sharedEngines)")
    print("  共享应用: \(sharedApps)")
    
    if !sharedEngines.isEmpty || !sharedApps.isEmpty {
        print("✅ App Groups有数据，小组件可能从这里读取")
    } else {
        print("⚠️ App Groups没有数据，小组件将从UserDefaults.standard读取")
    }
} else {
    print("⚠️ App Groups未配置或不可用")
}
EOF

if command -v swift &> /dev/null; then
    swift verify_widget_sync.swift
else
    echo "⚠️ Swift命令不可用，跳过数据验证"
fi

rm -f verify_widget_sync.swift

# 5. 检查可能的问题
echo ""
echo "🚨 可能的同步问题分析:"
echo "================================"
echo "1. 数据保存问题 - 主应用没有正确保存到UserDefaults"
echo "2. 数据读取问题 - 小组件没有从正确的键读取数据"
echo "3. 刷新时机问题 - 小组件没有在数据更新后及时刷新"
echo "4. App Groups配置 - 主应用和小组件使用不同的存储"
echo "5. 小组件缓存 - 系统缓存了旧的小组件数据"
echo ""

echo "🔧 建议的解决步骤:"
echo "1. 在主应用中修改配置，查看控制台日志"
echo "2. 确认看到'🔥🔥🔥 立即同步到小组件开始'"
echo "3. 确认看到'🔄 已请求刷新所有小组件'"
echo "4. 等待2-3分钟让小组件系统更新"
echo "5. 检查桌面小组件是否显示新配置"
echo "6. 如果仍未更新，尝试删除并重新添加小组件"
echo ""

echo "🔍🔍🔍 小组件数据同步状态诊断完成！"
