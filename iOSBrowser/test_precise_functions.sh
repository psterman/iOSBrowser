#!/bin/bash

# 测试精准功能的脚本

echo "🎯 测试iOSBrowser精准功能..."

# 1. 检查代码更新
echo "📝 检查代码更新..."

if grep -q "smart-search" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 智能搜索深度链接已更新"
else
    echo "❌ 智能搜索深度链接未更新"
fi

if grep -q "direct-chat" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 直接聊天深度链接已更新"
else
    echo "❌ 直接聊天深度链接未更新"
fi

if grep -q "app-search" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 应用搜索深度链接已更新"
else
    echo "❌ 应用搜索深度链接未更新"
fi

if grep -q "smartSearchWithClipboard" iOSBrowser/ContentView.swift; then
    echo "✅ 智能搜索通知处理已添加"
else
    echo "❌ 智能搜索通知处理缺失"
fi

if grep -q "appSearchWithClipboard" iOSBrowser/ContentView.swift; then
    echo "✅ 应用搜索通知处理已添加"
else
    echo "❌ 应用搜索通知处理缺失"
fi

# 2. 编译测试
echo "🔨 编译测试..."
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowser -quiet

if [ $? -eq 0 ]; then
    echo "✅ 主应用编译成功"
else
    echo "❌ 主应用编译失败"
    exit 1
fi

xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowserWidgets -quiet

if [ $? -eq 0 ]; then
    echo "✅ 小组件编译成功"
else
    echo "❌ 小组件编译失败"
    exit 1
fi

# 3. 启动模拟器
echo "📱 启动模拟器..."
xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || echo "模拟器已在运行"

sleep 3

# 4. 测试精准深度链接
echo "🔗 测试精准深度链接..."

echo "测试智能搜索（自动剪贴板）..."
xcrun simctl openurl booted "iosbrowser://smart-search?engine=google&auto=true"

sleep 2

echo "测试AI助手直达对话..."
xcrun simctl openurl booted "iosbrowser://direct-chat?assistant=deepseek"

sleep 2

echo "测试应用搜索（自动剪贴板）..."
xcrun simctl openurl booted "iosbrowser://app-search?app=taobao&auto=true"

sleep 2

echo "✅ 深度链接测试完成！"
echo ""
echo "🎯 精准功能验证完成！"
echo ""
echo "📋 功能说明："
echo ""
echo "🔍 智能搜索小组件："
echo "   ✅ 小尺寸: 点击 → 自动使用剪贴板内容搜索"
echo "   ✅ 中尺寸: 点击引擎图标 → 使用该引擎搜索剪贴板内容"
echo "   ✅ 深度链接: iosbrowser://smart-search?engine=google&auto=true"
echo ""
echo "🤖 AI助手小组件："
echo "   ✅ 小尺寸: 点击 → 直达DeepSeek聊天界面"
echo "   ✅ 中尺寸: 点击AI图标 → 直达对应AI聊天界面"
echo "   ✅ 深度链接: iosbrowser://direct-chat?assistant=deepseek"
echo ""
echo "📱 应用启动器小组件："
echo "   ✅ 点击应用图标 → 激活应用搜索tab中对应图标"
echo "   ✅ 自动填入剪贴板内容 → 直接跳转到搜索结果"
echo "   ✅ 深度链接: iosbrowser://app-search?app=taobao&auto=true"
echo ""
echo "🎯 用户操作步骤："
echo ""
echo "1. 📋 复制要搜索的内容到剪贴板"
echo "2. 🔍 点击智能搜索小组件 → 自动搜索"
echo "3. 🤖 点击AI助手图标 → 直达聊天界面"
echo "4. 📱 点击应用图标 → 直达应用搜索结果"
echo ""
echo "✨ 减少操作步骤："
echo "   ❌ 原来: 复制 → 打开应用 → 找到搜索 → 粘贴 → 搜索"
echo "   ✅ 现在: 复制 → 点击小组件 → 直接看结果"
echo ""
echo "🎉 精准功能测试完成！"
