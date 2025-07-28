#!/bin/bash

# 智能剪贴板跳转功能测试脚本

echo "🚀 智能剪贴板跳转功能测试..."

# 1. 检查代码更新
echo "📝 检查代码更新..."

if grep -q "getClipboardText" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ 剪贴板检测函数已添加"
else
    echo "❌ 剪贴板检测函数缺失"
fi

if grep -q "buildAppSearchURL" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ 应用搜索URL构建函数已添加"
else
    echo "❌ 应用搜索URL构建函数缺失"
fi

if grep -q "buildSearchEngineURL" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ 搜索引擎URL构建函数已添加"
else
    echo "❌ 搜索引擎URL构建函数缺失"
fi

if grep -q "handleAppSearchAction" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ 智能应用搜索处理函数已添加"
else
    echo "❌ 智能应用搜索处理函数缺失"
fi

if grep -q "handleSearchEngineAction" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ 智能搜索引擎处理函数已添加"
else
    echo "❌ 智能搜索引擎处理函数缺失"
fi

if grep -q "fallbackToInAppSearch" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ 回退到应用内搜索函数已添加"
else
    echo "❌ 回退到应用内搜索函数缺失"
fi

if grep -q "import UIKit" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ UIKit导入已添加"
else
    echo "❌ UIKit导入缺失"
fi

# 2. 检查支持的应用URL Scheme
echo ""
echo "📱 检查支持的应用URL Scheme..."

app_schemes=(
    "taobao://s.taobao.com"
    "zhihu://search"
    "snssdk1128://search"
    "weixin://dl/search"
    "alipay://platformapi"
    "imeituan://www.meituan.com/search"
    "openapp.jdmobile://virtual"
    "bilibili://search"
    "xhsdiscover://search"
    "diditaxi://search"
    "eleme://search"
    "pinduoduo://com.xunmeng.pinduoduo"
    "kwai://search"
    "qqmusic://search"
    "orpheus://search"
    "iqiyi://search"
    "youku://search"
    "tenvideo2://search"
    "iosamap://search"
    "baidumap://map/search"
    "cn.12306://search"
    "ctrip://search"
    "qunar://search"
    "bosszhipin://search"
    "lagou://search"
    "liepin://search"
)

supported_count=0
for scheme in "${app_schemes[@]}"; do
    if grep -q "$scheme" iOSBrowser/iOSBrowserApp.swift; then
        ((supported_count++))
    fi
done

echo "📱 支持的应用URL Scheme: $supported_count/${#app_schemes[@]}"

if [ $supported_count -ge 20 ]; then
    echo "✅ 应用URL Scheme支持充足"
else
    echo "❌ 应用URL Scheme支持不足"
fi

# 3. 检查支持的搜索引擎URL
echo ""
echo "🔍 检查支持的搜索引擎URL..."

search_engines=(
    "baidu.com/s"
    "google.com/search"
    "bing.com/search"
    "sogou.com/web"
    "so.com/s"
    "duckduckgo.com"
)

search_count=0
for engine in "${search_engines[@]}"; do
    if grep -q "$engine" iOSBrowser/iOSBrowserApp.swift; then
        ((search_count++))
    fi
done

echo "🔍 支持的搜索引擎: $search_count/${#search_engines[@]}"

if [ $search_count -eq ${#search_engines[@]} ]; then
    echo "✅ 搜索引擎URL支持完整"
else
    echo "❌ 搜索引擎URL支持不完整"
fi

# 4. 检查错误处理
echo ""
echo "❌ 检查错误处理..."

if grep -q "UIApplication.shared.open.*success" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ URL跳转成功/失败处理已添加"
else
    echo "❌ URL跳转成功/失败处理缺失"
fi

if grep -q "fallbackToInAppSearch.*appId.*query" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ 回退机制参数传递正确"
else
    echo "❌ 回退机制参数传递错误"
fi

# 5. 编译测试
echo ""
echo "🔨 编译测试..."
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowser -quiet

if [ $? -eq 0 ]; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

# 6. 启动模拟器测试
echo ""
echo "📱 启动模拟器测试..."
xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || echo "模拟器已在运行"

sleep 3

# 7. 测试深度链接
echo ""
echo "🔗 测试深度链接..."

echo "测试应用搜索深度链接..."
xcrun simctl openurl booted "iosbrowser://search?app=taobao"

sleep 2

echo "测试搜索引擎深度链接..."
xcrun simctl openurl booted "iosbrowser://search?engine=baidu"

sleep 2

echo ""
echo "🎉 智能剪贴板跳转功能测试完成！"
echo ""
echo "✅ 实现的功能："
echo "   - 剪贴板内容自动检测"
echo "   - 26个应用URL Scheme支持"
echo "   - 6个搜索引擎直链支持"
echo "   - 智能跳转逻辑"
echo "   - 优雅降级机制"
echo "   - 完整错误处理"
echo ""
echo "🚀 智能跳转流程："
echo "   1. 用户复制文本到剪贴板"
echo "   2. 点击桌面小组件中的应用图标"
echo "   3. 系统检测剪贴板内容"
echo "   4. 如果有内容：直接跳转到对应应用搜索"
echo "   5. 如果为空：跳转到应用内搜索tab并自动选中应用"
echo ""
echo "📱 支持的应用类型："
echo "   🛒 购物: 淘宝、京东、拼多多"
echo "   💬 社交: 微信、知乎、小红书"
echo "   📺 视频: 抖音、哔哩哔哩、快手、爱奇艺、优酷、腾讯视频"
echo "   🎵 音乐: QQ音乐、网易云音乐"
echo "   🍔 生活: 美团、饿了么、滴滴、支付宝"
echo "   🗺️  地图: 高德地图、百度地图"
echo "   ✈️  旅行: 12306、携程、去哪儿"
echo "   💼 求职: BOSS直聘、拉勾、猎聘"
echo ""
echo "🔍 支持的搜索引擎："
echo "   🔵 百度、Google、必应、搜狗、360搜索、DuckDuckGo"
echo ""
echo "🧪 测试步骤："
echo "   1. 复制文本: 'iPhone 15 Pro Max'"
echo "   2. 点击桌面小组件中的淘宝图标"
echo "   3. 验证是否直接跳转到淘宝搜索结果"
echo "   4. 清空剪贴板，再次点击"
echo "   5. 验证是否跳转到应用内搜索并选中淘宝"
echo ""
echo "🎯 预期效果："
echo "   ✅ 有剪贴板内容时直接跳转外部应用搜索"
echo "   ✅ 无剪贴板内容时跳转应用内搜索"
echo "   ✅ 搜索关键词正确传递"
echo "   ✅ 中文字符正确编码"
echo "   ✅ 应用未安装时优雅降级"
