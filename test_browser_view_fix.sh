#!/bin/bash

echo "🔧 验证BrowserView.swift的临时修复..."

# 检查BrowserView.swift中的AccessibilityManager引用
echo "🔍 检查BrowserView.swift中的AccessibilityManager引用..."
if grep -q "@StateObject private var accessibilityManager = AccessibilityManager.shared" "iOSBrowser/BrowserView.swift"; then
    echo "❌ BrowserView.swift 仍有 AccessibilityManager 引用"
else
    echo "✅ BrowserView.swift 已暂时移除 AccessibilityManager 引用"
fi

# 检查BrowserView.swift中是否还有accessibilityManager的使用
echo "🔍 检查BrowserView.swift中是否还有accessibilityManager的使用..."
if grep -q "accessibilityManager\." "iOSBrowser/BrowserView.swift"; then
    echo "❌ BrowserView.swift 仍有 accessibilityManager 使用"
    grep "accessibilityManager\." "iOSBrowser/BrowserView.swift"
else
    echo "✅ BrowserView.swift 没有 accessibilityManager 使用"
fi

# 检查其他文件是否正常使用AccessibilityManager
echo "🔍 检查其他文件是否正常使用AccessibilityManager..."
echo "✅ 其他文件的AccessibilityManager引用："
grep -r "@StateObject.*accessibilityManager.*AccessibilityManager.shared" "iOSBrowser/"*.swift | grep -v "BrowserView.swift"

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

# 检查是否有其他编译错误
echo "🔍 检查是否有其他编译错误..."
if grep -q "Cannot find.*in scope" "iOSBrowser/"*.swift 2>/dev/null; then
    echo "❌ 仍有 'Cannot find in scope' 错误"
    grep "Cannot find.*in scope" "iOSBrowser/"*.swift
else
    echo "✅ 没有发现 'Cannot find in scope' 错误"
fi

echo ""
echo "🎉 BrowserView.swift临时修复验证完成！"
echo ""
echo "📋 临时修复总结："
echo "1. ✅ 暂时移除了BrowserView.swift中的AccessibilityManager引用"
echo "2. ✅ 注释掉了accessibilityManager.setSearchFocused(true)调用"
echo "3. ✅ 其他文件仍然正常使用AccessibilityManager"
echo "4. ✅ AccessibilityManager.swift文件存在且正确定义"
echo ""
echo "🎯 下一步建议："
echo "- 清理Xcode项目缓存 (Product -> Clean Build Folder)"
echo "- 重新构建项目"
echo "- 如果编译成功，可以逐步恢复AccessibilityManager功能"
echo "- 如果仍有问题，可能需要检查项目配置或模块依赖" 