#!/bin/bash

# 测试新功能的脚本

echo "🧪 开始测试iOSBrowser新功能..."

# 1. 清理并重新编译
echo "🧹 清理项目..."
xcodebuild clean -project iOSBrowser.xcodeproj -scheme iOSBrowser

echo "🔨 编译主应用..."
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowser

echo "🔨 编译Widget Extension..."
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowserWidgets

# 2. 启动模拟器
echo "📱 启动模拟器..."
xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || echo "模拟器已在运行"

# 等待模拟器启动
sleep 3

# 3. 测试深度链接
echo "🔗 测试新的深度链接..."

echo "测试应用搜索（无需输入）..."
xcrun simctl openurl booted "iosbrowser://apps?app=taobao"

sleep 2

echo "测试AI直达对话..."
xcrun simctl openurl booted "iosbrowser://direct-chat?assistant=deepseek"

sleep 2

echo "测试批量操作..."
xcrun simctl openurl booted "iosbrowser://batch-operation"

sleep 2

echo "测试剪贴板搜索..."
xcrun simctl openurl booted "iosbrowser://clipboard-search?engine=google"

sleep 2

echo "✅ 深度链接测试完成！"
echo ""
echo "📋 手动测试步骤："
echo ""
echo "🎯 1. 小组件配置功能："
echo "   - 打开应用"
echo "   - 点击第4个标签页（小组件图标）"
echo "   - 验证配置界面显示正常"
echo "   - 尝试选择不同的搜索引擎/应用/AI助手"
echo ""
echo "🎯 2. 应用搜索精准控制："
echo "   - 在小组件中点击淘宝图标"
echo "   - 验证直接跳转到搜索页面"
echo "   - 验证无需手动输入内容"
echo ""
echo "🎯 3. AI直达对话："
echo "   - 在小组件中点击DeepSeek"
echo "   - 验证直接跳转到聊天页面"
echo "   - 验证绕过联系人列表"
echo ""
echo "🎯 4. 批量操作功能："
echo "   - 复制一些文本到剪贴板"
echo "   - 点击批量操作小组件"
echo "   - 选择多个搜索引擎和AI助手"
echo "   - 验证一键激活多个服务"
echo ""
echo "🎯 5. 小组件显示验证："
echo "   - 长按主屏幕 → 点击'+'"
echo "   - 搜索'iOSBrowser'"
echo "   - 添加各种小组件"
echo "   - 验证显示内容与配置一致"
echo ""
echo "✅ 验证要点："
echo "   ✓ 小组件配置页面正常显示"
echo "   ✓ 应用搜索无需输入限制"
echo "   ✓ AI对话直接跳转功能"
echo "   ✓ 批量操作界面和功能"
echo "   ✓ 用户配置同步到小组件"
echo "   ✓ 深度链接参数正确传递"
echo ""
echo "🎉 新功能测试指南完成！"
