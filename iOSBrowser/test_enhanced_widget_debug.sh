#!/bin/bash

# 🔧 测试增强调试的小组件
# 验证详细调试信息是否能帮助找出问题

echo "🔧🔧🔧 开始测试增强调试的小组件..."
echo "📅 测试时间: $(date)"
echo ""

# 1. 检查增强调试是否添加成功
echo "🔍 检查增强调试是否添加成功..."

echo "🔍 检查详细App Groups调试:"
if grep -q "App Groups UserDefaults创建成功" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 详细App Groups调试已添加"
else
    echo "❌ 详细App Groups调试缺失"
fi

echo "🔍 检查同步结果调试:"
if grep -q "同步结果:" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 同步结果调试已添加"
else
    echo "❌ 同步结果调试缺失"
fi

echo "🔍 检查读取结果调试:"
if grep -q "读取结果:" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 读取结果调试已添加"
else
    echo "❌ 读取结果调试缺失"
fi

# 2. 确保数据是最新的
echo ""
echo "💾 确保数据是最新的..."

cat > ensure_latest_data.swift << 'EOF'
import Foundation

print("💾 确保数据是最新的...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 使用当前时间戳确保数据是最新的
let timestamp = Int(Date().timeIntervalSince1970)
let engines = ["bing_\(timestamp)", "yahoo_\(timestamp)", "duckduckgo_\(timestamp)", "yandex_\(timestamp)"]
let apps = ["wechat_\(timestamp)", "alipay_\(timestamp)", "meituan_\(timestamp)", "didi_\(timestamp)"]
let ai = ["chatgpt_\(timestamp)", "claude_\(timestamp)", "gemini_\(timestamp)", "copilot_\(timestamp)"]
let actions = ["translate_\(timestamp)", "calculator_\(timestamp)", "weather_\(timestamp)", "timer_\(timestamp)"]

print("💾 写入最新数据 (时间戳: \(timestamp)):")
print("  搜索引擎: \(engines)")
print("  应用: \(apps)")
print("  AI助手: \(ai)")
print("  快捷操作: \(actions)")

// 写入到所有位置
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
    
    print("✅ 最新数据写入完成")
    print("🎯 现在小组件应该显示带时间戳 \(timestamp) 的数据")
} else {
    print("❌ App Groups不可用")
}
EOF

if command -v swift &> /dev/null; then
    swift ensure_latest_data.swift
else
    echo "⚠️ Swift命令不可用，跳过最新数据写入"
fi

rm -f ensure_latest_data.swift

# 3. 提供增强调试测试指南
echo ""
echo "🔧 增强调试测试指南:"
echo "================================"
echo ""

echo "现在小组件有了详细的调试信息，可以精确定位问题："
echo ""

echo "📱 测试步骤:"
echo "1. 🏗️ 重新编译应用:"
echo "   - 在Xcode中: Product → Build (Cmd+B)"
echo "   - 重新安装到设备"
echo ""

echo "2. 🔄 刷新小组件:"
echo "   - 删除桌面上的所有小组件"
echo "   - 重新添加小组件"
echo ""

echo "3. 🔍 查看详细调试日志:"
echo "   现在应该看到更详细的日志:"
echo ""

echo "   成功情况下的日志:"
echo "   - '🔧 [SimpleWidget] 尝试创建App Groups UserDefaults...'"
echo "   - '🔧 [SimpleWidget] ✅ App Groups UserDefaults创建成功'"
echo "   - '🔧 [SimpleWidget] App Groups同步结果: true'"
echo "   - '🔧 [SimpleWidget] App Groups读取结果: widget_search_engines = [\"bing_...\", ...]'"
echo "   - '🔧 [SimpleWidget] App Groups读取成功: [...]'"
echo ""

echo "   失败情况下的日志:"
echo "   - '🔧 [SimpleWidget] ❌ App Groups UserDefaults创建失败' → 权限问题"
echo "   - '🔧 [SimpleWidget] App Groups同步结果: false' → 同步问题"
echo "   - '🔧 [SimpleWidget] ⚠️ App Groups数据为空' → 数据问题"
echo "   - '🔧 [SimpleWidget] ⚠️ UserDefaults数据为空' → 备用数据也为空"
echo ""

echo "🔍 关键判断点:"
echo ""

echo "情况1: 看到'❌ App Groups UserDefaults创建失败'"
echo "- 问题: 小组件扩展没有App Groups权限"
echo "- 解决: 在Xcode中检查Widget Extension的Capabilities"
echo "- 确保添加了'App Groups'并选择'group.com.iosbrowser.shared'"
echo ""

echo "情况2: 看到'✅ App Groups UserDefaults创建成功'但'⚠️ App Groups数据为空'"
echo "- 问题: 权限正常，但数据读取失败"
echo "- 可能: 数据写入失败或时机问题"
echo "- 解决: 检查数据是否真的写入了"
echo ""

echo "情况3: 看到'App Groups读取结果: widget_search_engines = [带时间戳的数据]'"
echo "- 成功: 数据读取成功"
echo "- 小组件应该显示带时间戳的数据"
echo "- 如果仍显示测试数据，可能是UI渲染问题"
echo ""

echo "情况4: 看到'App Groups同步结果: false'"
echo "- 问题: 数据同步失败"
echo "- 可能: iOS系统限制或沙盒问题"
echo "- 解决: 重启设备，重新安装应用"
echo ""

echo "🎯 预期成功日志序列:"
echo "1. '🔧 [SimpleWidget] 尝试创建App Groups UserDefaults...'"
echo "2. '🔧 [SimpleWidget] ✅ App Groups UserDefaults创建成功'"
echo "3. '🔧 [SimpleWidget] App Groups同步结果: true'"
echo "4. '🔧 [SimpleWidget] App Groups读取结果: widget_search_engines = [\"bing_...\", ...]'"
echo "5. '🔧 [SimpleWidget] App Groups读取成功: [...]'"
echo ""

echo "🔧 如果仍然失败:"
echo "1. 检查控制台日志，找出具体失败点"
echo "2. 根据失败点采取相应的解决方案"
echo "3. 如果权限问题，重新配置App Groups"
echo "4. 如果数据问题，检查主应用的保存逻辑"
echo "5. 如果同步问题，重启设备"
echo ""

echo "🔧🔧🔧 增强调试测试准备完成！"
echo "现在请重新编译并测试，详细的日志会告诉我们确切的问题所在。"
