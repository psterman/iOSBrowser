#!/bin/bash

echo "🧪 测试浏览器改进功能"
echo "================================"

# 检查chat.html中的"how to use swiftui"是否已被清除
echo "1. 检查chat.html中的'how to use swiftui'是否已被清除..."
if grep -q "how to use swiftui" iOSBrowser/chat.html; then
    echo "❌ chat.html中仍然包含'how to use swiftui'"
else
    echo "✅ chat.html中的'how to use swiftui'已被清除"
fi

# 检查搜索引擎选择按钮大小是否已修复
echo ""
echo "2. 检查搜索引擎选择按钮大小是否已修复..."
if grep -q "frame(width: 44, height: 44)" iOSBrowser/BrowserView.swift; then
    echo "✅ 搜索引擎选择按钮大小已修复为44x44"
else
    echo "❌ 搜索引擎选择按钮大小未修复"
fi

# 检查前往按钮是否已被移除
echo ""
echo "3. 检查前往按钮是否已被移除..."
if grep -q "arrow.right.circle.fill" iOSBrowser/BrowserView.swift; then
    echo "❌ 前往按钮仍然存在"
else
    echo "✅ 前往按钮已被移除"
fi

# 检查收藏夹是否隐藏了真实地址
echo ""
echo "4. 检查收藏夹是否隐藏了真实地址..."
if grep -q "Text(extractDomain(from: bookmark))" iOSBrowser/BrowserView.swift; then
    echo "✅ 收藏夹已隐藏真实地址，只显示域名"
else
    echo "❌ 收藏夹仍然显示真实地址"
fi

# 检查收藏夹按钮是否已移到收藏动作旁边
echo ""
echo "5. 检查收藏夹按钮是否已移到收藏动作旁边..."
if grep -A 15 "addToBookmarks" iOSBrowser/BrowserView.swift | grep -q "book.fill"; then
    echo "✅ 收藏夹按钮已移到收藏动作旁边"
else
    echo "❌ 收藏夹按钮位置未调整"
fi

# 检查智能提示管理是否添加了粘贴功能
echo ""
echo "6. 检查智能提示管理是否添加了粘贴功能..."
if grep -q "pasteToInput" iOSBrowser/BrowserView.swift; then
    echo "✅ 智能提示管理已添加粘贴功能"
else
    echo "❌ 智能提示管理未添加粘贴功能"
fi

# 检查通知名称是否已添加
echo ""
echo "7. 检查粘贴通知名称是否已添加..."
if grep -q "pasteToBrowserInput" iOSBrowser/ContentView.swift; then
    echo "✅ 粘贴通知名称已添加"
else
    echo "❌ 粘贴通知名称未添加"
fi

# 检查通知处理是否已添加
echo ""
echo "8. 检查粘贴通知处理是否已添加..."
if grep -q "pasteToBrowserInput" iOSBrowser/BrowserView.swift; then
    echo "✅ 粘贴通知处理已添加"
else
    echo "❌ 粘贴通知处理未添加"
fi

echo ""
echo "================================"
echo "🎉 浏览器改进功能测试完成！" 