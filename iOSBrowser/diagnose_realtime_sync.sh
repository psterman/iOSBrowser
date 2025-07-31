#!/bin/bash

# 诊断实时数据联动问题的脚本

echo "🔍🔍🔍 诊断实时数据联动问题 🔍🔍🔍"

# 1. 检查用户操作触发链
echo "1. 检查用户操作触发链..."

echo "1.1 检查toggle方法是否调用updateXXXSelection:"
if grep -A 5 "toggleApp.*updateAppSelection" iOSBrowser/ContentView.swift; then
    echo "✅ toggleApp → updateAppSelection 链路存在"
else
    echo "❌ toggleApp → updateAppSelection 链路缺失"
fi

if grep -A 5 "toggleAssistant.*updateAISelection" iOSBrowser/ContentView.swift; then
    echo "✅ toggleAssistant → updateAISelection 链路存在"
else
    echo "❌ toggleAssistant → updateAISelection 链路缺失"
fi

if grep -A 5 "toggleSearchEngine.*updateSearchEngineSelection" iOSBrowser/ContentView.swift; then
    echo "✅ toggleSearchEngine → updateSearchEngineSelection 链路存在"
else
    echo "❌ toggleSearchEngine → updateSearchEngineSelection 链路缺失"
fi

if grep -A 5 "toggleQuickAction.*updateQuickActionSelection" iOSBrowser/ContentView.swift; then
    echo "✅ toggleQuickAction → updateQuickActionSelection 链路存在"
else
    echo "❌ toggleQuickAction → updateQuickActionSelection 链路缺失"
fi

echo ""
echo "1.2 检查updateXXXSelection是否调用immediateSyncToWidgets:"
if grep -A 10 "updateAppSelection" iOSBrowser/ContentView.swift | grep -q "immediateSyncToWidgets"; then
    echo "✅ updateAppSelection → immediateSyncToWidgets 链路存在"
else
    echo "❌ updateAppSelection → immediateSyncToWidgets 链路缺失"
fi

if grep -A 10 "updateAISelection" iOSBrowser/ContentView.swift | grep -q "immediateSyncToWidgets"; then
    echo "✅ updateAISelection → immediateSyncToWidgets 链路存在"
else
    echo "❌ updateAISelection → immediateSyncToWidgets 链路缺失"
fi

echo ""
echo "2. 检查数据保存机制..."

echo "2.1 检查immediateSyncToWidgets实现:"
if grep -A 20 "func immediateSyncToWidgets" iOSBrowser/ContentView.swift | grep -q "saveToWidgetAccessibleLocationFromDataSyncCenter"; then
    echo "✅ immediateSyncToWidgets 调用保存方法"
else
    echo "❌ immediateSyncToWidgets 未调用保存方法"
fi

echo "2.2 检查保存方法是否同步到UserDefaults:"
if grep -A 30 "saveToWidgetAccessibleLocationFromDataSyncCenter" iOSBrowser/ContentView.swift | grep -q "defaults.synchronize()"; then
    echo "✅ 保存方法调用了同步"
else
    echo "❌ 保存方法未调用同步"
fi

echo ""
echo "3. 检查小组件刷新机制..."

echo "3.1 检查是否调用WidgetCenter.reloadAllTimelines:"
if grep -q "WidgetCenter.*reloadAllTimelines\|reloadAllWidgets" iOSBrowser/ContentView.swift; then
    echo "✅ 找到小组件刷新调用"
    grep -n "WidgetCenter.*reloadAllTimelines\|reloadAllWidgets" iOSBrowser/ContentView.swift | head -3
else
    echo "❌ 未找到小组件刷新调用"
fi

echo ""
echo "4. 检查数据读取时机..."

echo "4.1 检查小组件Provider的getTimeline实现:"
if grep -A 10 "func getTimeline" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "SimpleWidgetDataManager"; then
    echo "✅ getTimeline 使用数据管理器"
else
    echo "❌ getTimeline 未使用数据管理器"
fi

echo "4.2 检查数据管理器是否每次都重新读取:"
if grep -A 5 "func getSearchEngines\|func getApps\|func getAIAssistants\|func getQuickActions" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "UserDefaults.standard.synchronize()"; then
    echo "✅ 数据管理器每次都同步读取"
else
    echo "❌ 数据管理器可能使用缓存数据"
fi

echo ""
echo "5. 检查可能的问题..."

echo "5.1 检查是否有数据缓存问题:"
if grep -q "@Published.*selected" iOSBrowser/ContentView.swift; then
    echo "⚠️  发现@Published变量，可能存在UI缓存问题"
    grep -n "@Published.*selected" iOSBrowser/ContentView.swift | head -5
else
    echo "✅ 未发现明显的缓存问题"
fi

echo "5.2 检查小组件更新频率:"
if grep -A 10 "getTimeline" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "after.*Date()"; then
    echo "✅ 小组件有定时更新机制"
else
    echo "⚠️  小组件可能缺少定时更新"
fi

echo ""
echo "6. 生成诊断建议..."

echo "💡 可能的问题和解决方案:"
echo "1. 数据保存延迟 - 用户操作后数据没有立即保存"
echo "2. 小组件刷新延迟 - 数据保存后小组件没有立即刷新"
echo "3. 数据读取缓存 - 小组件读取了旧的缓存数据"
echo "4. 进程间通信延迟 - UserDefaults同步有延迟"
echo "5. UI状态不一致 - 界面显示与实际保存的数据不一致"

echo ""
echo "🔧 建议的修复步骤:"
echo "1. 在用户操作时添加更多调试日志"
echo "2. 强制小组件立即刷新"
echo "3. 验证数据保存的时机和内容"
echo "4. 检查小组件读取数据的时机"
echo "5. 添加数据一致性验证"

echo ""
echo "🔍🔍🔍 诊断完成 🔍🔍🔍"
