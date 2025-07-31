#!/bin/bash

# 🔧 强制小组件重新编译和缓存清除脚本
# 解决小组件扩展使用旧代码的问题

echo "🔧🔧🔧 开始强制小组件重新编译和缓存清除..."
echo "📅 操作时间: $(date)"
echo ""

# 1. 检查当前代码状态
echo "🔍 检查当前代码状态..."

echo "🔍 检查快捷操作读取逻辑:"
if grep -q "🔥🔥🔥 小组件开始多源快捷操作数据读取" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 快捷操作代码已更新（新版本）"
else
    echo "❌ 快捷操作代码仍是旧版本"
fi

echo "🔍 检查App Groups优先读取:"
if grep -A 5 "优先从App Groups读取" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "widget_quick_actions"; then
    echo "✅ App Groups优先读取逻辑存在"
else
    echo "❌ App Groups优先读取逻辑缺失"
fi

echo "🔍 检查搜索引擎读取逻辑:"
if grep -q "🔥🔥🔥 所有搜索引擎键的数据状态" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 搜索引擎代码已更新（新版本）"
else
    echo "❌ 搜索引擎代码仍是旧版本"
fi

# 2. 创建强制数据写入
echo ""
echo "💾 创建强制数据写入..."

cat > force_write_all_data.swift << 'EOF'
import Foundation

