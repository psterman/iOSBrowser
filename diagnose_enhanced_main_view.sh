#!/bin/bash

echo "🔍 诊断 EnhancedMainView 编译问题..."

# 检查 EnhancedMainView.swift 文件是否存在
if [ ! -f "iOSBrowser/EnhancedMainView.swift" ]; then
    echo "❌ EnhancedMainView.swift 文件不存在"
    exit 1
else
    echo "✅ EnhancedMainView.swift 文件存在"
fi

# 检查文件是否被包含在 Xcode 项目中
if grep -q "EnhancedMainView.swift" iOSBrowser.xcodeproj/project.pbxproj; then
    echo "✅ EnhancedMainView.swift 已包含在 Xcode 项目中"
else
    echo "❌ EnhancedMainView.swift 未包含在 Xcode 项目中"
fi

# 检查 struct 定义
if grep -q "struct EnhancedMainView: View" iOSBrowser/EnhancedMainView.swift; then
    echo "✅ EnhancedMainView struct 定义正确"
else
    echo "❌ EnhancedMainView struct 定义有问题"
fi

# 检查所有依赖项
echo ""
echo "🔍 检查依赖项..."

dependencies=(
    "WebViewModel"
    "AccessibilityManager"
    "SearchView"
    "EnhancedAIChatView"
    "AggregatedSearchView"
    "EnhancedBrowserView"
    "WidgetConfigView"
    "DataEncryptionManager"
    "AccessibilityModeToggleView"
    "GestureGuideView"
)

for dep in "${dependencies[@]}"; do
    if grep -r "struct $dep\|class $dep" iOSBrowser/ 2>/dev/null | grep -v ".git" | grep -v ".DS_Store" > /dev/null; then
        echo "✅ $dep 存在"
    else
        echo "❌ $dep 不存在"
    fi
done

# 检查语法错误
echo ""
echo "🔍 检查语法错误..."

# 检查是否有未闭合的括号
open_braces=$(grep -o '{' iOSBrowser/EnhancedMainView.swift | wc -l)
close_braces=$(grep -o '}' iOSBrowser/EnhancedMainView.swift | wc -l)

echo "开括号数量: $open_braces"
echo "闭括号数量: $close_braces"

if [ "$open_braces" -eq "$close_braces" ]; then
    echo "✅ 括号匹配正确"
else
    echo "❌ 括号不匹配"
fi

# 检查是否有语法错误
if grep -q "error:" iOSBrowser/EnhancedMainView.swift 2>/dev/null; then
    echo "❌ 发现语法错误"
    grep "error:" iOSBrowser/EnhancedMainView.swift
else
    echo "✅ 没有发现语法错误"
fi

# 检查文件编码
echo ""
echo "🔍 检查文件编码..."
file_encoding=$(file -I iOSBrowser/EnhancedMainView.swift | cut -d'=' -f2)
echo "文件编码: $file_encoding"

# 检查是否有隐藏字符
echo ""
echo "🔍 检查隐藏字符..."
if grep -q $'\t' iOSBrowser/EnhancedMainView.swift; then
    echo "⚠️  发现制表符"
else
    echo "✅ 没有制表符"
fi

# 检查文件结尾
echo ""
echo "🔍 检查文件结尾..."
last_line=$(tail -n 1 iOSBrowser/EnhancedMainView.swift)
echo "最后一行: '$last_line'"

if [[ "$last_line" == *"}"* ]]; then
    echo "✅ 文件以正确的括号结尾"
else
    echo "❌ 文件结尾不正确"
fi

echo ""
echo "🎯 诊断完成！" 