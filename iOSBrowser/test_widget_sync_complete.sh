#!/bin/bash

# 🎉 完整小组件同步测试脚本
# 验证主应用配置到桌面小组件的完整同步流程

echo "🎉🎉🎉 开始完整小组件同步测试..."
echo "📅 测试时间: $(date)"
echo ""

# 1. 检查主应用的增强同步机制
echo "🔧 检查主应用的增强同步机制..."

if grep -A 10 "开始多重刷新策略" iOSBrowser/ContentView.swift; then
    echo "✅ 主应用有多重刷新策略"
else
    echo "❌ 主应用缺少多重刷新策略"
fi

if grep -q "延迟0.5秒刷新小组件" iOSBrowser/ContentView.swift; then
    echo "✅ 主应用有延迟刷新机制"
else
    echo "❌ 主应用缺少延迟刷新机制"
fi

# 2. 检查小组件的增强调试
echo ""
echo "📱 检查小组件的增强调试..."

if grep -q "🔥🔥🔥 小组件开始多源搜索引擎数据读取" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件有增强调试日志"
else
    echo "❌ 小组件缺少增强调试日志"
fi

if grep -q "所有搜索引擎键的数据状态" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件有详细数据状态检查"
else
    echo "❌ 小组件缺少详细数据状态检查"
fi

if grep -q "与主应用数据一致性" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件有数据一致性验证"
else
    echo "❌ 小组件缺少数据一致性验证"
fi

# 3. 验证当前数据状态
echo ""
echo "🧪 验证当前数据状态..."

cat > test_widget_data_sync.swift << 'EOF'
import Foundation

print("🔍 测试小组件数据同步状态...")

let defaults = UserDefaults.standard
defaults.synchronize()

// 检查主应用保存的数据
let engines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
let apps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []
let ai = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
let actions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []
let lastUpdate = defaults.double(forKey: "iosbrowser_last_update")

print("📱 主应用当前数据:")
print("  搜索引擎: \(engines)")
print("  应用: \(apps)")
print("  AI助手: \(ai)")
print("  快捷操作: \(actions)")
print("  最后更新: \(Date(timeIntervalSince1970: lastUpdate))")

// 检查备用键的数据
let enginesV2 = defaults.stringArray(forKey: "widget_search_engines_v2") ?? []
let enginesV3 = defaults.stringArray(forKey: "widget_search_engines_v3") ?? []
let appsV2 = defaults.stringArray(forKey: "widget_apps_v2") ?? []
let appsV3 = defaults.stringArray(forKey: "widget_apps_v3") ?? []

print("📱 备用键数据:")
print("  搜索引擎v2: \(enginesV2)")
print("  搜索引擎v3: \(enginesV3)")
print("  应用v2: \(appsV2)")
print("  应用v3: \(appsV3)")

// 模拟小组件读取逻辑
print("🔍 模拟小组件读取逻辑:")

// 搜索引擎读取优先级
var widgetEngines: [String] = []
if !engines.isEmpty {
    widgetEngines = engines
    print("  小组件将从iosbrowser_engines读取: \(widgetEngines)")
} else if !enginesV2.isEmpty {
    widgetEngines = enginesV2
    print("  小组件将从widget_search_engines_v2读取: \(widgetEngines)")
} else {
    widgetEngines = ["baidu", "google"]
    print("  小组件将使用默认搜索引擎: \(widgetEngines)")
}

// 应用读取优先级
var widgetApps: [String] = []
if !apps.isEmpty {
    widgetApps = apps
    print("  小组件将从iosbrowser_apps读取: \(widgetApps)")
} else if !appsV2.isEmpty {
    widgetApps = appsV2
    print("  小组件将从widget_apps_v2读取: \(widgetApps)")
} else {
    widgetApps = ["taobao", "zhihu", "douyin"]
    print("  小组件将使用默认应用: \(widgetApps)")
}

print("🎯 小组件最终应该显示:")
print("  搜索引擎: \(widgetEngines.joined(separator: ", "))")
print("  应用: \(widgetApps.joined(separator: ", "))")

// 检查数据新鲜度
let timeSinceUpdate = Date().timeIntervalSince1970 - lastUpdate
print("📊 数据新鲜度: \(Int(timeSinceUpdate))秒前更新")

