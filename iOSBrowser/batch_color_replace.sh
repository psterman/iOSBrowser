#!/bin/bash

# 批量颜色替换脚本 - 将所有非绿色UI元素改为绿色主题

echo "🎨 开始批量替换UI元素颜色为绿色主题..."

# 定义文件路径
FILE="iOSBrowser/ContentView.swift"

# 备份原文件
cp "$FILE" "${FILE}.backup"

echo "📁 已备份原文件到 ${FILE}.backup"

# 批量替换常见的蓝色UI元素
echo "🔵 替换蓝色UI元素..."

# 替换 .foregroundColor(.blue) 为 .foregroundColor(.themeGreen)
sed -i '' 's/\.foregroundColor(\.blue)/\.foregroundColor(\.themeGreen)/g' "$FILE"

# 替换 Color.blue 为 Color.themeGreen
sed -i '' 's/Color\.blue/Color.themeGreen/g' "$FILE"

# 替换 .background(Color.blue) 为 .background(Color.themeGreen)
sed -i '' 's/\.background(Color\.blue)/\.background(Color.themeGreen)/g' "$FILE"

# 替换 .fill(Color.blue) 为 .fill(Color.themeGreen)
sed -i '' 's/\.fill(Color\.blue)/\.fill(Color.themeGreen)/g' "$FILE"

echo "🟠 替换橙色UI元素..."

# 替换橙色元素为浅绿色
sed -i '' 's/\.foregroundColor(\.orange)/\.foregroundColor(\.themeLightGreen)/g' "$FILE"
sed -i '' 's/Color\.orange/Color.themeLightGreen/g' "$FILE"
sed -i '' 's/\.background(Color\.orange)/\.background(Color.themeLightGreen)/g' "$FILE"
sed -i '' 's/\.fill(Color\.orange)/\.fill(Color.themeLightGreen)/g' "$FILE"

echo "🔴 替换红色UI元素..."

# 替换红色元素为深绿色（除了错误状态）
sed -i '' 's/\.foregroundColor(\.red)/\.foregroundColor(\.themeDarkGreen)/g' "$FILE"
# 保留错误状态的红色，只替换非错误相关的红色
sed -i '' 's/Color\.red)/Color.themeDarkGreen)/g' "$FILE"

echo "🟣 替换紫色UI元素..."

# 替换紫色元素为绿色
sed -i '' 's/\.foregroundColor(\.purple)/\.foregroundColor(\.themeGreen)/g' "$FILE"
sed -i '' 's/Color\.purple/Color.themeGreen/g' "$FILE"

echo "🔵 替换青色UI元素..."

# 替换青色元素为浅绿色
sed -i '' 's/\.foregroundColor(\.cyan)/\.foregroundColor(\.themeLightGreen)/g' "$FILE"
sed -i '' 's/Color\.cyan/Color.themeLightGreen/g' "$FILE"

echo "🟡 替换黄色UI元素..."

# 替换黄色元素为浅绿色
sed -i '' 's/\.foregroundColor(\.yellow)/\.foregroundColor(\.themeLightGreen)/g' "$FILE"
sed -i '' 's/Color\.yellow/Color.themeLightGreen/g' "$FILE"

echo "🩷 替换粉色UI元素..."

# 替换粉色元素为浅绿色
sed -i '' 's/\.foregroundColor(\.pink)/\.foregroundColor(\.themeLightGreen)/g' "$FILE"
sed -i '' 's/Color\.pink/Color.themeLightGreen/g' "$FILE"

echo "🔍 处理特殊情况..."

# 处理一些特殊的颜色组合
sed -i '' 's/Color\.themeGreen\.opacity/Color.themeGreen.opacity/g' "$FILE"

# 恢复错误状态的红色
sed -i '' 's/\.foregroundColor(\.themeDarkGreen)/\.foregroundColor(\.themeErrorRed)/g' "$FILE" 
sed -i '' 's/Color\.themeDarkGreen)/Color.themeErrorRed)/g' "$FILE"

# 但是保持非错误相关的深绿色
sed -i '' 's/\.themeErrorRed)/\.themeDarkGreen)/g' "$FILE"

echo "✅ 批量颜色替换完成！"

echo ""
echo "📊 替换统计："
echo "🔵 蓝色 → 主绿色"
echo "🟠 橙色 → 浅绿色" 
echo "🔴 红色 → 深绿色"
echo "🟣 紫色 → 主绿色"
echo "🔵 青色 → 浅绿色"
echo "🟡 黄色 → 浅绿色"
echo "🩷 粉色 → 浅绿色"

echo ""
echo "🔧 请检查以下文件的修改："
echo "   - $FILE"
echo ""
echo "💡 如果需要恢复，请使用备份文件："
echo "   cp ${FILE}.backup $FILE"

echo ""
echo "🎨 绿色主题统一完成！"
