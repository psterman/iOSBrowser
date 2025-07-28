#!/bin/bash

# 测试小组件功能的脚本

echo "🧪 开始测试iOSBrowser小组件..."

# 1. 清理并重新编译
echo "🧹 清理项目..."
xcodebuild clean -project iOSBrowser.xcodeproj -scheme iOSBrowserWidgets

echo "🔨 编译Widget Extension..."
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowserWidgets

# 2. 测试深度链接
echo "🔗 测试深度链接..."

# 启动模拟器（如果没有运行）
xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || echo "模拟器已在运行"

# 等待模拟器启动
sleep 3

# 测试各种深度链接
echo "测试剪贴板搜索链接..."
xcrun simctl openurl booted "iosbrowser://clipboard-search?engine=google"

sleep 2

echo "测试应用搜索链接..."
xcrun simctl openurl booted "iosbrowser://apps?app=taobao"

sleep 2

echo "测试AI助手链接..."
xcrun simctl openurl booted "iosbrowser://ai?assistant=deepseek"

sleep 2

echo "✅ 深度链接测试完成！"
echo ""
echo "🎯 新功能测试："

echo "测试批量操作链接..."
xcrun simctl openurl booted "iosbrowser://batch-operation"

sleep 2

echo "测试直接聊天链接..."
xcrun simctl openurl booted "iosbrowser://direct-chat?assistant=deepseek&prompt=帮我写代码"

sleep 2

echo ""
echo "📋 接下来请手动测试："
echo "1. 在模拟器中长按主屏幕"
echo "2. 点击左上角的 '+' 按钮"
echo "3. 搜索 'iOSBrowser'"
echo "4. 添加以下小组件："
echo "   - 剪贴板搜索 (小/中)"
echo "   - 精确App搜索 (中/大)"
echo "   - AI直达对话 (中/大)"
echo "   - 快捷操作 (中)"
echo ""
echo "🎯 验证要点："
echo "✅ 小组件显示正确的图标和文字"
echo "✅ 小组件背景不是空白"
echo "✅ 点击小组件能跳转到正确页面"
echo "✅ 深度链接参数正确传递"
echo ""
echo "🆕 新功能验证："
echo "✅ 小组件配置页面 - 第4个标签页"
echo "✅ 应用搜索无需输入内容"
echo "✅ AI直达对话功能"
echo "✅ 批量操作功能"
echo "✅ 用户自定义小组件内容"
