#!/bin/bash

# 桌面小组件问题诊断脚本

echo "🔍 桌面小组件问题诊断..."

# 问题1：桌面小组件没有及时更新用户配置的本地数据
echo ""
echo "📱 问题1：检查小组件数据更新机制..."

if grep -q "reloadAllWidgets" iOSBrowser/ContentView.swift; then
    echo "✅ 找到小组件刷新函数"
else
    echo "❌ 缺少小组件刷新函数"
fi

if grep -q "WidgetCenter.shared.reloadAllTimelines" iOSBrowser/ContentView.swift; then
    echo "✅ 找到WidgetCenter刷新调用"
else
    echo "❌ 缺少WidgetCenter刷新调用"
fi

if grep -q "updateAppSelection.*reloadAllWidgets" iOSBrowser/ContentView.swift; then
    echo "✅ 应用选择更新时会刷新小组件"
else
    echo "❌ 应用选择更新时不会刷新小组件"
fi

if grep -q "updateAISelection.*reloadAllWidgets" iOSBrowser/ContentView.swift; then
    echo "✅ AI选择更新时会刷新小组件"
else
    echo "❌ AI选择更新时不会刷新小组件"
fi

if grep -q "updateSearchEngineSelection.*reloadAllWidgets" iOSBrowser/ContentView.swift; then
    echo "✅ 搜索引擎选择更新时会刷新小组件"
else
    echo "❌ 搜索引擎选择更新时不会刷新小组件"
fi

# 检查共享存储保存
if grep -q "saveToSharedStorage" iOSBrowser/ContentView.swift; then
    echo "✅ 找到共享存储保存函数"
else
    echo "❌ 缺少共享存储保存函数"
fi

# 问题2：用户点击桌面小组件的图标没有精准跳转到图标对应的命令
echo ""
echo "🔗 问题2：检查深度链接精准跳转..."

# 检查小组件URL格式
if grep -q 'iosbrowser://search?app=' iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 应用搜索URL格式正确"
else
    echo "❌ 应用搜索URL格式错误"
fi

if grep -q 'iosbrowser://search?engine=' iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 搜索引擎URL格式正确"
else
    echo "❌ 搜索引擎URL格式错误"
fi

if grep -q 'iosbrowser://ai?assistant=' iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ AI助手URL格式正确"
else
    echo "❌ AI助手URL格式错误"
fi

# 检查深度链接处理
if grep -q "handleAppSearchAction" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ 应用搜索深度链接处理存在"
else
    echo "❌ 应用搜索深度链接处理缺失"
fi

if grep -q "handleSearchEngineAction" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ 搜索引擎深度链接处理存在"
else
    echo "❌ 搜索引擎深度链接处理缺失"
fi

if grep -q "handleAIAssistantAction" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ AI助手深度链接处理存在"
else
    echo "❌ AI助手深度链接处理缺失"
fi

# 检查SearchView深度链接响应
if grep -q "handleDeepLinkIfNeeded" iOSBrowser/SearchView.swift; then
    echo "✅ SearchView深度链接响应存在"
else
    echo "❌ SearchView深度链接响应缺失"
fi

# 问题3：应用桌面小组件跳转的逻辑有问题
echo ""
echo "📱 问题3：检查应用跳转逻辑..."

# 检查应用ID到URL的映射
echo "检查关键应用的URL映射："

if grep -q 'case "zhihu":' iOSBrowser/iOSBrowserApp.swift; then
    zhihu_url=$(grep -A1 'case "zhihu":' iOSBrowser/iOSBrowserApp.swift | tail -1 | sed 's/.*return URL(string: "\([^"]*\)".*/\1/')
    echo "✅ 知乎映射: $zhihu_url"
else
    echo "❌ 知乎映射缺失"
fi

if grep -q 'case "douyin":' iOSBrowser/iOSBrowserApp.swift; then
    douyin_url=$(grep -A1 'case "douyin":' iOSBrowser/iOSBrowserApp.swift | tail -1 | sed 's/.*return URL(string: "\([^"]*\)".*/\1/')
    echo "✅ 抖音映射: $douyin_url"
else
    echo "❌ 抖音映射缺失"
fi

if grep -q 'case "taobao":' iOSBrowser/iOSBrowserApp.swift; then
    taobao_url=$(grep -A1 'case "taobao":' iOSBrowser/iOSBrowserApp.swift | tail -1 | sed 's/.*return URL(string: "\([^"]*\)".*/\1/')
    echo "✅ 淘宝映射: $taobao_url"
else
    echo "❌ 淘宝映射缺失"
fi

# 检查SearchView中的应用ID映射
echo ""
echo "检查SearchView中的应用ID映射："

if grep -q '"zhihu": "知乎"' iOSBrowser/SearchView.swift; then
    echo "✅ SearchView知乎ID映射正确"
else
    echo "❌ SearchView知乎ID映射错误"
fi

if grep -q '"douyin": "抖音"' iOSBrowser/SearchView.swift; then
    echo "✅ SearchView抖音ID映射正确"
else
    echo "❌ SearchView抖音ID映射错误"
fi

if grep -q '"taobao": "淘宝"' iOSBrowser/SearchView.swift; then
    echo "✅ SearchView淘宝ID映射正确"
else
    echo "❌ SearchView淘宝ID映射错误"
fi

# 检查小组件数据管理器
echo ""
echo "🔄 检查小组件数据管理器..."

if grep -q "UserConfigWidgetDataManager" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件数据管理器存在"
else
    echo "❌ 小组件数据管理器缺失"
fi

if grep -q "getUserSelectedApps" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 用户应用选择读取函数存在"
else
    echo "❌ 用户应用选择读取函数缺失"
fi

if grep -q "group.com.iosbrowser.shared" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 共享存储组配置正确"
else
    echo "❌ 共享存储组配置错误"
fi

# 检查小组件刷新频率
echo ""
echo "⏰ 检查小组件刷新频率..."

if grep -q "30.*minute" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件30分钟刷新频率设置正确"
else
    echo "❌ 小组件刷新频率设置错误"
fi

echo ""
echo "🎯 诊断总结："
echo ""
echo "问题1 - 小组件数据更新："
echo "  - 数据更新机制应该是完整的"
echo "  - 每次用户配置变更都会触发WidgetCenter.reloadAllTimelines()"
echo "  - 如果小组件没有更新，可能是iOS系统的缓存问题"
echo ""
echo "问题2 - 深度链接精准跳转："
echo "  - URL格式应该是正确的"
echo "  - 深度链接处理逻辑应该是完整的"
echo "  - 如果跳转不精准，可能是tab索引或参数传递问题"
echo ""
echo "问题3 - 应用跳转逻辑："
echo "  - 应用ID到URL的映射应该是正确的"
echo "  - 知乎 → 知乎app，抖音 → 抖音app"
echo "  - 如果跳转错误，可能是应用ID传递或URL构建问题"
echo ""
echo "🔧 建议的修复步骤："
echo "1. 强制刷新小组件：删除桌面小组件，重新添加"
echo "2. 检查应用是否安装：确保目标应用已安装"
echo "3. 测试深度链接：使用Safari测试iosbrowser://协议"
echo "4. 查看控制台日志：观察深度链接处理过程"
echo "5. 重启应用：清除可能的缓存问题"
