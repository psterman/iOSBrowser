#!/bin/bash

echo "🔧 添加AI相关文件到Xcode项目"
echo "=================================="

# 检查文件是否存在
echo "📱 检查AI相关文件..."

if [ ! -f "iOSBrowser/AIChatManager.swift" ]; then
    echo "❌ 错误：AIChatManager.swift文件不存在"
    exit 1
else
    echo "✅ AIChatManager.swift文件存在"
fi

if [ ! -f "iOSBrowser/AIChatView.swift" ]; then
    echo "❌ 错误：AIChatView.swift文件不存在"
    exit 1
else
    echo "✅ AIChatView.swift文件存在"
fi

# 检查项目文件
if [ ! -f "iOSBrowser.xcodeproj/project.pbxproj" ]; then
    echo "❌ 错误：项目文件不存在"
    exit 1
else
    echo "✅ 项目文件存在"
fi

echo ""
echo "🔧 开始添加文件到项目..."

# 创建临时项目文件
cp iOSBrowser.xcodeproj/project.pbxproj iOSBrowser.xcodeproj/project.pbxproj.backup

echo "✅ 已备份项目文件"

# 生成新的UUID
AICHATMANAGER_UUID=$(uuidgen | tr '[:lower:]' '[:upper:]')
AICHATVIEW_UUID=$(uuidgen | tr '[:lower:]' '[:upper:]')

echo "📋 生成的UUID："
echo "   AIChatManager: $AICHATMANAGER_UUID"
echo "   AIChatView: $AICHATVIEW_UUID"

# 添加文件引用到项目文件
echo ""
echo "🔧 添加文件引用..."

# 在PBXBuildFile section中添加
sed -i '' "/34503E662E2343E4006CF9FF \/\\* Persistence.swift in Sources \*\/ = {isa = PBXBuildFile; fileRef = 34503E652E2343E4006CF9FF \/\\* Persistence.swift \*\/; };/a\\
		$AICHATMANAGER_UUID /* AIChatManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = $AICHATMANAGER_UUID /* AIChatManager.swift */; };
		$AICHATVIEW_UUID /* AIChatView.swift in Sources */ = {isa = PBXBuildFile; fileRef = $AICHATVIEW_UUID /* AIChatView.swift */; };
" iOSBrowser.xcodeproj/project.pbxproj

# 在PBXFileReference section中添加
sed -i '' "/34503E652E2343E4006CF9FF \/\\* Persistence.swift \*\/ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Persistence.swift; sourceTree = \"<group>\"; };/a\\
		$AICHATMANAGER_UUID /* AIChatManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AIChatManager.swift; sourceTree = \"<group>\"; };
		$AICHATVIEW_UUID /* AIChatView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AIChatView.swift; sourceTree = \"<group>\"; };
" iOSBrowser.xcodeproj/project.pbxproj

# 在PBXGroup section中添加文件到iOSBrowser组
sed -i '' "/34503E652E2343E4006CF9FF \/\\* Persistence.swift \*\/,/a\\
				$AICHATMANAGER_UUID /* AIChatManager.swift */,
				$AICHATVIEW_UUID /* AIChatView.swift */,
" iOSBrowser.xcodeproj/project.pbxproj

# 在PBXSourcesBuildPhase section中添加编译文件
sed -i '' "/34503E662E2343E4006CF9FF \/\\* Persistence.swift in Sources \*\/,/a\\
				$AICHATMANAGER_UUID /* AIChatManager.swift in Sources */,
				$AICHATVIEW_UUID /* AIChatView.swift in Sources */,
" iOSBrowser.xcodeproj/project.pbxproj

echo "✅ 文件引用已添加到项目"

# 验证修改
echo ""
echo "🔍 验证修改..."

if grep -q "AIChatManager.swift" iOSBrowser.xcodeproj/project.pbxproj; then
    echo "✅ AIChatManager.swift已添加到项目"
else
    echo "❌ 错误：AIChatManager.swift未添加到项目"
    exit 1
fi

if grep -q "AIChatView.swift" iOSBrowser.xcodeproj/project.pbxproj; then
    echo "✅ AIChatView.swift已添加到项目"
else
    echo "❌ 错误：AIChatView.swift未添加到项目"
    exit 1
fi

echo ""
echo "🎉 AI相关文件已成功添加到Xcode项目"
echo ""
echo "📋 添加的文件："
echo "   ✅ AIChatManager.swift"
echo "   ✅ AIChatView.swift"
echo ""
echo "🔍 现在可以尝试编译项目了" 