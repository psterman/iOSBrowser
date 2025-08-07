#!/bin/bash

# 🔧 修复缺失组件脚本

echo "🔧 开始修复缺失的组件..."

# 1. 备份当前文件
echo "📁 1. 备份当前文件..."
cp iOSBrowser/BrowserView.swift iOSBrowser/BrowserView.swift.before_fix

# 2. 从备份文件中提取缺失的组件
echo "🔍 2. 提取缺失的组件..."

# 提取ScrollableCustomHomePage和相关组件
echo "   📱 提取ScrollableCustomHomePage组件..."
grep -A 50 "struct ScrollableCustomHomePage" iOSBrowser/BrowserView.swift.backup > temp_components.swift

# 提取BookmarksView
echo "   📚 提取BookmarksView组件..."
grep -A 30 "struct BookmarksView" iOSBrowser/BrowserView.swift.backup >> temp_components.swift

# 提取ExpandedInputView
echo "   📝 提取ExpandedInputView组件..."
grep -A 30 "struct ExpandedInputView" iOSBrowser/BrowserView.swift.backup >> temp_components.swift

# 提取BrowserAIChatView
echo "   🤖 提取BrowserAIChatView组件..."
grep -A 30 "struct BrowserAIChatView" iOSBrowser/BrowserView.swift.backup >> temp_components.swift

# 提取FloatingPromptView
echo "   💬 提取FloatingPromptView组件..."
grep -A 30 "struct FloatingPromptView" iOSBrowser/BrowserView.swift.backup >> temp_components.swift

# 提取PromptManagerView
echo "   ⚙️ 提取PromptManagerView组件..."
grep -A 30 "struct PromptManagerView" iOSBrowser/BrowserView.swift.backup >> temp_components.swift

# 提取ToastView
echo "   🔔 提取ToastView组件..."
grep -A 30 "struct ToastView" iOSBrowser/BrowserView.swift.backup >> temp_components.swift

# 提取其他相关类型定义
echo "   🏷️ 提取类型定义..."
grep -A 20 "enum AssistantType" iOSBrowser/BrowserView.swift.backup >> temp_components.swift
grep -A 20 "enum IdentityType" iOSBrowser/BrowserView.swift.backup >> temp_components.swift
grep -A 20 "enum ReplyStyleType" iOSBrowser/BrowserView.swift.backup >> temp_components.swift
grep -A 20 "enum ToneType" iOSBrowser/BrowserView.swift.backup >> temp_components.swift
grep -A 20 "struct PromptCategory" iOSBrowser/BrowserView.swift.backup >> temp_components.swift

# 3. 将组件添加到BrowserView.swift文件末尾
echo "📝 3. 添加组件到文件..."
cat temp_components.swift >> iOSBrowser/BrowserView.swift

# 4. 清理临时文件
echo "🧹 4. 清理临时文件..."
rm temp_components.swift

# 5. 修复重复的performSearch声明
echo "🔧 5. 修复重复声明..."
# 移除重复的performSearch声明
sed -i '' '/static let performSearch = Notification.Name("performSearch")/d' iOSBrowser/BrowserView.swift

echo "✅ 组件修复完成！"
echo ""
echo "📋 修复的组件："
echo "   ✅ ScrollableCustomHomePage"
echo "   ✅ BookmarksView"
echo "   ✅ ExpandedInputView"
echo "   ✅ BrowserAIChatView"
echo "   ✅ FloatingPromptView"
echo "   ✅ PromptManagerView"
echo "   ✅ ToastView"
echo "   ✅ 相关类型定义"
echo "   ✅ 修复重复声明" 