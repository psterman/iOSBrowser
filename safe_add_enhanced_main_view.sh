#!/bin/bash

echo "🔧 安全添加EnhancedMainView.swift到Xcode项目..."
echo "=================================="

# 检查文件是否存在
if [ ! -f "iOSBrowser/EnhancedMainView.swift" ]; then
    echo "❌ EnhancedMainView.swift文件不存在"
    exit 1
fi

echo "✅ EnhancedMainView.swift文件存在"

# 生成唯一的UUID
ENHANCED_MAIN_VIEW_UUID=$(uuidgen | tr '[:lower:]' '[:upper:]' | sed 's/-//g')
echo "🔑 生成的UUID: $ENHANCED_MAIN_VIEW_UUID"

# 备份当前项目文件
cp iOSBrowser.xcodeproj/project.pbxproj iOSBrowser.xcodeproj/project.pbxproj.safe_backup
echo "✅ 已备份当前项目文件"

# 检查是否已经存在EnhancedMainView的引用
if grep -q "EnhancedMainView.swift" iOSBrowser.xcodeproj/project.pbxproj; then
    echo "⚠️ 检测到EnhancedMainView.swift已存在，正在清理..."
    # 移除所有EnhancedMainView相关的条目
    sed -i '' '/EnhancedMainView.swift/d' iOSBrowser.xcodeproj/project.pbxproj
    echo "✅ 已清理旧的EnhancedMainView引用"
fi

# 找到正确的插入位置
echo "🔍 查找插入位置..."

# 1. 添加PBXFileReference
PBXFILE_REF_LINE=$(grep -n "SettingsView.swift.*PBXFileReference" iOSBrowser.xcodeproj/project.pbxproj | head -1 | cut -d: -f1)
if [ -n "$PBXFILE_REF_LINE" ]; then
    echo "📝 在PBXFileReference第${PBXFILE_REF_LINE}行后添加文件引用"
    sed -i '' "${PBXFILE_REF_LINE}a\\
		$ENHANCED_MAIN_VIEW_UUID \/\* EnhancedMainView.swift \*\/ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = EnhancedMainView.swift; sourceTree = \"<group>\"; };
" iOSBrowser.xcodeproj/project.pbxproj
fi

# 2. 添加PBXBuildFile
PBXBUILD_LINE=$(grep -n "SettingsView.swift in Sources" iOSBrowser.xcodeproj/project.pbxproj | head -1 | cut -d: -f1)
if [ -n "$PBXBUILD_LINE" ]; then
    echo "📝 在PBXBuildFile第${PBXBUILD_LINE}行后添加构建引用"
    sed -i '' "${PBXBUILD_LINE}a\\
		$ENHANCED_MAIN_VIEW_UUID \/\* EnhancedMainView.swift in Sources \*\/ = {isa = PBXBuildFile; fileRef = $ENHANCED_MAIN_VIEW_UUID \/\* EnhancedMainView.swift \*\/; };
" iOSBrowser.xcodeproj/project.pbxproj
fi

# 3. 添加PBXGroup
PBXGROUP_LINE=$(grep -n "SettingsView.swift," iOSBrowser.xcodeproj/project.pbxproj | head -1 | cut -d: -f1)
if [ -n "$PBXGROUP_LINE" ]; then
    echo "📝 在PBXGroup第${PBXGROUP_LINE}行后添加文件分组"
    sed -i '' "${PBXGROUP_LINE}a\\
					$ENHANCED_MAIN_VIEW_UUID \/\* EnhancedMainView.swift \*\/,
" iOSBrowser.xcodeproj/project.pbxproj
fi

# 4. 添加Sources构建阶段
SOURCES_LINE=$(grep -n "SettingsView.swift in Sources," iOSBrowser.xcodeproj/project.pbxproj | head -1 | cut -d: -f1)
if [ -n "$SOURCES_LINE" ]; then
    echo "📝 在Sources构建阶段第${SOURCES_LINE}行后添加构建文件"
    sed -i '' "${SOURCES_LINE}a\\
					$ENHANCED_MAIN_VIEW_UUID \/\* EnhancedMainView.swift in Sources \*\/,
" iOSBrowser.xcodeproj/project.pbxproj
fi

echo "✅ 已安全添加EnhancedMainView.swift到项目文件"

# 验证添加是否成功
echo ""
echo "🔍 验证添加结果..."
if grep -q "EnhancedMainView.swift" iOSBrowser.xcodeproj/project.pbxproj; then
    echo "✅ EnhancedMainView.swift已成功添加到项目"
else
    echo "❌ 添加失败，请手动添加文件到Xcode项目"
    exit 1
fi

# 修改iOSBrowserApp.swift
echo "📝 修改iOSBrowserApp.swift..."
if grep -q "ContentView()" iOSBrowser/iOSBrowserApp.swift; then
    sed -i '' 's/ContentView()/EnhancedMainView()/g' iOSBrowser/iOSBrowserApp.swift
    echo "✅ 已修改iOSBrowserApp.swift使用EnhancedMainView"
else
    echo "⚠️ 未找到ContentView()，请手动修改"
fi

echo ""
echo "🎉 安全添加完成！"
echo "现在可以尝试在Xcode中打开项目"
echo ""
echo "如果仍有问题，请运行以下命令验证："
echo "./test_enhanced_main_view_integration.sh" 