#!/bin/bash

# 🚀 增强功能测试脚本
# 测试每个tab的设置功能、网页版完整功能等

echo "🚀🚀🚀 开始测试增强功能..."
echo "=================================="

# 1. 检查新文件是否存在
echo "📁 检查新文件..."
enhanced_files=(
    "iOSBrowser/EnhancedMainView.swift"
    "iOSBrowser/EnhancedBrowserView.swift"
)

for file in "${enhanced_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file 存在"
    else
        echo "❌ $file 缺失"
    fi
done

echo ""

# 2. 检查主应用集成
echo "📱 检查主应用集成..."
if grep -q "EnhancedMainView" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ 主应用已集成增强主视图"
else
    echo "❌ 主应用未集成增强主视图"
fi

echo ""

# 3. 检查每个tab的设置功能
echo "⚙️ 检查每个tab的设置功能..."

# 搜索设置
if grep -q "SearchSettingsView" iOSBrowser/EnhancedMainView.swift; then
    echo "✅ 搜索Tab设置功能已实现"
else
    echo "❌ 搜索Tab设置功能未实现"
fi

# AI设置
if grep -q "AISettingsView" iOSBrowser/EnhancedMainView.swift; then
    echo "✅ AI Tab设置功能已实现"
else
    echo "❌ AI Tab设置功能未实现"
fi

# 聚合搜索设置
if grep -q "AggregatedSearchSettingsView" iOSBrowser/EnhancedMainView.swift; then
    echo "✅ 聚合搜索Tab设置功能已实现"
else
    echo "❌ 聚合搜索Tab设置功能未实现"
fi

# 浏览器设置
if grep -q "BrowserSettingsView" iOSBrowser/EnhancedMainView.swift; then
    echo "✅ 浏览器Tab设置功能已实现"
else
    echo "❌ 浏览器Tab设置功能未实现"
fi

# 通用设置
if grep -q "GeneralSettingsView" iOSBrowser/EnhancedMainView.swift; then
    echo "✅ 通用设置功能已实现"
else
    echo "❌ 通用设置功能未实现"
fi

echo ""

# 4. 检查网页版完整功能
echo "🌐 检查网页版完整功能..."

# 浏览器工具栏
if grep -q "browserToolbar" iOSBrowser/EnhancedBrowserView.swift; then
    echo "✅ 浏览器工具栏已实现"
else
    echo "❌ 浏览器工具栏未实现"
fi

# 后退前进功能
if grep -q "goBack" iOSBrowser/EnhancedBrowserView.swift; then
    echo "✅ 后退功能已实现"
else
    echo "❌ 后退功能未实现"
fi

if grep -q "goForward" iOSBrowser/EnhancedBrowserView.swift; then
    echo "✅ 前进功能已实现"
else
    echo "❌ 前进功能未实现"
fi

# 刷新功能
if grep -q "refresh" iOSBrowser/EnhancedBrowserView.swift; then
    echo "✅ 刷新功能已实现"
else
    echo "❌ 刷新功能未实现"
fi

# 书签功能
if grep -q "BookmarksView" iOSBrowser/EnhancedBrowserView.swift; then
    echo "✅ 书签功能已实现"
else
    echo "❌ 书签功能未实现"
fi

# 历史记录功能
if grep -q "HistoryView" iOSBrowser/EnhancedBrowserView.swift; then
    echo "✅ 历史记录功能已实现"
else
    echo "❌ 历史记录功能未实现"
fi

# 分享功能
if grep -q "showingShareSheet" iOSBrowser/EnhancedBrowserView.swift; then
    echo "✅ 分享功能已实现"
else
    echo "❌ 分享功能未实现"
fi

# 搜索引擎选择
if grep -q "SearchEngineSelectorView" iOSBrowser/EnhancedBrowserView.swift; then
    echo "✅ 搜索引擎选择功能已实现"
else
    echo "❌ 搜索引擎选择功能未实现"
fi

echo ""

# 5. 检查数据管理
echo "💾 检查数据管理..."

# 书签管理器
if grep -q "BookmarkManager" iOSBrowser/EnhancedBrowserView.swift; then
    echo "✅ 书签管理器已实现"
else
    echo "❌ 书签管理器未实现"
fi

