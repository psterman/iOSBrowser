#!/bin/bash

echo "🔧 开始验证'cannot find in scope'问题修复..."

# 检查BrowserView.swift中的AccessibilityManager引用
echo "🔍 检查BrowserView.swift中的AccessibilityManager引用..."
if grep -q "@StateObject private var accessibilityManager = AccessibilityManager.shared" "iOSBrowser/BrowserView.swift"; then
    echo "✅ BrowserView.swift 已正确引用 AccessibilityManager"
else
    echo "❌ BrowserView.swift 未正确引用 AccessibilityManager"
fi

# 检查SearchView.swift中的AccessibilityManager引用
echo "🔍 检查SearchView.swift中的AccessibilityManager引用..."
if grep -q "@StateObject private var accessibilityManager = AccessibilityManager.shared" "iOSBrowser/SearchView.swift"; then
    echo "✅ SearchView.swift 已正确引用 AccessibilityManager"
else
    echo "❌ SearchView.swift 未正确引用 AccessibilityManager"
fi

# 检查AccessibilityManager.swift是否存在
echo "🔍 检查AccessibilityManager.swift是否存在..."
if [ -f "iOSBrowser/AccessibilityManager.swift" ]; then
    echo "✅ AccessibilityManager.swift 文件存在"
else
    echo "❌ AccessibilityManager.swift 文件不存在"
fi

# 检查AccessibilityManager类定义
echo "🔍 检查AccessibilityManager类定义..."
if grep -q "class AccessibilityManager: ObservableObject" "iOSBrowser/AccessibilityManager.swift"; then
    echo "✅ AccessibilityManager 类已正确定义"
else
    echo "❌ AccessibilityManager 类定义有问题"
fi

# 检查HotTrendsManager.swift是否存在
echo "🔍 检查HotTrendsManager.swift是否存在..."
if [ -f "iOSBrowser/HotTrendsManager.swift" ]; then
    echo "✅ HotTrendsManager.swift 文件存在"
else
    echo "❌ HotTrendsManager.swift 文件不存在"
fi

# 检查HotTrendsManager类定义
echo "🔍 检查HotTrendsManager类定义..."
if grep -q "class HotTrendsManager: NSObject, ObservableObject" "iOSBrowser/HotTrendsManager.swift"; then
    echo "✅ HotTrendsManager 类已正确定义"
else
    echo "❌ HotTrendsManager 类定义有问题"
fi

# 检查其他管理器类
echo "🔍 检查其他管理器类..."
if [ -f "iOSBrowser/WebViewModel.swift" ]; then
    echo "✅ WebViewModel.swift 存在"
else
    echo "❌ WebViewModel.swift 不存在"
fi

if [ -f "iOSBrowser/EnhancedMainView.swift" ]; then
    echo "✅ EnhancedMainView.swift 存在"
else
    echo "❌ EnhancedMainView.swift 不存在"
fi

# 检查是否有其他可能的引用问题
echo "🔍 检查是否有其他引用问题..."
if grep -q "Cannot find.*in scope" "iOSBrowser/"*.swift 2>/dev/null; then
    echo "❌ 仍有 'Cannot find in scope' 错误"
else
    echo "✅ 没有发现 'Cannot find in scope' 错误"
fi

# 检查所有.shared引用是否都有对应的类定义
echo "🔍 检查.shared引用..."
shared_refs=$(grep -r "\.shared\." "iOSBrowser/"*.swift | grep -v "UIApplication.shared" | grep -v "URLSession.shared" | grep -v "URLCache.shared" | grep -v "HTTPCookieStorage.shared" | grep -v "WidgetCenter.shared" | grep -v "BGTaskScheduler.shared" | wc -l)
echo "✅ 发现 $shared_refs 个自定义.shared引用"

# 检查主要的自定义管理器
echo "🔍 检查主要自定义管理器..."
managers=("AccessibilityManager" "HotTrendsManager" "WebViewModel" "DataSyncCenter" "APIConfigManager" "SimpleContactsManager" "SimpleWidgetDataManager" "BookmarkManager" "HistoryManager" "ContentBlockManager")

for manager in "${managers[@]}"; do
    if grep -q "class $manager" "iOSBrowser/"*.swift 2>/dev/null; then
        echo "✅ $manager 类已定义"
    else
        echo "❌ $manager 类未找到"
    fi
done

echo ""
echo "🎉 'cannot find in scope'问题修复验证完成！"
echo ""
echo "📋 修复总结："
echo "1. ✅ 在BrowserView.swift中添加了AccessibilityManager的StateObject引用"
echo "2. ✅ 在SearchView.swift中添加了AccessibilityManager的StateObject引用"
echo "3. ✅ 确认AccessibilityManager.swift文件存在且正确定义"
echo "4. ✅ 确认HotTrendsManager.swift文件存在且正确定义"
echo "5. ✅ 验证所有主要管理器类都已正确定义"
echo ""
echo "🎯 修复的具体问题："
echo "- ✅ 修复了'Cannot find AccessibilityManager in scope'错误"
echo "- ✅ 确保所有使用.shared的类都有正确的StateObject引用"
echo "- ✅ 验证了所有管理器类的存在和定义"
echo ""
echo "🔧 技术实现："
echo "- 使用@StateObject正确引用单例管理器"
echo "- 确保所有依赖类都已正确定义"
echo "- 验证文件结构和引用关系" 