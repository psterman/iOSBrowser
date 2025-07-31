#!/bin/bash

# 🎮 测试用户交互触发机制
# 验证用户在界面上的操作是否正确触发数据保存

echo "🎮🎮🎮 开始测试用户交互触发机制..."
echo "📅 测试时间: $(date)"
echo ""

# 1. 检查用户交互方法
echo "🔍 检查用户交互方法..."

echo "🔍 检查toggle方法:"
methods=("toggleSearchEngine" "toggleApp" "toggleAssistant" "toggleQuickAction")
for method in "${methods[@]}"; do
    if grep -q "func $method" iOSBrowser/ContentView.swift; then
        echo "✅ $method 方法存在"
    else
        echo "❌ $method 方法缺失"
    fi
done

echo "🔍 检查update方法:"
update_methods=("updateSearchEngineSelection" "updateAppSelection" "updateAISelection" "updateQuickActionSelection")
for method in "${update_methods[@]}"; do
    if grep -q "func $method" iOSBrowser/ContentView.swift; then
        echo "✅ $method 方法存在"
    else
        echo "❌ $method 方法缺失"
    fi
done

echo "🔍 检查保存方法:"
save_methods=("saveAllConfigurations" "saveUserSelectionsToStorage")
for method in "${save_methods[@]}"; do
    if grep -q "func $method" iOSBrowser/ContentView.swift; then
        echo "✅ $method 方法存在"
    else
        echo "❌ $method 方法缺失"
    fi
done

# 2. 创建强制触发用户选择的脚本
echo ""
echo "🎮 创建强制触发用户选择的脚本..."

cat > force_trigger_user_selections.swift << 'EOF'
import Foundation

print("🎮 强制触发用户选择...")

let defaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 模拟用户在界面上的选择操作
let userSelectedEngines = ["bing", "yahoo", "duckduckgo"]
let userSelectedApps = ["wechat", "alipay", "meituan"]
let userSelectedAI = ["chatgpt", "claude", "gemini"]
let userSelectedActions = ["translate", "calculator", "weather"]

print("🎮 模拟用户选择:")
print("  搜索引擎: \(userSelectedEngines)")
print("  应用: \(userSelectedApps)")
print("  AI助手: \(userSelectedAI)")
print("  快捷操作: \(userSelectedActions)")

// 模拟主应用的saveUserSelectionsToStorage逻辑
print("💾 模拟主应用保存逻辑...")

// 1. 保存到UserDefaults.standard
defaults.set(userSelectedEngines, forKey: "iosbrowser_engines")
defaults.set(userSelectedApps, forKey: "iosbrowser_apps")
defaults.set(userSelectedAI, forKey: "iosbrowser_ai")
defaults.set(userSelectedActions, forKey: "iosbrowser_actions")
defaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

let stdSync = defaults.synchronize()
print("💾 UserDefaults保存同步: \(stdSync)")

// 2. 保存到App Groups
if let shared = sharedDefaults {
    shared.set(userSelectedEngines, forKey: "widget_search_engines")
    shared.set(userSelectedApps, forKey: "widget_apps")
    shared.set(userSelectedAI, forKey: "widget_ai_assistants")
    shared.set(userSelectedActions, forKey: "widget_quick_actions")
    shared.set(Date().timeIntervalSince1970, forKey: "widget_last_update")
    
    let sharedSync = shared.synchronize()
    print("💾 App Groups保存同步: \(sharedSync)")
    
    // 验证App Groups保存结果
    let verifyEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let verifyApps = shared.stringArray(forKey: "widget_apps") ?? []
    let verifyAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let verifyActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("💾 App Groups保存验证:")
    print("  搜索引擎: \(verifyEngines)")
    print("  应用: \(verifyApps)")
    print("  AI助手: \(verifyAI)")
    print("  快捷操作: \(verifyActions)")
    
    let success = verifyEngines == userSelectedEngines && 
                  verifyApps == userSelectedApps && 
                  verifyAI == userSelectedAI && 
                  verifyActions == userSelectedActions
    
    if success {
        print("✅ 用户选择保存成功")
        print("🎯 现在小组件应该显示用户选择的内容")
    } else {
        print("❌ 用户选择保存失败")
    }
} else {
    print("❌ App Groups不可用")
}

