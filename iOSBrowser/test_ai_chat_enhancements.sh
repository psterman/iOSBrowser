#!/bin/bash

# AI聊天功能增强验证脚本

echo "🎉 AI聊天功能增强验证开始..."

# 1. 检查流式回复功能
echo "📝 检查流式回复功能..."

if grep -q "stream.*true" iOSBrowser/ContentView.swift; then
    echo "✅ 流式API调用已启用"
else
    echo "❌ 流式API调用未启用"
fi

if grep -q "parseStreamingResponse" iOSBrowser/ContentView.swift; then
    echo "✅ 流式响应解析函数已添加"
else
    echo "❌ 流式响应解析函数缺失"
fi

if grep -q "isStreaming" iOSBrowser/ContentView.swift; then
    echo "✅ 流式状态标识已添加"
else
    echo "❌ 流式状态标识缺失"
fi

# 2. 检查Markdown支持
echo "🔍 检查Markdown支持..."

if [ -f "iOSBrowser/MarkdownView.swift" ]; then
    echo "✅ MarkdownView组件已创建"
else
    echo "❌ MarkdownView组件缺失"
fi

if grep -q "parseMarkdown" iOSBrowser/MarkdownView.swift; then
    echo "✅ Markdown解析函数已实现"
else
    echo "❌ Markdown解析函数缺失"
fi

if grep -q "MarkdownView.*content.*isFromUser" iOSBrowser/ContentView.swift; then
    echo "✅ MarkdownView已集成到消息显示"
else
    echo "❌ MarkdownView未集成"
fi

# 3. 检查内容清理功能
echo "🧹 检查内容清理功能..."

if grep -q "cleanContent" iOSBrowser/ContentView.swift; then
    echo "✅ 内容清理函数已添加"
else
    echo "❌ 内容清理函数缺失"
fi

if grep -q "regularExpression" iOSBrowser/ContentView.swift; then
    echo "✅ 正则表达式清理已实现"
else
    echo "❌ 正则表达式清理缺失"
fi

# 4. 检查消息操作功能
echo "🔧 检查消息操作功能..."

if grep -q "onLongPressGesture" iOSBrowser/ContentView.swift; then
    echo "✅ 长按手势已添加"
else
    echo "❌ 长按手势缺失"
fi

if grep -q "actionSheet.*isPresented" iOSBrowser/ContentView.swift; then
    echo "✅ 操作菜单已实现"
else
    echo "❌ 操作菜单缺失"
fi

if grep -q "editMessage.*toggleFavorite.*deleteMessage" iOSBrowser/ContentView.swift; then
    echo "✅ 消息操作函数已实现"
else
    echo "❌ 消息操作函数缺失"
fi

# 5. 检查头像功能
echo "👤 检查头像功能..."

if grep -q "getUserAvatar.*getAIAvatar" iOSBrowser/ContentView.swift; then
    echo "✅ 头像获取函数已添加"
else
    echo "❌ 头像获取函数缺失"
fi

if grep -q "avatar.*String" iOSBrowser/ContentView.swift; then
    echo "✅ 头像字段已添加到ChatMessage"
else
    echo "❌ 头像字段缺失"
fi

if grep -q "Image.*systemName.*message\.avatar" iOSBrowser/ContentView.swift; then
    echo "✅ 头像显示已实现"
else
    echo "❌ 头像显示缺失"
fi

# 6. 检查联系人列表优化
echo "📱 检查联系人列表优化..."

if grep -q "getLastMessagePreview" iOSBrowser/ContentView.swift; then
    echo "✅ 最后消息预览函数已添加"
else
    echo "❌ 最后消息预览函数缺失"
fi

if grep -q "ScrollViewReader.*proxy" iOSBrowser/ContentView.swift; then
    echo "✅ 自动滚动功能已实现"
else
    echo "❌ 自动滚动功能缺失"
fi

if grep -q "scrollTo.*lastMessage\.id" iOSBrowser/ContentView.swift; then
    echo "✅ 滚动到底部逻辑已实现"
else
    echo "❌ 滚动到底部逻辑缺失"
fi

# 7. 检查通知系统
echo "📢 检查通知系统..."

if grep -q "editMessage.*toggleFavorite.*shareMessage.*forwardMessage.*deleteMessage" iOSBrowser/ContentView.swift; then
    echo "✅ 消息操作通知已定义"
else
    echo "❌ 消息操作通知缺失"
fi

if grep -q "onReceive.*NotificationCenter" iOSBrowser/ContentView.swift; then
    echo "✅ 通知监听已实现"
else
    echo "❌ 通知监听缺失"
