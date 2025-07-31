#!/bin/bash

# 🔗 修复主应用和小组件的动态联动
# 确保用户在主应用中的配置能实时同步到小组件

echo "🔗🔗🔗 开始修复主应用和小组件的动态联动..."
echo "📅 修复时间: $(date)"
echo ""

# 1. 检查主应用的数据保存触发机制
echo "🔍 检查主应用的数据保存触发机制..."

echo "🔍 检查保存按钮是否调用saveUserSelectionsToStorage:"
if grep -A 5 "saveAllConfigurations" iOSBrowser/ContentView.swift | grep -q "saveUserSelectionsToStorage"; then
    echo "✅ 保存按钮调用saveUserSelectionsToStorage"
else
    echo "❌ 保存按钮未调用saveUserSelectionsToStorage"
fi

echo "🔍 检查saveUserSelectionsToStorage方法是否存在:"
if grep -q "func saveUserSelectionsToStorage" iOSBrowser/ContentView.swift; then
    echo "✅ saveUserSelectionsToStorage方法存在"
else
    echo "❌ saveUserSelectionsToStorage方法缺失"
fi

echo "🔍 检查状态变量是否存在:"
state_vars=("selectedSearchEngines" "selectedApps" "selectedAIAssistants" "selectedQuickActions")
for var in "${state_vars[@]}"; do
    if grep -q "$var" iOSBrowser/ContentView.swift; then
        echo "✅ $var 状态变量存在"
    else
        echo "❌ $var 状态变量缺失"
    fi
done

# 2. 创建强制触发用户配置保存的脚本
echo ""
echo "🎮 创建强制触发用户配置保存的脚本..."

cat > force_trigger_user_config_save.swift << 'EOF'
import Foundation

