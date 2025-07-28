#!/bin/bash

# 测试应用搜索功能的脚本

echo "📱 测试应用搜索功能..."

# 1. 检查代码更新
echo "📝 检查代码更新..."

if grep -q "directAppSearch" iOSBrowser/ContentView.swift; then
    echo "✅ 直接应用搜索通知已添加"
else
    echo "❌ 直接应用搜索通知缺失"
fi

if grep -q "handleDirectAppSearch" iOSBrowser/SearchView.swift; then
    echo "✅ 直接应用搜索处理函数已添加"
else
    echo "❌ 直接应用搜索处理函数缺失"
fi

if grep -q "taobao://s.taobao.com" iOSBrowser/SearchView.swift; then
    echo "✅ 淘宝搜索URL已配置"
else
    echo "❌ 淘宝搜索URL缺失"
fi

# 2. 编译测试
echo "🔨 编译测试..."
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowser -quiet

if [ $? -eq 0 ]; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

# 3. 启动模拟器
echo "📱 启动模拟器..."
xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || echo "模拟器已在运行"

sleep 3

# 4. 测试应用搜索深度链接
echo "🔗 测试应用搜索深度链接..."

echo "测试淘宝搜索..."
xcrun simctl openurl booted "iosbrowser://app-search?app=taobao&auto=true"

sleep 3

echo "测试京东搜索..."
xcrun simctl openurl booted "iosbrowser://app-search?app=jd&auto=true"

sleep 3

echo "测试美团搜索..."
xcrun simctl openurl booted "iosbrowser://app-search?app=meituan&auto=true"

sleep 3

echo "✅ 应用搜索测试完成！"
echo ""
echo "📱 应用搜索功能说明："
echo ""
echo "🎯 功能流程："
echo "1. 用户复制内容到剪贴板（如：iPhone 15 Pro Max）"
echo "2. 点击应用启动器小组件的淘宝图标"
echo "3. 直接打开淘宝应用的搜索结果页面"
echo "4. 显示'iPhone 15 Pro Max'的搜索结果"
echo ""
echo "🔗 支持的应用搜索URL："
echo "   📦 淘宝: taobao://s.taobao.com?q=搜索词"
echo "   🛒 京东: openapp.jdmobile://virtual?params={...}"
echo "   🍔 美团: imeituan://www.meituan.com/search?q=搜索词"
echo "   📹 抖音: snssdk1128://search?keyword=搜索词"
echo "   💰 支付宝: alipay://platformapi/startapp?appId=20000067&query=搜索词"
echo "   💬 微信: weixin:// (直接打开微信)"
echo ""
echo "✨ 用户体验："
echo "   ❌ 原来: 复制 → 打开应用 → 找搜索 → 粘贴 → 搜索"
echo "   ✅ 现在: 复制 → 点击小组件 → 直接看结果"
echo ""
echo "🎯 测试步骤："
echo "1. 复制'iPhone 15 Pro Max'到剪贴板"
echo "2. 添加应用启动器小组件到桌面"
echo "3. 点击淘宝图标"
echo "4. 验证是否直接打开淘宝搜索结果页面"
echo ""
echo "🎉 应用搜索功能测试完成！"
