#!/bin/bash

# 🔍 诊断小组件数据隔离问题
# 彻底分析为什么小组件无法读取任何数据

echo "🔍🔍🔍 开始诊断小组件数据隔离问题..."
echo "📅 诊断时间: $(date)"
echo ""

# 1. 测试App Groups的实际可用性
echo "🔐 测试App Groups的实际可用性..."

cat > test_app_groups_isolation.swift << 'EOF'
import Foundation

print("🔐 测试App Groups隔离问题...")

// 测试标准UserDefaults
let standardDefaults = UserDefaults.standard
print("📱 测试标准UserDefaults...")

// 写入测试数据
let testKey = "isolation_test_\(Date().timeIntervalSince1970)"
let testValue = "isolation_test_value"

standardDefaults.set(testValue, forKey: testKey)
let stdSync = standardDefaults.synchronize()
print("📱 标准UserDefaults写入同步: \(stdSync)")

// 立即读取
let stdReadValue = standardDefaults.string(forKey: testKey) ?? ""
if stdReadValue == testValue {
    print("✅ 标准UserDefaults读写正常")
} else {
    print("❌ 标准UserDefaults读写失败")
}

// 测试App Groups
print("🔐 测试App Groups...")
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

if let shared = sharedDefaults {
    print("✅ App Groups UserDefaults创建成功")
    
    // 写入测试数据
    let sharedTestKey = "shared_isolation_test_\(Date().timeIntervalSince1970)"
    let sharedTestValue = "shared_isolation_test_value"
    
    shared.set(sharedTestValue, forKey: sharedTestKey)
    let sharedSync = shared.synchronize()
    print("🔐 App Groups写入同步: \(sharedSync)")
    
    // 立即读取
    let sharedReadValue = shared.string(forKey: sharedTestKey) ?? ""
    if sharedReadValue == sharedTestValue {
        print("✅ App Groups读写正常")
    } else {
        print("❌ App Groups读写失败")
        print("   写入: \(sharedTestValue)")
        print("   读取: \(sharedReadValue)")
    }
    
    // 检查之前写入的数据
    print("🔍 检查之前写入的数据:")
    let engines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let apps = shared.stringArray(forKey: "widget_apps") ?? []
    let ai = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let actions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("  widget_search_engines: \(engines)")
    print("  widget_apps: \(apps)")
    print("  widget_ai_assistants: \(ai)")
    print("  widget_quick_actions: \(actions)")
    
    if engines.isEmpty && apps.isEmpty && ai.isEmpty && actions.isEmpty {
        print("🚨 关键发现: App Groups中的数据已经丢失或从未写入")
        print("🚨 这说明存在数据隔离或权限问题")
    } else {
        print("✅ App Groups中有数据，但小组件无法读取")
        print("✅ 这说明是小组件的读取逻辑问题")
    }
    
    // 清理测试数据
    shared.removeObject(forKey: sharedTestKey)
    shared.synchronize()
} else {
    print("❌ App Groups UserDefaults创建失败")
    print("❌ 这是权限或配置问题")
}

// 清理标准UserDefaults测试数据
standardDefaults.removeObject(forKey: testKey)
standardDefaults.synchronize()
EOF

if command -v swift &> /dev/null; then
    swift test_app_groups_isolation.swift
else
    echo "⚠️ Swift命令不可用，跳过App Groups隔离测试"
fi

rm -f test_app_groups_isolation.swift

# 2. 强制重新写入数据并立即验证
echo ""
echo "💾 强制重新写入数据并立即验证..."

cat > force_rewrite_and_verify.swift << 'EOF'
import Foundation

