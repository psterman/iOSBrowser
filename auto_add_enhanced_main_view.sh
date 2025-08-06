#!/bin/bash

echo "🔧 自动添加EnhancedMainView.swift到Xcode项目..."
echo "=================================="

# 生成唯一的UUID
ENHANCED_MAIN_VIEW_UUID=$(uuidgen | tr '[:lower:]' '[:upper:]' | sed 's/-//g')
echo "🔑 生成的UUID: $ENHANCED_MAIN_VIEW_UUID"

# 备份原始项目文件
cp iOSBrowser.xcodeproj/project.pbxproj iOSBrowser.xcodeproj/project.pbxproj.backup
echo "✅ 已备份原始项目文件"

# 添加文件引用到PBXFileReference
sed -i '' "/34503EA42E2400A4006CF9FF \/\* SettingsView.swift \*\/ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SettingsView.swift; sourceTree = \"<group>\"; };/a\\
		$ENHANCED_MAIN_VIEW_UUID \/\* EnhancedMainView.swift \*\/ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = EnhancedMainView.swift; sourceTree = \"<group>\"; };
" iOSBrowser.xcodeproj/project.pbxproj

# 添加文件到PBXBuildFile
sed -i '' "/34503EA82E2400B4006CF9FF \/\* SettingsView.swift in Sources \*\/ = {isa = PBXBuildFile; fileRef = 34503EA42E2400A4006CF9FF \/\* SettingsView.swift \*\/; };/a\\
		$ENHANCED_MAIN_VIEW_UUID \/\* EnhancedMainView.swift in Sources \*\/ = {isa = PBXBuildFile; fileRef = $ENHANCED_MAIN_VIEW_UUID \/\* EnhancedMainView.swift \*\/; };
" iOSBrowser.xcodeproj/project.pbxproj

# 添加文件到PBXGroup
sed -i '' "/34503EA42E2400A4006CF9FF \/\* SettingsView.swift \*\/,/a\\
					$ENHANCED_MAIN_VIEW_UUID \/\* EnhancedMainView.swift \*\/,
" iOSBrowser.xcodeproj/project.pbxproj

# 添加构建文件到Sources构建阶段
sed -i '' "/34503EA82E2400B4006CF9FF \/\* SettingsView.swift in Sources \*\/,/a\\
					$ENHANCED_MAIN_VIEW_UUID \/\* EnhancedMainView.swift in Sources \*\/,
" iOSBrowser.xcodeproj/project.pbxproj

echo "✅ 已自动添加EnhancedMainView.swift到项目文件"

# 现在修改iOSBrowserApp.swift
sed -i '' 's/ContentView()/EnhancedMainView()/g' iOSBrowser/iOSBrowserApp.swift
echo "✅ 已修改iOSBrowserApp.swift使用EnhancedMainView"

echo ""
echo "🎉 自动添加完成！"
echo "现在可以尝试编译项目了"
echo ""
echo "如果仍有问题，请运行以下命令验证："
echo "./test_enhanced_main_view_integration.sh" 