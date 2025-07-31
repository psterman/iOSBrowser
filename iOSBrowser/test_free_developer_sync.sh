#!/bin/bash

echo "🎯🎯🎯 免费开发者数据同步测试 🎯🎯🎯"
echo ""

# 1. 检查小组件代码是否已修复为免费开发者模式
echo "🔧 检查小组件代码..."

if grep -q "FreeWidget.*免费开发者模式" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件已修复为免费开发者模式"
else
    echo "❌ 小组件仍使用App Groups模式"
    echo "需要修复小组件代码"
fi

# 2. 检查是否移除了App Groups依赖
echo ""
echo "🚫 检查App Groups依赖..."

if grep -q "getSharedDefaults" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "⚠️  小组件仍包含App Groups代码"
    echo "建议完全移除App Groups依赖"
else
    echo "✅ 小组件已移除App Groups依赖"
fi

# 3. 检查主应用数据保存机制
echo ""
echo "💾 检查主应用数据保存..."

if grep -q "UserDefaults.standard.set.*iosbrowser_" iOSBrowser/ContentView.swift; then
    echo "✅ 主应用使用UserDefaults.standard保存数据"
else
    echo "❌ 主应用数据保存机制需要检查"
fi

# 4. 检查数据键名一致性
echo ""
echo "🔑 检查数据键名一致性..."

echo "主应用保存键名："
grep -o "iosbrowser_[a-z]*" iOSBrowser/ContentView.swift | sort | uniq

echo ""
echo "小组件读取键名："
grep -o "iosbrowser_[a-z]*" iOSBrowserWidgets/iOSBrowserWidgets.swift | sort | uniq

# 5. 生成测试数据保存脚本
echo ""
echo "📝 生成测试数据..."

cat > test_free_developer_data.swift << 'EOF'
import Foundation

print("🧪 免费开发者数据同步测试")

// 模拟用户在主应用中的选择
let testEngines = ["baidu", "google", "bing"]
let testApps = ["taobao", "wechat", "douyin"]
let testAI = ["deepseek", "chatgpt"]
let testActions = ["search", "bookmark", "history"]

print("🧪 保存测试数据到UserDefaults.standard...")

let defaults = UserDefaults.standard

// 保存数据（使用小组件期望的键名）
defaults.set(testEngines, forKey: "iosbrowser_engines")
defaults.set(testApps, forKey: "iosbrowser_apps")
defaults.set(testAI, forKey: "iosbrowser_ai")
defaults.set(testActions, forKey: "iosbrowser_actions")

// 强制同步
let syncResult = defaults.synchronize()
print("🧪 数据同步结果: \(syncResult)")

// 验证保存结果
print("🧪 验证保存的数据:")
print("   搜索引擎: \(defaults.stringArray(forKey: "iosbrowser_engines") ?? [])")
print("   应用: \(defaults.stringArray(forKey: "iosbrowser_apps") ?? [])")
print("   AI助手: \(defaults.stringArray(forKey: "iosbrowser_ai") ?? [])")
print("   快捷操作: \(defaults.stringArray(forKey: "iosbrowser_actions") ?? [])")

print("🧪 测试完成！现在可以检查小组件是否显示这些数据")
EOF

echo "✅ 已生成 test_free_developer_data.swift"

# 6. 提供测试指导
echo ""
echo "🚀 测试步骤："
echo "1. 编译并运行主应用"
echo "2. 进入'小组件配置'tab"
echo "3. 勾选一些应用、AI助手等"
echo "4. 返回桌面查看小组件"
echo "5. 检查控制台日志"
echo ""

echo "🔍 期望的成功日志："
echo "主应用："
echo "  🔥 DataSyncCenter.updateAppSelection 被调用: [用户选择]"
echo "  🔥 已保存应用到UserDefaults，同步结果: true"
echo ""
echo "小组件："
echo "  🔧 [FreeWidget] 读取应用数据（免费开发者模式）"
echo "  🔧 [FreeWidget] 应用数据: [用户选择]"
echo ""

echo "❌ 如果看到默认数据，说明同步失败："
echo "  🔧 [FreeWidget] 应用数据: [\"taobao\", \"zhihu\", \"douyin\"]"
echo ""

echo "🔧 故障排除："
echo "1. 完全关闭应用，重新打开"
echo "2. 删除桌面小组件，重新添加"
echo "3. 检查控制台是否有错误日志"
echo "4. 确认小组件代码已更新"

echo ""
echo "🎯 免费开发者数据同步测试完成！"