print("💾 强制重新写入数据...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 使用时间戳确保数据是全新的
let timestamp = Int(Date().timeIntervalSince1970)
let engines = ["bing_\(timestamp)", "yahoo_\(timestamp)"]
let apps = ["wechat_\(timestamp)", "alipay_\(timestamp)"]
let ai = ["chatgpt_\(timestamp)", "claude_\(timestamp)"]
let actions = ["translate_\(timestamp)", "calculator_\(timestamp)"]

print("💾 写入带时间戳的数据:")
print("  搜索引擎: \(engines)")
print("  应用: \(apps)")
print("  AI助手: \(ai)")
print("  快捷操作: \(actions)")

// 1. 写入到所有可能的UserDefaults键
print("💾 写入到UserDefaults所有键...")
let allStandardKeys = [
    ("iosbrowser_engines", engines),
    ("widget_search_engines", engines),
    ("widget_search_engines_v2", engines),
    ("iosbrowser_apps", apps),
    ("widget_apps", apps),
    ("widget_apps_v2", apps),
    ("iosbrowser_ai", ai),
    ("widget_ai_assistants", ai),
    ("widget_ai_assistants_v2", ai),
    ("iosbrowser_actions", actions),
    ("widget_quick_actions", actions),
    ("widget_quick_actions_v2", actions)
]

for (key, value) in allStandardKeys {
    standardDefaults.set(value, forKey: key)
}
standardDefaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

let stdSync = standardDefaults.synchronize()
print("💾 UserDefaults同步: \(stdSync)")

// 2. 写入到App Groups所有键
if let shared = sharedDefaults {
    print("💾 写入到App Groups所有键...")
    let allSharedKeys = [
        ("widget_search_engines", engines),
        ("widget_apps", apps),
        ("widget_ai_assistants", ai),
        ("widget_quick_actions", actions)
    ]
    
    for (key, value) in allSharedKeys {
        shared.set(value, forKey: key)
    }
    shared.set(Date().timeIntervalSince1970, forKey: "widget_last_update")
    
    let sharedSync = shared.synchronize()
    print("💾 App Groups同步: \(sharedSync)")
    
    // 立即验证每个键
    print("💾 立即验证App Groups写入:")
    for (key, expectedValue) in allSharedKeys {
        let actualValue = shared.stringArray(forKey: key) ?? []
        let success = actualValue == expectedValue
        print("  \(key): \(success ? "✅" : "❌") \(actualValue)")
    }
}

// 3. 立即验证UserDefaults写入
print("💾 立即验证UserDefaults写入:")
for (key, expectedValue) in allStandardKeys {
    let actualValue = standardDefaults.stringArray(forKey: key) ?? []
    let success = actualValue == expectedValue
    print("  \(key): \(success ? "✅" : "❌") \(actualValue)")
}

print("🎯 如果小组件仍然读取不到数据，说明存在以下可能:")
print("1. 小组件扩展没有App Groups权限")
print("2. 小组件扩展使用了不同的App Groups ID")
print("3. iOS系统的沙盒隔离问题")
print("4. 小组件的读取逻辑有bug")
EOF

if command -v swift &> /dev/null; then
    swift force_rewrite_and_verify.swift
else
    echo "⚠️ Swift命令不可用，跳过强制重写验证"
fi

rm -f force_rewrite_and_verify.swift

# 3. 检查小组件的读取逻辑
echo ""
echo "🔍 检查小组件的读取逻辑..."

echo "🔍 检查小组件的App Groups配置:"
if grep -n "group.com.iosbrowser.shared" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件使用正确的App Groups ID"
else
    echo "❌ 小组件App Groups ID配置有问题"
fi

echo "🔍 检查小组件的读取方法:"
if grep -A 10 "readStringArray" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "sharedDefaults?.stringArray"; then
    echo "✅ 小组件有App Groups读取逻辑"
else
    echo "❌ 小组件缺少App Groups读取逻辑"
fi

echo "🔍 检查小组件的同步调用:"
if grep -q "sharedDefaults?.synchronize" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件调用了同步方法"
else
    echo "❌ 小组件未调用同步方法"
fi

# 4. 提供最终解决方案
echo ""
echo "🔍 最终诊断结果和解决方案:"
echo "================================"
echo ""
echo "基于测试结果，问题可能是以下之一:"
echo ""
echo "1. 🔐 App Groups权限问题"
echo "   - 小组件扩展没有正确的App Groups权限"
echo "   - 需要在Xcode中检查Widget Extension的Capabilities"
echo "   - 确保添加了'group.com.iosbrowser.shared'"
echo ""
echo "2. 📱 沙盒隔离问题"
echo "   - iOS系统阻止了小组件访问App Groups"
echo "   - 需要重新安装应用和小组件扩展"
echo "   - 可能需要重新配置App Groups"
echo ""
echo "3. 🔧 读取逻辑问题"
echo "   - 小组件的读取逻辑有bug"
echo "   - 需要增强调试日志"
echo "   - 需要检查数据类型转换"
echo ""
echo "4. ⏰ 时机问题"
echo "   - 数据写入和读取之间有时间差"
echo "   - 需要强制刷新机制"
echo "   - 需要等待更长时间"
echo ""

echo "🔧 立即尝试的解决方案:"
echo "1. 在Xcode中检查Widget Extension的App Groups权限"
echo "2. 完全删除应用，重新安装"
echo "3. 重启设备清除所有缓存"
echo "4. 重新添加小组件"
echo ""

echo "🔍🔍🔍 小组件数据隔离问题诊断完成！"
