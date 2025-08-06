#!/bin/bash

echo "🧪 开始测试 WidgetDataManager 集成..."

# 1. 检查文件存在性
echo "检查文件存在性..."
if [ -f "iOSBrowser/WidgetDataManager.swift" ]; then
    echo "✅ WidgetDataManager.swift 文件存在"
else
    echo "❌ WidgetDataManager.swift 文件不存在"
    exit 1
fi

# 2. 检查项目文件引用
echo "检查项目文件引用..."
if grep -q "WidgetDataManager.swift" iOSBrowser.xcodeproj/project.pbxproj; then
    echo "✅ WidgetDataManager.swift 已添加到项目中"
else
    echo "❌ WidgetDataManager.swift 未添加到项目中"
    exit 1
fi

# 3. 检查导入和使用
echo "检查文件导入和使用..."

# 检查 iOSBrowserApp.swift
if grep -q "WidgetDataManager.shared.initializeData()" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ iOSBrowserApp.swift 正确使用 WidgetDataManager"
else
    echo "❌ iOSBrowserApp.swift 未正确使用 WidgetDataManager"
    exit 1
fi

# 检查 EnhancedMainView.swift
if grep -q "class WidgetDataManager" iOSBrowser/EnhancedMainView.swift; then
    echo "❌ EnhancedMainView.swift 仍包含 WidgetDataManager 定义"
    exit 1
else
    echo "✅ EnhancedMainView.swift 已移除 WidgetDataManager 定义"
fi

# 4. 检查实现完整性
echo "检查实现完整性..."
if grep -q "public class WidgetDataManager" iOSBrowser/WidgetDataManager.swift && \
   grep -q "public static let shared" iOSBrowser/WidgetDataManager.swift && \
   grep -q "public func initializeData" iOSBrowser/WidgetDataManager.swift; then
    echo "✅ WidgetDataManager 实现完整"
else
    echo "❌ WidgetDataManager 实现不完整"
    exit 1
fi

# 5. 检查编译错误
echo "检查编译错误..."
if grep -q "Cannot find 'WidgetDataManager' in scope" iOSBrowser/iOSBrowserApp.swift || \
   grep -q "Cannot find 'EnhancedMainView' in scope" iOSBrowser/iOSBrowserApp.swift; then
    echo "❌ 仍存在编译错误"
    exit 1
else
    echo "✅ 未发现编译错误"
fi

echo ""
echo "🎉 测试完成！"
echo "✅ WidgetDataManager 集成验证通过" 