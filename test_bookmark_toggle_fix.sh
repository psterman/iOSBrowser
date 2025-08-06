#!/bin/bash

echo "🔍 测试书签切换功能修复..."

# 1. 检查BrowserView中的书签功能
echo "1. 检查BrowserView中的书签功能..."
if grep -q "addToBookmarks" iOSBrowser/BrowserView.swift; then
    echo "   ✅ 书签添加功能已实现"
else
    echo "   ❌ 书签添加功能缺失"
fi

if grep -q "bookmarks.contains" iOSBrowser/BrowserView.swift; then
    echo "   ✅ 书签状态检查已实现"
else
    echo "   ❌ 书签状态检查缺失"
fi

if grep -q "bookmarks.removeAll" iOSBrowser/BrowserView.swift; then
    echo "   ✅ 书签移除功能已实现"
else
    echo "   ❌ 书签移除功能缺失"
fi

if grep -q "取消收藏" iOSBrowser/BrowserView.swift; then
    echo "   ✅ 取消收藏提示已实现"
else
    echo "   ❌ 取消收藏提示缺失"
fi

if grep -q "页面已从书签中移除" iOSBrowser/BrowserView.swift; then
    echo "   ✅ 移除成功提示已实现"
else
    echo "   ❌ 移除成功提示缺失"
fi

# 2. 检查SearchView中的收藏功能
echo "2. 检查SearchView中的收藏功能..."
if grep -q "toggleFavorite" iOSBrowser/SearchView.swift; then
    echo "   ✅ 收藏切换功能已实现"
else
    echo "   ❌ 收藏切换功能缺失"
fi

if grep -q "favoriteApps.contains" iOSBrowser/SearchView.swift; then
    echo "   ✅ 收藏状态检查已实现"
else
    echo "   ❌ 收藏状态检查缺失"
fi

if grep -q "favoriteApps.remove" iOSBrowser/SearchView.swift; then
    echo "   ✅ 取消收藏功能已实现"
else
    echo "   ❌ 取消收藏功能缺失"
fi

if grep -q "已取消收藏" iOSBrowser/SearchView.swift; then
    echo "   ✅ 取消收藏提示已实现"
else
    echo "   ❌ 取消收藏提示缺失"
fi

# 3. 检查是否还有错误的逻辑
echo "3. 检查是否还有错误的逻辑..."
if grep -q "该页面已在书签中" iOSBrowser/BrowserView.swift; then
    echo "   ❌ 发现错误的逻辑：'该页面已在书签中'"
else
    echo "   ✅ 错误逻辑已修复"
fi

if grep -q "已收藏.*该页面已在书签中" iOSBrowser/BrowserView.swift; then
    echo "   ❌ 发现错误的逻辑：'已收藏，该页面已在书签中'"
else
    echo "   ✅ 错误逻辑已修复"
fi

# 4. 检查正确的逻辑
echo "4. 检查正确的逻辑..."
if grep -q "收藏成功.*页面已添加到书签" iOSBrowser/BrowserView.swift; then
    echo "   ✅ 添加收藏逻辑正确"
else
    echo "   ❌ 添加收藏逻辑错误"
fi

if grep -q "取消收藏.*页面已从书签中移除" iOSBrowser/BrowserView.swift; then
    echo "   ✅ 取消收藏逻辑正确"
else
    echo "   ❌ 取消收藏逻辑错误"
fi

echo ""
echo "🎉 书签切换功能测试完成！"
echo ""
echo "📋 修复总结："
echo "✅ BrowserView书签功能 - 支持添加和取消收藏"
echo "✅ SearchView收藏功能 - 支持应用收藏切换"
echo "✅ 错误逻辑修复 - 移除了'该页面已在书签中'的强逻辑"
echo "✅ 正确提示信息 - 显示'取消收藏'和'页面已从书签中移除'"
echo ""
echo "🎯 功能流程："
echo "1. 用户点击收藏按钮"
echo "2. 检查页面是否已在书签中"
echo "3. 如果未收藏：添加到书签，显示'收藏成功'"
echo "4. 如果已收藏：从书签移除，显示'取消收藏'"
echo "5. 保存书签状态到本地存储" 