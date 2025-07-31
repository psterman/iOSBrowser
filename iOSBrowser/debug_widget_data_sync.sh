#!/bin/bash

# 调试小组件数据同步问题的脚本

echo "🔍🔍🔍 小组件数据同步问题调试 🔍🔍🔍"

# 1. 检查主应用数据保存逻辑
echo "📱 检查主应用数据保存逻辑..."

echo "1.1 检查DataSyncCenter的数据保存方法"
if grep -q "saveToWidgetAccessibleLocationFromDataSyncCenter" iOSBrowser/ContentView.swift; then
    echo "✅ 找到数据保存方法"
    
    # 检查保存的键名
    echo "1.2 检查保存的键名:"
    grep -A 20 "defaults.set.*forKey" iOSBrowser/ContentView.swift | grep "forKey" | head -10
else
    echo "❌ 未找到数据保存方法"
fi

echo ""
echo "1.3 检查App Groups保存逻辑"
if grep -q "group.com.iosbrowser.shared" iOSBrowser/ContentView.swift; then
    echo "✅ 找到App Groups保存逻辑"
    grep -A 10 "group.com.iosbrowser.shared" iOSBrowser/ContentView.swift | head -5
else
    echo "❌ 未找到App Groups保存逻辑"
fi

echo ""
echo "2. 检查小组件数据读取逻辑..."

echo "2.1 检查小组件数据管理器"
if [ -f "iOSBrowserWidgets/iOSBrowserWidgets.swift" ]; then
    echo "✅ 找到小组件文件"
    
    echo "2.2 检查读取的键名:"
    grep -n "forKey.*:" iOSBrowserWidgets/iOSBrowserWidgets.swift | head -10
    
    echo ""
    echo "2.3 检查App Groups读取:"
    grep -A 5 -B 5 "group.com.iosbrowser.shared" iOSBrowserWidgets/iOSBrowserWidgets.swift | head -10
else
    echo "❌ 未找到小组件文件"
fi

echo ""
echo "3. 对比键名匹配情况..."

echo "3.1 主应用保存的键名:"
echo "   UserDefaults: iosbrowser_engines, iosbrowser_apps, iosbrowser_ai, iosbrowser_actions"
echo "   App Groups: widget_search_engines, widget_apps, widget_ai_assistants, widget_quick_actions"

echo ""
echo "3.2 小组件读取的键名:"
grep "stringArray.*forKey" iOSBrowserWidgets/iOSBrowserWidgets.swift | sed 's/.*forKey: *"\([^"]*\)".*/   \1/' | sort | uniq

echo ""
echo "4. 检查数据流向..."

echo "4.1 用户操作触发流程:"
if grep -q "toggleApp.*dataSyncCenter.updateAppSelection" iOSBrowser/ContentView.swift; then
    echo "✅ 用户点击 → toggleApp → dataSyncCenter.updateAppSelection"
else
    echo "❌ 用户操作流程不完整"
fi

if grep -q "updateAppSelection.*immediateSyncToWidgets" iOSBrowser/ContentView.swift; then
    echo "✅ updateAppSelection → immediateSyncToWidgets"
else
    echo "❌ 数据同步流程不完整"
fi

if grep -q "immediateSyncToWidgets.*saveToWidgetAccessibleLocationFromDataSyncCenter" iOSBrowser/ContentView.swift; then
    echo "✅ immediateSyncToWidgets → saveToWidgetAccessibleLocationFromDataSyncCenter"
else
    echo "❌ 保存流程不完整"
fi

echo ""
echo "5. 检查可能的问题..."

echo "5.1 检查是否有数据类型不匹配:"
if grep -q "stringArray.*forKey.*widget_search_engines" iOSBrowserWidgets/iOSBrowserWidgets.swift && 
   grep -q "set.*selectedSearchEngines.*forKey.*widget_search_engines" iOSBrowser/ContentView.swift; then
    echo "✅ 搜索引擎数据类型匹配 (stringArray)"
else
    echo "❌ 搜索引擎数据类型可能不匹配"
fi

echo ""
echo "5.2 检查是否有进程隔离问题:"
echo "   主应用进程: iOSBrowser"
echo "   小组件进程: iOSBrowserWidgets"
echo "   共享方式: UserDefaults.standard + App Groups"

echo ""
echo "5.3 检查小组件是否正确处理空数据:"
if grep -q "isEmpty.*测试" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "⚠️  小组件在数据为空时使用测试数据"
    echo "   这可能掩盖了真正的数据读取问题"
else
    echo "✅ 小组件没有使用测试数据作为fallback"
fi

echo ""
echo "6. 建议的调试步骤..."

echo "6.1 在主应用中添加更详细的保存日志"
echo "6.2 在小组件中添加更详细的读取日志"
echo "6.3 验证App Groups配置是否正确"
echo "6.4 检查UserDefaults.synchronize()是否真正生效"
echo "6.5 测试简单的字符串保存和读取"

echo ""
echo "🔍🔍🔍 调试完成 🔍🔍🔍"
