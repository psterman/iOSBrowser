#!/bin/bash

# 🔍 调试小组件数据加载问题
# 专门检查为什么小组件仍显示百度谷歌而不是用户配置

echo "🔍🔍🔍 开始调试小组件数据加载问题..."
echo "📅 调试时间: $(date)"
echo ""

# 1. 验证当前UserDefaults中的数据
echo "🧪 验证当前UserDefaults中的数据..."

cat > check_widget_userdefaults.swift << 'EOF'
import Foundation

print("🔍 检查小组件应该读取的UserDefaults数据...")

let defaults = UserDefaults.standard
defaults.synchronize()

// 检查所有相关键
let mainKey = "iosbrowser_engines"
let v2Key = "widget_search_engines_v2"
let v3Key = "widget_search_engines_v3"

let mainData = defaults.stringArray(forKey: mainKey) ?? []
let v2Data = defaults.stringArray(forKey: v2Key) ?? []
let v3Data = defaults.stringArray(forKey: v3Key) ?? []
let lastUpdate = defaults.double(forKey: "iosbrowser_last_update")

print("📱 UserDefaults中的搜索引擎数据:")
print("  \(mainKey): \(mainData)")
print("  \(v2Key): \(v2Data)")
print("  \(v3Key): \(v3Data)")
print("  最后更新: \(Date(timeIntervalSince1970: lastUpdate))")

// 模拟小组件的读取逻辑
print("🔍 模拟小组件读取逻辑:")
var selectedEngines: [String] = []
var dataSource = "未知"

// 方法1: 从主键读取
selectedEngines = mainData
if !selectedEngines.isEmpty {
    dataSource = "主键(\(mainKey))"
    print("✅ 从\(mainKey)读取成功: \(selectedEngines)")
} else {
    print("❌ \(mainKey)为空")
}

// 方法2: 从v2键读取
if selectedEngines.isEmpty {
    selectedEngines = v2Data
    if !selectedEngines.isEmpty {
        dataSource = "v2键(\(v2Key))"
        print("✅ 从\(v2Key)读取成功: \(selectedEngines)")
    } else {
        print("❌ \(v2Key)为空")
    }
}

// 方法3: 使用默认值
if selectedEngines.isEmpty {
    selectedEngines = ["baidu", "google"]
    dataSource = "默认值"
    print("⚠️ 使用默认值: \(selectedEngines)")
}

print("🎯 小组件最终应该显示: \(selectedEngines) (来源: \(dataSource))")

// 检查是否是默认值
if selectedEngines == ["baidu", "google"] {
    print("🚨 问题确认: 小组件将显示默认的百度和谷歌")
    print("🔧 原因: 所有UserDefaults键都为空或数据未正确保存")
} else {
    print("✅ 预期正常: 小组件应该显示用户配置的搜索引擎")
}
EOF

if command -v swift &> /dev/null; then
    swift check_widget_userdefaults.swift
else
    echo "⚠️ Swift命令不可用，跳过UserDefaults检查"
fi

rm -f check_widget_userdefaults.swift

# 2. 检查小组件的数据读取方法
echo ""
echo "📱 检查小组件的数据读取方法..."

echo "🔍 getUserSelectedSearchEngines方法分析:"
if grep -A 30 "func getUserSelectedSearchEngines" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "iosbrowser_engines"; then
    echo "✅ 小组件读取iosbrowser_engines键"
else
    echo "❌ 小组件未读取iosbrowser_engines键"
fi

if grep -A 30 "func getUserSelectedSearchEngines" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "baidu.*google"; then
    echo "⚠️ 小组件有默认值设置"
    echo "📋 默认值设置位置:"
    grep -n "baidu.*google" iOSBrowserWidgets/iOSBrowserWidgets.swift
else
    echo "✅ 小组件没有硬编码默认值"
fi

# 3. 检查TimelineProvider的实现
echo ""
echo "⏰ 检查TimelineProvider的实现..."

