#!/bin/bash

# 强制保存测试数据到UserDefaults，验证小组件是否能读取

echo "🧪 强制保存测试数据到UserDefaults..."

# 创建一个Swift脚本来强制保存测试数据
cat > /tmp/force_save_test.swift << 'EOF'
import Foundation

print("🧪 开始强制保存测试数据...")

let defaults = UserDefaults.standard

// 用户选择的测试数据
let userEngines = ["google", "bing", "duckduckgo"]
let userApps = ["wechat", "alipay", "taobao", "jd"]
let userAI = ["chatgpt", "deepseek", "claude"]
let userActions = ["search", "bookmark", "translate", "qr_scan"]

print("🧪 保存用户选择数据...")
defaults.set(userEngines, forKey: "iosbrowser_engines")
defaults.set(userApps, forKey: "iosbrowser_apps")
defaults.set(userAI, forKey: "iosbrowser_ai")
defaults.set(userActions, forKey: "iosbrowser_actions")

// 设置时间戳
defaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

// 强制同步
let syncResult = defaults.synchronize()
print("🧪 同步结果: \(syncResult)")

// 立即验证
print("🧪 立即验证保存结果...")
let readEngines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
let readApps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []
let readAI = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
let readActions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []

print("🧪 验证结果:")
print("   搜索引擎: \(readEngines)")
print("   应用: \(readApps)")
print("   AI助手: \(readAI)")
print("   快捷操作: \(readActions)")

// 检查数据一致性
let enginesMatch = userEngines == readEngines
let appsMatch = userApps == readApps
let aiMatch = userAI == readAI
let actionsMatch = userActions == readActions

print("🧪 数据一致性:")
print("   搜索引擎: \(enginesMatch ? "✅" : "❌")")
print("   应用: \(appsMatch ? "✅" : "❌")")
print("   AI助手: \(aiMatch ? "✅" : "❌")")
print("   快捷操作: \(actionsMatch ? "✅" : "❌")")

if enginesMatch && appsMatch && aiMatch && actionsMatch {
    print("🎉 数据保存成功！小组件应该能读取到这些数据")
} else {
    print("❌ 数据保存失败！")
}

print("🧪 测试数据保存完成")
EOF

echo "✅ 创建了强制保存脚本"

# 如果有swift命令，尝试运行
if command -v swift >/dev/null 2>&1; then
    echo "🧪 运行强制保存脚本..."
    swift /tmp/force_save_test.swift
else
    echo "⚠️  系统没有swift命令，无法直接运行测试"
    echo "📝 可以将以下代码添加到主应用中测试:"
    echo ""
    cat /tmp/force_save_test.swift
fi

echo ""
echo "🧪 现在可以测试小组件是否显示以下数据:"
echo "   搜索引擎: google, bing, duckduckgo"
echo "   应用: wechat, alipay, taobao, jd"
echo "   AI助手: chatgpt, deepseek, claude"
echo "   快捷操作: search, bookmark, translate, qr_scan"

echo ""
echo "📱 测试步骤:"
echo "1. 在Xcode中编译并运行项目"
echo "2. 添加小组件到桌面"
echo "3. 检查小组件是否显示上述数据而不是默认数据"
echo "4. 如果显示默认数据，说明还有其他问题需要解决"

echo ""
echo "🧪 强制测试数据保存完成"
