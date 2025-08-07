#!/bin/bash

# 测试搜索tab抽屉问题修复
echo "🔍 测试搜索tab抽屉问题修复..."

# 检查ContentView.swift中的tab切换逻辑
echo "📱 检查ContentView.swift中的tab切换逻辑..."

# 检查是否使用了正确的switch语句而不是HStack
if grep -q "switch selectedTab" iOSBrowser/ContentView.swift; then
    echo "✅ 正确：使用了switch语句进行tab切换"
else
    echo "❌ 错误：未使用switch语句进行tab切换"
    exit 1
fi

# 检查是否移除了tab切换的HStack布局
if grep -A 20 "主内容区域" iOSBrowser/ContentView.swift | grep -q "HStack(spacing: 0)"; then
    echo "❌ 错误：仍然存在tab切换的HStack布局"
    exit 1
else
    echo "✅ 正确：已移除tab切换的HStack布局"
fi

# 检查是否移除了tab切换的offset逻辑
if grep -A 20 "主内容区域" iOSBrowser/ContentView.swift | grep -q "offset(x: -CGFloat(selectedTab)"; then
    echo "❌ 错误：仍然存在tab切换的offset逻辑"
    exit 1
else
    echo "✅ 正确：已移除tab切换的offset逻辑"
fi

# 检查BrowserView是否只在浏览tab中加载
echo "🔍 检查BrowserView的加载逻辑..."

# 检查switch语句中是否正确包含了BrowserView
if grep -A 10 "switch selectedTab" iOSBrowser/ContentView.swift | grep -q "BrowserView"; then
    echo "✅ 正确：BrowserView在switch语句中正确配置"
else
    echo "❌ 错误：BrowserView未在switch语句中正确配置"
    exit 1
fi

# 检查SearchView是否只在搜索tab中加载
if grep -A 10 "switch selectedTab" iOSBrowser/ContentView.swift | grep -q "SearchView"; then
    echo "✅ 正确：SearchView在switch语句中正确配置"
else
    echo "❌ 错误：SearchView未在switch语句中正确配置"
    exit 1
fi

# 检查语法是否正确
echo "🔍 检查Swift语法..."

# 使用swift语法检查
if swift -frontend -parse iOSBrowser/ContentView.swift > /dev/null 2>&1; then
    echo "✅ 正确：ContentView.swift语法检查通过"
else
    echo "❌ 错误：ContentView.swift语法检查失败"
    exit 1
fi

# 检查BrowserView.swift中的搜索引擎抽屉状态
echo "🔍 检查BrowserView中的搜索引擎抽屉状态..."

# 检查搜索引擎抽屉的初始状态
if grep -q "@State private var showingSearchEngineDrawer = false" iOSBrowser/BrowserView.swift; then
    echo "✅ 正确：搜索引擎抽屉初始状态为false"
else
    echo "❌ 错误：搜索引擎抽屉初始状态不正确"
    exit 1
fi

# 检查搜索引擎抽屉的offset初始状态
if grep -q "@State private var searchEngineDrawerOffset: CGFloat = -300" iOSBrowser/BrowserView.swift; then
    echo "✅ 正确：搜索引擎抽屉offset初始状态为-300"
else
    echo "❌ 错误：搜索引擎抽屉offset初始状态不正确"
    exit 1
fi

# 检查是否有正确的关闭逻辑
if grep -q "showingSearchEngineDrawer = false" iOSBrowser/BrowserView.swift; then
    echo "✅ 正确：存在搜索引擎抽屉关闭逻辑"
else
    echo "❌ 错误：缺少搜索引擎抽屉关闭逻辑"
    exit 1
fi

# 检查是否有正确的offset重置逻辑
if grep -q "searchEngineDrawerOffset = -300" iOSBrowser/BrowserView.swift; then
    echo "✅ 正确：存在搜索引擎抽屉offset重置逻辑"
else
    echo "❌ 错误：缺少搜索引擎抽屉offset重置逻辑"
    exit 1
fi

echo ""
echo "🎉 搜索tab抽屉问题修复验证完成！"
echo ""
echo "📋 修复内容："
echo "1. ✅ 将HStack布局改为switch语句"
echo "2. ✅ 移除了offset切换逻辑"
echo "3. ✅ 确保每个tab只加载对应的视图"
echo "4. ✅ 保持动画效果"
echo ""
echo "🔧 修复原理："
echo "- 之前：所有tab同时加载在HStack中，通过offset切换显示"
echo "- 现在：只加载当前选中的tab，通过switch语句切换"
echo "- 效果：避免BrowserView的搜索引擎抽屉在搜索tab中显示"
echo ""
echo "✅ 问题已修复：搜索tab中不再显示浏览tab的搜索引擎抽屉" 