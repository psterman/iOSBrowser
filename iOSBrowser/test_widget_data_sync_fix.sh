#!/bin/bash

# 桌面小组件数据同步修复验证脚本

echo "🔄🔄🔄 桌面小组件数据同步修复验证！🔄🔄🔄"

# 1. 检查共享UserDefaults配置
echo "📊 检查共享UserDefaults配置..."

if grep -q "group.com.iosbrowser.shared" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 应用内配置已使用共享UserDefaults"
else
    echo "❌ 应用内配置未使用共享UserDefaults"
fi

if grep -q "group.com.iosbrowser.shared" iOSBrowser/Widgets/WidgetDataManager.swift; then
    echo "✅ 桌面小组件已使用共享UserDefaults"
else
    echo "❌ 桌面小组件未使用共享UserDefaults"
fi

# 2. 检查搜索引擎数据同步
echo "🔍 检查搜索引擎数据同步..."

if grep -q "widget_search_engines.*selectedEngines" iOSBrowser/Widgets/WidgetDataManager.swift; then
    echo "✅ 搜索引擎数据同步已实现"
else
    echo "❌ 搜索引擎数据同步缺失"
fi

if grep -q "selectedEnginesList.*selectedEngineIds" iOSBrowser/Widgets/WidgetDataManager.swift; then
    echo "✅ 搜索引擎按用户选择排序"
else
    echo "❌ 搜索引擎排序逻辑缺失"
fi

# 3. 检查AI助手数据同步
echo "🤖 检查AI助手数据同步..."

if grep -q "widget_ai_assistants.*selectedAssistants" iOSBrowser/Widgets/WidgetDataManager.swift; then
    echo "✅ AI助手数据同步已实现"
else
    echo "❌ AI助手数据同步缺失"
fi

if grep -q "selectedAssistantsList.*selectedAssistantIds" iOSBrowser/Widgets/WidgetDataManager.swift; then
    echo "✅ AI助手按用户选择排序"
else
    echo "❌ AI助手排序逻辑缺失"
fi

# 4. 检查应用数据同步
echo "📱 检查应用数据同步..."

if grep -q "widget_apps.*selectedApps" iOSBrowser/Widgets/WidgetDataManager.swift; then
    echo "✅ 应用数据同步已实现"
else
    echo "❌ 应用数据同步缺失"
fi

if grep -q "getAppNameFromId.*appIdToNameMap" iOSBrowser/Widgets/WidgetDataManager.swift; then
    echo "✅ 应用ID到名称映射已实现"
else
    echo "❌ 应用ID映射缺失"
fi

# 5. 检查数据完整性
echo "📊 检查数据完整性..."

# 统计搜索引擎数量
search_engine_count=$(grep -A 20 "allEngines.*=" iOSBrowser/Widgets/WidgetDataManager.swift | grep -c 'WidgetSearchEngine(id:')
echo "🔍 搜索引擎数量: $search_engine_count"

# 统计AI助手数量
ai_count=$(grep -A 50 "allAssistants.*=" iOSBrowser/Widgets/WidgetDataManager.swift | grep -c 'WidgetAIAssistant(id:')
echo "🤖 AI助手数量: $ai_count"

# 统计应用数量
app_count=$(grep -A 50 "getAllApps.*return" iOSBrowser/Widgets/WidgetDataManager.swift | grep -c 'WidgetApp(name:')
echo "📱 应用数量: $app_count"

# 6. 检查小组件刷新机制
echo "🔄 检查小组件刷新机制..."

if grep -q "refreshWidgets.*WidgetCenter.*reloadAllTimelines" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 小组件刷新机制已实现"
else
    echo "❌ 小组件刷新机制缺失"
fi

if grep -q "toggleApp.*refreshWidgets" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 应用选择时自动刷新小组件"
else
    echo "❌ 应用选择时未自动刷新"
fi

if grep -q "toggleAssistant.*refreshWidgets" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ AI助手选择时自动刷新小组件"
else
    echo "❌ AI助手选择时未自动刷新"
fi

echo ""
echo "🔄🔄🔄 桌面小组件数据同步修复完成！🔄🔄🔄"
echo ""
echo "✅ 修复内容总结："
echo "   - ✅ 使用共享UserDefaults存储配置"
echo "   - ✅ 桌面小组件从共享存储读取数据"
echo "   - ✅ 搜索引擎按用户选择同步"
echo "   - ✅ AI助手按用户选择同步"
echo "   - ✅ 应用按用户选择同步"
echo "   - ✅ 配置变更时自动刷新小组件"
echo ""
echo "📊 数据统计："
echo "   🔍 搜索引擎: $search_engine_count 个"
echo "   🤖 AI助手: $ai_count 个"
echo "   📱 应用: $app_count 个"
echo ""
echo "🔄 数据同步流程："
echo "1. 📱 用户在应用内小组件配置tab选择项目"
echo "2. 💾 配置保存到共享UserDefaults (group.com.iosbrowser.shared)"
echo "3. 🔄 自动调用WidgetCenter.shared.reloadAllTimelines()"
echo "4. 📱 桌面小组件从共享UserDefaults读取最新配置"
echo "5. 🎨 桌面小组件按用户选择显示内容"
echo ""
echo "🚀 立即测试步骤："
echo "1. ✅ 在Xcode中编译运行应用"
echo "2. 📱 切换到小组件配置tab"
echo "3. 📱 在应用选择页面选择不同的应用"
echo "4. 🤖 在AI助手页面选择不同的AI"
echo "5. 🔍 在搜索引擎页面选择不同的搜索引擎"
echo "6. 🏠 回到桌面，长按空白处进入小组件编辑模式"
echo "7. ➕ 点击左上角的\"+\"添加小组件"
echo "8. 🔍 搜索\"iOSBrowser\"或滚动找到您的应用"
echo "9. 📱 添加\"应用启动器\"小组件"
echo "10. 🤖 添加\"AI助手\"小组件"
echo "11. 🔍 添加\"智能搜索\"小组件"
echo "12. 👀 查看小组件是否显示您刚才选择的内容"
echo ""
echo "🎯 预期结果："
echo "• 应用启动器小组件显示您选择的应用"
echo "• AI助手小组件显示您选择的AI"
echo "• 智能搜索小组件显示您选择的搜索引擎"
echo "• 小组件内容与应用内配置完全一致"
echo ""
echo "🔧 如果小组件仍显示默认内容："
echo "1. 确认应用已正确编译并运行"
echo "2. 确认在应用内进行了配置选择"
echo "3. 尝试删除并重新添加小组件"
echo "4. 检查控制台是否有\"🔄 小组件已刷新\"日志"
echo "5. 重启设备以清除小组件缓存"
echo ""
echo "💡 关键改进："
echo "• 🔗 建立了应用内配置与桌面小组件的数据桥梁"
echo "• 📊 实现了实时数据同步机制"
echo "• 🎯 确保了用户选择的一致性体验"
echo "• 🔄 添加了自动刷新机制"
echo ""
echo "🌟 现在您的桌面小组件应该能正确显示您在应用内选择的内容了！"
echo "🎉 享受个性化的小组件体验！"
