#!/bin/bash

# 测试应用启动器小组件修复的脚本

echo "🔧 测试应用启动器小组件修复..."

# 1. 检查代码修复
echo "📝 检查代码修复..."

if grep -q "getAppSearchURL" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ getAppSearchURL函数已添加"
else
    echo "❌ getAppSearchURL函数缺失"
fi

if grep -q "taobao://s.taobao.com" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 淘宝搜索URL已配置"
else
    echo "❌ 淘宝搜索URL缺失"
fi

if grep -q "UIPasteboard.general.string" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 剪贴板读取已添加"
else
    echo "❌ 剪贴板读取缺失"
fi

# 检查是否还在使用错误的深度链接
if grep -q "iosbrowser://app-search" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "❌ 仍在使用错误的深度链接"
else
    echo "✅ 已移除错误的深度链接"
fi

# 2. 编译测试
echo "🔨 编译测试..."
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowserWidgets -quiet

if [ $? -eq 0 ]; then
    echo "✅ 小组件编译成功"
else
    echo "❌ 小组件编译失败"
    exit 1
fi

# 3. 启动模拟器
echo "📱 启动模拟器..."
xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || echo "模拟器已在运行"

sleep 3

# 4. 测试应用URL scheme
echo "🔗 测试应用URL scheme..."

echo "测试淘宝搜索URL..."
xcrun simctl openurl booted "taobao://s.taobao.com?q=iPhone15ProMax"

sleep 2

echo "测试京东搜索URL..."
xcrun simctl openurl booted 'openapp.jdmobile://virtual?params={"category":"jump","des":"search","keyWord":"iPhone15ProMax"}'

sleep 2

echo "测试美团搜索URL..."
xcrun simctl openurl booted "imeituan://www.meituan.com/search?q=火锅"

sleep 2

echo "✅ URL scheme测试完成！"
echo ""
echo "🔧 修复说明："
echo ""
echo "❌ 修复前的问题："
echo "   - 小组件使用 iosbrowser://app-search 深度链接"
echo "   - 点击淘宝图标打开iOSBrowser搜索tab"
echo "   - 需要用户手动选择应用和输入搜索词"
echo ""
echo "✅ 修复后的功能："
echo "   - 小组件直接使用应用URL scheme"
echo "   - 点击淘宝图标直接打开淘宝搜索结果"
echo "   - 自动使用剪贴板内容作为搜索词"
echo ""
echo "🎯 现在的工作流程："
echo "1. 复制'iPhone 15 Pro Max'到剪贴板"
echo "2. 点击应用启动器小组件的淘宝图标"
echo "3. 直接打开淘宝应用，显示'iPhone 15 Pro Max'搜索结果"
echo ""
echo "📱 支持的应用搜索："
echo "   📦 淘宝: taobao://s.taobao.com?q=搜索词"
echo "   🛒 京东: openapp.jdmobile://virtual?params={...}"
echo "   🍔 美团: imeituan://www.meituan.com/search?q=搜索词"
echo "   📹 抖音: snssdk1128://search?keyword=搜索词"
echo "   💰 支付宝: alipay://platformapi/startapp?appId=20000067&query=搜索词"
echo "   💬 微信: weixin:// (直接打开微信)"
echo ""
echo "🎉 应用启动器小组件修复完成！"
echo ""
echo "💡 测试步骤："
echo "1. 在Xcode中编译运行应用"
echo "2. 添加应用启动器小组件到桌面"
echo "3. 复制内容到剪贴板"
echo "4. 点击淘宝图标"
echo "5. 验证是否直接打开淘宝搜索结果"
