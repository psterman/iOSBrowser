#!/bin/bash

echo "🧪 测试搜索tab改进功能"
echo "================================"

# 检查收藏功能是否已添加
echo "1. 检查收藏功能是否已添加..."
if grep -q "favoriteApps" iOSBrowser/SearchView.swift; then
    echo "✅ 收藏功能已添加"
else
    echo "❌ 收藏功能未添加"
fi

# 检查收藏按钮是否已添加
echo ""
echo "2. 检查收藏按钮是否已添加..."
if grep -q "star.fill.*star" iOSBrowser/SearchView.swift; then
    echo "✅ 收藏按钮已添加"
else
    echo "❌ 收藏按钮未添加"
fi

# 检查粘贴菜单功能是否已添加
echo ""
echo "3. 检查粘贴菜单功能是否已添加..."
if grep -q "showPasteMenu" iOSBrowser/SearchView.swift; then
    echo "✅ 粘贴菜单功能已添加"
else
    echo "❌ 粘贴菜单功能未添加"
fi

# 检查粘贴按钮是否已添加
echo ""
echo "4. 检查粘贴按钮是否已添加..."
if grep -q "doc.on.clipboard" iOSBrowser/SearchView.swift; then
    echo "✅ 粘贴按钮已添加"
else
    echo "❌ 粘贴按钮未添加"
fi

# 检查放大输入界面是否已添加
echo ""
echo "5. 检查放大输入界面是否已添加..."
if grep -q "ExpandedInputView" iOSBrowser/SearchView.swift; then
    echo "✅ 放大输入界面已添加"
else
    echo "❌ 放大输入界面未添加"
fi

# 检查放大输入界面的sheet是否已添加
echo ""
echo "6. 检查放大输入界面的sheet是否已添加..."
if grep -q "showingExpandedInput" iOSBrowser/SearchView.swift; then
    echo "✅ 放大输入界面的sheet已添加"
else
    echo "❌ 放大输入界面的sheet未添加"
fi

# 检查后退按钮是否已添加
echo ""
echo "7. 检查后退按钮是否已添加..."
if grep -q "chevron.left" iOSBrowser/SearchView.swift; then
    echo "✅ 后退按钮已添加"
else
    echo "❌ 后退按钮未添加"
fi

# 检查AI对话按钮是否已添加
echo ""
echo "8. 检查AI对话按钮是否已添加..."
if grep -q "brain.head.profile" iOSBrowser/SearchView.swift; then
    echo "✅ AI对话按钮已添加"
else
    echo "❌ AI对话按钮未添加"
fi

# 检查AI对话界面是否已添加
echo ""
echo "9. 检查AI对话界面是否已添加..."
if grep -q "AIChatView" iOSBrowser/SearchView.swift; then
    echo "✅ AI对话界面已添加"
else
    echo "❌ AI对话界面未添加"
fi

# 检查AI选择功能是否已添加
echo ""
echo "10. 检查AI选择功能是否已添加..."
if grep -q "selectedAI" iOSBrowser/SearchView.swift; then
    echo "✅ AI选择功能已添加"
else
    echo "❌ AI选择功能未添加"
fi

# 检查智能提示功能是否已添加
echo ""
echo "11. 检查智能提示功能是否已添加..."
if grep -q "showingPromptPicker" iOSBrowser/SearchView.swift; then
    echo "✅ 智能提示功能已添加"
else
    echo "❌ 智能提示功能未添加"
fi

# 检查聊天消息模型是否已添加
echo ""
echo "12. 检查聊天消息模型是否已添加..."
if grep -q "struct ChatMessage" iOSBrowser/SearchView.swift; then
    echo "✅ 聊天消息模型已添加"
else
    echo "❌ 聊天消息模型未添加"
fi

echo ""
echo "================================"
echo "🎉 搜索tab改进功能测试完成！" 