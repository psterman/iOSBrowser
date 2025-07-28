#!/bin/bash

# 测试文件引用修复的脚本

echo "🔧 测试文件引用修复..."

# 1. 检查文件存在性
echo "📁 检查文件状态..."

if [ -f "iOSBrowserWidgets/iOSBrowserWidgets.swift" ]; then
    echo "✅ 新文件存在: iOSBrowserWidgets.swift"
else
    echo "❌ 新文件不存在"
    exit 1
fi

if [ -f "iOSBrowserWidgets/iOSBrowserWidgets .swift" ]; then
    echo "⚠️  旧文件仍存在: iOSBrowserWidgets .swift (带空格)"
    echo "正在删除旧文件..."
    rm -f "iOSBrowserWidgets/iOSBrowserWidgets .swift"
    echo "✅ 旧文件已删除"
else
    echo "✅ 旧文件不存在"
fi

# 2. 检查项目文件引用
echo "🔍 检查项目文件引用..."

if grep -q "iOSBrowserWidgets .swift" iOSBrowser.xcodeproj/project.pbxproj; then
    echo "❌ 项目文件仍引用旧文件名（带空格）"
    exit 1
else
    echo "✅ 项目文件引用正确"
fi

if grep -q "iOSBrowserWidgets.swift" iOSBrowser.xcodeproj/project.pbxproj; then
    echo "✅ 项目文件引用新文件名"
else
    echo "❌ 项目文件未引用新文件名"
    exit 1
fi

# 3. 检查代码结构
echo "📝 检查代码结构..."

if grep -q "SmartSearchWidget" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ SmartSearchWidget 已定义"
else
    echo "❌ SmartSearchWidget 未找到"
    exit 1
fi

if grep -q "getSampleSearchEngines" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 示例数据函数已定义"
else
    echo "❌ 示例数据函数未找到"
    exit 1
fi

# 4. 快速编译测试
echo "🔨 快速编译测试..."

# 清理构建缓存
xcodebuild clean -project iOSBrowser.xcodeproj -scheme iOSBrowserWidgets -quiet

# 编译测试
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowserWidgets -quiet

if [ $? -eq 0 ]; then
    echo "✅ 编译成功！"
else
    echo "❌ 编译失败！"
    echo "尝试查看详细错误信息..."
    xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowserWidgets
    exit 1
fi

echo ""
echo "🎉 文件引用修复完成！"
echo ""
echo "✅ 修复总结："
echo "   ✅ 删除了带空格的旧文件名"
echo "   ✅ 更新了项目文件引用"
echo "   ✅ 使用正确的文件名: iOSBrowserWidgets.swift"
echo "   ✅ 编译成功，无错误"
echo ""
echo "📱 下一步："
echo "1. 在Xcode中打开项目"
echo "2. 编译并运行应用"
echo "3. 添加小组件到桌面"
echo "4. 验证功能正常"
