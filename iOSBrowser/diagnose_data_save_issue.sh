#!/bin/bash

# 诊断数据保存问题的脚本

echo "🔍🔍🔍 诊断数据保存问题 🔍🔍🔍"

echo "从日志分析："
echo "❌ UserDefaults.standard读取结果: iosbrowser_actions = []"
echo "❌ App Groups读取结果: widget_quick_actions = []"
echo "❌ 小组件使用默认数据: [\"search\", \"bookmark\"]"
echo ""
echo "🚨 问题：主应用没有成功保存数据到UserDefaults"

echo ""
echo "1. 检查主应用是否有初始数据..."

# 检查DataSyncCenter的初始化
if grep -A 10 "@Published.*selectedQuickActions.*=" iOSBrowser/ContentView.swift | grep -q "search.*bookmark"; then
    echo "✅ 找到selectedQuickActions初始化"
    grep -A 5 "@Published.*selectedQuickActions.*=" iOSBrowser/ContentView.swift | head -8
else
    echo "❌ 未找到selectedQuickActions初始化"
fi

echo ""
echo "2. 检查数据保存逻辑..."

# 检查保存方法是否被调用
if grep -A 20 "func updateQuickActionSelection" iOSBrowser/ContentView.swift | grep -q "immediateSyncToWidgets"; then
    echo "✅ updateQuickActionSelection调用了immediateSyncToWidgets"
else
    echo "❌ updateQuickActionSelection未调用immediateSyncToWidgets"
fi

# 检查保存的键名
if grep -q "defaults.set.*iosbrowser_actions" iOSBrowser/ContentView.swift; then
    echo "✅ 找到保存到iosbrowser_actions的代码"
else
    echo "❌ 未找到保存到iosbrowser_actions的代码"
fi

echo ""
echo "3. 可能的问题原因..."

echo "🔍 问题1: 应用启动时没有初始数据"
echo "   - selectedQuickActions可能初始化为空数组"
echo "   - 需要确保有默认值"

echo ""
echo "🔍 问题2: 用户从未操作过快捷操作配置"
echo "   - 如果用户没有点击过快捷操作tab，数据可能没有保存"
echo "   - 需要在应用启动时保存默认数据"

echo ""
echo "🔍 问题3: 数据保存时机问题"
echo "   - 可能只有在用户操作时才保存数据"
echo "   - 需要在应用启动时就保存初始数据"

echo ""
echo "4. 建议的修复方案..."

echo "💡 方案1: 在应用启动时强制保存默认数据"
echo "💡 方案2: 检查selectedQuickActions的初始值"
echo "💡 方案3: 在WidgetConfigView出现时保存当前数据"
echo "💡 方案4: 添加更多调试日志确认数据保存流程"

echo ""
echo "5. 立即测试建议..."

echo "📱 测试步骤："
echo "1. 在主应用中进入小组件配置tab"
echo "2. 点击快捷操作tab"
echo "3. 勾选/取消勾选一些快捷操作"
echo "4. 观察控制台是否有🔥🔥🔥 updateQuickActionSelection日志"
echo "5. 点击'测试联动'按钮"
echo "6. 检查小组件是否更新"

echo ""
echo "🔧 如果仍然不工作，需要："
echo "1. 检查selectedQuickActions的初始值"
echo "2. 在应用启动时强制保存默认数据"
echo "3. 确保用户操作能触发数据保存"

echo ""
echo "🔍🔍🔍 诊断完成 🔍🔍🔍"