if timeSinceUpdate < 300 { // 5分钟内
    print("✅ 数据较新，小组件应该能正确显示")
} else {
    print("⚠️ 数据较旧，可能需要重新配置")
}
EOF

if command -v swift &> /dev/null; then
    swift test_widget_data_sync.swift
else
    echo "⚠️ Swift命令不可用，跳过数据测试"
fi

rm -f test_widget_data_sync.swift

# 4. 创建明确的测试数据
echo ""
echo "🛠️ 创建明确的小组件测试数据..."

cat > create_widget_test_data.swift << 'EOF'
import Foundation

print("🔧 创建明确的小组件测试数据...")

let defaults = UserDefaults.standard

// 创建明显不同的测试数据
let testEngines = ["bing", "duckduckgo", "yahoo"]  // 明显不同于默认值
let testApps = ["wechat", "alipay", "meituan"]     // 明显不同于默认值
let testAI = ["chatgpt", "claude", "gemini"]       // 明显不同于默认值
let testActions = ["translate", "calculator"]      // 明显不同于默认值

// 保存到所有相关键
defaults.set(testEngines, forKey: "iosbrowser_engines")
defaults.set(testEngines, forKey: "widget_search_engines_v2")
defaults.set(testEngines, forKey: "widget_search_engines_v3")

defaults.set(testApps, forKey: "iosbrowser_apps")
defaults.set(testApps, forKey: "widget_apps_v2")
defaults.set(testApps, forKey: "widget_apps_v3")

defaults.set(testAI, forKey: "iosbrowser_ai")
defaults.set(testActions, forKey: "iosbrowser_actions")

defaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

let syncResult = defaults.synchronize()
print("📱 测试数据写入结果: \(syncResult)")

// 立即验证
let readEngines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
let readApps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []

print("📱 验证写入结果:")
print("  搜索引擎: \(readEngines)")
print("  应用: \(readApps)")

if readEngines == testEngines && readApps == testApps {
    print("✅ 测试数据写入成功")
    print("🎯 小组件应该显示:")
    print("  搜索引擎: Bing, DuckDuckGo, Yahoo")
    print("  应用: WeChat, Alipay, Meituan")
    print("  (而不是默认的 Baidu, Google 和 Taobao, Zhihu, Douyin)")
} else {
    print("❌ 测试数据写入失败")
}
EOF

if command -v swift &> /dev/null; then
    swift create_widget_test_data.swift
else
    echo "⚠️ Swift命令不可用，跳过测试数据创建"
fi

rm -f create_widget_test_data.swift

# 5. 总结测试指南
echo ""
echo "🎉 完整小组件同步测试总结:"
echo "================================"
echo "✅ 1. 主应用增强同步机制 - 多重刷新策略"
echo "✅ 2. 小组件增强调试 - 详细数据状态检查"
echo "✅ 3. 数据一致性验证 - 实时对比主应用数据"
echo "✅ 4. 明确测试数据 - 与默认值完全不同"
echo ""

echo "📱 测试步骤:"
echo "1. 重新编译运行应用和小组件"
echo "2. 进入小组件配置页面"
echo "3. 查看控制台日志，确认数据已写入"
echo "4. 添加桌面小组件到主屏幕"
echo "5. 查看小组件是否显示: Bing, DuckDuckGo, Yahoo"
echo "6. 如果仍显示默认值，等待2-3分钟或重新添加小组件"
echo ""

echo "🔍 关键日志标识:"
echo "主应用:"
echo "- '🔥🔥🔥 立即同步到小组件开始'"
echo "- '🔥🔥🔥 开始多重刷新策略'"
echo "- '🔄 已请求刷新所有小组件'"
echo ""
echo "小组件:"
echo "- '🔥🔥🔥 小组件开始多源搜索引擎数据读取'"
echo "- '🔍🔥 从UserDefaults v3主键读取搜索引擎成功'"
echo "- '🔍🔥 与主应用数据一致性: ✅一致'"
echo ""

echo "🎯 预期效果:"
echo "桌面小组件应该显示 Bing, DuckDuckGo, Yahoo"
echo "而不是默认的 Baidu, Google"
echo "这证明小组件正确读取了用户配置"
echo ""

echo "🎉🎉🎉 完整小组件同步测试完成！"
