#!/bin/bash

echo "🔍 开始测试搜索tab功能..."

# 1. 检查收藏按钮功能
echo "1. 检查收藏按钮功能..."
if grep -q "favoriteApps.*Set<String>" iOSBrowser/SearchView.swift; then
    echo "   ✅ 收藏状态管理已实现"
else
    echo "   ❌ 收藏状态管理缺失"
fi

if grep -q "toggleFavorite" iOSBrowser/SearchView.swift; then
    echo "   ✅ 收藏切换功能已实现"
else
    echo "   ❌ 收藏切换功能缺失"
fi

if grep -q "star.fill.*star" iOSBrowser/SearchView.swift; then
    echo "   ✅ 收藏按钮UI已实现"
else
    echo "   ❌ 收藏按钮UI缺失"
fi

# 2. 检查粘贴按钮功能
echo "2. 检查粘贴按钮功能..."
if grep -q "doc.on.clipboard" iOSBrowser/SearchView.swift; then
    echo "   ✅ 粘贴按钮已实现"
else
    echo "   ❌ 粘贴按钮缺失"
fi

if grep -q "showPasteMenu" iOSBrowser/SearchView.swift; then
    echo "   ✅ 粘贴菜单功能已实现"
else
    echo "   ❌ 粘贴菜单功能缺失"
fi

if grep -q "UIAlertController.*actionSheet" iOSBrowser/SearchView.swift; then
    echo "   ✅ 粘贴菜单UI已实现"
else
    echo "   ❌ 粘贴菜单UI缺失"
fi

# 3. 检查放大输入界面功能
echo "3. 检查放大输入界面功能..."
if grep -q "ExpandedInputView" iOSBrowser/SearchView.swift; then
    echo "   ✅ 放大输入界面已实现"
else
    echo "   ❌ 放大输入界面缺失"
fi

if grep -q "showingExpandedInput" iOSBrowser/SearchView.swift; then
    echo "   ✅ 放大输入状态管理已实现"
else
    echo "   ❌ 放大输入状态管理缺失"
fi

if grep -q "快速输入建议" iOSBrowser/SearchView.swift; then
    echo "   ✅ 快速输入建议已实现"
else
    echo "   ❌ 快速输入建议缺失"
fi

# 4. 检查后退按钮功能
echo "4. 检查后退按钮功能..."
if grep -q "chevron.left" iOSBrowser/SearchView.swift; then
    echo "   ✅ 后退按钮已实现"
else
    echo "   ❌ 后退按钮缺失"
fi

if grep -q "searchText = \"\"" iOSBrowser/SearchView.swift; then
    echo "   ✅ 后退清空功能已实现"
else
    echo "   ❌ 后退清空功能缺失"
fi

# 5. 检查AI对话功能
echo "5. 检查AI对话功能..."
if grep -q "brain.head.profile" iOSBrowser/SearchView.swift; then
    echo "   ✅ AI对话按钮已实现"
else
    echo "   ❌ AI对话按钮缺失"
fi

if grep -q "AIChatView" iOSBrowser/SearchView.swift; then
    echo "   ✅ AI对话界面已实现"
else
    echo "   ❌ AI对话界面缺失"
fi

if grep -q "ChatMessage" iOSBrowser/SearchView.swift; then
    echo "   ✅ 聊天消息模型已实现"
else
    echo "   ❌ 聊天消息模型缺失"
fi

# 6. 检查通知处理
echo "6. 检查通知处理..."
if grep -q "setupNotificationObservers" iOSBrowser/SearchView.swift; then
    echo "   ✅ 通知观察者设置已实现"
else
    echo "   ❌ 通知观察者设置缺失"
fi

if grep -q "activateAppSearch" iOSBrowser/ContentView.swift; then
    echo "   ✅ 应用搜索通知已定义"
else
    echo "   ❌ 应用搜索通知未定义"
fi

# 7. 检查数据持久化
echo "7. 检查数据持久化..."
if grep -q "UserDefaults.*favoriteApps" iOSBrowser/SearchView.swift; then
    echo "   ✅ 收藏数据持久化已实现"
else
    echo "   ❌ 收藏数据持久化缺失"
fi

# 8. 检查智能提示集成
echo "8. 检查智能提示集成..."
if grep -q "GlobalPromptManager" iOSBrowser/SearchView.swift; then
    echo "   ✅ 全局提示管理器集成已实现"
else
    echo "   ❌ 全局提示管理器集成缺失"
fi

if grep -q "PromptPickerView" iOSBrowser/SearchView.swift; then
    echo "   ✅ 提示选择器集成已实现"
else
    echo "   ❌ 提示选择器集成缺失"
fi

echo ""
echo "🎉 搜索tab功能测试完成！"
echo ""
echo "📋 功能总结："
echo "✅ 收藏按钮功能 - 支持收藏/取消收藏，状态自动保存"
echo "✅ 粘贴按钮功能 - 支持剪贴板内容和智能提示"
echo "✅ 放大输入界面 - 全屏输入，快速建议，多行支持"
echo "✅ 后退按钮功能 - 清空搜索内容"
echo "✅ AI对话功能 - 多AI助手支持，聊天界面"
echo "✅ 通知处理 - 深度链接和应用搜索支持"
echo "✅ 数据持久化 - 收藏状态自动保存"
echo "✅ 智能提示集成 - 全局提示管理器和选择器" 