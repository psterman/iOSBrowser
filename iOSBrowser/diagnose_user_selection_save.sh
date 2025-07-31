#!/bin/bash

# 诊断用户勾选数据保存问题的脚本

echo "🔍🔍🔍 诊断用户勾选数据保存问题 🔍🔍🔍"

echo "📊 问题现象："
echo "❌ 用户在tab中勾选数据"
echo "❌ 数据没有保存到UserDefaults.standard"
echo "❌ 小组件读取到空数组: iosbrowser_engines = []"

echo ""
echo "1. 检查用户操作触发链..."

echo "1.1 检查toggle方法是否存在:"
for method in "toggleApp" "toggleAssistant" "toggleSearchEngine" "toggleQuickAction"; do
    if grep -q "func $method" iOSBrowser/ContentView.swift; then
        echo "✅ $method 方法存在"
    else
        echo "❌ $method 方法缺失"
    fi
done

echo ""
echo "1.2 检查toggle方法是否调用updateXXXSelection:"
if grep -A 5 "func toggleApp" iOSBrowser/ContentView.swift | grep -q "updateAppSelection"; then
    echo "✅ toggleApp → updateAppSelection"
else
    echo "❌ toggleApp 未调用 updateAppSelection"
fi

if grep -A 5 "func toggleSearchEngine" iOSBrowser/ContentView.swift | grep -q "updateSearchEngineSelection"; then
    echo "✅ toggleSearchEngine → updateSearchEngineSelection"
else
    echo "❌ toggleSearchEngine 未调用 updateSearchEngineSelection"
fi

echo ""
echo "1.3 检查updateXXXSelection方法是否存在:"
for method in "updateAppSelection" "updateAISelection" "updateSearchEngineSelection" "updateQuickActionSelection"; do
    if grep -q "func $method" iOSBrowser/ContentView.swift; then
        echo "✅ $method 方法存在"
    else
        echo "❌ $method 方法缺失"
    fi
done

echo ""
echo "2. 检查数据保存逻辑..."

echo "2.1 检查updateXXXSelection是否调用immediateSyncToWidgets:"
if grep -A 10 "func updateSearchEngineSelection" iOSBrowser/ContentView.swift | grep -q "immediateSyncToWidgets"; then
    echo "✅ updateSearchEngineSelection → immediateSyncToWidgets"
else
    echo "❌ updateSearchEngineSelection 未调用 immediateSyncToWidgets"
fi

echo ""
echo "2.2 检查immediateSyncToWidgets是否调用保存方法:"
if grep -A 10 "func immediateSyncToWidgets" iOSBrowser/ContentView.swift | grep -q "saveToWidgetAccessibleLocationFromDataSyncCenter"; then
    echo "✅ immediateSyncToWidgets → saveToWidgetAccessibleLocationFromDataSyncCenter"
else
    echo "❌ immediateSyncToWidgets 未调用保存方法"
fi

echo ""
echo "2.3 检查保存方法是否正确保存到UserDefaults:"
if grep -A 20 "func saveToWidgetAccessibleLocationFromDataSyncCenter" iOSBrowser/ContentView.swift | grep -q "defaults.set.*iosbrowser_engines"; then
    echo "✅ 保存方法包含 iosbrowser_engines"
else
    echo "❌ 保存方法未保存 iosbrowser_engines"
fi

echo ""
echo "3. 检查可能的问题..."

echo "🔍 问题1: DataSyncCenter实例问题"
echo "   - 检查是否正确使用@StateObject"
echo "   - 检查DataSyncCenter是否被正确初始化"

if grep -q "@StateObject.*dataSyncCenter" iOSBrowser/ContentView.swift; then
    echo "✅ 找到@StateObject dataSyncCenter"
else
    echo "❌ 未找到@StateObject dataSyncCenter"
fi

echo ""
echo "🔍 问题2: 方法调用链断裂"
echo "   - 用户点击 → toggle方法 → update方法 → 保存方法"
echo "   - 任何一环断裂都会导致数据不保存"

echo ""
echo "🔍 问题3: 数据状态更新问题"
echo "   - selectedXXX变量可能没有正确更新"
echo "   - 保存的可能是旧数据"

echo ""
echo "4. 建议的调试步骤..."

echo "💡 步骤1: 添加详细日志"
echo "   在每个toggle方法中添加日志"
echo "   在每个update方法中添加日志"
echo "   在保存方法中添加日志"

echo ""
echo "💡 步骤2: 验证数据流向"
echo "   1. 用户点击搜索引擎"
echo "   2. 观察控制台是否有 toggleSearchEngine 日志"
echo "   3. 观察是否有 updateSearchEngineSelection 日志"
echo "   4. 观察是否有 immediateSyncToWidgets 日志"
echo "   5. 观察是否有保存成功日志"

echo ""
echo "💡 步骤3: 检查数据状态"
echo "   在保存前打印 selectedSearchEngines 的值"
echo "   确认数据确实被更新了"

echo ""
echo "5. 可能的修复方案..."

echo "🔧 方案1: 强化日志系统"
echo "   在关键节点添加详细日志"
echo "   确认每个步骤都被执行"

echo ""
echo "🔧 方案2: 简化调用链"
echo "   在toggle方法中直接保存数据"
echo "   减少中间环节"

echo ""
echo "🔧 方案3: 添加数据验证"
echo "   保存后立即读取验证"
echo "   确认数据确实被保存"

echo ""
echo "🔍🔍🔍 诊断完成 🔍🔍🔍"

echo ""
echo "📱 立即测试建议:"
echo "1. 在应用中进入小组件配置页面"
echo "2. 点击一个搜索引擎进行勾选/取消勾选"
echo "3. 观察控制台日志，查看是否有相关的调试信息"
echo "4. 如果没有日志，说明toggle方法没有被调用"
echo "5. 如果有日志但数据没保存，说明保存逻辑有问题"
