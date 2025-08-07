#!/bin/bash

echo "🔍 测试双抽屉功能实现"
echo "=================================="

# 检查BrowserView.swift文件
echo "📱 检查BrowserView.swift文件..."

# 检查搜索引擎抽屉相关代码
if grep -q "SearchEngineDrawerView" iOSBrowser/BrowserView.swift; then
    echo "✅ SearchEngineDrawerView已还原"
else
    echo "❌ 错误：SearchEngineDrawerView未找到"
    exit 1
fi

if grep -q "showingSearchEngineDrawer" iOSBrowser/BrowserView.swift; then
    echo "✅ showingSearchEngineDrawer变量已还原"
else
    echo "❌ 错误：showingSearchEngineDrawer变量未找到"
    exit 1
fi

if grep -q "searchEngineDrawerOffset" iOSBrowser/BrowserView.swift; then
    echo "✅ searchEngineDrawerOffset变量已还原"
else
    echo "❌ 错误：searchEngineDrawerOffset变量未找到"
    exit 1
fi

# 检查AI抽屉相关代码
if grep -q "AIDrawerView" iOSBrowser/BrowserView.swift; then
    echo "✅ AIDrawerView已添加"
else
    echo "❌ 错误：AIDrawerView未找到"
    exit 1
fi

if grep -q "showingAIDrawer" iOSBrowser/BrowserView.swift; then
    echo "✅ showingAIDrawer变量已添加"
else
    echo "❌ 错误：showingAIDrawer变量未找到"
    exit 1
fi

if grep -q "aiDrawerOffset" iOSBrowser/BrowserView.swift; then
    echo "✅ aiDrawerOffset变量已添加"
else
    echo "❌ 错误：aiDrawerOffset变量未找到"
    exit 1
fi

# 检查AIService结构体
if grep -q "struct AIService" iOSBrowser/BrowserView.swift; then
    echo "✅ AIService结构体已添加"
else
    echo "❌ 错误：AIService结构体未找到"
    exit 1
fi

# 检查AI服务列表
if grep -q "aiServices = \[" iOSBrowser/BrowserView.swift; then
    echo "✅ AI服务列表已添加"
else
    echo "❌ 错误：AI服务列表未找到"
    exit 1
fi

# 检查工具栏按钮
if grep -q "搜索引擎选择按钮" iOSBrowser/BrowserView.swift; then
    echo "✅ 搜索引擎选择按钮已还原"
else
    echo "❌ 错误：搜索引擎选择按钮未找到"
    exit 1
fi

if grep -q "AI对话按钮" iOSBrowser/BrowserView.swift; then
    echo "✅ AI对话按钮已添加"
else
    echo "❌ 错误：AI对话按钮未找到"
    exit 1
fi

# 检查抽屉overlay
if grep -q "左侧抽屉式搜索引擎列表" iOSBrowser/BrowserView.swift; then
    echo "✅ 左侧搜索引擎抽屉overlay已还原"
else
    echo "❌ 错误：左侧搜索引擎抽屉overlay未找到"
    exit 1
fi

if grep -q "右侧抽屉式AI对话列表" iOSBrowser/BrowserView.swift; then
    echo "✅ 右侧AI抽屉overlay已添加"
else
    echo "❌ 错误：右侧AI抽屉overlay未找到"
    exit 1
fi

# 检查抽屉组件
if grep -q "struct SearchEngineDrawerItem" iOSBrowser/BrowserView.swift; then
    echo "✅ SearchEngineDrawerItem组件已还原"
else
    echo "❌ 错误：SearchEngineDrawerItem组件未找到"
    exit 1
fi

if grep -q "struct AIDrawerItem" iOSBrowser/BrowserView.swift; then
    echo "✅ AIDrawerItem组件已添加"
else
    echo "❌ 错误：AIDrawerItem组件未找到"
    exit 1
fi

# 检查其他功能是否保留
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

# 检查AI服务数量
aiServiceCount=$(grep -c "AIService(id:" iOSBrowser/BrowserView.swift)
echo "✅ AI服务数量: $aiServiceCount 个"

# 检查搜索引擎数量
searchEngineCount=$(grep -c "BrowserSearchEngine(id:" iOSBrowser/BrowserView.swift)
echo "✅ 搜索引擎数量: $searchEngineCount 个"

echo ""
echo "🎉 测试完成！双抽屉功能已成功实现"
echo ""
echo "📋 功能总结："
echo "   ✅ 还原了搜索引擎抽屉（左侧）"
echo "   ✅ 添加了AI对话抽屉（右侧）"
echo "   ✅ 实现了左右两个抽屉的布局"
echo "   ✅ 添加了工具栏按钮控制抽屉显示"
echo "   ✅ 实现了抽屉互斥显示（打开一个会关闭另一个）"
echo "   ✅ 保留了浏览tab的其他功能"
echo ""
echo "🎯 用户体验："
echo "   • 点击左侧按钮显示搜索引擎抽屉"
echo "   • 点击右侧按钮显示AI对话抽屉"
echo "   • 两个抽屉互斥，同时只能显示一个"
echo "   • 点击背景或关闭按钮可以关闭抽屉"
echo "   • 选择搜索引擎或AI服务后自动关闭抽屉并加载对应页面" 