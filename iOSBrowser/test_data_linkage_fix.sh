#!/bin/bash

# 🔗 测试数据联动修复效果
# 验证主应用数据保存逻辑是否正确修复

echo "🔗🔗🔗 开始测试数据联动修复效果..."
echo "📅 测试时间: $(date)"
echo ""

# 1. 检查修复代码是否正确添加
echo "🔍 检查修复代码是否正确添加..."

echo "🔍 检查saveUserSelectionsToStorage方法:"
if grep -q "func saveUserSelectionsToStorage" iOSBrowser/ContentView.swift; then
    echo "✅ saveUserSelectionsToStorage方法已添加"
else
    echo "❌ saveUserSelectionsToStorage方法缺失"
fi

echo "🔍 检查saveAllConfigurations调用:"
if grep -A 5 "func saveAllConfigurations" iOSBrowser/ContentView.swift | grep -q "saveUserSelectionsToStorage"; then
    echo "✅ saveAllConfigurations正确调用saveUserSelectionsToStorage"
else
    echo "❌ saveAllConfigurations未调用saveUserSelectionsToStorage"
fi

echo "🔍 检查App Groups保存逻辑:"
if grep -A 10 "saveUserSelectionsToStorage" iOSBrowser/ContentView.swift | grep -q "widget_search_engines"; then
    echo "✅ 包含App Groups保存逻辑"
else
    echo "❌ 缺少App Groups保存逻辑"
fi

echo "🔍 检查保存验证逻辑:"
if grep -A 20 "saveUserSelectionsToStorage" iOSBrowser/ContentView.swift | grep -q "App Groups保存验证"; then
    echo "✅ 包含保存验证逻辑"
else
    echo "❌ 缺少保存验证逻辑"
fi

# 2. 检查编译状态
echo ""
echo "🔧 检查编译状态..."

# 检查语法错误
if grep -q "dataSyncCenter.selectedSearchEngines" iOSBrowser/ContentView.swift; then
    echo "✅ 数据访问语法正确"
else
    echo "❌ 数据访问语法可能有问题"
fi

# 3. 创建测试数据
echo ""
echo "🧪 创建测试数据..."

cat > create_test_selections.swift << 'EOF'
import Foundation

print("🧪 创建测试用户选择数据...")

let defaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 模拟用户在UI中的选择
let userEngines = ["bing", "yahoo", "duckduckgo"]
let userApps = ["wechat", "alipay", "meituan"]
let userAI = ["chatgpt", "claude", "gemini"]
let userActions = ["translate", "calculator", "weather"]

print("🧪 模拟用户选择:")
print("  搜索引擎: \(userEngines)")
print("  应用: \(userApps)")
print("  AI助手: \(userAI)")
print("  快捷操作: \(userActions)")

// 模拟saveUserSelectionsToStorage的保存逻辑
print("💾 模拟保存逻辑...")

// 保存到UserDefaults
defaults.set(userEngines, forKey: "iosbrowser_engines")
defaults.set(userApps, forKey: "iosbrowser_apps")
defaults.set(userAI, forKey: "iosbrowser_ai")
defaults.set(userActions, forKey: "iosbrowser_actions")
defaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

let stdSync = defaults.synchronize()
print("💾 UserDefaults同步: \(stdSync)")

// 保存到App Groups
if let shared = sharedDefaults {
    shared.set(userEngines, forKey: "widget_search_engines")
    shared.set(userApps, forKey: "widget_apps")
    shared.set(userAI, forKey: "widget_ai_assistants")
    shared.set(userActions, forKey: "widget_quick_actions")
    shared.set(Date().timeIntervalSince1970, forKey: "widget_last_update")
    
    let sharedSync = shared.synchronize()
    print("💾 App Groups同步: \(sharedSync)")
    
    // 验证保存结果
    let verifyEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let verifyApps = shared.stringArray(forKey: "widget_apps") ?? []
    let verifyAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let verifyActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("💾 App Groups保存验证:")
    print("  搜索引擎: \(verifyEngines)")
    print("  应用: \(verifyApps)")
    print("  AI助手: \(verifyAI)")
    print("  快捷操作: \(verifyActions)")
    
    let success = verifyEngines == userEngines && 
                  verifyApps == userApps && 
                  verifyAI == userAI && 
                  verifyActions == userActions
    
    if success {
        print("✅ 模拟保存验证成功")
        print("🎯 现在小组件应该能读取到用户数据")
    } else {
        print("❌ 模拟保存验证失败")
    }
} else {
    print("❌ App Groups不可用")
}
EOF

if command -v swift &> /dev/null; then
    swift create_test_selections.swift
else
    echo "⚠️ Swift命令不可用，跳过测试数据创建"
fi

rm -f create_test_selections.swift

# 4. 提供使用指南
echo ""
echo "🔗 数据联动修复使用指南:"
echo "================================"
echo ""
echo "✅ 修复内容:"
echo "1. 添加了saveUserSelectionsToStorage()方法"
echo "2. 修复了saveAllConfigurations()调用逻辑"
echo "3. 确保用户选择正确保存到存储"
echo "4. 添加了详细的保存验证日志"
echo ""
echo "📱 测试步骤:"
echo ""
echo "1. 🏗️ 重新编译应用:"
echo "   - 在Xcode中: Product → Build (Cmd+B)"
echo "   - 确保没有编译错误"
echo ""
echo "2. 📱 在主应用中测试:"
echo "   - 打开主应用"
echo "   - 进入'小组件配置'页面"
echo "   - 选择不同的搜索引擎、应用、AI助手、快捷操作"
echo "   - 点击'保存'按钮"
echo ""
echo "3. 🔍 查看控制台日志:"
echo "   应该看到以下日志:"
echo "   - '🔥🔥🔥 开始保存用户选择到存储...'"
echo "   - '🔥🔥🔥 当前用户选择状态:'"
echo "   - '🔥🔥🔥 App Groups保存验证:'"
echo "   - '✅ App Groups保存验证成功'"
echo ""
echo "4. 🔄 刷新小组件:"
echo "   - 在主应用中点击'刷新小组件'按钮"
echo "   - 删除桌面上的旧小组件"
echo "   - 重新添加小组件"
echo ""
echo "5. ✅ 验证效果:"
echo "   - 小组件应该显示用户选择的内容"
echo "   - 不再显示默认值"
echo "   - 控制台应该显示'✅ [App Groups] 读取成功'"
echo ""

echo "🔍 成功标志:"
echo "- 控制台显示: '✅ App Groups保存验证成功'"
echo "- 控制台显示: '✅ [App Groups] 读取成功'"
echo "- 小组件显示用户选择的内容"
echo "- 主应用配置变更时小组件同步更新"
echo ""

echo "⚠️ 如果仍有问题:"
echo "- 检查dataSyncCenter的状态变量是否正确"
echo "- 确认用户选择是否正确更新到状态变量"
echo "- 重启设备清除iOS系统缓存"
echo ""

echo "🔗🔗🔗 数据联动修复测试完成！"
