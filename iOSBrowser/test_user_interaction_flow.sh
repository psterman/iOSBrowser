#!/bin/bash

# 🔍 用户交互流程测试脚本
# 验证用户在界面上的操作是否正确保存到存储中

echo "🔍🔍🔍 开始用户交互流程测试..."
echo "📅 测试时间: $(date)"
echo ""

# 1. 检查当前存储状态
echo "💾 检查当前存储状态..."

cat > check_current_storage.swift << 'EOF'
import Foundation

print("🔍 检查当前存储状态...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

standardDefaults.synchronize()

print("📱 UserDefaults.standard 当前数据:")
let engines = standardDefaults.stringArray(forKey: "iosbrowser_engines") ?? []
let apps = standardDefaults.stringArray(forKey: "iosbrowser_apps") ?? []
let ai = standardDefaults.stringArray(forKey: "iosbrowser_ai") ?? []
let actions = standardDefaults.stringArray(forKey: "iosbrowser_actions") ?? []

print("  搜索引擎: \(engines)")
print("  应用: \(apps)")
print("  AI助手: \(ai)")
print("  快捷操作: \(actions)")

if let shared = sharedDefaults {
    shared.synchronize()
    print("📱 App Groups 当前数据:")
    let sharedEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let sharedApps = shared.stringArray(forKey: "widget_apps") ?? []
    let sharedAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let sharedActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("  搜索引擎: \(sharedEngines)")
    print("  应用: \(sharedApps)")
    print("  AI助手: \(sharedAI)")
    print("  快捷操作: \(sharedActions)")
    
    // 检查数据一致性
    let enginesMatch = engines == sharedEngines
    let appsMatch = apps == sharedApps
    let aiMatch = ai == sharedAI
    let actionsMatch = actions == sharedActions
    
    print("🔍 数据一致性:")
    print("  搜索引擎: \(enginesMatch ? "✅" : "❌")")
    print("  应用: \(appsMatch ? "✅" : "❌")")
    print("  AI助手: \(aiMatch ? "✅" : "❌")")
    print("  快捷操作: \(actionsMatch ? "✅" : "❌")")
    
    if !enginesMatch || !appsMatch || !aiMatch || !actionsMatch {
        print("⚠️ 发现数据不一致，这可能是问题的原因")
    }
} else {
    print("❌ App Groups不可用")
}

// 检查是否都是默认值
let isDefaultEngines = engines == ["baidu", "google"] || engines.isEmpty
let isDefaultApps = apps == ["taobao", "zhihu", "douyin"] || apps.isEmpty
let isDefaultAI = ai == ["deepseek", "qwen"] || ai.isEmpty
let isDefaultActions = actions == ["search", "bookmark"] || actions.isEmpty

print("🎯 是否为默认值:")
print("  搜索引擎: \(isDefaultEngines ? "是默认值" : "已自定义")")
print("  应用: \(isDefaultApps ? "是默认值" : "已自定义")")
print("  AI助手: \(isDefaultAI ? "是默认值" : "已自定义")")
print("  快捷操作: \(isDefaultActions ? "是默认值" : "已自定义")")

if isDefaultEngines && isDefaultApps && isDefaultAI && isDefaultActions {
    print("🚨 所有数据都是默认值，这解释了为什么小组件只显示默认内容")
    print("🚨 问题：用户的选择没有被保存到存储中")
} else {
    print("✅ 检测到自定义数据，小组件应该能显示用户配置")
}
EOF

if command -v swift &> /dev/null; then
    swift check_current_storage.swift
else
    echo "⚠️ Swift命令不可用，跳过存储检查"
fi

rm -f check_current_storage.swift

# 2. 模拟用户交互并验证保存
echo ""
echo "🎮 模拟用户交互并验证保存..."

cat > simulate_user_interaction.swift << 'EOF'
import Foundation

print("🎮 模拟用户交互流程...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 模拟用户在界面上选择了不同的选项
let userSelectedEngines = ["bing", "yahoo", "duckduckgo"]
let userSelectedApps = ["wechat", "alipay", "meituan"]
let userSelectedAI = ["chatgpt", "claude", "gemini"]
let userSelectedActions = ["translate", "calculator", "weather"]

print("🎮 用户在界面上选择了:")
print("  搜索引擎: \(userSelectedEngines)")
print("  应用: \(userSelectedApps)")
print("  AI助手: \(userSelectedAI)")
print("  快捷操作: \(userSelectedActions)")

// 模拟 DataSyncCenter 的保存逻辑
print("💾 模拟保存到 UserDefaults.standard...")
standardDefaults.set(userSelectedEngines, forKey: "iosbrowser_engines")
standardDefaults.set(userSelectedApps, forKey: "iosbrowser_apps")
standardDefaults.set(userSelectedAI, forKey: "iosbrowser_ai")
standardDefaults.set(userSelectedActions, forKey: "iosbrowser_actions")
standardDefaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

let standardSync = standardDefaults.synchronize()
print("💾 UserDefaults.standard 同步结果: \(standardSync)")

// 模拟保存到 App Groups
if let shared = sharedDefaults {
    print("💾 模拟保存到 App Groups...")
    shared.set(userSelectedEngines, forKey: "widget_search_engines")
    shared.set(userSelectedApps, forKey: "widget_apps")
    shared.set(userSelectedAI, forKey: "widget_ai_assistants")
    shared.set(userSelectedActions, forKey: "widget_quick_actions")
    shared.set(Date().timeIntervalSince1970, forKey: "widget_last_update")
    
    let sharedSync = shared.synchronize()
    print("💾 App Groups 同步结果: \(sharedSync)")
}

// 立即验证保存结果
print("🔍 验证保存结果...")
let savedEngines = standardDefaults.stringArray(forKey: "iosbrowser_engines") ?? []
let savedApps = standardDefaults.stringArray(forKey: "iosbrowser_apps") ?? []
let savedAI = standardDefaults.stringArray(forKey: "iosbrowser_ai") ?? []
let savedActions = standardDefaults.stringArray(forKey: "iosbrowser_actions") ?? []

print("📱 UserDefaults.standard 保存验证:")
print("  搜索引擎: \(savedEngines)")
print("  应用: \(savedApps)")
print("  AI助手: \(savedAI)")
print("  快捷操作: \(savedActions)")

let standardSuccess = savedEngines == userSelectedEngines && 
                      savedApps == userSelectedApps && 
                      savedAI == userSelectedAI && 
                      savedActions == userSelectedActions

if standardSuccess {
    print("✅ UserDefaults.standard 保存成功")
} else {
    print("❌ UserDefaults.standard 保存失败")
}

if let shared = sharedDefaults {
    let sharedEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let sharedApps = shared.stringArray(forKey: "widget_apps") ?? []
    let sharedAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let sharedActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("📱 App Groups 保存验证:")
    print("  搜索引擎: \(sharedEngines)")
    print("  应用: \(sharedApps)")
    print("  AI助手: \(sharedAI)")
    print("  快捷操作: \(sharedActions)")
    
    let sharedSuccess = sharedEngines == userSelectedEngines && 
                        sharedApps == userSelectedApps && 
                        sharedAI == userSelectedAI && 
                        sharedActions == userSelectedActions
    
    if sharedSuccess {
        print("✅ App Groups 保存成功")
    } else {
        print("❌ App Groups 保存失败")
    }
}

print("🎯 现在小组件应该显示:")
print("  搜索引擎: Bing, Yahoo, DuckDuckGo")
print("  应用: WeChat, Alipay, Meituan")
print("  AI助手: ChatGPT, Claude, Gemini")
print("  快捷操作: Translate, Calculator, Weather")
print("")
print("🎯 而不是默认值:")
print("  搜索引擎: 百度, 谷歌")
print("  应用: 淘宝, 知乎, 抖音")
print("  AI助手: DeepSeek, 通义千问")
print("  快捷操作: Search, Bookmark")
EOF

if command -v swift &> /dev/null; then
    swift simulate_user_interaction.swift
else
    echo "⚠️ Swift命令不可用，跳过交互模拟"
fi

rm -f simulate_user_interaction.swift

# 3. 分析可能的问题
echo ""
echo "🚨 可能的问题分析:"
echo "================================"
echo ""
echo "根据您的描述，小组件只能加载程序最初始的数据，"
echo "无法加载用户后期更改的配置。这可能的原因包括："
echo ""
echo "1. 🔄 用户交互没有触发保存"
echo "   - 用户点击选项时，toggle方法没有被调用"
echo "   - toggle方法没有调用updateXXXSelection"
echo "   - updateXXXSelection没有调用immediateSyncToWidgets"
echo ""
echo "2. 💾 保存逻辑有问题"
echo "   - 数据保存到了错误的键"
echo "   - UserDefaults同步失败"
echo "   - App Groups保存失败"
echo ""
echo "3. 📱 小组件读取逻辑有问题"
echo "   - 小组件从错误的键读取数据"
echo "   - 小组件缓存了旧数据"
echo "   - 小组件没有使用最新的代码"
echo ""
echo "4. ⏰ 时机问题"
echo "   - 用户操作和保存之间有延迟"
echo "   - 保存和小组件读取之间有延迟"
echo "   - 系统缓存导致的延迟"
echo ""

echo "🔧 调试建议:"
echo "1. 在主应用中进入小组件配置页面"
echo "2. 点击任意选项（搜索引擎、应用等）"
echo "3. 查看控制台日志，确认是否有以下日志："
echo "   - '🔥🔥🔥 toggleXXX 被调用'"
echo "   - '🔥 DataSyncCenter.updateXXXSelection 被调用'"
echo "   - '🔥🔥🔥 立即同步到小组件开始'"
echo "   - '✅ App Groups保存成功'"
echo "4. 点击'保存'按钮"
echo "5. 查看是否有'🔥🔥🔥 手动保存所有配置开始'日志"
echo "6. 删除并重新添加小组件"
echo "7. 查看小组件是否显示新的配置"
echo ""

echo "🔍 关键检查点:"
echo "- 如果没有toggle日志：UI交互有问题"
echo "- 如果没有update日志：数据流有问题"
echo "- 如果没有同步日志：保存逻辑有问题"
echo "- 如果有所有日志但小组件仍显示默认值：小组件缓存问题"
echo ""

echo "🔍🔍🔍 用户交互流程测试完成！"