echo "🔍 UserSearchProvider分析:"
if grep -A 10 "func getTimeline" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "getUserSelectedSearchEngines"; then
    echo "✅ getTimeline调用getUserSelectedSearchEngines"
else
    echo "❌ getTimeline未调用getUserSelectedSearchEngines"
fi

if grep -A 10 "func getSnapshot" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "getUserSelectedSearchEngines"; then
    echo "✅ getSnapshot调用getUserSelectedSearchEngines"
else
    echo "❌ getSnapshot未调用getUserSelectedSearchEngines"
fi

# 4. 检查小组件视图的数据使用
echo ""
echo "🎨 检查小组件视图的数据使用..."

echo "🔍 SmallUserSearchView分析:"
if grep -A 10 "ForEach.*entry.searchEngines" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件视图使用entry.searchEngines"
else
    echo "❌ 小组件视图未使用entry.searchEngines"
fi

# 5. 强制写入测试数据并验证
echo ""
echo "🛠️ 强制写入测试数据并验证..."

cat > force_write_test_data.swift << 'EOF'
import Foundation

print("🔧 强制写入明确的测试数据...")

let defaults = UserDefaults.standard

// 写入非常明确的测试数据
let testEngines = ["bing", "duckduckgo", "yahoo", "sogou"]
print("📝 准备写入: \(testEngines)")

// 写入到所有可能的键
defaults.set(testEngines, forKey: "iosbrowser_engines")
defaults.set(testEngines, forKey: "widget_search_engines_v2")
defaults.set(testEngines, forKey: "widget_search_engines_v3")
defaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

// 强制同步
let syncResult = defaults.synchronize()
print("📱 同步结果: \(syncResult)")

// 立即验证所有键
let verify1 = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
let verify2 = defaults.stringArray(forKey: "widget_search_engines_v2") ?? []
let verify3 = defaults.stringArray(forKey: "widget_search_engines_v3") ?? []

print("📱 验证写入结果:")
print("  iosbrowser_engines: \(verify1)")
print("  widget_search_engines_v2: \(verify2)")
print("  widget_search_engines_v3: \(verify3)")

let allMatch = verify1 == testEngines && verify2 == testEngines && verify3 == testEngines
if allMatch {
    print("✅ 所有键写入成功")
    print("🎯 小组件现在应该显示: Bing, DuckDuckGo, Yahoo, 搜狗")
    print("🎯 而不是: 百度, Google")
} else {
    print("❌ 数据写入失败")
}
EOF

if command -v swift &> /dev/null; then
    swift force_write_test_data.swift
else
    echo "⚠️ Swift命令不可用，跳过强制写入"
fi

rm -f force_write_test_data.swift

# 6. 分析可能的问题
echo ""
echo "🚨 可能的问题分析:"
echo "================================"
echo "1. 小组件缓存问题 - 系统缓存了旧的小组件数据"
echo "2. 刷新时机问题 - 小组件没有在数据更新后及时刷新"
echo "3. 数据读取顺序 - 小组件读取了错误的键或默认值"
echo "4. Timeline更新问题 - TimelineProvider没有正确更新"
echo "5. 沙盒隔离问题 - 小组件扩展无法访问主应用的UserDefaults"
echo ""

echo "🔧 建议的解决步骤:"
echo "1. 删除桌面上的所有小组件"
echo "2. 重新编译并安装应用"
echo "3. 重新添加小组件到桌面"
echo "4. 查看控制台日志确认数据读取"
echo "5. 等待5-10分钟让系统完全更新"
echo ""

echo "🔍 关键调试信息:"
echo "如果小组件仍显示百度和谷歌，说明："
echo "- 要么UserDefaults数据没有正确保存"
echo "- 要么小组件没有正确读取数据"
echo "- 要么系统缓存了旧的小组件内容"
echo ""

echo "🔍🔍🔍 小组件数据加载问题调试完成！"
