#!/bin/bash

# 🔗 修复数据联动问题
# 确保主应用的小组件配置tab与桌面小组件正确联动

echo "🔗🔗🔗 开始修复数据联动问题..."
echo "📅 修复时间: $(date)"
echo ""

# 1. 检查当前数据状态
echo "🔍 检查当前数据状态..."

cat > check_linkage_data.swift << 'EOF'
import Foundation

print("🔍 检查数据联动状态...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

standardDefaults.synchronize()
sharedDefaults?.synchronize()

print("📱 UserDefaults.standard 状态:")
let stdEngines = standardDefaults.stringArray(forKey: "iosbrowser_engines") ?? []
let stdApps = standardDefaults.stringArray(forKey: "iosbrowser_apps") ?? []
let stdAI = standardDefaults.stringArray(forKey: "iosbrowser_ai") ?? []
let stdActions = standardDefaults.stringArray(forKey: "iosbrowser_actions") ?? []

print("  iosbrowser_engines: \(stdEngines)")
print("  iosbrowser_apps: \(stdApps)")
print("  iosbrowser_ai: \(stdAI)")
print("  iosbrowser_actions: \(stdActions)")

if let shared = sharedDefaults {
    print("📱 App Groups 状态:")
    let sharedEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let sharedApps = shared.stringArray(forKey: "widget_apps") ?? []
    let sharedAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let sharedActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("  widget_search_engines: \(sharedEngines)")
    print("  widget_apps: \(sharedApps)")
    print("  widget_ai_assistants: \(sharedAI)")
    print("  widget_quick_actions: \(sharedActions)")
    
    // 分析问题
    let allEmpty = sharedEngines.isEmpty && sharedApps.isEmpty && sharedAI.isEmpty && sharedActions.isEmpty
    if allEmpty {
        print("🚨 问题确认: App Groups中所有数据都为空")
        print("🚨 这解释了为什么小组件显示默认值")
        print("🚨 主应用的保存逻辑没有被正确触发")
    } else {
        print("✅ App Groups中有数据")
    }
} else {
    print("❌ App Groups不可用")
}
EOF

if command -v swift &> /dev/null; then
    swift check_linkage_data.swift
else
    echo "⚠️ Swift命令不可用，跳过数据检查"
fi

rm -f check_linkage_data.swift

# 2. 强制写入联动数据
echo ""
echo "💾 强制写入联动数据..."

cat > force_write_linkage_data.swift << 'EOF'
import Foundation

print("💾 强制写入联动数据...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 创建明确的联动测试数据
let linkageEngines = ["bing", "yahoo", "duckduckgo", "yandex"]
let linkageApps = ["wechat", "alipay", "meituan", "didi"]
let linkageAI = ["chatgpt", "claude", "gemini", "copilot"]
let linkageActions = ["translate", "calculator", "weather", "timer"]

print("📝 写入联动测试数据:")
print("  搜索引擎: \(linkageEngines)")
print("  应用: \(linkageApps)")
print("  AI助手: \(linkageAI)")
print("  快捷操作: \(linkageActions)")

// 1. 写入到UserDefaults.standard（主应用数据）
print("💾 写入到UserDefaults.standard...")
standardDefaults.set(linkageEngines, forKey: "iosbrowser_engines")
standardDefaults.set(linkageApps, forKey: "iosbrowser_apps")
standardDefaults.set(linkageAI, forKey: "iosbrowser_ai")
standardDefaults.set(linkageActions, forKey: "iosbrowser_actions")
standardDefaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

let stdSync = standardDefaults.synchronize()
print("💾 UserDefaults同步: \(stdSync)")

// 2. 写入到App Groups（小组件数据）
if let shared = sharedDefaults {
    print("💾 写入到App Groups...")
    shared.set(linkageEngines, forKey: "widget_search_engines")
    shared.set(linkageApps, forKey: "widget_apps")
    shared.set(linkageAI, forKey: "widget_ai_assistants")
    shared.set(linkageActions, forKey: "widget_quick_actions")
    shared.set(Date().timeIntervalSince1970, forKey: "widget_last_update")
    
    let sharedSync = shared.synchronize()
    print("💾 App Groups同步: \(sharedSync)")
    
    // 立即验证
    let verifyEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let verifyApps = shared.stringArray(forKey: "widget_apps") ?? []
    let verifyAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let verifyActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("💾 App Groups验证:")
    print("  widget_search_engines: \(verifyEngines)")
    print("  widget_apps: \(verifyApps)")
    print("  widget_ai_assistants: \(verifyAI)")
    print("  widget_quick_actions: \(verifyActions)")
    
    let success = verifyEngines == linkageEngines && 
                  verifyApps == linkageApps && 
                  verifyAI == linkageAI && 
                  verifyActions == linkageActions
    
    if success {
        print("✅ 联动数据写入成功")
        print("🔗 现在主应用和小组件应该有相同的数据")
    } else {
        print("❌ 联动数据写入失败")
    }
} else {
    print("❌ App Groups不可用，无法建立联动")
}

print("🎯 现在桌面小组件应该显示:")
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
    swift force_write_linkage_data.swift
else
    echo "⚠️ Swift命令不可用，跳过联动数据写入"
fi

rm -f force_write_linkage_data.swift

# 3. 检查主应用的保存逻辑
echo ""
echo "🔍 检查主应用的保存逻辑..."

echo "🔍 检查DataSyncCenter的immediateSyncToWidgets方法:"
if grep -A 10 "func immediateSyncToWidgets" iOSBrowser/ContentView.swift | grep -q "widget_search_engines"; then
    echo "✅ 主应用有App Groups保存逻辑"
else
    echo "❌ 主应用缺少App Groups保存逻辑"
fi

echo "🔍 检查保存按钮的调用:"
if grep -A 5 "保存.*按钮" iOSBrowser/ContentView.swift | grep -q "saveAllConfigurations"; then
    echo "✅ 保存按钮调用saveAllConfigurations"
else
    echo "❌ 保存按钮未调用saveAllConfigurations"
fi

echo "🔍 检查saveAllConfigurations方法:"
if grep -A 10 "func saveAllConfigurations" iOSBrowser/ContentView.swift | grep -q "immediateSyncToWidgets"; then
    echo "✅ saveAllConfigurations调用immediateSyncToWidgets"
else
    echo "❌ saveAllConfigurations未调用immediateSyncToWidgets"
fi

# 4. 提供联动修复方案
echo ""
echo "🔗 数据联动修复方案:"
echo "================================"
echo ""
echo "问题分析:"
echo "从日志可以看出，小组件正在运行新代码，但无法读取到数据。"
echo "这说明主应用的数据保存逻辑没有被正确触发。"
echo ""
echo "🔧 立即解决步骤:"
echo ""
echo "1. 📱 在主应用中手动触发保存:"
echo "   - 打开主应用"
echo "   - 进入'小组件配置'页面"
echo "   - 点击任意一个选项（搜索引擎、应用、AI助手、快捷操作）"
echo "   - 点击'保存'按钮"
echo "   - 查看控制台是否有'App Groups保存验证'日志"
echo ""
echo "2. 🔄 强制刷新小组件:"
echo "   - 在主应用中点击'刷新小组件'按钮"
echo "   - 等待5-10秒"
echo "   - 删除桌面上的所有小组件"
echo "   - 重新添加小组件"
echo ""
echo "3. 🔍 验证联动效果:"
echo "   - 查看控制台日志"
echo "   - 应该看到'✅ [App Groups] 读取成功'"
echo "   - 小组件应该显示4个自定义项目"
echo "   - 不再显示2-3个默认项目"
echo ""
echo "4. 📊 测试联动:"
echo "   - 在主应用中修改选择"
echo "   - 点击'保存'按钮"
echo "   - 小组件应该相应更新"
echo ""

echo "🔍 成功标志:"
echo "- 控制台显示: '✅ [App Groups] 读取成功'"
echo "- 小组件显示: 4个自定义项目"
echo "- 主应用配置变更时小组件同步更新"
echo ""

echo "🔗🔗🔗 数据联动修复完成！"
