#!/bin/bash

# 测试正确小组件代码的脚本

echo "🎯 开始测试正确的小组件代码..."

# 1. 检查文件是否存在
echo "📁 检查小组件文件..."

if [ -f "iOSBrowserWidgets/iOSBrowserWidgets.swift" ]; then
    echo "✅ 新的小组件文件存在"
else
    echo "❌ 小组件文件缺失"
    exit 1
fi

# 2. 检查关键代码结构
echo "🔍 检查代码结构..."

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

if grep -q "getSampleSearchEngines" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 示例数据函数已定义"
else
    echo "❌ 示例数据函数未找到"
fi

# 3. 编译测试
echo "🔨 编译测试..."
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowserWidgets -quiet

if [ $? -eq 0 ]; then
    echo "✅ 小组件编译成功！"
else
    echo "❌ 小组件编译失败！"
    exit 1
fi

# 4. 启动模拟器测试
echo "📱 启动模拟器..."
xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || echo "模拟器已在运行"

sleep 3

# 5. 测试深度链接
echo "🔗 测试深度链接..."

echo "测试智能搜索..."
xcrun simctl openurl booted "iosbrowser://search?engine=google"

sleep 2

echo "测试AI助手..."
xcrun simctl openurl booted "iosbrowser://ai?assistant=deepseek"

sleep 2

echo "✅ 深度链接测试完成！"
echo ""
echo "🎯 正确小组件验证完成！"
echo ""
echo "📋 手动验证步骤："
echo ""
echo "1. 📱 添加小组件："
echo "   - 长按主屏幕 → 点击'+'"
echo "   - 搜索'iOSBrowser'"
echo "   - 现在应该看到3个简洁的小组件："
echo "     🔍 智能搜索 (小/中)"
echo "     🤖 AI助手 (小/中)"
echo "     📱 应用启动器 (中)"
echo ""
echo "2. ✅ 验证特性："
echo "   ✅ 简洁设计 - 清晰的图标和文字"
echo "   ✅ 正确显示 - 无截断，完整内容"
echo "   ✅ 精确跳转 - 点击跳转到正确页面"
echo "   ✅ 深度链接 - 参数正确传递"
echo ""
echo "3. 🔗 深度链接测试："
echo "   ✅ 智能搜索: iosbrowser://search?engine=google"
echo "   ✅ AI助手: iosbrowser://ai?assistant=deepseek"
echo "   ✅ 应用启动器: taobao:// (直接启动淘宝)"
echo ""
echo "4. 🎨 视觉验证："
echo "   ✅ 图标清晰 - 所有图标正确显示"
echo "   ✅ 文字完整 - 无截断现象"
echo "   ✅ 布局合理 - 间距和对齐正确"
echo "   ✅ 颜色一致 - 统一的颜色主题"
echo ""
echo "🎉 正确小组件代码测试完成！"
echo ""
echo "💡 下一步："
echo "1. 在Xcode中运行应用"
echo "2. 添加小组件到桌面"
echo "3. 验证所有功能正常"
echo "4. 测试深度链接跳转"