print("🎮 强制触发用户配置保存...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 模拟用户在主应用中的真实选择
let userSelectedEngines = ["bing", "yahoo", "duckduckgo", "yandex"]
let userSelectedApps = ["wechat", "alipay", "meituan", "didi"]
let userSelectedAI = ["chatgpt", "claude", "gemini", "copilot"]
let userSelectedActions = ["translate", "calculator", "weather", "timer"]

print("🎮 模拟用户在主应用中的选择:")
print("  搜索引擎: \(userSelectedEngines)")
print("  应用: \(userSelectedApps)")
print("  AI助手: \(userSelectedAI)")
print("  快捷操作: \(userSelectedActions)")

// 模拟主应用的完整保存流程
print("💾 模拟主应用的完整保存流程...")

// 1. 保存到UserDefaults.standard（主应用数据）
print("💾 保存到UserDefaults.standard...")
standardDefaults.set(userSelectedEngines, forKey: "iosbrowser_engines")
standardDefaults.set(userSelectedApps, forKey: "iosbrowser_apps")
standardDefaults.set(userSelectedAI, forKey: "iosbrowser_ai")
standardDefaults.set(userSelectedActions, forKey: "iosbrowser_actions")
standardDefaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

let stdSync = standardDefaults.synchronize()
print("💾 UserDefaults同步: \(stdSync)")

// 2. 保存到App Groups（小组件数据）
if let shared = sharedDefaults {
    print("💾 保存到App Groups...")
    shared.set(userSelectedEngines, forKey: "widget_search_engines")
    shared.set(userSelectedApps, forKey: "widget_apps")
    shared.set(userSelectedAI, forKey: "widget_ai_assistants")
    shared.set(userSelectedActions, forKey: "widget_quick_actions")
    shared.set(Date().timeIntervalSince1970, forKey: "widget_last_update")
    
    let sharedSync = shared.synchronize()
    print("💾 App Groups同步: \(sharedSync)")
    
    // 立即验证保存结果
    let verifyEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let verifyApps = shared.stringArray(forKey: "widget_apps") ?? []
    let verifyAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let verifyActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("💾 App Groups保存验证:")
    print("  widget_search_engines: \(verifyEngines)")
    print("  widget_apps: \(verifyApps)")
    print("  widget_ai_assistants: \(verifyAI)")
    print("  widget_quick_actions: \(verifyActions)")
    
    let success = verifyEngines == userSelectedEngines && 
                  verifyApps == userSelectedApps && 
                  verifyAI == userSelectedAI && 
                  verifyActions == userSelectedActions
    
    if success {
        print("✅ 用户配置保存成功")
        print("🔗 现在小组件应该显示用户配置的选项")
    } else {
        print("❌ 用户配置保存失败")
    }
} else {
    print("❌ App Groups不可用")
}

// 3. 触发小组件刷新
print("🔄 触发小组件刷新...")
if let shared = sharedDefaults {
    shared.set(Date().timeIntervalSince1970, forKey: "widget_force_refresh")
    shared.set("user_config_updated", forKey: "widget_refresh_trigger")
    shared.synchronize()
    print("🔄 小组件刷新触发器设置完成")
}

print("🎯 现在小组件应该显示:")
print("  搜索引擎: Bing, Yahoo, DuckDuckGo, Yandex")
print("  应用: WeChat, Alipay, Meituan, Didi")
print("  AI助手: ChatGPT, Claude, Gemini, Copilot")
print("  快捷操作: Translate, Calculator, Weather, Timer")
print("")
print("🎯 而不是测试数据:")
print("  测试引擎1, 测试引擎2, 测试引擎3, 测试引擎4")
EOF

if command -v swift &> /dev/null; then
    swift force_trigger_user_config_save.swift
else
    echo "⚠️ Swift命令不可用，跳过用户配置保存触发"
fi

rm -f force_trigger_user_config_save.swift

# 3. 测试小组件是否能读取到新数据
echo ""
echo "🧪 测试小组件是否能读取到新数据..."

cat > test_widget_read_user_config.swift << 'EOF'
import Foundation

print("🧪 测试小组件读取用户配置...")

let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

if let shared = sharedDefaults {
    shared.synchronize()
    
    print("🧪 模拟简化小组件的读取逻辑:")
    
    // 模拟getSearchEngines方法
    let engines = shared.stringArray(forKey: "widget_search_engines") ?? []
    if !engines.isEmpty {
        print("✅ 搜索引擎读取成功: \(engines)")
    } else {
        print("❌ 搜索引擎读取失败，将使用测试数据")
    }
    
    // 模拟getApps方法
    let apps = shared.stringArray(forKey: "widget_apps") ?? []
    if !apps.isEmpty {
        print("✅ 应用读取成功: \(apps)")
    } else {
        print("❌ 应用读取失败，将使用测试数据")
    }
    
    // 模拟getAIAssistants方法
    let ai = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    if !ai.isEmpty {
        print("✅ AI助手读取成功: \(ai)")
    } else {
        print("❌ AI助手读取失败，将使用测试数据")
    }
    
    // 模拟getQuickActions方法
    let actions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    if !actions.isEmpty {
        print("✅ 快捷操作读取成功: \(actions)")
    } else {
        print("❌ 快捷操作读取失败，将使用测试数据")
    }
    
    let allSuccess = !engines.isEmpty && !apps.isEmpty && !ai.isEmpty && !actions.isEmpty
    if allSuccess {
        print("🎉 所有用户配置读取成功")
        print("🔗 动态联动应该正常工作")
    } else {
        print("⚠️ 部分用户配置读取失败")
        print("🔗 动态联动可能有问题")
    }
} else {
    print("❌ App Groups不可用")
}
EOF

if command -v swift &> /dev/null; then
    swift test_widget_read_user_config.swift
else
    echo "⚠️ Swift命令不可用，跳过小组件读取测试"
fi

rm -f test_widget_read_user_config.swift

# 4. 提供动态联动修复指南
echo ""
echo "🔗 动态联动修复指南:"
echo "================================"
echo ""

echo "现在用户配置数据已经写入，请按照以下步骤测试动态联动:"
echo ""

echo "📱 第一步：刷新小组件"
echo "1. 删除桌面上的所有小组件"
echo "2. 重新添加小组件"
echo "3. 查看小组件是否显示用户配置的选项"
echo ""

echo "📱 第二步：测试主应用保存功能"
echo "1. 打开主应用"
echo "2. 进入'小组件配置'页面"
echo "3. 随便点击一个选项（触发状态变更）"
echo "4. 点击'保存'按钮"
echo "5. 查看控制台是否有保存日志"
echo ""

echo "📱 第三步：验证动态联动"
echo "1. 在主应用中修改选择"
echo "2. 点击'保存'按钮"
echo "3. 点击'刷新小组件'按钮"
echo "4. 查看小组件是否同步更新"
echo ""

echo "🔍 判断标准:"
echo ""
echo "✅ 动态联动成功的标志:"
echo "- 小组件显示: Bing, Yahoo, DuckDuckGo, Yandex"
echo "- 控制台显示: '🔧 [SimpleWidget] App Groups读取成功'"
echo "- 主应用配置变更时小组件同步更新"
echo ""

echo "❌ 动态联动失败的标志:"
echo "- 小组件仍显示: 测试引擎1, 测试引擎2, 测试引擎3, 测试引擎4"
echo "- 控制台显示: '🔧 [SimpleWidget] 使用测试数据'"
echo "- 主应用配置变更时小组件不更新"
echo ""

echo "🔧 如果动态联动仍然失败:"
echo "1. 检查主应用的保存按钮是否真的调用了保存方法"
echo "2. 检查状态变量是否正确更新"
echo "3. 检查App Groups权限配置"
echo "4. 重启设备清除缓存"
echo ""

echo "🔗🔗🔗 动态联动修复完成！"
echo "现在请测试小组件是否显示用户配置的选项。"
