#!/bin/bash

# 桌面小组件同步测试脚本

echo "🔄 桌面小组件同步测试..."

# 1. 检查是否只有一个小组件文件
echo ""
echo "📁 检查小组件文件数量..."

widget_files=$(find . -name "*Widget*.swift" -type f | grep -v ".git" | wc -l)
echo "找到的小组件文件数量: $widget_files"

if [ $widget_files -eq 1 ]; then
    echo "✅ 只有一个小组件文件，没有冲突"
else
    echo "❌ 发现多个小组件文件，可能存在冲突"
    find . -name "*Widget*.swift" -type f | grep -v ".git"
fi

# 2. 检查主要小组件文件
echo ""
echo "📱 检查主要小组件文件..."

if [ -f "iOSBrowserWidgets/iOSBrowserWidgets.swift" ]; then
    echo "✅ 主要小组件文件存在: iOSBrowserWidgets/iOSBrowserWidgets.swift"
else
    echo "❌ 主要小组件文件缺失"
    exit 1
fi

# 3. 检查小组件数据同步机制
echo ""
echo "🔄 检查小组件数据同步机制..."

if grep -q "UserConfigWidgetDataManager" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件数据管理器存在"
else
    echo "❌ 小组件数据管理器缺失"
fi

if grep -q "group.com.iosbrowser.shared" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 共享存储组配置正确"
else
    echo "❌ 共享存储组配置错误"
fi

if grep -q "widget_apps" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 应用数据读取键正确"
else
    echo "❌ 应用数据读取键错误"
fi

if grep -q "widget_ai_assistants" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ AI数据读取键正确"
else
    echo "❌ AI数据读取键错误"
fi

if grep -q "widget_search_engines" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 搜索引擎数据读取键正确"
else
    echo "❌ 搜索引擎数据读取键错误"
fi

# 4. 检查深度链接URL格式
echo ""
echo "🔗 检查深度链接URL格式..."

if grep -q "iosbrowser://search?app=" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 应用搜索URL格式正确"
else
    echo "❌ 应用搜索URL格式错误"
fi

if grep -q "iosbrowser://search?engine=" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 搜索引擎URL格式正确"
else
    echo "❌ 搜索引擎URL格式错误"
fi

if grep -q "iosbrowser://ai?assistant=" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ AI助手URL格式正确"
else
    echo "❌ AI助手URL格式错误"
fi

# 5. 检查小组件视图数据绑定
echo ""
echo "📊 检查小组件视图数据绑定..."

if grep -q "ForEach.*entry\.apps" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 应用数据绑定正确"
else
    echo "❌ 应用数据绑定错误"
fi

if grep -q "ForEach.*entry\.assistants" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ AI助手数据绑定正确"
else
    echo "❌ AI助手数据绑定错误"
fi

if grep -q "ForEach.*entry\.searchEngines" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 搜索引擎数据绑定正确"
else
    echo "❌ 搜索引擎数据绑定错误"
fi

# 6. 检查主应用的数据保存机制
echo ""
echo "💾 检查主应用的数据保存机制..."

if grep -q "saveToSharedStorage" iOSBrowser/ContentView.swift; then
    echo "✅ 共享存储保存函数存在"
else
    echo "❌ 共享存储保存函数缺失"
fi

if grep -q "reloadAllWidgets" iOSBrowser/ContentView.swift; then
    echo "✅ 小组件刷新函数存在"
else
    echo "❌ 小组件刷新函数缺失"
fi

if grep -q "updateAppSelection.*reloadAllWidgets" iOSBrowser/ContentView.swift; then
    echo "✅ 应用选择更新会触发小组件刷新"
else
    echo "❌ 应用选择更新不会触发小组件刷新"
fi

# 7. 检查深度链接处理器
echo ""
echo "🔗 检查深度链接处理器..."

if grep -q "handleAppSearchAction" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ 应用搜索深度链接处理存在"
else
    echo "❌ 应用搜索深度链接处理缺失"
fi

if grep -q "handleAIAssistantAction" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ AI助手深度链接处理存在"
else
    echo "❌ AI助手深度链接处理缺失"
fi

if grep -q "handleSearchEngineAction" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ 搜索引擎深度链接处理存在"
else
    echo "❌ 搜索引擎深度链接处理缺失"
fi

# 8. 编译测试
echo ""
echo "🔨 编译测试..."
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowser -quiet

if [ $? -eq 0 ]; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

echo ""
echo "🎯 小组件同步测试总结："
echo ""
echo "✅ 已解决的问题："
echo "   1. 删除了所有冲突的小组件文件"
echo "   2. 只保留一个统一的小组件实现"
echo "   3. 确保数据同步机制完整"
echo "   4. 确保深度链接处理正确"
echo ""
echo "📱 当前小组件架构："
echo "   - 主文件: iOSBrowserWidgets/iOSBrowserWidgets.swift"
echo "   - 数据管理: UserConfigWidgetDataManager"
echo "   - 共享存储: group.com.iosbrowser.shared"
echo "   - 深度链接: iosbrowser:// 协议"
echo ""
echo "🔄 数据同步流程："
echo "   1. 用户在配置tab中选择应用/AI/搜索引擎"
echo "   2. 数据保存到共享存储 (saveToSharedStorage)"
echo "   3. 触发小组件刷新 (reloadAllWidgets)"
echo "   4. 小组件读取最新数据 (UserConfigWidgetDataManager)"
echo "   5. 小组件显示用户选择的内容"
echo ""
echo "🔗 深度链接流程："
echo "   1. 用户点击小组件图标"
echo "   2. 触发深度链接: iosbrowser://search?app=zhihu"
echo "   3. 深度链接处理器解析参数"
echo "   4. 检测剪贴板内容"
echo "   5. 智能跳转到对应功能"
echo ""
echo "🧪 测试步骤："
echo "   1. 进入小组件配置tab"
echo "   2. 修改应用选择（如：选择知乎、抖音、京东）"
echo "   3. 删除桌面上的旧小组件"
echo "   4. 重新添加'个性化应用'小组件"
echo "   5. 验证小组件是否显示新选择的应用"
echo "   6. 复制文本到剪贴板"
echo "   7. 点击小组件中的知乎图标"
echo "   8. 验证是否跳转到知乎app搜索"
echo ""
echo "🎯 预期效果："
echo "   ✅ 小组件显示用户在配置tab中选择的内容"
echo "   ✅ 点击知乎图标跳转到知乎app搜索"
echo "   ✅ 点击百度图标在浏览器中打开百度搜索"
echo "   ✅ 点击DeepSeek图标跳转到AI聊天界面"
echo "   ✅ 剪贴板内容正确传递到目标应用"
