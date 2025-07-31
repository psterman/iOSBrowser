#!/bin/bash

# 🔍 诊断小组件运行时数据访问问题
# 找出为什么小组件无法读取用户配置数据

echo "🔍🔍🔍 开始诊断小组件运行时数据访问问题..."
echo "📅 诊断时间: $(date)"
echo ""

# 1. 检查当前数据状态
echo "🔍 检查当前数据状态..."

cat > check_runtime_data_access.swift << 'EOF'
import Foundation

print("🔍 检查小组件运行时数据访问...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 强制同步
standardDefaults.synchronize()
sharedDefaults?.synchronize()

print("📱 UserDefaults.standard 当前状态:")
let stdEngines = standardDefaults.stringArray(forKey: "iosbrowser_engines") ?? []
let stdApps = standardDefaults.stringArray(forKey: "iosbrowser_apps") ?? []
let stdAI = standardDefaults.stringArray(forKey: "iosbrowser_ai") ?? []
let stdActions = standardDefaults.stringArray(forKey: "iosbrowser_actions") ?? []

print("  iosbrowser_engines: \(stdEngines)")
print("  iosbrowser_apps: \(stdApps)")
print("  iosbrowser_ai: \(stdAI)")
print("  iosbrowser_actions: \(stdActions)")

if let shared = sharedDefaults {
    print("📱 App Groups 当前状态:")
    let sharedEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let sharedApps = shared.stringArray(forKey: "widget_apps") ?? []
    let sharedAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let sharedActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("  widget_search_engines: \(sharedEngines)")
    print("  widget_apps: \(sharedApps)")
    print("  widget_ai_assistants: \(sharedAI)")
    print("  widget_quick_actions: \(sharedActions)")
    
    // 分析问题
    let hasUserData = !sharedEngines.isEmpty || !sharedApps.isEmpty || !sharedAI.isEmpty || !sharedActions.isEmpty
    if hasUserData {
        print("✅ App Groups中有用户数据")
        print("🚨 但小组件读取不到，说明存在运行时访问问题")
        
        // 检查数据内容
        let hasCorrectData = sharedEngines.contains("bing") || sharedApps.contains("wechat") || 
                            sharedAI.contains("chatgpt") || sharedActions.contains("translate")
        if hasCorrectData {
            print("✅ 数据内容正确")
        } else {
            print("⚠️ 数据内容可能不正确")
        }
    } else {
        print("❌ App Groups中没有用户数据")
        print("🚨 数据可能已经丢失或从未正确写入")
    }
} else {
    print("❌ App Groups不可用")
    print("🚨 这是权限配置问题")
}

// 模拟小组件的完整读取逻辑
print("🧪 模拟小组件的完整读取逻辑:")

func simulateWidgetRead(primaryKey: String, fallbackKey: String, testData: [String]) -> [String] {
    print("🔍 读取 \(primaryKey)...")
    
    // 1. 尝试从App Groups读取
    if let shared = sharedDefaults {
        shared.synchronize()
        let data = shared.stringArray(forKey: primaryKey) ?? []
        print("  App Groups读取结果: \(data)")
        if !data.isEmpty {
            print("  ✅ App Groups读取成功")
            return data
        } else {
            print("  ❌ App Groups数据为空")
        }
    } else {
        print("  ❌ App Groups不可用")
    }
    
    // 2. 尝试从UserDefaults读取
    standardDefaults.synchronize()
    let data = standardDefaults.stringArray(forKey: fallbackKey) ?? []
    print("  UserDefaults读取结果: \(data)")
    if !data.isEmpty {
        print("  ✅ UserDefaults读取成功")
        return data
    } else {
        print("  ❌ UserDefaults数据为空")
    }
    
    // 3. 使用测试数据
    print("  🔧 使用测试数据: \(testData)")
    return testData
}

let resultEngines = simulateWidgetRead(
    primaryKey: "widget_search_engines", 
    fallbackKey: "iosbrowser_engines", 
    testData: ["测试引擎1", "测试引擎2", "测试引擎3", "测试引擎4"]
)

let resultApps = simulateWidgetRead(
    primaryKey: "widget_apps", 
    fallbackKey: "iosbrowser_apps", 
    testData: ["测试应用1", "测试应用2", "测试应用3", "测试应用4"]
)

let resultAI = simulateWidgetRead(
    primaryKey: "widget_ai_assistants", 
    fallbackKey: "iosbrowser_ai", 
    testData: ["测试AI1", "测试AI2", "测试AI3", "测试AI4"]
)

let resultActions = simulateWidgetRead(
    primaryKey: "widget_quick_actions", 
    fallbackKey: "iosbrowser_actions", 
    testData: ["测试操作1", "测试操作2", "测试操作3", "测试操作4"]
)

print("🎯 模拟结果:")
print("  搜索引擎: \(resultEngines)")
print("  应用: \(resultApps)")
print("  AI助手: \(resultAI)")
print("  快捷操作: \(resultActions)")

// 判断问题类型
let allUsingTestData = resultEngines.contains("测试引擎1") && 
                      resultApps.contains("测试应用1") && 
                      resultAI.contains("测试AI1") && 
                      resultActions.contains("测试操作1")

if allUsingTestData {
    print("🚨 确认问题: 小组件无法访问任何用户数据")
    print("🚨 可能原因:")
    print("  1. App Groups权限配置错误")
    print("  2. 小组件运行在隔离的沙盒环境中")
    print("  3. 数据写入和读取的时机不匹配")
    print("  4. iOS系统的安全限制")
} else {
    print("✅ 部分数据读取成功")
}
EOF

if command -v swift &> /dev/null; then
    swift check_runtime_data_access.swift
else
    echo "⚠️ Swift命令不可用，跳过运行时数据访问检查"
fi

rm -f check_runtime_data_access.swift

# 2. 立即重新写入数据并测试
echo ""
echo "💾 立即重新写入数据并测试..."

cat > immediate_write_and_test.swift << 'EOF'
import Foundation

print("💾 立即重新写入数据并测试...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 使用当前时间戳确保数据是最新的
let timestamp = Int(Date().timeIntervalSince1970)
let engines = ["bing_\(timestamp)", "yahoo_\(timestamp)", "duckduckgo_\(timestamp)"]
let apps = ["wechat_\(timestamp)", "alipay_\(timestamp)", "meituan_\(timestamp)"]
let ai = ["chatgpt_\(timestamp)", "claude_\(timestamp)", "gemini_\(timestamp)"]
let actions = ["translate_\(timestamp)", "calculator_\(timestamp)", "weather_\(timestamp)"]

print("💾 写入带时间戳的数据:")
print("  搜索引擎: \(engines)")
print("  应用: \(apps)")
print("  AI助手: \(ai)")
print("  快捷操作: \(actions)")

// 写入到所有可能的位置
standardDefaults.set(engines, forKey: "iosbrowser_engines")
standardDefaults.set(apps, forKey: "iosbrowser_apps")
standardDefaults.set(ai, forKey: "iosbrowser_ai")
standardDefaults.set(actions, forKey: "iosbrowser_actions")
standardDefaults.synchronize()

if let shared = sharedDefaults {
    shared.set(engines, forKey: "widget_search_engines")
    shared.set(apps, forKey: "widget_apps")
    shared.set(ai, forKey: "widget_ai_assistants")
    shared.set(actions, forKey: "widget_quick_actions")
    shared.synchronize()
    
    // 立即验证
    let verifyEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let verifyApps = shared.stringArray(forKey: "widget_apps") ?? []
    let verifyAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let verifyActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("💾 立即验证:")
    print("  widget_search_engines: \(verifyEngines)")
    print("  widget_apps: \(verifyApps)")
    print("  widget_ai_assistants: \(verifyAI)")
    print("  widget_quick_actions: \(verifyActions)")
    
    let success = verifyEngines == engines && verifyApps == apps && verifyAI == ai && verifyActions == actions
    if success {
        print("✅ 数据写入验证成功")
        print("🎯 现在小组件应该能读取到带时间戳的数据")
    } else {
        print("❌ 数据写入验证失败")
    }
}

print("🔄 现在请刷新小组件，查看是否显示带时间戳的数据")
EOF

if command -v swift &> /dev/null; then
    swift immediate_write_and_test.swift
else
    echo "⚠️ Swift命令不可用，跳过立即写入测试"
fi

rm -f immediate_write_and_test.swift

# 3. 提供解决方案
echo ""
echo "🔍 运行时数据访问问题解决方案:"
echo "================================"
echo ""

echo "基于诊断结果，问题可能是以下之一:"
echo ""

echo "1. 🔐 App Groups权限问题:"
echo "   - 在Xcode中检查Widget Extension的Capabilities"
echo "   - 确保添加了'App Groups'权限"
echo "   - 确保选择了'group.com.iosbrowser.shared'"
echo "   - 确保主应用和Widget Extension使用相同的App Groups ID"
echo ""

echo "2. 📱 沙盒隔离问题:"
echo "   - iOS可能阻止了Widget Extension访问App Groups"
echo "   - 需要完全重新安装应用"
echo "   - 可能需要重新配置开发者证书"
echo ""

echo "3. ⏰ 时机问题:"
echo "   - 数据写入和Widget读取之间有延迟"
echo "   - Widget可能在数据写入之前就已经读取了"
echo "   - 需要强制Widget刷新"
echo ""

echo "🔧 立即尝试的解决方案:"
echo ""
echo "方案1: 检查Xcode配置"
echo "1. 在Xcode中选择iOSBrowserWidgets target"
echo "2. 进入Signing & Capabilities"
echo "3. 检查是否有'App Groups'权限"
echo "4. 确保选择了'group.com.iosbrowser.shared'"
echo ""

echo "方案2: 完全重新安装"
echo "1. 完全删除应用"
echo "2. 在Xcode中: Product → Clean Build Folder"
echo "3. 重新编译并安装"
echo "4. 重启设备"
echo ""

echo "方案3: 强制Widget刷新"
echo "1. 删除所有Widget"
echo "2. 等待30秒"
echo "3. 重新添加Widget"
echo "4. 查看控制台日志"
echo ""

echo "🔍 判断标准:"
echo "- 如果看到带时间戳的数据 → 数据访问正常"
echo "- 如果仍显示测试数据 → 存在权限或沙盒问题"
echo "- 如果Widget完全不显示 → 编译或安装问题"
echo ""

echo "🔍🔍🔍 运行时数据访问问题诊断完成！"
echo "现在请刷新Widget，查看是否显示带时间戳的数据。"
