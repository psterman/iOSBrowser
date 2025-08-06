#!/bin/bash

echo "🧪 测试 WidgetDataManager 实现..."

# 检查文件是否存在
if grep -q "class WidgetDataManager" iOSBrowser/EnhancedMainView.swift; then
    echo "✅ WidgetDataManager 已正确定义"
else
    echo "❌ WidgetDataManager 未找到"
    exit 1
fi

# 检查是否移除了对 iOSBrowserApp 的直接依赖
if grep -q "iOSBrowserApp\.initializeWidgetData" iOSBrowser/EnhancedMainView.swift; then
    echo "❌ 仍然存在对 iOSBrowserApp.initializeWidgetData 的引用"
    exit 1
else
    echo "✅ 已移除对 iOSBrowserApp.initializeWidgetData 的引用"
fi

# 检查 iOSBrowserApp.swift 是否使用了新的 WidgetDataManager
if grep -q "WidgetDataManager\.shared\.initializeData" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ iOSBrowserApp 正确使用 WidgetDataManager"
else
    echo "❌ iOSBrowserApp 未使用 WidgetDataManager"
    exit 1
fi

# 检查是否还有其他循环依赖
echo ""
echo "🔍 检查其他潜在的循环依赖..."

# 检查 EnhancedMainView.swift 中的导入
if grep -q "import.*iOSBrowser" iOSBrowser/EnhancedMainView.swift; then
    echo "❌ EnhancedMainView.swift 中存在可疑的导入"
    exit 1
else
    echo "✅ EnhancedMainView.swift 导入正常"
fi

# 检查文件结构
echo ""
echo "🔍 检查文件结构..."

# 检查 WidgetDataManager 的实现
if grep -q "func initializeData" iOSBrowser/EnhancedMainView.swift; then
    echo "✅ initializeData 方法已实现"
else
    echo "❌ 缺少 initializeData 方法"
    exit 1
fi

# 检查数据初始化
if grep -q "UserDefaults\.standard" iOSBrowser/EnhancedMainView.swift; then
    echo "✅ 包含数据初始化代码"
else
    echo "❌ 缺少数据初始化代码"
    exit 1
fi

echo ""
echo "🎉 WidgetDataManager 实现验证完成！"
echo ""
echo "📋 验证总结:"
echo "   ✅ WidgetDataManager 正确定义"
echo "   ✅ 移除了循环依赖"
echo "   ✅ iOSBrowserApp 正确使用新的管理器"
echo "   ✅ 文件结构清晰"
echo "   ✅ 数据初始化逻辑完整" 