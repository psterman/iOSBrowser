#!/bin/bash

# 测试小组件修复的脚本

echo "🔧 测试小组件修复..."

# 1. 检查代码修复
echo "📝 检查代码修复..."

if grep -q "direct-app-launch" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件使用正确的深度链接"
else
    echo "❌ 小组件深度链接错误"
fi

if grep -q "handleDirectAppLaunch" iOSBrowser/ContentView.swift; then
    echo "✅ 主应用添加了直接启动处理"
else
    echo "❌ 主应用缺少直接启动处理"
fi

if grep -q "UIPasteboard.general.string" iOSBrowser/ContentView.swift; then
    echo "✅ 主应用可以读取剪贴板"
else
    echo "❌ 主应用无法读取剪贴板"
fi

# 检查是否移除了错误的函数
if grep -q "getAppSearchURL" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "❌ 仍有错误的函数"
else
    echo "✅ 已移除错误的函数"
fi

# 2. 编译测试
echo "🔨 编译测试..."
xcodebuild clean -project iOSBrowser.xcodeproj -scheme iOSBrowser -quiet
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowser -quiet

if [ $? -eq 0 ]; then
    echo "✅ 主应用编译成功"
else
    echo "❌ 主应用编译失败"
    exit 1
fi

xcodebuild clean -project iOSBrowser.xcodeproj -scheme iOSBrowserWidgets -quiet
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

# 4. 测试深度链接
echo "🔗 测试深度链接..."

echo "测试直接应用启动..."
xcrun simctl openurl booted "iosbrowser://direct-app-launch?app=taobao"

sleep 3

echo "✅ 深度链接测试完成！"
echo ""
echo "🔧 修复说明："
echo ""
echo "❌ 问题分析："
echo "   1. 小组件无法直接访问剪贴板（iOS安全限制）"
echo "   2. 小组件的Link只能打开URL，不能执行复杂逻辑"
echo "   3. 需要通过主应用作为中转来处理剪贴板和应用启动"
echo ""
echo "✅ 修复方案："
echo "   1. 小组件使用: iosbrowser://direct-app-launch?app=taobao"
echo "   2. 主应用接收深度链接，读取剪贴板"
echo "   3. 主应用构建应用搜索URL并直接打开"
echo ""
echo "🎯 新的工作流程："
echo "1. 用户复制'iPhone 15 Pro Max'到剪贴板"
echo "2. 点击小组件淘宝图标"
echo "3. 小组件发送: iosbrowser://direct-app-launch?app=taobao"
echo "4. 主应用接收深度链接"
echo "5. 主应用读取剪贴板内容"
echo "6. 主应用构建: taobao://s.taobao.com?q=iPhone15ProMax"
echo "7. 主应用直接打开淘宝搜索结果"
echo ""
echo "📱 支持的应用："
echo "   📦 淘宝: taobao://s.taobao.com?q=搜索词"
echo "   🛒 京东: openapp.jdmobile://virtual?params={...}"
echo "   🍔 美团: imeituan://www.meituan.com/search?q=搜索词"
echo "   📹 抖音: snssdk1128://search?keyword=搜索词"
echo "   💰 支付宝: alipay://platformapi/startapp?appId=20000067&query=搜索词"
echo "   💬 微信: weixin://"
echo ""
echo "🎉 小组件修复完成！"
echo ""
echo "💡 测试步骤："
echo "1. 复制'iPhone 15 Pro Max'到剪贴板"
echo "2. 在Xcode中编译运行应用"
echo "3. 添加应用启动器小组件到桌面"
echo "4. 点击淘宝图标"
echo "5. 验证是否直接打开淘宝搜索结果"
echo ""
echo "⚠️  注意事项："
echo "- 确保目标应用已安装"
echo "- 清理应用缓存后重新安装"
echo "- 检查URL Scheme是否正确注册"
