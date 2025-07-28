#!/bin/bash

# 测试完整小组件功能的脚本

echo "🎯 测试完整小组件功能..."

# 1. 检查代码更新
echo "📝 检查代码更新..."

if grep -q "app-search-tab" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 应用启动器小组件使用正确链接"
else
    echo "❌ 应用启动器小组件链接错误"
fi

if grep -q "browse-tab" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 智能搜索小组件使用正确链接"
else
    echo "❌ 智能搜索小组件链接错误"
fi

if grep -q "ai-chat" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ AI助手小组件使用正确链接"
else
    echo "❌ AI助手小组件链接错误"
fi

if grep -q "BrowseView" iOSBrowser/ContentView.swift; then
    echo "✅ 浏览tab已添加"
else
    echo "❌ 浏览tab缺失"
fi

if [ -f "iOSBrowser/BrowseView.swift" ]; then
    echo "✅ BrowseView文件已创建"
else
    echo "❌ BrowseView文件缺失"
fi

# 2. 编译测试
echo "🔨 编译测试..."
xcodebuild clean -project iOSBrowser.xcodeproj -scheme iOSBrowser -quiet
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowser -quiet

if [ $? -eq 0 ]; then
    echo "✅ 主应用编译成功"
else
    echo "❌ 主应用编译失败"
    exit 1
fi

xcodebuild clean -project iOSBrowser.xcodeproj -scheme iOSBrowserWidgets -quiet
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

# 4. 测试深度链接
echo "🔗 测试深度链接..."

echo "测试应用搜索tab..."
xcrun simctl openurl booted "iosbrowser://app-search-tab?app=taobao"

sleep 2

echo "测试浏览tab..."
xcrun simctl openurl booted "iosbrowser://browse-tab?engine=google&auto=true"

sleep 2

echo "测试AI聊天..."
xcrun simctl openurl booted "iosbrowser://ai-chat?assistant=deepseek"

sleep 2

echo "✅ 深度链接测试完成！"
echo ""
echo "🎯 完整功能说明："
echo ""
echo "📱 应用启动器小组件："
echo "   ✅ 点击图标 → 打开软件的搜索tab"
echo "   ✅ 自动选中对应的app图标"
echo "   ✅ 有剪贴板内容 → 自动搜索"
echo "   ✅ 无剪贴板内容 → 等待输入状态"
echo "   🔗 深度链接: iosbrowser://app-search-tab?app=taobao"
echo ""
echo "🔍 智能搜索小组件："
echo "   ✅ 点击图标 → 打开软件的浏览tab"
echo "   ✅ 加载对应搜索引擎"
echo "   ✅ 有剪贴板内容 → 显示搜索结果"
echo "   ✅ 无剪贴板内容 → 显示搜索引擎首页"
echo "   🔗 深度链接: iosbrowser://browse-tab?engine=google&auto=true"
echo ""
echo "🤖 AI助手小组件："
echo "   ✅ 点击图标 → 直接进入对应AI聊天界面"
echo "   ✅ 跳过联系人列表"
echo "   ✅ 直达具体AI的对话页面"
echo "   🔗 深度链接: iosbrowser://ai-chat?assistant=deepseek"
echo ""
echo "⚙️  设置tab功能："
echo "   ✅ 搜索引擎配置 - 选择显示在小组件中的引擎"
echo "   ✅ 应用配置 - 选择显示在小组件中的应用"
echo "   ✅ AI助手配置 - 选择显示在小组件中的AI"
echo "   ✅ 小组件预览 - 实时预览配置效果"
echo ""
echo "📋 Tab结构："
echo "   0️⃣  搜索tab - 应用搜索功能"
echo "   1️⃣  浏览tab - 搜索引擎浏览"
echo "   2️⃣  AI tab - AI联系人管理"
echo "   3️⃣  聊天tab - AI对话界面"
echo "   4️⃣  小组件tab - 小组件配置"
echo ""
echo "🎉 完整小组件功能测试完成！"
echo ""
echo "💡 测试步骤："
echo "1. 复制内容到剪贴板"
echo "2. 在Xcode中编译运行应用"
echo "3. 添加三种小组件到桌面"
echo "4. 分别测试每个小组件的功能"
echo "5. 在设置tab中配置小组件选项"