fi

# 8. 检查数据结构增强
echo "📊 检查数据结构增强..."

if grep -q "isStreaming.*Bool" iOSBrowser/ContentView.swift; then
    echo "✅ 流式状态字段已添加"
else
    echo "❌ 流式状态字段缺失"
fi

if grep -q "isFavorited.*Bool" iOSBrowser/ContentView.swift; then
    echo "✅ 收藏状态字段已添加"
else
    echo "❌ 收藏状态字段缺失"
fi

if grep -q "isEdited.*Bool" iOSBrowser/ContentView.swift; then
    echo "✅ 编辑状态字段已添加"
else
    echo "❌ 编辑状态字段缺失"
fi

echo ""
echo "🎯 功能验证总结："
echo ""

# 统计功能完成情况
total_checks=0
passed_checks=0

# 流式回复 (3项)
total_checks=$((total_checks + 3))
if grep -q "stream.*true" iOSBrowser/ContentView.swift; then passed_checks=$((passed_checks + 1)); fi
if grep -q "parseStreamingResponse" iOSBrowser/ContentView.swift; then passed_checks=$((passed_checks + 1)); fi
if grep -q "isStreaming" iOSBrowser/ContentView.swift; then passed_checks=$((passed_checks + 1)); fi

# Markdown支持 (3项)
total_checks=$((total_checks + 3))
if [ -f "iOSBrowser/MarkdownView.swift" ]; then passed_checks=$((passed_checks + 1)); fi
if grep -q "parseMarkdown" iOSBrowser/MarkdownView.swift 2>/dev/null; then passed_checks=$((passed_checks + 1)); fi
if grep -q "MarkdownView.*content.*isFromUser" iOSBrowser/ContentView.swift; then passed_checks=$((passed_checks + 1)); fi

# 内容清理 (2项)
total_checks=$((total_checks + 2))
if grep -q "cleanContent" iOSBrowser/ContentView.swift; then passed_checks=$((passed_checks + 1)); fi
if grep -q "regularExpression" iOSBrowser/ContentView.swift; then passed_checks=$((passed_checks + 1)); fi

# 消息操作 (3项)
total_checks=$((total_checks + 3))
if grep -q "onLongPressGesture" iOSBrowser/ContentView.swift; then passed_checks=$((passed_checks + 1)); fi
if grep -q "actionSheet.*isPresented" iOSBrowser/ContentView.swift; then passed_checks=$((passed_checks + 1)); fi
if grep -q "editMessage.*toggleFavorite.*deleteMessage" iOSBrowser/ContentView.swift; then passed_checks=$((passed_checks + 1)); fi

# 头像功能 (3项)
total_checks=$((total_checks + 3))
if grep -q "getUserAvatar.*getAIAvatar" iOSBrowser/ContentView.swift; then passed_checks=$((passed_checks + 1)); fi
if grep -q "avatar.*String" iOSBrowser/ContentView.swift; then passed_checks=$((passed_checks + 1)); fi
if grep -q "Image.*systemName.*message\.avatar" iOSBrowser/ContentView.swift; then passed_checks=$((passed_checks + 1)); fi

# 联系人优化 (3项)
total_checks=$((total_checks + 3))
if grep -q "getLastMessagePreview" iOSBrowser/ContentView.swift; then passed_checks=$((passed_checks + 1)); fi
if grep -q "ScrollViewReader.*proxy" iOSBrowser/ContentView.swift; then passed_checks=$((passed_checks + 1)); fi
if grep -q "scrollTo.*lastMessage\.id" iOSBrowser/ContentView.swift; then passed_checks=$((passed_checks + 1)); fi

# 计算完成率
completion_rate=$((passed_checks * 100 / total_checks))

echo "📊 完成情况: $passed_checks/$total_checks 项检查通过"
echo "📈 完成率: $completion_rate%"

if [ $completion_rate -ge 90 ]; then
    echo "🎉 优秀！AI聊天功能增强基本完成！"
elif [ $completion_rate -ge 70 ]; then
    echo "👍 良好！大部分功能已实现，还有少量细节需要完善。"
else
    echo "⚠️  需要继续完善功能实现。"
fi

echo ""
echo "🚀 测试建议："
echo "1. 在Xcode中编译项目，确保无编译错误"
echo "2. 运行应用，测试DeepSeek聊天功能"
echo "3. 验证流式回复、Markdown渲染、消息操作等功能"
echo "4. 检查联系人列表的最后消息预览"
echo "5. 测试自动滚动到底部功能"
echo ""
echo "🎯 AI聊天功能增强验证完成！"
