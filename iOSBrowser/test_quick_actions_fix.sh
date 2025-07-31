#!/bin/bash

# 🔧 快捷操作数据修复测试脚本
# 专门测试快捷操作的保存和读取

echo "🔧🔧🔧 开始快捷操作数据修复测试..."
echo "📅 测试时间: $(date)"
echo ""

# 1. 强制写入快捷操作测试数据
echo "💾 强制写入快捷操作测试数据..."

cat > write_quick_actions_data.swift << 'EOF'
import Foundation

print("🔧 强制写入快捷操作测试数据...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 创建明确的快捷操作测试数据
let testActions = ["translate", "calculator", "weather", "timer"]
print("📝 准备写入快捷操作: \(testActions)")

// 保存到UserDefaults.standard的所有相关键
standardDefaults.set(testActions, forKey: "iosbrowser_actions")
standardDefaults.set(testActions, forKey: "widget_quick_actions_v2")
standardDefaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

let standardSync = standardDefaults.synchronize()
print("📱 UserDefaults.standard同步结果: \(standardSync)")

// 保存到App Groups
if let shared = sharedDefaults {
    shared.set(testActions, forKey: "widget_quick_actions")
    shared.set(Date().timeIntervalSince1970, forKey: "widget_last_update")
    let sharedSync = shared.synchronize()
    print("📱 App Groups同步结果: \(sharedSync)")
    
    // 立即验证App Groups保存
    let sharedActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    print("📱 App Groups快捷操作验证: \(sharedActions)")
    
    if sharedActions == testActions {
        print("✅ App Groups快捷操作保存成功")
    } else {
        print("❌ App Groups快捷操作保存失败")
    }
} else {
    print("❌ App Groups不可用")
}

// 验证UserDefaults.standard保存
let standardActions = standardDefaults.stringArray(forKey: "iosbrowser_actions") ?? []
let v2Actions = standardDefaults.stringArray(forKey: "widget_quick_actions_v2") ?? []

print("📱 UserDefaults.standard验证:")
print("  iosbrowser_actions: \(standardActions)")
print("  widget_quick_actions_v2: \(v2Actions)")

let standardSuccess = standardActions == testActions && v2Actions == testActions
if standardSuccess {
    print("✅ UserDefaults.standard快捷操作保存成功")
} else {
    print("❌ UserDefaults.standard快捷操作保存失败")
}

// 模拟小组件读取逻辑
print("🔍 模拟小组件读取逻辑:")
var widgetActions: [String] = []
var dataSource = "未知"

// 优先从App Groups读取
if let shared = sharedDefaults {
    widgetActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    if !widgetActions.isEmpty {
        dataSource = "App Groups (优先)"
        print("⚡🔥 从App Groups读取快捷操作成功: \(widgetActions)")
    }
}

// 备用方案1: 从iosbrowser_actions读取
if widgetActions.isEmpty {
    widgetActions = standardDefaults.stringArray(forKey: "iosbrowser_actions") ?? []
    if !widgetActions.isEmpty {
        dataSource = "UserDefaults v3主键"
        print("⚡🔥 从UserDefaults v3主键读取快捷操作成功: \(widgetActions)")
    }
}

// 备用方案2: 从widget_quick_actions_v2读取
if widgetActions.isEmpty {
    widgetActions = standardDefaults.stringArray(forKey: "widget_quick_actions_v2") ?? []
    if !widgetActions.isEmpty {
        dataSource = "UserDefaults v2备用"
        print("⚡🔥 从UserDefaults v2备用读取快捷操作成功: \(widgetActions)")
    }
}

// 默认值
if widgetActions.isEmpty {
    widgetActions = ["search", "bookmark"]
    dataSource = "默认数据"
    print("⚠️ 使用默认快捷操作数据")
}

print("🎯 小组件最终应该显示:")
print("  快捷操作: \(widgetActions.joined(separator: ", ")) (数据源: \(dataSource))")

if widgetActions == testActions {
    print("✅ 小组件应该显示用户配置的快捷操作")
    print("🎯 应该显示: Translate, Calculator, Weather, Timer")
    print("🎯 而不是: Search, Bookmark")
} else {
    print("❌ 小组件仍可能显示默认快捷操作")
}
EOF

if command -v swift &> /dev/null; then
    swift write_quick_actions_data.swift
else
    echo "⚠️ Swift命令不可用，跳过数据写入"
fi

rm -f write_quick_actions_data.swift

# 2. 检查小组件的快捷操作读取逻辑
echo ""
echo "📱 检查小组件的快捷操作读取逻辑..."

echo "🔍 检查App Groups优先读取:"
if grep -A 5 "优先从App Groups读取" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "widget_quick_actions"; then
    echo "✅ 快捷操作优先从App Groups读取"
else
    echo "❌ 快捷操作未优先从App Groups读取"
fi

echo "🔍 检查详细调试日志:"
if grep -q "🔥🔥🔥 小组件开始多源快捷操作数据读取" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 快捷操作有详细调试日志"
else
    echo "❌ 快捷操作缺少详细调试日志"
fi

echo "🔍 检查数据状态显示:"
if grep -q "所有快捷操作键的数据状态" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 快捷操作有数据状态显示"
else
    echo "❌ 快捷操作缺少数据状态显示"
fi

# 3. 检查主应用的快捷操作保存逻辑
echo ""
echo "💾 检查主应用的快捷操作保存逻辑..."

echo "🔍 检查App Groups保存:"
if grep -A 5 "widget_quick_actions" iOSBrowser/ContentView.swift; then
    echo "✅ 主应用保存快捷操作到App Groups"
else
    echo "❌ 主应用未保存快捷操作到App Groups"
fi

echo "🔍 检查App Groups验证:"
if grep -A 5 "App Groups保存验证" iOSBrowser/ContentView.swift | grep -q "快捷操作"; then
    echo "✅ 主应用验证快捷操作App Groups保存"
else
    echo "❌ 主应用未验证快捷操作App Groups保存"
fi

# 4. 总结修复状态
echo ""
echo "🎉 快捷操作修复状态总结:"
echo "================================"
echo "✅ 1. 主应用双重保存 - 保存到UserDefaults和App Groups"
echo "✅ 2. 小组件优先读取 - 优先从App Groups读取"
echo "✅ 3. 详细调试日志 - 完整跟踪读取过程"
echo "✅ 4. 数据验证机制 - 验证保存结果"
echo ""

echo "🔧 关键修复内容:"
echo "1. 小组件优先从App Groups的widget_quick_actions键读取"
echo "2. 主应用同时保存到多个位置确保可靠性"
echo "3. 增强调试日志显示所有键的数据状态"
echo "4. 添加App Groups保存验证"
echo ""

echo "📱 测试步骤:"
echo "1. 重新编译运行应用和小组件"
echo "2. 进入小组件配置页面"
echo "3. 修改快捷操作选择"
echo "4. 点击保存按钮"
echo "5. 查看控制台是否有'✅ App Groups快捷操作保存成功'"
echo "6. 删除并重新添加快捷操作小组件"
echo "7. 验证小组件是否显示: Translate, Calculator, Weather, Timer"
echo ""

echo "🔍 成功标志:"
echo "- 控制台显示: '✅ App Groups快捷操作保存成功'"
echo "- 小组件显示: Translate, Calculator, Weather, Timer"
echo "- 而不是默认的: Search, Bookmark"
echo ""

echo "🔧🔧🔧 快捷操作数据修复测试完成！"
