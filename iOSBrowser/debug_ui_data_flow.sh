#!/bin/bash

# 🔍 直接追踪UI数据流问题
# 从UI层面分析为什么勾选状态重置

echo "🔍🔍🔍 开始直接追踪UI数据流问题..."
echo "📅 分析时间: $(date)"
echo ""

# 1. 检查UI绑定的具体实现
echo "🎨 检查UI绑定的具体实现..."

echo "🔍 SearchEngineConfigView的UI绑定分析:"
echo "查找UI元素如何绑定到数据..."

# 查看勾选状态的具体绑定
if grep -A 10 -B 5 "selectedSearchEngines.contains" iOSBrowser/ContentView.swift; then
    echo "✅ 找到UI勾选状态绑定"
else
    echo "❌ 未找到UI勾选状态绑定"
fi

echo ""
echo "🔍 检查toggle方法的数据流..."

# 查看toggle方法的完整实现
echo "📋 toggleSearchEngine完整实现:"
start_line=$(grep -n "private func toggleSearchEngine" iOSBrowser/ContentView.swift | cut -d: -f1)
if [ ! -z "$start_line" ]; then
    # 显示完整的toggle方法
    sed -n "${start_line},$(($start_line + 25))p" iOSBrowser/ContentView.swift
else
    echo "❌ 未找到toggleSearchEngine方法"
fi

echo ""
echo "🔍 检查数据更新链路..."

# 查看updateSearchEngineSelection方法
echo "📋 updateSearchEngineSelection方法:"
update_line=$(grep -n "func updateSearchEngineSelection" iOSBrowser/ContentView.swift | cut -d: -f1)
if [ ! -z "$update_line" ]; then
    sed -n "${update_line},$(($update_line + 15))p" iOSBrowser/ContentView.swift
else
    echo "❌ 未找到updateSearchEngineSelection方法"
fi

# 2. 检查可能的数据覆盖点
echo ""
echo "🚨 检查可能的数据覆盖点..."

echo "🔍 查找所有可能重置selectedSearchEngines的地方:"
grep -n "selectedSearchEngines.*=" iOSBrowser/ContentView.swift | while read line; do
    line_num=$(echo "$line" | cut -d: -f1)
    echo "第 $line_num 行: $line"
    
    # 显示上下文
    echo "  上下文:"
    sed -n "$(($line_num - 2)),$(($line_num + 2))p" iOSBrowser/ContentView.swift | sed 's/^/    /'
    echo ""
done

# 3. 检查初始化时机问题
echo ""
echo "⏰ 检查初始化时机问题..."

echo "🔍 DataSyncCenter初始化分析:"
init_line=$(grep -n "private init()" iOSBrowser/ContentView.swift | head -1 | cut -d: -f1)
if [ ! -z "$init_line" ]; then
    echo "DataSyncCenter初始化在第 $init_line 行:"
    sed -n "${init_line},$(($init_line + 10))p" iOSBrowser/ContentView.swift
else
    echo "❌ 未找到DataSyncCenter初始化"
fi

echo ""
echo "🔍 @Published属性初始化分析:"
grep -n "@Published var selected" iOSBrowser/ContentView.swift | while read line; do
    echo "$line"
done

# 4. 创建实时数据监控
echo ""
echo "🛠️ 创建实时数据监控..."

cat > real_time_monitor.swift << 'EOF'
import Foundation

print("🔍 实时数据监控开始...")

// 模拟应用启动时的数据状态
let defaults = UserDefaults.standard
defaults.synchronize()

print("📱 应用启动时UserDefaults状态:")
let engines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
let ai = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
let actions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []
let apps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []

print("  搜索引擎: \(engines)")
print("  AI助手: \(ai)")
print("  快捷操作: \(actions)")
print("  应用: \(apps)")

// 模拟DataSyncCenter的默认值
let defaultEngines = ["baidu", "google"]
let defaultAI = ["deepseek", "qwen"]
let defaultActions = ["search", "bookmark"]
let defaultApps = ["taobao", "zhihu", "douyin"]

print("📊 默认值对比:")
print("  搜索引擎: 存储=\(engines), 默认=\(defaultEngines), 相同=\(engines == defaultEngines)")
print("  AI助手: 存储=\(ai), 默认=\(defaultAI), 相同=\(ai == defaultAI)")
print("  快捷操作: 存储=\(actions), 默认=\(defaultActions), 相同=\(actions == defaultActions)")
print("  应用: 存储=\(apps), 默认=\(defaultApps), 相同=\(apps == defaultApps)")

// 分析问题
print("🔍 问题分析:")
if engines.isEmpty {
    print("⚠️ 搜索引擎数据为空，UI会显示默认值")
} else if engines == defaultEngines {
    print("⚠️ 搜索引擎数据与默认值相同，可能看不出差异")
} else {
    print("✅ 搜索引擎有自定义数据，UI应该显示自定义状态")
}

// 模拟UI显示逻辑
print("🎨 模拟UI显示逻辑:")
let uiEngines = engines.isEmpty ? defaultEngines : engines
print("  UI应该显示的搜索引擎: \(uiEngines)")

// 检查特定引擎的勾选状态
let testEngines = ["baidu", "google", "bing", "sogou"]
for engine in testEngines {
    let shouldBeChecked = uiEngines.contains(engine)
    print("  \(engine): \(shouldBeChecked ? "✅勾选" : "❌未勾选")")
}
EOF

# 运行监控
if command -v swift &> /dev/null; then
    echo "🔧 运行实时数据监控..."
    swift real_time_monitor.swift
else
    echo "⚠️ Swift命令不可用，跳过实时监控"
fi

# 清理
rm -f real_time_monitor.swift

# 5. 提供直接修复方案
echo ""
echo "🔧 直接修复方案建议:"
echo "================================"
echo "基于分析，问题可能出现在以下几个方面："
echo ""
echo "1. UI绑定问题 - UI元素没有正确绑定到数据"
echo "2. 数据加载时机 - loadUserSelections在UI渲染后才执行"
echo "3. 默认值覆盖 - @Published属性的默认值覆盖了加载的数据"
echo "4. 视图生命周期 - onAppear没有在正确时机触发"
echo "5. 数据同步问题 - 内存数据与UI显示不同步"
echo ""

echo "🎯 下一步行动:"
echo "1. 在UI元素中添加实时数据显示"
echo "2. 在toggle方法中添加UI状态验证"
echo "3. 强制在UI渲染前加载数据"
echo "4. 添加UI状态与数据状态的实时对比"
echo ""

echo "🔍🔍🔍 UI数据流问题追踪完成！"
