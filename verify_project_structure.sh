#!/bin/bash

echo "🔍 验证项目结构..."

# 检查项目文件是否存在
if [ ! -f "iOSBrowser.xcodeproj/project.pbxproj" ]; then
    echo "❌ 项目文件不存在"
    exit 1
fi

# 检查 Managers 目录
if [ ! -d "iOSBrowser/Managers" ]; then
    echo "❌ Managers 目录不存在"
    exit 1
fi

# 检查 WidgetDataManager.swift
if [ ! -f "iOSBrowser/Managers/WidgetDataManager.swift" ]; then
    echo "❌ WidgetDataManager.swift 不在正确位置"
    exit 1
fi

# 检查项目文件格式
if ! plutil -lint iOSBrowser.xcodeproj/project.pbxproj > /dev/null; then
    echo "❌ 项目文件格式无效"
    exit 1
fi

# 检查项目文件中的引用
if ! grep -q "path = Managers;" iOSBrowser.xcodeproj/project.pbxproj; then
    echo "❌ 项目文件中缺少 Managers 组引用"
    exit 1
fi

if ! grep -q "WidgetDataManager.swift in Sources" iOSBrowser.xcodeproj/project.pbxproj; then
    echo "❌ 项目文件中缺少 WidgetDataManager.swift 源文件引用"
    exit 1
fi

# 检查文件内容
if ! grep -q "public class WidgetDataManager" iOSBrowser/Managers/WidgetDataManager.swift; then
    echo "❌ WidgetDataManager.swift 内容不完整"
    exit 1
fi

echo "✅ 项目结构验证通过！"
echo "✅ 所有必需的文件和引用都存在且格式正确" 