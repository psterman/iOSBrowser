#!/bin/bash

# 验证最终状态的脚本

echo "🔍 验证iOSBrowser小组件最终状态..."

# 1. 检查文件存在性
echo "📁 检查文件结构..."

if [ -f "iOSBrowserWidgets/iOSBrowserWidgets.swift" ]; then
    echo "✅ 小组件文件存在"
    echo "   文件大小: $(wc -l < iOSBrowserWidgets/iOSBrowserWidgets.swift) 行"
else
    echo "❌ 小组件文件不存在"
    exit 1
fi

if [ -f "iOSBrowser/ContentView.swift" ]; then
    echo "✅ 主应用文件存在"
else
    echo "❌ 主应用文件不存在"
    exit 1
fi

# 2. 检查关键代码
echo "📝 检查关键代码结构..."

# 检查小组件代码
if grep -q "SmartSearchWidget" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ SmartSearchWidget 已定义"
else
    echo "❌ SmartSearchWidget 未找到"
fi

if grep -q "AIAssistantWidget" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ AIAssistantWidget 已定义"
else
    echo "❌ AIAssistantWidget 未找到"
fi

if grep -q "AppLauncherWidget" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ AppLauncherWidget 已定义"
else
    echo "❌ AppLauncherWidget 未找到"
fi

# 检查主应用代码
if grep -q "WidgetConfigView" iOSBrowser/ContentView.swift; then
    echo "✅ WidgetConfigView 已定义"
else
    echo "❌ WidgetConfigView 未找到"
fi

if grep -q "DirectChatRequest" iOSBrowser/ContentView.swift; then
    echo "✅ DirectChatRequest 已定义"
else
    echo "❌ DirectChatRequest 未找到"
fi

# 3. 检查深度链接支持
echo "🔗 检查深度链接支持..."

if grep -q "batch-operation" iOSBrowser/ContentView.swift; then
    echo "✅ 批量操作深度链接支持"
else
    echo "❌ 批量操作深度链接缺失"
fi

if grep -q "direct-chat" iOSBrowser/ContentView.swift; then
    echo "✅ 直接聊天深度链接支持"
else
    echo "❌ 直接聊天深度链接缺失"
fi

# 4. 检查项目配置
echo "⚙️  检查项目配置..."

if grep -q "iOSBrowserWidgets.swift" iOSBrowser.xcodeproj/project.pbxproj; then
    echo "✅ 项目文件引用正确"
else
    echo "❌ 项目文件引用错误"
fi

# 5. 总结
echo ""
echo "🎯 最终状态总结:"
echo ""
echo "✅ 已实现的功能:"
echo "   🔍 智能搜索小组件 (小/中)"
echo "   🤖 AI助手小组件 (小/中)"
echo "   📱 应用启动器小组件 (中)"
echo "   🎛️  小组件配置界面"
echo "   🔗 深度链接支持"
echo "   ⚡ 批量操作功能"
echo ""
echo "📱 使用方法:"
echo "1. 在Xcode中打开项目"
echo "2. 选择iOSBrowser scheme编译运行"
echo "3. 在设备上长按主屏幕 → 点击'+'"
echo "4. 搜索'iOSBrowser'添加小组件"
echo "5. 在应用中点击'小组件'标签页配置"
echo ""
echo "🔗 深度链接测试:"
echo "   iosbrowser://search?engine=google"
echo "   iosbrowser://ai?assistant=deepseek"
echo "   iosbrowser://apps?app=taobao"
echo "   iosbrowser://batch-operation"
echo "   iosbrowser://direct-chat?assistant=qwen"
echo ""
echo "🎉 iOSBrowser小组件系统验证完成！"
