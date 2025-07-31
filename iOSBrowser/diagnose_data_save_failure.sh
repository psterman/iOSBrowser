#!/bin/bash

# 🔍 诊断数据保存失败问题
# 检查为什么主应用的数据没有保存到UserDefaults

echo "🔍🔍🔍 开始诊断数据保存失败问题..."
echo "📅 诊断时间: $(date)"
echo ""

# 1. 检查toggle方法是否正确调用update方法
echo "🔄 检查toggle方法调用链..."

# 检查toggleSearchEngine是否调用updateSearchEngineSelection
if grep -A 5 "func toggleSearchEngine" iOSBrowser/ContentView.swift | grep -q "updateSearchEngineSelection"; then
    echo "✅ toggleSearchEngine正确调用updateSearchEngineSelection"
else
    echo "❌ toggleSearchEngine未调用updateSearchEngineSelection"
fi

# 检查toggleAssistant是否调用updateAISelection
if grep -A 5 "func toggleAssistant" iOSBrowser/ContentView.swift | grep -q "updateAISelection"; then
    echo "✅ toggleAssistant正确调用updateAISelection"
else
    echo "❌ toggleAssistant未调用updateAISelection"
fi

# 检查toggleQuickAction是否调用updateQuickActionSelection
if grep -A 5 "func toggleQuickAction" iOSBrowser/ContentView.swift | grep -q "updateQuickActionSelection"; then
    echo "✅ toggleQuickAction正确调用updateQuickActionSelection"
else
    echo "❌ toggleQuickAction未调用updateQuickActionSelection"
fi

# 2. 检查update方法是否调用保存逻辑
echo ""
echo "💾 检查update方法保存逻辑..."

# 检查updateSearchEngineSelection是否调用immediateSyncToWidgets
if grep -A 10 "func updateSearchEngineSelection" iOSBrowser/ContentView.swift | grep -q "immediateSyncToWidgets"; then
    echo "✅ updateSearchEngineSelection调用immediateSyncToWidgets"
else
    echo "❌ updateSearchEngineSelection未调用immediateSyncToWidgets"
fi

# 检查updateAISelection是否调用immediateSyncToWidgets
if grep -A 10 "func updateAISelection" iOSBrowser/ContentView.swift | grep -q "immediateSyncToWidgets"; then
    echo "✅ updateAISelection调用immediateSyncToWidgets"
else
    echo "❌ updateAISelection未调用immediateSyncToWidgets"
fi

# 检查updateQuickActionSelection是否调用immediateSyncToWidgets
if grep -A 10 "func updateQuickActionSelection" iOSBrowser/ContentView.swift | grep -q "immediateSyncToWidgets"; then
    echo "✅ updateQuickActionSelection调用immediateSyncToWidgets"
else
    echo "❌ updateQuickActionSelection未调用immediateSyncToWidgets"
fi

# 3. 检查immediateSyncToWidgets是否调用保存方法
echo ""
echo "🔧 检查immediateSyncToWidgets保存逻辑..."

if grep -A 10 "func immediateSyncToWidgets" iOSBrowser/ContentView.swift | grep -q "saveToWidgetAccessibleLocationFromDataSyncCenter"; then
    echo "✅ immediateSyncToWidgets调用saveToWidgetAccessibleLocationFromDataSyncCenter"
else
    echo "❌ immediateSyncToWidgets未调用保存方法"
fi

# 4. 检查保存方法是否正确设置UserDefaults
echo ""
echo "🔑 检查UserDefaults保存逻辑..."

# 检查是否保存到正确的键
save_keys=("iosbrowser_engines" "iosbrowser_ai" "iosbrowser_actions")
for key in "${save_keys[@]}"; do
    if grep -q "defaults.set.*forKey.*\"$key\"" iOSBrowser/ContentView.swift; then
        echo "✅ 保存到键: $key"
    else
        echo "❌ 未保存到键: $key"
    fi
done

# 检查是否调用synchronize
if grep -q "defaults.synchronize()" iOSBrowser/ContentView.swift; then
    echo "✅ 调用了defaults.synchronize()"
else
    echo "❌ 未调用defaults.synchronize()"
fi

# 5. 检查初始化时是否加载数据
echo ""
echo "📂 检查数据加载逻辑..."

if grep -A 5 "private init()" iOSBrowser/ContentView.swift | grep -q "loadUserSelections"; then
    echo "✅ 初始化时调用loadUserSelections"
else
    echo "❌ 初始化时未调用loadUserSelections"
fi

# 6. 检查可能的问题
echo ""
echo "🚨 可能的问题分析..."

# 检查是否有多个DataSyncCenter定义
datasync_class_count=$(grep -c "class DataSyncCenter" iOSBrowser/ContentView.swift)
echo "📊 DataSyncCenter类定义数量: $datasync_class_count"

if [ $datasync_class_count -gt 1 ]; then
    echo "⚠️ 可能存在多个DataSyncCenter类定义"
fi

# 检查是否有语法错误导致方法未执行
if grep -q "🔥🔥🔥.*被调用" iOSBrowser/ContentView.swift; then
    echo "✅ 包含调试日志，方法应该能被调用"
else
    echo "⚠️ 缺少调试日志，可能存在调用问题"
fi

# 7. 建议的调试步骤
echo ""
echo "🔧 建议的调试步骤:"
echo "================================"
echo "1. 在主应用中勾选一个搜索引擎选项"
echo "2. 查看控制台是否出现以下日志："
echo "   - '🔥🔥🔥 toggleSearchEngine 被调用'"
echo "   - '🔥 DataSyncCenter.updateSearchEngineSelection 被调用'"
echo "   - '🔥🔥🔥 立即同步到小组件开始'"
echo "   - '🔥 准备保存数据'"
echo "3. 如果没有这些日志，说明调用链断了"
echo "4. 如果有日志但数据仍为空，说明保存逻辑有问题"
echo ""

echo "🔍🔍🔍 数据保存失败问题诊断完成！"
