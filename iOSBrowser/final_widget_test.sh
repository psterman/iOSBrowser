#!/bin/bash

# 🎯 最终小组件测试
# 验证增强调试后的小组件数据读取

echo "🎯🎯🎯 开始最终小组件测试..."
echo "📅 测试时间: $(date)"
echo ""

# 1. 确认数据状态
echo "🔍 确认当前数据状态..."

cat > confirm_data_status.swift << 'EOF'
import Foundation

print("🔍 确认当前数据状态...")

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
    
    let hasData = !sharedEngines.isEmpty || !sharedApps.isEmpty || !sharedAI.isEmpty || !sharedActions.isEmpty
    if hasData {
        print("✅ App Groups中有数据")
        print("🎯 小组件应该能读取到这些数据")
    } else {
        print("❌ App Groups中没有数据")
        print("🎯 需要重新写入数据")
    }
} else {
    print("❌ App Groups不可用")
}
EOF

if command -v swift &> /dev/null; then
    swift confirm_data_status.swift
else
    echo "⚠️ Swift命令不可用，跳过数据状态确认"
fi

rm -f confirm_data_status.swift

# 2. 检查增强调试是否添加成功
echo ""
echo "🔍 检查增强调试是否添加成功..."

echo "🔍 检查详细日志:"
if grep -q "App Groups同步:" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 增强调试日志已添加"
else
    echo "❌ 增强调试日志缺失"
fi

echo "🔍 检查App Groups对象检查:"
if grep -q "UserDefaults对象创建成功" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ App Groups对象检查已添加"
else
    echo "❌ App Groups对象检查缺失"
fi

echo "🔍 检查备用键详细日志:"
if grep -q "尝试备用键:" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 备用键详细日志已添加"
else
    echo "❌ 备用键详细日志缺失"
fi

# 3. 提供最终测试指南
echo ""
echo "🎯 最终测试指南:"
echo "================================"
echo ""
echo "现在小组件有了增强的调试日志，可以精确定位问题。"
echo ""
echo "📱 测试步骤:"
echo ""
echo "1. 🏗️ 重新编译应用:"
echo "   - 在Xcode中: Product → Build (Cmd+B)"
echo "   - 重新安装到设备"
echo ""
echo "2. 🔄 刷新小组件:"
echo "   - 删除桌面上的所有小组件"
echo "   - 重新添加小组件"
echo ""
echo "3. 🔍 查看详细日志:"
echo "   现在应该看到更详细的日志:"
echo "   - '🔍 [WidgetDataManager] UserDefaults同步: true/false'"
echo "   - '🔍 [WidgetDataManager] App Groups同步: true/false'"
echo "   - '🔍 [App Groups] UserDefaults对象创建成功' 或 '❌ [App Groups] UserDefaults对象创建失败'"
echo "   - '🔍 [App Groups] 读取结果: widget_search_engines = [...]'"
echo ""

echo "🔍 关键判断点:"
echo ""
echo "情况1：看到'❌ [App Groups] UserDefaults对象创建失败'"
echo "- 说明：小组件扩展没有App Groups权限"
echo "- 解决：在Xcode中检查Widget Extension的Capabilities"
echo "- 确保添加了'App Groups'并选择'group.com.iosbrowser.shared'"
echo ""
echo "情况2：看到'🔍 [App Groups] UserDefaults对象创建成功'但'⚠️ [App Groups] 数据为空'"
echo "- 说明：权限正常，但数据读取失败"
echo "- 可能：沙盒隔离或数据同步问题"
echo "- 解决：重启设备，重新安装应用"
echo ""
echo "情况3：看到'🔍 [App Groups] 读取结果: widget_search_engines = [数据]'"
echo "- 说明：数据读取成功"
echo "- 小组件应该显示用户数据"
echo "- 如果仍显示空白，可能是UI渲染问题"
echo ""
echo "情况4：看到'✅ [备用键] 读取成功'"
echo "- 说明：App Groups失败，但UserDefaults成功"
echo "- 小组件应该显示用户数据"
echo "- 需要修复App Groups权限"
echo ""

echo "🎯 预期成功日志:"
echo "- '🔍 [App Groups] UserDefaults对象创建成功'"
echo "- '🔍 [App Groups] 读取结果: widget_search_engines = [\"bing_...\", \"yahoo_...\"]'"
echo "- '✅ [App Groups] 读取成功: widget_search_engines = [...]'"
echo "- '🔍 [getSearchEngines] 最终返回: [\"bing_...\", \"yahoo_...\"]'"
echo ""

echo "🔧 如果仍然失败:"
echo "1. 检查Xcode中Widget Extension的App Groups配置"
echo "2. 完全删除应用，重新安装"
echo "3. 重启设备"
echo "4. 联系我进行进一步诊断"
echo ""

echo "🎯🎯🎯 最终小组件测试准备完成！"
echo "现在请重新编译并测试，查看详细的调试日志。"
