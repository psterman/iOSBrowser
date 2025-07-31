#!/bin/bash

# 测试默认数据修复的脚本

echo "🧪🧪🧪 测试默认数据修复 🧪🧪🧪"

echo "1. 验证修复内容..."

echo "1.1 检查是否在@Published初始化时保存默认值:"
if grep -A 5 "关键修复：立即保存默认值到UserDefaults" iOSBrowser/ContentView.swift | grep -q "defaults.set.*defaults.synchronize"; then
    echo "✅ 找到默认值保存逻辑"
    grep -c "关键修复：立即保存默认值到UserDefaults" iOSBrowser/ContentView.swift
else
    echo "❌ 未找到默认值保存逻辑"
fi

echo ""
echo "1.2 检查所有数据类型是否都有默认值保存:"
search_engines=$(grep -A 10 "selectedSearchEngines.*=" iOSBrowser/ContentView.swift | grep -c "defaults.set.*iosbrowser_engines")
apps=$(grep -A 10 "selectedApps.*=" iOSBrowser/ContentView.swift | grep -c "defaults.set.*iosbrowser_apps")
ai=$(grep -A 10 "selectedAIAssistants.*=" iOSBrowser/ContentView.swift | grep -c "defaults.set.*iosbrowser_ai")
actions=$(grep -A 10 "selectedQuickActions.*=" iOSBrowser/ContentView.swift | grep -c "defaults.set.*iosbrowser_actions")

echo "   搜索引擎: $search_engines 个保存点"
echo "   应用: $apps 个保存点"
echo "   AI助手: $ai 个保存点"
echo "   快捷操作: $actions 个保存点"

if [ "$search_engines" -ge 1 ] && [ "$apps" -ge 1 ] && [ "$ai" -ge 1 ] && [ "$actions" -ge 1 ]; then
    echo "✅ 所有数据类型都有默认值保存逻辑"
else
    echo "❌ 部分数据类型缺少默认值保存逻辑"
fi

echo ""
echo "2. 预期的修复效果..."

echo "🎯 修复前的问题:"
echo "   - 应用启动时，@Published变量有默认值"
echo "   - 但默认值没有保存到UserDefaults"
echo "   - 小组件读取UserDefaults时得到空数组[]"
echo "   - 小组件使用自己的默认数据"

echo ""
echo "🎯 修复后的效果:"
echo "   - 应用启动时，@Published变量有默认值"
echo "   - 默认值立即保存到UserDefaults"
echo "   - 小组件读取UserDefaults时得到正确的默认值"
echo "   - 小组件显示与主应用一致的数据"

echo ""
echo "3. 测试步骤..."

echo "📱 测试方法1 - 全新安装测试:"
echo "1. 删除应用（清除所有数据）"
echo "2. 重新安装并运行应用"
echo "3. 不进行任何操作，直接添加小组件"
echo "4. 检查小组件是否显示默认数据而不是测试数据"

echo ""
echo "📱 测试方法2 - 清除UserDefaults测试:"
echo "1. 在应用中点击'重置'按钮"
echo "2. 重启应用"
echo "3. 添加小组件"
echo "4. 检查小组件是否显示默认数据"

echo ""
echo "📱 测试方法3 - 控制台日志验证:"
echo "1. 在Xcode中运行应用"
echo "2. 观察控制台，应该看到:"
echo "   🔥🔥🔥 @Published初始化: 使用默认搜索引擎 [baidu, google]"
echo "   🔥🔥🔥 @Published初始化: 已保存默认搜索引擎到UserDefaults"
echo "   🔥🔥🔥 @Published初始化: 使用默认应用"
echo "   🔥🔥🔥 @Published初始化: 已保存默认应用到UserDefaults"
echo "3. 添加小组件，观察小组件日志:"
echo "   🔧 [SimpleWidget] UserDefaults.standard读取结果: iosbrowser_actions = [\"search\", \"bookmark\"]"
echo "   🔧 [SimpleWidget] ✅ UserDefaults读取成功: [\"search\", \"bookmark\"]"

echo ""
echo "4. 预期的小组件数据..."

echo "🎯 小组件应该显示以下默认数据:"
echo "   搜索引擎: [\"baidu\", \"google\"]"
echo "   应用: [\"taobao\", \"zhihu\", \"douyin\"]"
echo "   AI助手: [\"deepseek\", \"qwen\"]"
echo "   快捷操作: [\"search\", \"bookmark\"]"

echo ""
echo "❌ 如果小组件仍显示以下数据说明修复失败:"
echo "   搜索引擎: [\"测试引擎1\", \"测试引擎2\"]"
echo "   应用: [\"测试应用1\", \"测试应用2\"]"
echo "   AI助手: [\"测试AI1\", \"测试AI2\"]"
echo "   快捷操作: [\"测试操作1\", \"测试操作2\"]"

echo ""
echo "5. 进一步测试联动..."

echo "📱 联动测试:"
echo "1. 确认小组件显示默认数据后"
echo "2. 在主应用中进入小组件配置tab"
echo "3. 勾选/取消勾选一些选项"
echo "4. 点击'测试联动'按钮"
echo "5. 检查小组件是否更新为用户选择的数据"

echo ""
echo "🧪🧪🧪 测试指南完成 🧪🧪🧪"
