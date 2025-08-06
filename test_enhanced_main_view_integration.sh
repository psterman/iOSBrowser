#!/bin/bash

echo "🔍 验证EnhancedMainView集成..."
echo "=================================="

# 检查文件是否在项目中
if grep -q "EnhancedMainView.swift" iOSBrowser.xcodeproj/project.pbxproj; then
    echo "✅ EnhancedMainView.swift已在项目文件中"
else
    echo "❌ EnhancedMainView.swift未在项目文件中"
    echo "请按照上述步骤手动添加文件到Xcode项目"
    exit 1
fi

# 检查iOSBrowserApp.swift中的引用
if grep -q "EnhancedMainView()" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ iOSBrowserApp.swift正确引用EnhancedMainView"
else
    echo "❌ iOSBrowserApp.swift未引用EnhancedMainView"
    echo "请将ContentView()改回EnhancedMainView()"
    exit 1
fi

echo ""
echo "🎉 EnhancedMainView集成验证完成！"
echo "现在可以正常编译和运行项目了"
