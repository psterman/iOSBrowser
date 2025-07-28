#!/bin/bash

# 测试编译修复的脚本

echo "🔧 测试编译修复..."

# 1. 检查视图引用
echo "📝 检查视图引用..."

if grep -q "AIContactsView()" iOSBrowser/ContentView.swift; then
    echo "✅ AIContactsView引用正确"
else
    echo "❌ AIContactsView引用错误"
fi

if grep -q "BrowseView()" iOSBrowser/ContentView.swift; then
    echo "✅ BrowseView引用正确"
else
    echo "❌ BrowseView引用错误"
fi

if grep -q "DirectChatView()" iOSBrowser/ContentView.swift; then
    echo "✅ DirectChatView引用正确"
else
    echo "❌ DirectChatView引用错误"
fi

# 2. 检查文件存在性
echo "📁 检查文件存在性..."

if [ -f "iOSBrowser/BrowseView.swift" ]; then
    echo "✅ BrowseView.swift存在"
else
    echo "❌ BrowseView.swift缺失"
fi

if [ -f "iOSBrowser/AIContactsView.swift" ]; then
    echo "✅ AIContactsView.swift存在"
else
    echo "❌ AIContactsView.swift缺失"
fi

if [ -f "iOSBrowser/DirectChatView.swift" ]; then
    echo "✅ DirectChatView.swift存在"
else
    echo "❌ DirectChatView.swift缺失"
fi

# 3. 编译测试
echo "🔨 编译测试..."

# 清理构建
xcodebuild clean -project iOSBrowser.xcodeproj -scheme iOSBrowser -quiet

# 编译主应用
echo "编译主应用..."
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowser -quiet

if [ $? -eq 0 ]; then
    echo "✅ 主应用编译成功"
else
    echo "❌ 主应用编译失败"
    echo "尝试查看详细错误..."
    xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowser 2>&1 | head -20
    exit 1
fi

# 编译小组件
echo "编译小组件..."
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowserWidgets -quiet

if [ $? -eq 0 ]; then
    echo "✅ 小组件编译成功"
else
    echo "❌ 小组件编译失败"
    echo "尝试查看详细错误..."
    xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowserWidgets 2>&1 | head -20
    exit 1
fi

echo ""
echo "🎉 编译修复完成！"
echo ""
echo "✅ 修复内容："
echo "   - 修复了ContentView中的视图引用错误"
echo "   - AIView → AIContactsView"
echo "   - 保持了BrowseView和DirectChatView的正确引用"
echo "   - 更新了深度链接处理中的tab索引"
echo ""
echo "📱 Tab结构："
echo "   0️⃣  搜索tab - SearchView"
echo "   1️⃣  浏览tab - BrowseView"
echo "   2️⃣  AI tab - AIContactsView"
echo "   3️⃣  聊天tab - DirectChatView"
echo "   4️⃣  小组件tab - WidgetConfigView"
echo ""
echo "🔗 深度链接映射："
echo "   app-search-tab → 搜索tab (0)"
echo "   browse-tab → 浏览tab (1)"
echo "   ai-chat → 聊天tab (3)"
echo ""
echo "💡 下一步："
echo "1. 在Xcode中运行应用"
echo "2. 验证所有tab正常工作"
echo "3. 测试小组件深度链接功能"