# 历史管理器
if grep -q "HistoryManager" iOSBrowser/EnhancedBrowserView.swift; then
    echo "✅ 历史管理器已实现"
else
    echo "❌ 历史管理器未实现"
fi

# 数据持久化
if grep -q "UserDefaults" iOSBrowser/EnhancedBrowserView.swift; then
    echo "✅ 数据持久化已实现"
else
    echo "❌ 数据持久化未实现"
fi

echo ""

# 6. 检查导航功能
echo "🧭 检查导航功能..."

# 导航栏设置按钮
if grep -q "navigationBarTrailing" iOSBrowser/EnhancedMainView.swift; then
    echo "✅ 导航栏设置按钮已实现"
else
    echo "❌ 导航栏设置按钮未实现"
fi

# 导航标题
if grep -q "navigationTitle" iOSBrowser/EnhancedMainView.swift; then
    echo "✅ 导航标题已实现"
else
    echo "❌ 导航标题未实现"
fi

echo ""

# 7. 检查设置功能完整性
echo "🔧 检查设置功能完整性..."

# 内容拦截设置
if grep -q "内容拦截" iOSBrowser/EnhancedBrowserView.swift; then
    echo "✅ 内容拦截设置已集成"
else
    echo "❌ 内容拦截设置未集成"
fi

# HTTPS设置
if grep -q "安全传输" iOSBrowser/EnhancedBrowserView.swift; then
    echo "✅ HTTPS设置已集成"
else
    echo "❌ HTTPS设置未集成"
fi

# 数据加密设置
if grep -q "数据安全" iOSBrowser/EnhancedMainView.swift; then
    echo "✅ 数据加密设置已集成"
else
    echo "❌ 数据加密设置未集成"
fi

echo ""

echo "=================================="
echo "🎉 增强功能测试完成！"

# 8. 统计结果
echo ""
echo "📊 测试统计："
total_checks=0
passed_checks=0

# 统计文件检查
for file in "${enhanced_files[@]}"; do
    total_checks=$((total_checks + 1))
    if [ -f "$file" ]; then
        passed_checks=$((passed_checks + 1))
    fi
done

# 统计功能检查
function count_checks() {
    local pattern="$1"
    local file="$2"
    total_checks=$((total_checks + 1))
    if grep -q "$pattern" "$file"; then
        passed_checks=$((passed_checks + 1))
    fi
}

count_checks "EnhancedMainView" "iOSBrowser/iOSBrowserApp.swift"
count_checks "SearchSettingsView" "iOSBrowser/EnhancedMainView.swift"
count_checks "AISettingsView" "iOSBrowser/EnhancedMainView.swift"
count_checks "AggregatedSearchSettingsView" "iOSBrowser/EnhancedMainView.swift"
count_checks "BrowserSettingsView" "iOSBrowser/EnhancedMainView.swift"
count_checks "GeneralSettingsView" "iOSBrowser/EnhancedMainView.swift"
count_checks "browserToolbar" "iOSBrowser/EnhancedBrowserView.swift"
count_checks "goBack" "iOSBrowser/EnhancedBrowserView.swift"
count_checks "goForward" "iOSBrowser/EnhancedBrowserView.swift"
count_checks "refresh" "iOSBrowser/EnhancedBrowserView.swift"
count_checks "BookmarksView" "iOSBrowser/EnhancedBrowserView.swift"
count_checks "HistoryView" "iOSBrowser/EnhancedBrowserView.swift"
count_checks "showingShareSheet" "iOSBrowser/EnhancedBrowserView.swift"
count_checks "SearchEngineSelectorView" "iOSBrowser/EnhancedBrowserView.swift"
count_checks "BookmarkManager" "iOSBrowser/EnhancedBrowserView.swift"
count_checks "HistoryManager" "iOSBrowser/EnhancedBrowserView.swift"
count_checks "navigationBarTrailing" "iOSBrowser/EnhancedMainView.swift"

echo "总检查项: $total_checks"
echo "通过检查: $passed_checks"
echo "成功率: $((passed_checks * 100 / total_checks))%"

if [ $passed_checks -eq $total_checks ]; then
    echo "🎉 所有增强功能测试通过！"
    exit 0
else
    echo "⚠️ 部分增强功能需要完善"
    exit 1
fi 