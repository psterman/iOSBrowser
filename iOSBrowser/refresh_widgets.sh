#!/bin/bash

# 强制刷新iOS小组件的脚本

echo "🔄 开始刷新iOSBrowser小组件..."

# 1. 清理构建缓存
echo "🧹 清理构建缓存..."
rm -rf ~/Library/Developer/Xcode/DerivedData/iOSBrowser-*
rm -rf build/

# 2. 清理模拟器中的小组件缓存
echo "📱 清理模拟器小组件缓存..."
xcrun simctl shutdown all
xcrun simctl erase all

# 3. 重新启动模拟器
echo "🚀 启动模拟器..."
xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || xcrun simctl boot "iPhone 14 Pro" 2>/dev/null || echo "请手动启动模拟器"

# 4. 编译项目
echo "🔨 重新编译项目..."
xcodebuild clean -project iOSBrowser.xcodeproj -scheme iOSBrowserWidgets
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowserWidgets

echo "✅ 小组件刷新完成！"
echo ""
echo "📋 接下来的步骤："
echo "1. 在Xcode中选择 iOSBrowserWidgets scheme"
echo "2. 运行到模拟器 (Cmd+R)"
echo "3. 在模拟器中长按主屏幕"
echo "4. 点击左上角的 '+' 按钮"
echo "5. 搜索 'iOSBrowser'"
echo "6. 添加新的小组件"
echo ""
echo "🎯 现在应该能看到四个新的小组件："
echo "   - 剪贴板搜索"
echo "   - 精确App搜索"
echo "   - AI直达对话"
echo "   - 快捷操作"
