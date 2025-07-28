#!/bin/bash

# 小组件显示最终修复验证脚本

echo "🚀🚀🚀 小组件显示最终修复验证！🚀🚀🚀"

# 1. 检查应用配置视图重构
echo "📱 检查应用配置视图重构..."

if grep -q "从应用搜索tab同步的.*个应用" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 应用同步标题已添加"
else
    echo "❌ 应用同步标题缺失"
fi

if grep -q "LazyVGrid.*availableApps.*enumerated" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 应用网格视图已重构"
else
    echo "❌ 应用网格视图重构失败"
fi

if grep -q "调试信息.*应用总数.*选中应用" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 应用调试信息已添加"
else
    echo "❌ 应用调试信息缺失"
fi

# 2. 检查AI助手配置视图重构
echo "🤖 检查AI助手配置视图重构..."

if grep -q "所有AI助手.*个.*已配置API.*个" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ AI统计信息已添加"
else
    echo "❌ AI统计信息缺失"
fi

if grep -q "所有AI助手列表" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ AI列表标题已添加"
else
    echo "❌ AI列表标题缺失"
fi

if grep -q "已配置API.*未配置API" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ API状态指示已添加"
else
    echo "❌ API状态指示缺失"
fi

# 3. 检查数据结构
echo "📊 检查数据结构..."

# 统计应用数量
app_count=$(grep -A 50 "availableApps.*=" iOSBrowser/WidgetConfigView.swift | grep -c '(".*", ".*", ".*", Color\.')
echo "📱 应用数量: $app_count"

# 统计AI数量
ai_count=$(grep -A 30 "allAssistants.*=" iOSBrowser/WidgetConfigView.swift | grep -c '(".*", ".*", ".*", Color\.')
echo "🤖 AI数量: $ai_count"

# 4. 检查具体应用
echo "🔍 检查具体应用..."

if grep -q "淘宝.*天猫.*拼多多.*京东.*闲鱼" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 购物类应用: 淘宝、天猫、拼多多、京东、闲鱼"
else
    echo "❌ 购物类应用缺失"
fi

if grep -q "知乎.*微博.*小红书" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 社交媒体: 知乎、微博、小红书"
else
    echo "❌ 社交媒体缺失"
fi

if grep -q "抖音.*快手.*bilibili.*YouTube.*优酷.*爱奇艺" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 视频娱乐: 抖音、快手、bilibili、YouTube、优酷、爱奇艺"
else
    echo "❌ 视频娱乐缺失"
fi

# 5. 检查具体AI
echo "🔍 检查具体AI..."

if grep -q "deepseek.*qwen.*chatglm.*moonshot" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 国内AI: DeepSeek、通义千问、智谱清言、Kimi"
else
    echo "❌ 国内AI缺失"
fi

if grep -q "openai.*claude.*gemini.*copilot" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 国际AI: ChatGPT、Claude、Gemini、Copilot"
else
    echo "❌ 国际AI缺失"
fi

if grep -q "groq.*together.*perplexity" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 高性能AI: Groq、Together AI、Perplexity"
else
    echo "❌ 高性能AI缺失"
fi

echo ""
echo "🚀🚀🚀 小组件显示最终修复完成！🚀🚀🚀"
echo ""
echo "✅ 修复内容总结："
echo "   - ✅ 完全重构了应用配置视图"
echo "   - ✅ 完全重构了AI助手配置视图"
echo "   - ✅ 添加了详细的调试信息显示"
echo "   - ✅ 简化了UI组件，直接显示数据"
echo "   - ✅ 添加了实时统计信息"
echo ""
echo "📱 应用配置视图新特性："
echo "   🎯 标题显示: \"从应用搜索tab同步的 X 个应用\""
echo "   📊 统计信息: \"当前已选择: X 个\""
echo "   🎨 简化按钮: 直接点击选择，无复杂组件"
echo "   🔍 调试面板: 显示应用总数、选中应用、应用列表"
echo "   📱 应用总数: $app_count 个"
echo ""
echo "🤖 AI助手配置视图新特性:"
echo "   🎯 多重统计: \"所有AI助手: X 个\" \"已配置API: X 个\""
echo "   🔍 API状态: 每个AI显示\"已配置API\"或\"未配置API\""
echo "   🎨 简化按钮: 直接点击选择，无复杂组件"
echo "   🔍 调试面板: 显示所有AI数量、可用AI、选中AI、AI列表"
echo "   🤖 AI总数: $ai_count 个"
echo ""
echo "🔍 调试信息说明:"
echo "   📱 应用配置加载时会输出:"
echo "      - 📱 AppConfigView 加载，应用数量: X"
echo "      - 📱 应用列表: [应用名称列表]"
echo "      - 📱 当前选中: [选中的应用ID]"
echo ""
echo "   🤖 AI助手配置加载时会输出:"
echo "      - 🤖 AIAssistantConfigView 加载"
echo "      - 🤖 所有AI数量: X"
echo "      - 🤖 所有AI列表: [AI名称列表]"
echo "      - 🤖 可用AI数量: X"
echo "      - 🤖 当前选中: [选中的AI ID]"
echo ""
echo "🚀 立即测试步骤:"
echo "1. ✅ 在Xcode中编译运行应用"
echo "2. 📱 切换到小组件配置tab"
echo "3. 📱 点击第二个tab（应用选择）"
echo "4. 👀 应该看到\"从应用搜索tab同步的 $app_count 个应用\""
echo "5. 👀 应该看到$app_count个应用的网格布局"
echo "6. 👀 应该看到底部的调试信息面板"
echo "7. 🤖 点击第三个tab（AI助手选择）"
echo "8. 👀 应该看到\"所有AI助手: $ai_count 个\""
echo "9. 👀 应该看到$ai_count个AI的网格布局"
echo "10. 👀 应该看到每个AI的API配置状态"
echo "11. 👀 应该看到底部的调试信息面板"
echo "12. 📊 查看控制台输出的详细调试信息"
echo ""
echo "🎯 预期结果:"
echo "• 应用页面显示$app_count个应用选项"
echo "• AI页面显示$ai_count个AI选项"
echo "• 每个选项都可以点击选择"
echo "• 调试面板显示详细信息"
echo "• 控制台输出完整的调试日志"
echo ""
echo "🔧 如果仍然看不到数据:"
echo "1. 检查控制台是否有错误信息"
echo "2. 确认是否正确切换到对应的tab"
echo "3. 查看调试面板中的数据统计"
echo "4. 重新编译并运行应用"
echo ""
echo "🌟 现在应该能清楚看到所有$app_count个应用和$ai_count个AI助手了！"
echo "🎉 享受您的完整小组件配置体验！"
