#!/bin/bash

echo "🔧 添加EnhancedMainView.swift到Xcode项目..."
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

# 备份原始项目文件
cp iOSBrowser.xcodeproj/project.pbxproj iOSBrowser.xcodeproj/project.pbxproj.backup
echo "✅ 已备份原始项目文件"

echo ""
echo "📋 请按照以下步骤手动添加文件到Xcode项目："
echo ""
echo "1. 打开Xcode项目"
echo "2. 在项目导航器中右键点击iOSBrowser文件夹"
echo "3. 选择'Add Files to iOSBrowser'"
echo "4. 选择iOSBrowser/EnhancedMainView.swift文件"
echo "5. 确保'Add to target'中选中了iOSBrowser"
echo "6. 点击'Add'"
echo ""
echo "或者，您可以使用以下命令在Xcode中打开项目："
echo "open iOSBrowser.xcodeproj"
echo ""
echo "添加完成后，请将iOSBrowserApp.swift中的ContentView改回EnhancedMainView"
echo ""
echo "🎯 手动添加完成后，运行以下命令验证："
echo "./test_enhanced_main_view_integration.sh"

# 创建验证脚本
cat > test_enhanced_main_view_integration.sh << 'EOF'
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
EOF

chmod +x test_enhanced_main_view_integration.sh
echo "✅ 已创建验证脚本: test_enhanced_main_view_integration.sh" 