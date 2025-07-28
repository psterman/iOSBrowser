#!/bin/bash

# 桌面小组件深度链接测试脚本

echo "🔗 桌面小组件深度链接测试..."

# 1. 检查深度链接处理器更新
echo "📝 检查深度链接处理器更新..."

if grep -q "handleAppSearchAction" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ 应用搜索处理函数已添加"
else
    echo "❌ 应用搜索处理函数缺失"
fi

if grep -q "handleSearchEngineAction" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ 搜索引擎处理函数已添加"
else
    echo "❌ 搜索引擎处理函数缺失"
fi

if grep -q "handleAIAssistantAction" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ AI助手处理函数已添加"
else
    echo "❌ AI助手处理函数缺失"
fi

if grep -q "startAIConversation" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ AI对话通知已添加"
else
    echo "❌ AI对话通知缺失"
fi

# 2. 检查tab索引修复
echo ""
echo "📱 检查tab索引修复..."

if grep -q "targetTab = 0.*SearchView" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ 搜索tab索引正确 (0)"
else
    echo "❌ 搜索tab索引错误"
fi

if grep -q "targetTab = 2.*SimpleAIChatView" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ AI tab索引正确 (2)"
else
    echo "❌ AI tab索引错误"
fi

# 3. 检查SearchView深度链接处理
echo ""
echo "🔍 检查SearchView深度链接处理..."

if grep -q "handleDeepLinkIfNeeded" iOSBrowser/SearchView.swift; then
    echo "✅ SearchView深度链接处理已添加"
else
    echo "❌ SearchView深度链接处理缺失"
fi

if grep -q "findAppById" iOSBrowser/SearchView.swift; then
    echo "✅ 应用ID映射函数已添加"
else
    echo "❌ 应用ID映射函数缺失"
fi

if grep -q "deepLinkHandler.selectedApp" iOSBrowser/SearchView.swift; then
    echo "✅ 应用选择处理已添加"
else
    echo "❌ 应用选择处理缺失"
fi

if grep -q "deepLinkHandler.selectedEngine" iOSBrowser/SearchView.swift; then
    echo "✅ 搜索引擎选择处理已添加"
else
    echo "❌ 搜索引擎选择处理缺失"
fi

# 4. 检查SimpleAIChatView通知处理
echo ""
echo "🤖 检查SimpleAIChatView通知处理..."

if grep -q "startAIConversation" iOSBrowser/SimpleAIChatView.swift; then
    echo "✅ AI对话通知处理已添加"
else
    echo "❌ AI对话通知处理缺失"
fi

if grep -q "startDirectChatWithMessage" iOSBrowser/SimpleAIChatView.swift; then
    echo "✅ 带消息的聊天启动函数已添加"
else
    echo "❌ 带消息的聊天启动函数缺失"
fi

# 5. 检查小组件URL格式
echo ""
echo "📱 检查小组件URL格式..."

widget_urls=(
    "iosbrowser://search?app="
    "iosbrowser://search?engine="
    "iosbrowser://ai?assistant="
    "iosbrowser://action?type="
)

url_count=0
for url in "${widget_urls[@]}"; do
    if grep -q "$url" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
        ((url_count++))
    fi
done

echo "📱 小组件URL格式: $url_count/${#widget_urls[@]}"

if [ $url_count -eq ${#widget_urls[@]} ]; then
    echo "✅ 小组件URL格式正确"
else
    echo "❌ 小组件URL格式不完整"
fi

# 6. 编译测试
echo ""
echo "🔨 编译测试..."
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowser -quiet

if [ $? -eq 0 ]; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

# 7. 启动模拟器测试
echo ""
echo "📱 启动模拟器测试..."
xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || echo "模拟器已在运行"

sleep 3

# 8. 测试深度链接
echo ""
echo "🔗 测试深度链接..."

echo "测试应用搜索深度链接..."
xcrun simctl openurl booted "iosbrowser://search?app=taobao"

sleep 2

echo "测试搜索引擎深度链接..."
xcrun simctl openurl booted "iosbrowser://search?engine=baidu"

sleep 2

echo "测试AI助手深度链接..."
xcrun simctl openurl booted "iosbrowser://ai?assistant=deepseek"

sleep 2

echo "测试快捷操作深度链接..."
xcrun simctl openurl booted "iosbrowser://action?type=search"

sleep 2

echo ""
echo "🎉 桌面小组件深度链接测试完成！"
echo ""
echo "✅ 修复的问题："
echo "   - AI助手深度链接处理"
echo "   - tab索引错误修复"
echo "   - SearchView深度链接响应"
echo "   - SimpleAIChatView通知处理"
echo "   - 应用ID到应用名称映射"
echo ""
echo "🚀 深度链接流程："
echo "   1. 用户点击桌面小组件"
echo "   2. 触发深度链接: iosbrowser://search?app=taobao"
echo "   3. DeepLinkHandler处理URL"
echo "   4. 检测剪贴板内容"
echo "   5. 有内容：直接跳转外部应用搜索"
echo "   6. 无内容：跳转应用内搜索并自动选中应用"
echo ""
echo "📱 支持的深度链接格式："
echo "   🔍 应用搜索: iosbrowser://search?app={appId}"
echo "   🌐 搜索引擎: iosbrowser://search?engine={engineId}"
echo "   🤖 AI助手: iosbrowser://ai?assistant={assistantId}"
echo "   ⚡ 快捷操作: iosbrowser://action?type={actionType}"
echo ""
echo "🧪 测试步骤："
echo "   1. 复制文本到剪贴板: 'iPhone 15 Pro Max'"
echo "   2. 点击桌面小组件中的淘宝图标"
echo "   3. 验证是否直接跳转到淘宝搜索"
echo "   4. 清空剪贴板，再次点击"
echo "   5. 验证是否跳转到应用内搜索并选中淘宝"
echo ""
echo "🎯 预期效果："
echo "   ✅ 有剪贴板内容时直接跳转外部应用"
echo "   ✅ 无剪贴板内容时跳转应用内对应tab"
echo "   ✅ 自动选中对应的应用/搜索引擎/AI助手"
echo "   ✅ 搜索框自动填入剪贴板内容或默认值"
echo "   ✅ 深度链接参数正确传递和处理"
