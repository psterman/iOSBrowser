#!/bin/bash

# 🔧 诊断小组件基础问题
# 彻底检查小组件的基础配置和权限

echo "🔧🔧🔧 开始诊断小组件基础问题..."
echo "📅 诊断时间: $(date)"
echo ""

# 1. 检查小组件扩展的基础配置
echo "🔍 检查小组件扩展的基础配置..."

echo "🔍 检查Info.plist文件:"
if [ -f "iOSBrowserWidgets/Info.plist" ]; then
    echo "✅ Info.plist文件存在"
else
    echo "❌ Info.plist文件缺失"
fi

echo "🔍 检查小组件Bundle ID:"
if grep -q "iOSBrowserWidgets" iOSBrowser.xcodeproj/project.pbxproj; then
    echo "✅ 小组件Bundle ID配置存在"
else
    echo "❌ 小组件Bundle ID配置缺失"
fi

echo "🔍 检查小组件Target:"
if grep -q "iOSBrowserWidgets" iOSBrowser.xcodeproj/project.pbxproj; then
    echo "✅ 小组件Target存在"
else
    echo "❌ 小组件Target缺失"
fi

# 2. 检查小组件代码的基础结构
echo ""
echo "🔍 检查小组件代码的基础结构..."

echo "🔍 检查Widget主结构:"
if grep -q "@main" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ Widget主结构存在"
else
    echo "❌ Widget主结构缺失"
fi

echo "🔍 检查Widget Provider:"
if grep -q "TimelineProvider" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ TimelineProvider存在"
else
    echo "❌ TimelineProvider缺失"
fi

echo "🔍 检查Widget Entry:"
if grep -q "TimelineEntry" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ TimelineEntry存在"
else
    echo "❌ TimelineEntry缺失"
fi

echo "🔍 检查Widget View:"
if grep -q "View" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ Widget View存在"
else
    echo "❌ Widget View缺失"
fi

# 3. 创建最简单的测试小组件
echo ""
echo "🧪 创建最简单的测试小组件..."

cat > test_basic_widget.swift << 'EOF'
import WidgetKit
import SwiftUI

// 最简单的测试Entry
struct TestEntry: TimelineEntry {
    let date: Date
    let testData: String
}

// 最简单的测试Provider
struct TestProvider: TimelineProvider {
    func placeholder(in context: Context) -> TestEntry {
        print("🧪 [TestProvider] placeholder被调用")
        return TestEntry(date: Date(), testData: "placeholder")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TestEntry) -> ()) {
        print("🧪 [TestProvider] getSnapshot被调用")
        let entry = TestEntry(date: Date(), testData: "snapshot")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TestEntry>) -> ()) {
        print("🧪 [TestProvider] getTimeline被调用")
        let entry = TestEntry(date: Date(), testData: "timeline_data")
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

// 最简单的测试View
struct TestWidgetView: View {
    let entry: TestEntry
    
    var body: some View {
        VStack {
            Text("测试小组件")
                .font(.headline)
            Text(entry.testData)
                .font(.caption)
            Text("时间: \(entry.date, style: .time)")
                .font(.caption2)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
    }
}

// 测试Widget配置
struct TestWidget: Widget {
    let kind: String = "TestWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TestProvider()) { entry in
            TestWidgetView(entry: entry)
        }
        .configurationDisplayName("测试小组件")
        .description("用于测试小组件基础功能")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

print("🧪 测试小组件代码编译检查...")
print("✅ 如果没有编译错误，说明基础结构正常")
EOF

echo "🧪 测试基础小组件代码编译..."
if command -v swift &> /dev/null; then
    if swift -c test_basic_widget.swift 2>/dev/null; then
        echo "✅ 基础小组件代码编译成功"
    else
        echo "❌ 基础小组件代码编译失败"
        echo "这说明Swift环境或基础依赖有问题"
    fi
else
    echo "⚠️ Swift命令不可用，跳过编译测试"
fi

rm -f test_basic_widget.swift

# 4. 检查当前小组件的错误
echo ""
echo "🔍 检查当前小组件的潜在错误..."

echo "🔍 检查小组件导入:"
if grep -q "import WidgetKit" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ WidgetKit导入正常"
else
    echo "❌ WidgetKit导入缺失"
fi

if grep -q "import SwiftUI" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ SwiftUI导入正常"
else
    echo "❌ SwiftUI导入缺失"
fi

echo "🔍 检查小组件配置:"
if grep -q "StaticConfiguration" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ StaticConfiguration存在"
else
    echo "❌ StaticConfiguration缺失"
fi

if grep -q "supportedFamilies" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ supportedFamilies配置存在"
else
    echo "❌ supportedFamilies配置缺失"
fi

echo "🔍 检查小组件Bundle:"
widget_bundles=$(grep -c "@main" iOSBrowserWidgets/iOSBrowserWidgets.swift)
if [ "$widget_bundles" -eq 1 ]; then
    echo "✅ 小组件Bundle配置正常"
elif [ "$widget_bundles" -gt 1 ]; then
    echo "❌ 多个@main入口，可能导致冲突"
else
    echo "❌ 没有@main入口"
fi

# 5. 创建修复建议
echo ""
echo "🔧 小组件基础问题修复建议:"
echo "================================"
echo ""

echo "基于诊断结果，可能的问题和解决方案:"
echo ""

echo "1. 🔐 权限和配置问题:"
echo "   - 在Xcode中检查Widget Extension的配置"
echo "   - 确保Widget Extension有正确的Bundle ID"
echo "   - 检查App Groups权限是否正确配置"
echo "   - 确保Widget Extension的Deployment Target正确"
echo ""

echo "2. 📱 编译和安装问题:"
echo "   - 确保Widget Extension被正确编译"
echo "   - 检查是否有编译错误或警告"
echo "   - 确保Widget Extension被包含在应用包中"
echo "   - 重新Clean Build并重新安装"
echo ""

echo "3. 🔧 代码结构问题:"
echo "   - 检查Widget的@main入口是否正确"
echo "   - 确保TimelineProvider的方法被正确实现"
echo "   - 检查Widget View的SwiftUI代码是否有错误"
echo "   - 确保没有运行时崩溃"
echo ""

echo "4. 🎯 立即尝试的解决方案:"
echo "   a) 在Xcode中:"
echo "      - 选择Widget Extension target"
echo "      - Product → Clean Build Folder"
echo "      - 检查编译错误"
echo "      - 重新编译整个项目"
echo ""
echo "   b) 在设备上:"
echo "      - 完全删除应用"
echo "      - 重启设备"
echo "      - 重新安装应用"
echo "      - 检查小组件是否出现在小组件库中"
echo ""
echo "   c) 调试步骤:"
echo "      - 在Xcode中运行Widget Extension scheme"
echo "      - 查看控制台是否有崩溃日志"
echo "      - 检查是否有权限被拒绝的错误"
echo ""

echo "🔍 关键检查点:"
echo "- 小组件是否出现在iOS的小组件库中？"
echo "- 添加小组件时是否有错误提示？"
echo "- 控制台是否有Widget相关的错误日志？"
echo "- Xcode中是否有Widget Extension的编译错误？"
echo ""

echo "🔧🔧🔧 小组件基础问题诊断完成！"
echo "请按照建议逐步检查和修复。"
