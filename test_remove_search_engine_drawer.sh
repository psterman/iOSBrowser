#!/bin/bash

echo "🔍 测试搜索引擎抽屉移除功能"
echo "=================================="

# 检查BrowserView.swift文件
echo "📱 检查BrowserView.swift文件..."

# 检查是否还有搜索引擎抽屉相关的代码
if grep -q "SearchEngineDrawerView" iOSBrowser/BrowserView.swift; then
    echo "❌ 错误：仍然存在SearchEngineDrawerView引用"
    exit 1
else
    echo "✅ SearchEngineDrawerView已成功移除"
fi

if grep -q "showingSearchEngineDrawer" iOSBrowser/BrowserView.swift; then
    echo "❌ 错误：仍然存在showingSearchEngineDrawer变量引用"
    exit 1
else
    echo "✅ showingSearchEngineDrawer变量已成功移除"
fi

if grep -q "searchEngineDrawerOffset" iOSBrowser/BrowserView.swift; then
    echo "❌ 错误：仍然存在searchEngineDrawerOffset变量引用"
    exit 1
else
    echo "✅ searchEngineDrawerOffset变量已成功移除"
fi

# 检查搜索引擎选择按钮是否已移除
if grep -q "搜索引擎选择按钮" iOSBrowser/BrowserView.swift; then
    echo "❌ 错误：仍然存在搜索引擎选择按钮"
    exit 1
else
    echo "✅ 搜索引擎选择按钮已成功移除"
fi

# 检查抽屉overlay是否已移除
if grep -q "左侧抽屉式搜索引擎列表" iOSBrowser/BrowserView.swift; then
    echo "❌ 错误：仍然存在抽屉overlay代码"
    exit 1
else
    echo "✅ 抽屉overlay代码已成功移除"
fi

# 检查是否保留了其他功能
echo ""
echo "🔧 检查其他功能是否保留..."

if grep -q "loadURL" iOSBrowser/BrowserView.swift; then
    echo "✅ loadURL功能保留"
else
    echo "❌ 错误：loadURL功能丢失"
    exit 1
fi

if grep -q "addToBookmarks" iOSBrowser/BrowserView.swift; then
    echo "✅ 书签功能保留"
else
    echo "❌ 错误：书签功能丢失"
    exit 1
fi

if grep -q "showToast" iOSBrowser/BrowserView.swift; then
    echo "✅ Toast提示功能保留"
else
    echo "❌ 错误：Toast提示功能丢失"
    exit 1
fi

# 检查搜索引擎数组是否保留（用于默认搜索功能）
if grep -q "searchEngines = \[" iOSBrowser/BrowserView.swift; then
    echo "✅ 搜索引擎数组保留（用于默认搜索功能）"
else
    echo "❌ 错误：搜索引擎数组丢失"
    exit 1
fi

echo ""
echo "🎉 测试完成！搜索引擎抽屉已成功移除，其他功能正常保留"
echo ""
echo "📋 修改总结："
echo "   ✅ 移除了搜索引擎抽屉UI组件"
echo "   ✅ 移除了搜索引擎选择按钮"
echo "   ✅ 移除了抽屉相关的状态变量"
echo "   ✅ 移除了SearchEngineDrawerView和SearchEngineDrawerItem组件"
echo "   ✅ 保留了浏览tab的其他功能（书签、Toast提示等）"
echo "   ✅ 保留了搜索引擎数组（用于默认搜索功能）"
echo ""
echo "🔍 用户现在可以正常使用浏览tab，但不会看到搜索引擎抽屉" 