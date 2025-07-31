#!/bin/bash

# 🔍 深入诊断UI重置问题
# 分析为什么小组件配置tab的勾选状态会重置

echo "🔍🔍🔍 开始深入诊断UI重置问题..."
echo "📅 诊断时间: $(date)"
echo ""

# 1. 检查UI绑定机制
echo "🎨 检查UI绑定机制..."

# 检查SearchEngineConfigView的UI绑定
echo "🔍 SearchEngineConfigView UI绑定分析:"
if grep -A 30 "struct SearchEngineConfigView" iOSBrowser/ContentView.swift | grep -q "dataSyncCenter.selectedSearchEngines"; then
    echo "✅ SearchEngineConfigView绑定到dataSyncCenter.selectedSearchEngines"
else
    echo "❌ SearchEngineConfigView未正确绑定数据"
fi

# 检查toggle方法的实现
echo ""
echo "🔄 检查toggle方法实现..."

# 查看toggleSearchEngine的具体实现
echo "🔍 toggleSearchEngine方法分析:"
toggle_line=$(grep -n "func toggleSearchEngine" iOSBrowser/ContentView.swift | head -1 | cut -d: -f1)
if [ ! -z "$toggle_line" ]; then
    echo "找到toggleSearchEngine方法在第 $toggle_line 行"
    # 显示方法内容
    sed -n "${toggle_line},$(($toggle_line + 15))p" iOSBrowser/ContentView.swift
else
    echo "❌ 未找到toggleSearchEngine方法"
fi

# 2. 检查数据流向
echo ""
echo "📊 检查数据流向..."

# 检查是否有多个数据源
echo "🔍 检查可能的数据源冲突:"

# 检查是否有其他地方重新设置selectedSearchEngines
reset_count=$(grep -n "selectedSearchEngines.*=" iOSBrowser/ContentView.swift | wc -l)
echo "📊 selectedSearchEngines赋值次数: $reset_count"

if [ $reset_count -gt 5 ]; then
    echo "⚠️ selectedSearchEngines被多次赋值，可能存在覆盖问题"
    echo "📋 所有赋值位置:"
    grep -n "selectedSearchEngines.*=" iOSBrowser/ContentView.swift | head -10
fi

# 3. 检查UI刷新时机
echo ""
echo "🔄 检查UI刷新时机..."

# 检查onAppear中的数据刷新
echo "🔍 onAppear数据刷新分析:"
if grep -A 20 "SearchEngineConfigView.*onAppear" iOSBrowser/ContentView.swift | grep -q "refreshUserSelections"; then
    echo "✅ SearchEngineConfigView有onAppear数据刷新"
else
    echo "❌ SearchEngineConfigView缺少onAppear数据刷新"
fi

# 4. 检查默认值问题
echo ""
echo "🎯 检查默认值问题..."

# 检查@Published属性的默认值
echo "🔍 @Published默认值分析:"
default_engines=$(grep "@Published var selectedSearchEngines" iOSBrowser/ContentView.swift | head -1)
echo "默认搜索引擎: $default_engines"

# 检查是否在某处重新设置为默认值
if grep -q "selectedSearchEngines.*\[.*baidu.*google.*\]" iOSBrowser/ContentView.swift; then
    echo "⚠️ 发现代码中有重新设置为默认值的地方"
    grep -n "selectedSearchEngines.*\[.*baidu.*google.*\]" iOSBrowser/ContentView.swift
fi

# 5. 检查视图生命周期
echo ""
echo "🔄 检查视图生命周期..."

# 检查是否有多个视图实例
echo "🔍 视图实例分析:"
config_view_count=$(grep -c "SearchEngineConfigView()" iOSBrowser/ContentView.swift)
echo "📊 SearchEngineConfigView实例化次数: $config_view_count"

# 6. 创建实时监控脚本
echo ""
echo "🛠️ 创建实时监控脚本..."

cat > monitor_data_changes.swift << 'EOF'
import Foundation

// 模拟监控DataSyncCenter的数据变化
print("🔍 开始监控数据变化...")

let defaults = UserDefaults.standard
defaults.synchronize()

// 读取当前数据
let currentEngines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
let currentAI = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
let currentActions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []
let currentApps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []

print("📱 当前UserDefaults数据:")
print("  搜索引擎: \(currentEngines)")
print("  AI助手: \(currentAI)")
print("  快捷操作: \(currentActions)")
print("  应用: \(currentApps)")

// 检查数据一致性
let hasSearchEngines = !currentEngines.isEmpty
let hasAI = !currentAI.isEmpty
let hasActions = !currentActions.isEmpty
let hasApps = !currentApps.isEmpty

print("📊 数据完整性检查:")
print("  搜索引擎: \(hasSearchEngines ? "有数据" : "无数据")")
print("  AI助手: \(hasAI ? "有数据" : "无数据")")
print("  快捷操作: \(hasActions ? "有数据" : "无数据")")
print("  应用: \(hasApps ? "有数据" : "无数据")")

if hasSearchEngines && hasAI && hasActions && hasApps {
    print("✅ 所有数据都存在，UI应该显示用户配置")
} else {
    print("⚠️ 部分数据缺失，可能导致UI显示默认值")
}

// 模拟检查默认值
let defaultEngines = ["baidu", "google"]
let defaultAI = ["deepseek", "qwen"]
let defaultActions = ["search", "bookmark"]
let defaultApps = ["taobao", "zhihu", "douyin"]

print("🎯 与默认值对比:")
print("  搜索引擎: \(currentEngines == defaultEngines ? "使用默认值" : "使用用户配置")")
print("  AI助手: \(currentAI == defaultAI ? "使用默认值" : "使用用户配置")")
print("  快捷操作: \(currentActions == defaultActions ? "使用默认值" : "使用用户配置")")
print("  应用: \(currentApps == defaultApps ? "使用默认值" : "使用用户配置")")
EOF

# 运行监控脚本
if command -v swift &> /dev/null; then
    echo "🔧 运行数据监控..."
    swift monitor_data_changes.swift
else
    echo "⚠️ Swift命令不可用，跳过数据监控"
fi

# 清理
rm -f monitor_data_changes.swift

# 7. 分析可能的问题
echo ""
echo "🚨 可能的UI重置原因分析:"
echo "================================"
echo "1. 数据加载时机问题 - UI渲染在数据加载之前"
echo "2. 默认值覆盖问题 - 某处重新设置了默认值"
echo "3. 视图实例问题 - 多个视图实例导致数据不同步"
echo "4. 绑定机制问题 - UI没有正确绑定到数据源"
echo "5. 生命周期问题 - onAppear没有正确触发数据刷新"
echo ""

echo "🔧 建议的调试步骤:"
echo "1. 在SearchEngineConfigView中添加实时数据监控"
echo "2. 在toggleSearchEngine中添加详细日志"
echo "3. 检查UI渲染时的实际数据值"
echo "4. 验证onAppear的触发时机"
echo "5. 确认数据绑定的正确性"
echo ""

echo "🔍🔍🔍 UI重置问题诊断完成！"
