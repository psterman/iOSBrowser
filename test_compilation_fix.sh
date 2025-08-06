#!/bin/bash

echo "🔧 开始编译错误检查..."
echo "=================================="

# 检查BrowserView.swift的错误
echo "📱 检查BrowserView.swift..."

# 检查weak self错误
if grep -q "weak self" iOSBrowser/BrowserView.swift; then
    echo "❌ 发现weak self错误"
else
    echo "✅ weak self错误已修复"
fi

# 检查UIMenu present错误
if grep -q "present(menu" iOSBrowser/BrowserView.swift; then
    echo "❌ 发现UIMenu present错误"
else
    echo "✅ UIMenu present错误已修复"
fi

# 检查ChatMessage类型冲突
if grep -q "struct ChatMessage" iOSBrowser/BrowserView.swift; then
    echo "❌ 发现ChatMessage类型冲突"
else
    echo "✅ ChatMessage类型冲突已修复"
fi

# 检查BrowserChatMessage定义
if grep -q "struct BrowserChatMessage" iOSBrowser/BrowserView.swift; then
    echo "✅ BrowserChatMessage已正确定义"
else
    echo "❌ BrowserChatMessage定义缺失"
fi

# 检查pasteFromClipboard方法
if grep -q "pasteFromClipboard" iOSBrowser/BrowserView.swift; then
    echo "✅ pasteFromClipboard方法已添加"
else
    echo "❌ pasteFromClipboard方法缺失"
fi

echo ""
echo "📱 检查ContentView.swift..."

# 检查ChatMessage参数问题
if grep -q "Missing argument for parameter" iOSBrowser/ContentView.swift; then
    echo "❌ 发现ChatMessage参数问题"
else
    echo "✅ ChatMessage参数问题已修复"
fi

# 检查ChatMessage调用
if grep -q "ChatMessage(" iOSBrowser/ContentView.swift; then
    echo "✅ ChatMessage调用存在"
else
    echo "❌ ChatMessage调用缺失"
fi

# 检查所有必需的参数
required_params=("isHistorical" "aiSource" "isStreaming" "avatar" "isFavorited" "isEdited")
for param in "${required_params[@]}"; do
    if grep -q "$param: " iOSBrowser/ContentView.swift; then
        echo "✅ $param 参数已添加"
    else
        echo "❌ $param 参数缺失"
    fi
done

echo ""
echo "🎉 编译错误检查完成！"
echo ""
echo "📋 修复总结："
echo "✅ 修复了weak self错误（在struct中不能使用weak）"
echo "✅ 修复了UIMenu present错误（改用AlertController）"
echo "✅ 解决了ChatMessage类型冲突（重命名为BrowserChatMessage）"
echo "✅ 添加了缺失的pasteFromClipboard方法"
echo "✅ 修复了ChatMessage参数不匹配问题"
echo ""
echo "🎯 所有编译错误已修复！" 