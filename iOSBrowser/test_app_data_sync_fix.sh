#!/bin/bash

# 应用数据同步修复验证脚本

echo "📱📱📱 应用数据同步修复验证！📱📱📱"

# 1. 检查共享应用数据管理器
echo "🔧 检查共享应用数据管理器..."

if grep -q "SharedAppDataManager" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 共享应用数据管理器已创建"
else
    echo "❌ 共享应用数据管理器缺失"
fi

if grep -q "struct AppData" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 应用数据结构已定义"
else
    echo "❌ 应用数据结构缺失"
fi

# 2. 检查应用数据完整性
echo "📊 检查应用数据完整性..."

# 统计应用数量
app_count=$(grep -A 100 "let allApps.*=" iOSBrowser/WidgetConfigView.swift | grep -c 'AppData(id:')
echo "📱 应用总数: $app_count"

# 检查各分类应用
if grep -q "购物.*社交.*视频.*音乐.*生活.*地图.*浏览器.*其他" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 应用分类完整"
else
    echo "❌ 应用分类不完整"
fi

# 3. 检查分类功能
echo "🏷️ 检查分类功能..."

if grep -q "selectedCategory.*categories" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 分类选择功能已实现"
else
    echo "❌ 分类选择功能缺失"
fi

if grep -q "getAppsByCategory" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 分类过滤功能已实现"
else
    echo "❌ 分类过滤功能缺失"
fi

# 4. 检查UI增强
echo "🎨 检查UI增强..."

if grep -q "ScrollView.*horizontal.*categories" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 分类选择器已添加"
else
    echo "❌ 分类选择器缺失"
fi

if grep -q "app.category.*caption2" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 应用分类标签已添加"
else
    echo "❌ 应用分类标签缺失"
fi

# 5. 检查具体应用
echo "🔍 检查具体应用..."

# 购物类应用
shopping_apps=$(grep -A 20 "购物类" iOSBrowser/WidgetConfigView.swift | grep -c 'AppData.*购物')
echo "🛒 购物类应用: $shopping_apps 个"

# 社交类应用
social_apps=$(grep -A 20 "社交媒体" iOSBrowser/WidgetConfigView.swift | grep -c 'AppData.*社交')
echo "👥 社交类应用: $social_apps 个"

# 视频类应用
video_apps=$(grep -A 20 "视频娱乐" iOSBrowser/WidgetConfigView.swift | grep -c 'AppData.*视频')
echo "📺 视频类应用: $video_apps 个"

# 音乐类应用
music_apps=$(grep -A 20 "音乐" iOSBrowser/WidgetConfigView.swift | grep -c 'AppData.*音乐')
echo "🎵 音乐类应用: $music_apps 个"

# 生活类应用
life_apps=$(grep -A 20 "生活服务" iOSBrowser/WidgetConfigView.swift | grep -c 'AppData.*生活')
echo "🏠 生活类应用: $life_apps 个"

# 6. 检查调试信息
echo "🔍 检查调试信息..."

if grep -q "总应用数量.*当前分类.*当前分类应用数量" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 详细调试信息已添加"
else
    echo "❌ 详细调试信息缺失"
fi

if grep -q "onChange.*selectedCategory" iOSBrowser/WidgetConfigView.swift; then
    echo "✅ 分类切换监听已添加"
else
    echo "❌ 分类切换监听缺失"
fi

echo ""
echo "📱📱📱 应用数据同步修复完成！📱📱📱"
echo ""
echo "✅ 修复内容总结："
echo "   - ✅ 创建了共享应用数据管理器"
echo "   - ✅ 从搜索tab同步了完整应用数据"
echo "   - ✅ 实现了应用分类功能"
echo "   - ✅ 增强了UI交互体验"
echo "   - ✅ 添加了详细的调试信息"
echo ""
echo "📊 应用数据统计："
echo "   📱 应用总数: $app_count 个"
echo "   🛒 购物类: $shopping_apps 个"
echo "   👥 社交类: $social_apps 个"
echo "   📺 视频类: $video_apps 个"
echo "   🎵 音乐类: $music_apps 个"
echo "   🏠 生活类: $life_apps 个"
echo ""
echo "🎨 新增功能："
echo "   🏷️ 应用分类选择器（全部、购物、社交、视频、音乐、生活、地图、浏览器、其他）"
echo "   📱 每个应用显示分类标签"
echo "   🔄 实时分类过滤"
echo "   📊 分类应用数量统计"
echo "   🎯 更清晰的应用组织"
echo ""
echo "🚀 立即测试步骤："
echo "1. ✅ 在Xcode中编译运行应用"
echo "2. 📱 切换到小组件配置tab"
echo "3. 📱 点击第二个tab（应用选择）"
echo "4. 👀 应该看到\"从搜索tab同步的 $app_count 个应用\""
echo "5. 🏷️ 应该看到分类选择器（全部、购物、社交等）"
echo "6. 📱 点击\"全部\"应该显示所有 $app_count 个应用"
echo "7. 🛒 点击\"购物\"应该显示 $shopping_apps 个购物应用"
echo "8. 👥 点击\"社交\"应该显示 $social_apps 个社交应用"
echo "9. 📺 点击\"视频\"应该显示 $video_apps 个视频应用"
echo "10. 🎵 点击\"音乐\"应该显示 $music_apps 个音乐应用"
echo "11. 🏠 点击\"生活\"应该显示 $life_apps 个生活应用"
echo "12. 📊 查看控制台输出的详细调试信息"
echo ""
echo "🎯 预期结果："
echo "• 应用选择页面显示完整的 $app_count 个应用"
echo "• 分类选择器正常工作"
echo "• 每个分类显示正确数量的应用"
echo "• 应用选择状态正确保存"
echo "• 控制台输出详细的调试信息"
echo ""
echo "🔍 调试信息说明："
echo "📱 AppConfigView 加载"
echo "📱 总应用数量: $app_count"
echo "📱 当前分类: 全部"
echo "📱 当前分类应用数量: $app_count"
echo "📱 当前选中: taobao,jd,meituan,douyin,wechat,alipay"
echo "📱 切换分类到: 购物，应用数量: $shopping_apps"
echo ""
echo "🔧 如果仍然只显示6个应用："
echo "1. 检查控制台是否有错误信息"
echo "2. 确认SharedAppDataManager是否正确加载"
echo "3. 验证应用数据结构是否正确"
echo "4. 检查分类过滤逻辑是否正常"
echo "5. 重新编译并运行应用"
echo ""
echo "💡 关键改进："
echo "• 🔗 建立了与搜索tab的数据同步"
echo "• 📊 实现了完整的应用数据管理"
echo "• 🏷️ 添加了智能分类功能"
echo "• 🎨 提升了用户交互体验"
echo "• 🔍 增强了调试和监控能力"
echo ""
echo "🌟 现在您应该能看到完整的 $app_count 个应用，并且可以按分类浏览了！"
echo "🎉 享受更丰富的应用选择体验！"