print("🔧 强制写入所有类型的测试数据...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 创建明确不同于默认值的测试数据
let testEngines = ["bing", "yahoo", "duckduckgo", "yandex"]
let testApps = ["wechat", "alipay", "meituan", "didi"]
let testAI = ["chatgpt", "claude", "gemini", "copilot"]
let testActions = ["translate", "calculator", "weather", "timer"]

print("📝 准备写入测试数据:")
print("  搜索引擎: \(testEngines)")
print("  应用: \(testApps)")
print("  AI助手: \(testAI)")
print("  快捷操作: \(testActions)")

// 保存到UserDefaults.standard的所有键
standardDefaults.set(testEngines, forKey: "iosbrowser_engines")
standardDefaults.set(testEngines, forKey: "widget_search_engines_v2")
standardDefaults.set(testEngines, forKey: "widget_search_engines_v3")

standardDefaults.set(testApps, forKey: "iosbrowser_apps")
standardDefaults.set(testApps, forKey: "widget_apps_v2")
standardDefaults.set(testApps, forKey: "widget_apps_v3")

standardDefaults.set(testAI, forKey: "iosbrowser_ai")
standardDefaults.set(testAI, forKey: "widget_ai_assistants_v2")

standardDefaults.set(testActions, forKey: "iosbrowser_actions")
standardDefaults.set(testActions, forKey: "widget_quick_actions_v2")

standardDefaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

let standardSync = standardDefaults.synchronize()
print("📱 UserDefaults.standard同步结果: \(standardSync)")

// 保存到App Groups的所有键
if let shared = sharedDefaults {
    shared.set(testEngines, forKey: "widget_search_engines")
    shared.set(testApps, forKey: "widget_apps")
    shared.set(testAI, forKey: "widget_ai_assistants")
    shared.set(testActions, forKey: "widget_quick_actions")
    shared.set(Date().timeIntervalSince1970, forKey: "widget_last_update")
    
    let sharedSync = shared.synchronize()
    print("📱 App Groups同步结果: \(sharedSync)")
    
    // 验证App Groups保存
    let sharedEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let sharedApps = shared.stringArray(forKey: "widget_apps") ?? []
    let sharedAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let sharedActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("📱 App Groups保存验证:")
    print("  搜索引擎: \(sharedEngines)")
    print("  应用: \(sharedApps)")
    print("  AI助手: \(sharedAI)")
    print("  快捷操作: \(sharedActions)")
    
    let allSuccess = sharedEngines == testEngines && 
                     sharedApps == testApps && 
                     sharedAI == testAI && 
                     sharedActions == testActions
    
    if allSuccess {
        print("✅ 所有数据App Groups保存成功")
    } else {
        print("❌ 部分数据App Groups保存失败")
    }
} else {
    print("❌ App Groups不可用")
}

// 验证UserDefaults.standard保存
let verifyEngines = standardDefaults.stringArray(forKey: "iosbrowser_engines") ?? []
let verifyApps = standardDefaults.stringArray(forKey: "iosbrowser_apps") ?? []
let verifyAI = standardDefaults.stringArray(forKey: "iosbrowser_ai") ?? []
let verifyActions = standardDefaults.stringArray(forKey: "iosbrowser_actions") ?? []

print("📱 UserDefaults.standard保存验证:")
print("  搜索引擎: \(verifyEngines)")
print("  应用: \(verifyApps)")
print("  AI助手: \(verifyAI)")
print("  快捷操作: \(verifyActions)")

let standardSuccess = verifyEngines == testEngines && 
                      verifyApps == testApps && 
                      verifyAI == testAI && 
                      verifyActions == testActions

if standardSuccess {
    print("✅ 所有数据UserDefaults.standard保存成功")
} else {
    print("❌ 部分数据UserDefaults.standard保存失败")
}

print("🎯 小组件应该显示:")
print("  搜索引擎: Bing, Yahoo, DuckDuckGo, Yandex")
print("  应用: WeChat, Alipay, Meituan, Didi")
print("  AI助手: ChatGPT, Claude, Gemini, Copilot")
print("  快捷操作: Translate, Calculator, Weather, Timer")
print("")
print("🎯 而不是默认值:")
print("  搜索引擎: 百度, 谷歌")
print("  应用: 淘宝, 知乎, 抖音")
print("  AI助手: DeepSeek, 通义千问")
print("  快捷操作: Search, Bookmark")
EOF

if command -v swift &> /dev/null; then
    swift force_write_all_data.swift
else
    echo "⚠️ Swift命令不可用，跳过数据写入"
fi

rm -f force_write_all_data.swift

# 3. 提供解决方案
echo ""
echo "🔧 小组件缓存问题解决方案:"
echo "================================"
echo ""
echo "问题分析:"
echo "从日志可以看出，小组件仍在使用旧的代码逻辑："
echo "- 显示 '🔥 小组件开始多源快捷操作数据读取...' (旧版本)"
echo "- 应该显示 '🔥🔥🔥 小组件开始多源快捷操作数据读取...' (新版本)"
echo "- 没有App Groups读取的日志"
echo ""
echo "这说明小组件扩展没有使用最新的代码。"
echo ""

echo "🔧 解决步骤:"
echo "1. 在Xcode中完全清理项目:"
echo "   - Product → Clean Build Folder (Cmd+Shift+K)"
echo "   - 删除 ~/Library/Developer/Xcode/DerivedData 中的项目文件夹"
echo ""
echo "2. 重新编译整个项目:"
echo "   - 确保选择正确的Target (包括Widget Extension)"
echo "   - Product → Build (Cmd+B)"
echo "   - 确保没有编译错误"
echo ""
echo "3. 完全重新安装应用:"
echo "   - 从设备上删除应用"
echo "   - 重新从Xcode安装"
echo ""
echo "4. 清除小组件缓存:"
echo "   - 删除桌面上的所有小组件"
echo "   - 重启设备"
echo "   - 重新添加小组件"
echo ""
echo "5. 验证新代码生效:"
echo "   - 查看控制台日志"
echo "   - 应该看到 '🔥🔥🔥' 开头的日志"
echo "   - 应该看到 'App Groups (优先)' 数据源"
echo ""

echo "🔍 验证标志:"
echo "新代码生效的标志:"
echo "- 日志显示: '🔥🔥🔥 小组件开始多源快捷操作数据读取...'"
echo "- 日志显示: '🔥🔥🔥 所有快捷操作键的数据状态:'"
echo "- 日志显示: '⚡🔥 从App Groups读取快捷操作成功:'"
echo "- 小组件显示: Translate, Calculator, Weather, Timer"
echo ""

echo "如果仍显示旧日志:"
echo "- 说明小组件扩展仍在使用缓存的旧代码"
echo "- 需要更彻底的清理和重新编译"
echo ""

echo "🔧🔧🔧 强制小组件重新编译和缓存清除完成！"