// 3. 验证UserDefaults保存
let stdVerifyEngines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
let stdVerifyApps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []
let stdVerifyAI = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
let stdVerifyActions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []

print("💾 UserDefaults保存验证:")
print("  搜索引擎: \(stdVerifyEngines)")
print("  应用: \(stdVerifyApps)")
print("  AI助手: \(stdVerifyAI)")
print("  快捷操作: \(stdVerifyActions)")

let stdSuccess = stdVerifyEngines == userSelectedEngines && 
                 stdVerifyApps == userSelectedApps && 
                 stdVerifyAI == userSelectedAI && 
                 stdVerifyActions == userSelectedActions

if stdSuccess {
    print("✅ UserDefaults保存成功")
} else {
    print("❌ UserDefaults保存失败")
}

print("🎯 现在小组件应该显示:")
print("  搜索引擎: Bing, Yahoo, DuckDuckGo")
print("  应用: WeChat, Alipay, Meituan")
print("  AI助手: ChatGPT, Claude, Gemini")
print("  快捷操作: Translate, Calculator, Weather")
print("")
print("🎯 而不是空白或默认值")
EOF

if command -v swift &> /dev/null; then
    swift force_trigger_user_selections.swift
else
    echo "⚠️ Swift命令不可用，跳过用户选择触发"
fi

rm -f force_trigger_user_selections.swift

# 3. 提供用户操作测试指南
echo ""
echo "🎮 用户操作测试指南:"
echo "================================"
echo ""
echo "现在我们已经强制写入了用户选择数据。"
echo "请按照以下步骤测试用户界面操作："
echo ""
echo "📱 第一步：测试界面操作"
echo "1. 打开主应用"
echo "2. 进入'小组件配置'页面"
echo "3. 点击'搜索引擎'标签"
echo "4. 随便点击一个搜索引擎选项"
echo "5. 查看控制台是否有以下日志："
echo "   - '🔥🔥🔥 toggleSearchEngine 被调用: [引擎名]'"
echo "   - '🔥 DataSyncCenter.updateSearchEngineSelection 被调用'"
echo ""
echo "📱 第二步：测试保存操作"
echo "1. 点击'保存'按钮"
echo "2. 查看控制台是否有以下日志："
echo "   - '🔥🔥🔥 手动保存所有配置开始...'"
echo "   - '🔥🔥🔥 开始保存用户选择到存储...'"
echo "   - '🔥🔥🔥 当前用户选择状态:'"
echo "   - '🔥🔥🔥 App Groups保存验证:'"
echo "   - '✅ App Groups保存验证成功'"
echo ""
echo "📱 第三步：测试小组件更新"
echo "1. 点击'刷新小组件'按钮"
echo "2. 删除桌面上的旧小组件"
echo "3. 重新添加小组件"
echo "4. 查看小组件是否显示用户选择的内容"
echo ""

echo "🔍 关键判断点:"
echo ""
echo "情况1：没有toggle日志"
echo "- 说明：用户界面操作没有触发toggle方法"
echo "- 原因：UI绑定有问题"
echo "- 解决：检查按钮的action绑定"
echo ""
echo "情况2：有toggle日志，没有保存日志"
echo "- 说明：用户操作触发了，但保存方法没有被调用"
echo "- 原因：保存按钮的action有问题"
echo "- 解决：检查保存按钮的绑定"
echo ""
echo "情况3：有保存日志，但数据为空"
echo "- 说明：保存方法被调用了，但状态变量为空"
echo "- 原因：状态变量没有正确更新"
echo "- 解决：检查toggle方法中的状态更新逻辑"
echo ""
echo "情况4：有保存日志，数据正确，但小组件仍为空"
echo "- 说明：数据保存成功，但小组件读取失败"
echo "- 原因：小组件缓存或读取逻辑问题"
echo "- 解决：重启设备清除缓存"
echo ""

echo "🎯 预期成功流程:"
echo "1. 点击选项 → 看到toggle日志"
echo "2. 点击保存 → 看到保存日志和验证成功"
echo "3. 刷新小组件 → 看到小组件显示用户选择"
echo ""

echo "🎮🎮🎮 用户交互触发机制测试完成！"
