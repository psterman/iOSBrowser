#!/bin/bash

# 测试实时数据联动的脚本

echo "🚀🚀🚀 测试实时数据联动功能 🚀🚀🚀"

# 1. 验证修复内容
echo "1. 验证修复内容..."

echo "1.1 检查小组件Timeline策略是否修复:"
if grep -q "policy: \.after" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件Timeline策略已修复为定时更新"
    grep -n "policy: \.after" iOSBrowserWidgets/iOSBrowserWidgets.swift | head -3
else
    echo "❌ 小组件Timeline策略未修复"
fi

echo ""
echo "1.2 检查增强的实时刷新策略:"
if grep -q "增强的实时刷新策略" iOSBrowser/ContentView.swift; then
    echo "✅ 找到增强的实时刷新策略"
else
    echo "❌ 未找到增强的实时刷新策略"
fi

echo ""
echo "1.3 检查实时数据验证方法:"
if grep -q "validateDataSyncRealtime" iOSBrowser/ContentView.swift; then
    echo "✅ 找到实时数据验证方法"
    grep -c "validateDataSyncRealtime" iOSBrowser/ContentView.swift | head -1
else
    echo "❌ 未找到实时数据验证方法"
fi

echo ""
echo "2. 验证数据流向完整性..."

echo "2.1 用户操作 → 数据更新链路:"
if grep -A 5 "toggleApp.*updateAppSelection" iOSBrowser/ContentView.swift >/dev/null 2>&1; then
    echo "✅ toggleApp → updateAppSelection 链路存在"
else
    echo "❌ toggleApp → updateAppSelection 链路缺失"
fi

echo "2.2 数据更新 → 立即同步链路:"
if grep -A 10 "updateAppSelection" iOSBrowser/ContentView.swift | grep -q "immediateSyncToWidgets"; then
    echo "✅ updateAppSelection → immediateSyncToWidgets 链路存在"
else
    echo "❌ updateAppSelection → immediateSyncToWidgets 链路缺失"
fi

echo "2.3 立即同步 → 小组件刷新链路:"
if grep -A 20 "immediateSyncToWidgets" iOSBrowser/ContentView.swift | grep -q "reloadAllWidgets"; then
    echo "✅ immediateSyncToWidgets → reloadAllWidgets 链路存在"
else
    echo "❌ immediateSyncToWidgets → reloadAllWidgets 链路缺失"
fi

echo ""
echo "3. 检查关键修复点..."

echo "3.1 小组件更新频率:"
timeline_count=$(grep -c "byAdding: \.minute, value: 5" iOSBrowserWidgets/iOSBrowserWidgets.swift)
if [ "$timeline_count" -ge 4 ]; then
    echo "✅ 所有小组件都设置了5分钟更新频率"
else
    echo "❌ 部分小组件未设置更新频率 (找到$timeline_count个)"
fi

echo "3.2 多重刷新策略:"
if grep -q "for i in 0\.\.<3" iOSBrowser/ContentView.swift; then
    echo "✅ 实现了多重刷新策略"
else
    echo "❌ 未实现多重刷新策略"
fi

echo "3.3 实时验证机制:"
validation_count=$(grep -c "validateDataSyncRealtime.*dataType.*expectedData.*key" iOSBrowser/ContentView.swift)
if [ "$validation_count" -ge 2 ]; then
    echo "✅ 实现了实时验证机制 (找到$validation_count个调用)"
else
    echo "❌ 实时验证机制不完整 (只找到$validation_count个调用)"
fi

echo ""
echo "4. 生成测试建议..."

echo "💡 实时联动测试步骤:"
echo "1. 在Xcode中编译并运行项目"
echo "2. 进入小组件配置tab"
echo "3. 勾选/取消勾选一些应用或AI助手"
echo "4. 观察控制台日志，应该看到:"
echo "   - 🔥🔥🔥 toggleApp/toggleAssistant 被调用"
echo "   - 🔥🔥🔥 updateAppSelection/updateAISelection 被调用"
echo "   - 🔥🔥🔥 立即同步到小组件开始"
echo "   - 🔍🔍🔍 实时验证数据同步"
echo "   - 🎉 数据同步成功"
echo "5. 添加小组件到桌面"
echo "6. 检查小组件是否在5分钟内显示最新的用户选择"

echo ""
echo "🔧 如果仍然不工作，可能的原因:"
echo "1. App Groups配置问题 - 需要在Xcode中配置entitlements"
echo "2. 小组件缓存问题 - 尝试删除并重新添加小组件"
echo "3. 系统限制 - iOS可能限制小组件更新频率"
echo "4. 数据格式问题 - 检查保存的数据格式是否正确"

echo ""
echo "📱 立即测试方法:"
echo "可以在主应用中添加一个测试按钮，直接调用:"
echo "dataSyncCenter.updateAppSelection([\"wechat\", \"alipay\", \"taobao\"])"
echo "然后观察小组件是否更新"

echo ""
echo "🚀🚀🚀 实时数据联动测试完成 🚀🚀🚀"
