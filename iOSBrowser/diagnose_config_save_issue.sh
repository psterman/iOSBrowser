#!/bin/bash

# 🔍 诊断小组件配置保存问题脚本
# 检查为什么小组件配置页面的选项无法保存

echo "🔍🔍🔍 开始诊断小组件配置保存问题..."
echo "📅 诊断时间: $(date)"
echo ""

# 1. 检查数据加载逻辑
echo "📊 检查数据加载逻辑..."

# 检查loadUserSelections是否完整
if grep -q "加载搜索引擎选择" iOSBrowser/ContentView.swift && \
   grep -q "加载AI助手选择" iOSBrowser/ContentView.swift && \
   grep -q "加载快捷操作选择" iOSBrowser/ContentView.swift; then
    echo "✅ loadUserSelections方法包含所有选项"
else
    echo "❌ loadUserSelections方法不完整"
fi

# 检查初始化时是否调用loadUserSelections
if grep -q "loadUserSelections()" iOSBrowser/ContentView.swift; then
    echo "✅ 初始化时调用了loadUserSelections"
else
    echo "❌ 初始化时未调用loadUserSelections"
fi

# 2. 检查保存逻辑
echo ""
echo "💾 检查保存逻辑..."

# 检查所有update方法是否存在
update_methods=("updateAppSelection" "updateAISelection" "updateSearchEngineSelection" "updateQuickActionSelection")
for method in "${update_methods[@]}"; do
    if grep -q "func $method" iOSBrowser/ContentView.swift; then
        echo "✅ $method 方法存在"
    else
        echo "❌ $method 方法缺失"
    fi
done

# 检查toggle方法是否调用update方法
if grep -q "dataSyncCenter.updateSearchEngineSelection" iOSBrowser/ContentView.swift && \
   grep -q "dataSyncCenter.updateAISelection" iOSBrowser/ContentView.swift && \
   grep -q "dataSyncCenter.updateQuickActionSelection" iOSBrowser/ContentView.swift; then
    echo "✅ toggle方法调用了对应的update方法"
else
    echo "❌ toggle方法未正确调用update方法"
fi

# 3. 检查UI刷新逻辑
echo ""
echo "🔄 检查UI刷新逻辑..."

# 检查WidgetConfigView的onAppear
if grep -q "refreshUserSelections" iOSBrowser/ContentView.swift; then
    echo "✅ WidgetConfigView有刷新用户选择的逻辑"
else
    echo "❌ WidgetConfigView缺少刷新用户选择的逻辑"
fi

# 检查各个子视图的onAppear
config_views=("SearchEngineConfigView" "UnifiedAIConfigView" "QuickActionConfigView")
for view in "${config_views[@]}"; do
    if grep -A 10 "struct $view" iOSBrowser/ContentView.swift | grep -q "onAppear"; then
        echo "✅ $view 有onAppear逻辑"
    else
        echo "⚠️ $view 缺少onAppear逻辑"
    fi
done

# 4. 检查数据绑定
echo ""
echo "🔗 检查数据绑定..."

# 检查@StateObject的使用
if grep -q "@StateObject.*dataSyncCenter.*DataSyncCenter.shared" iOSBrowser/ContentView.swift; then
    echo "✅ 使用了@StateObject绑定DataSyncCenter.shared"
else
    echo "❌ 数据绑定可能有问题"
fi

# 检查@Published属性
published_props=("selectedSearchEngines" "selectedAIAssistants" "selectedQuickActions")
for prop in "${published_props[@]}"; do
    if grep -q "@Published.*$prop" iOSBrowser/ContentView.swift; then
        echo "✅ $prop 使用了@Published"
    else
        echo "❌ $prop 未使用@Published"
    fi
done

# 5. 检查UserDefaults键的一致性
echo ""
echo "🔑 检查UserDefaults键的一致性..."

# 检查保存键
save_keys=("iosbrowser_engines" "iosbrowser_ai" "iosbrowser_actions")
for key in "${save_keys[@]}"; do
    if grep -q "\"$key\"" iOSBrowser/ContentView.swift; then
        echo "✅ 保存键 $key 存在"
    else
        echo "❌ 保存键 $key 缺失"
    fi
done

# 检查读取键
read_keys=("iosbrowser_engines" "iosbrowser_ai" "iosbrowser_actions")
for key in "${read_keys[@]}"; do
    if grep -q "forKey.*\"$key\"" iOSBrowser/ContentView.swift; then
        echo "✅ 读取键 $key 存在"
    else
        echo "❌ 读取键 $key 缺失"
    fi
done

# 6. 检查可能的问题
echo ""
echo "🚨 可能的问题分析..."

# 检查是否有重复的DataSyncCenter实例
datasync_count=$(grep -c "@StateObject.*dataSyncCenter.*DataSyncCenter" iOSBrowser/ContentView.swift)
echo "📊 DataSyncCenter实例数量: $datasync_count"

if [ $datasync_count -gt 4 ]; then
    echo "⚠️ 可能存在多个DataSyncCenter实例，导致数据不同步"
fi

# 检查是否有异步问题
if grep -q "DispatchQueue.main.async" iOSBrowser/ContentView.swift; then
    echo "⚠️ 存在异步操作，可能影响UI更新时机"
fi

# 7. 建议的修复方案
echo ""
echo "🔧 建议的修复方案:"
echo "================================"

echo "1. 确保每个配置子视图都有onAppear刷新逻辑"
echo "2. 检查@StateObject是否正确绑定到DataSyncCenter.shared"
echo "3. 验证UserDefaults的读写键是否一致"
echo "4. 添加UI状态强制刷新机制"
echo "5. 考虑添加保存按钮作为备用方案"

echo ""
echo "🔍🔍🔍 诊断完成！"
