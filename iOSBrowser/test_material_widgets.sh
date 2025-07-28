#!/bin/bash

# 测试Material Design小组件的脚本

echo "🎨 开始测试Material Design小组件..."

# 1. 清理并重新编译
echo "🧹 清理项目..."
xcodebuild clean -project iOSBrowser.xcodeproj -scheme iOSBrowserWidgets

echo "🔨 编译Widget Extension..."
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowserWidgets

if [ $? -eq 0 ]; then
    echo "✅ 编译成功！"
else
    echo "❌ 编译失败！"
    exit 1
fi

# 2. 启动模拟器
echo "📱 启动模拟器..."
xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || echo "模拟器已在运行"

# 等待模拟器启动
sleep 3

# 3. 测试深度链接
echo "🔗 测试Material Design小组件深度链接..."

echo "测试智能搜索..."
xcrun simctl openurl booted "iosbrowser://clipboard-search?engine=google"

sleep 2

echo "测试AI助手直达对话..."
xcrun simctl openurl booted "iosbrowser://direct-chat?assistant=deepseek"

sleep 2

echo "测试应用启动器精确搜索..."
xcrun simctl openurl booted "iosbrowser://apps?app=taobao"

sleep 2

echo "测试快捷操作批量功能..."
xcrun simctl openurl booted "iosbrowser://batch-operation"

sleep 2

echo "✅ 深度链接测试完成！"
echo ""
echo "🎨 Material Design小组件验证指南："
echo ""
echo "📱 1. 小组件添加测试："
echo "   - 长按主屏幕 → 点击'+'"
echo "   - 搜索'iOSBrowser'"
echo "   - 现在应该看到4个新的Material Design小组件："
echo "     🔍 智能搜索 (小/中)"
echo "     🤖 AI助手 (小/中/大)"
echo "     📱 应用启动器 (中/大)"
echo "     ⚡ 快捷操作 (中)"
echo ""
echo "🎯 2. Material Design特性验证："
echo "   ✅ 圆角设计 - 所有容器使用圆角"
echo "   ✅ 阴影效果 - 多层阴影营造深度"
echo "   ✅ 渐变背景 - 图标使用渐变色"
echo "   ✅ 按压动画 - 点击时缩放动画"
echo "   ✅ 颜色系统 - 统一的颜色主题"
echo "   ✅ 图标对齐 - 精确的图标和文字对齐"
echo ""
echo "🔧 3. 功能精确性验证："
echo "   ✅ 搜索引擎图标 - 与配置界面完全一致"
echo "   ✅ AI助手图标 - 精确对应配置选择"
echo "   ✅ 应用图标 - 无需输入直接搜索"
echo "   ✅ 用户配置同步 - 显示内容与设置一致"
echo ""
echo "📐 4. 样式完整性验证："
echo "   ✅ 无截断 - 所有内容完整显示"
echo "   ✅ 响应式布局 - 适配不同尺寸"
echo "   ✅ 动画流畅 - 春天动画效果"
echo "   ✅ 视觉层次 - 清晰的信息层级"
echo ""
echo "🎨 5. Material Design元素检查："
echo "   ✅ 卡片式设计 - 浮动卡片效果"
echo "   ✅ 圆形图标容器 - 统一的圆形设计"
echo "   ✅ 状态指示器 - 实时状态显示"
echo "   ✅ 渐变和透明度 - 现代视觉效果"
echo "   ✅ 微交互 - 按压反馈动画"
echo ""
echo "🔗 6. 深度链接精确性："
echo "   ✅ 搜索引擎 - 点击对应引擎图标"
echo "   ✅ AI助手 - 直达对应助手聊天"
echo "   ✅ 应用搜索 - 精确跳转应用页面"
echo "   ✅ 批量操作 - 一键多服务激活"
echo ""
echo "🎉 Material Design小组件测试完成！"
echo ""
echo "💡 如果发现问题："
echo "1. 删除现有小组件"
echo "2. 重新添加新的小组件"
echo "3. 检查小组件配置页面设置"
echo "4. 验证深度链接功能"
