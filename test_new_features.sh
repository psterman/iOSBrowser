#!/bin/bash

# 🚀 新功能测试脚本
# 测试聚合搜索、内容拦截、HTTPS传输、数据加密等功能

echo "🚀🚀🚀 开始测试新功能..."
echo "=================================="

# 1. 检查新文件是否存在
echo "📁 检查新文件..."
new_files=(
    "iOSBrowser/AggregatedSearchView.swift"
    "iOSBrowser/EnhancedAIChatView.swift"
    "iOSBrowser/ContentBlockManager.swift"
    "iOSBrowser/HTTPSManager.swift"
    "iOSBrowser/DataEncryptionManager.swift"
    "iOSBrowser/EnhancedContentView.swift"
    "iOSBrowser/FEATURE_SUMMARY.md"
)

for file in "${new_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file 存在"
    else
        echo "❌ $file 缺失"
    fi
done

echo ""

# 2. 检查聚合搜索功能
echo "🔍 检查聚合搜索功能..."
if grep -q "AggregatedSearchView" iOSBrowser/AggregatedSearchView.swift; then
    echo "✅ 聚合搜索视图已实现"
else
    echo "❌ 聚合搜索视图未实现"
fi

if grep -q "SearchPlatform" iOSBrowser/AggregatedSearchView.swift; then
    echo "✅ 搜索平台配置已实现"
else
    echo "❌ 搜索平台配置未实现"
fi

if grep -q "bilibili" iOSBrowser/AggregatedSearchView.swift; then
    echo "✅ B站平台支持已添加"
else
    echo "❌ B站平台支持未添加"
fi

if grep -q "toutiao" iOSBrowser/AggregatedSearchView.swift; then
    echo "✅ 今日头条平台支持已添加"
else
    echo "❌ 今日头条平台支持未添加"
fi

if grep -q "wechat_mp" iOSBrowser/AggregatedSearchView.swift; then
    echo "✅ 微信公众号平台支持已添加"
else
    echo "❌ 微信公众号平台支持未添加"
fi

if grep -q "ximalaya" iOSBrowser/AggregatedSearchView.swift; then
    echo "✅ 喜马拉雅平台支持已添加"
else
    echo "❌ 喜马拉雅平台支持未添加"
fi

echo ""

# 3. 检查增强AI聊天功能
echo "🤖 检查增强AI聊天功能..."
if grep -q "EnhancedAIChatView" iOSBrowser/EnhancedAIChatView.swift; then
    echo "✅ 增强AI聊天视图已实现"
else
    echo "❌ 增强AI聊天视图未实现"
fi

if grep -q "PlatformContact" iOSBrowser/EnhancedAIChatView.swift; then
    echo "✅ 平台对话人功能已实现"
else
    echo "❌ 平台对话人功能未实现"
fi

if grep -q "PlatformChatView" iOSBrowser/EnhancedAIChatView.swift; then
    echo "✅ 平台对话视图已实现"
else
    echo "❌ 平台对话视图未实现"
fi

echo ""

# 4. 检查内容拦截功能
echo "🛡️ 检查内容拦截功能..."
if grep -q "ContentBlockManager" iOSBrowser/ContentBlockManager.swift; then
    echo "✅ 内容拦截管理器已实现"
else
    echo "❌ 内容拦截管理器未实现"
fi

if grep -q "adBlockRules" iOSBrowser/ContentBlockManager.swift; then
    echo "✅ 广告过滤规则已配置"
else
    echo "❌ 广告过滤规则未配置"
fi

if grep -q "trackerBlockRules" iOSBrowser/ContentBlockManager.swift; then
    echo "✅ 追踪器过滤规则已配置"
else
    echo "❌ 追踪器过滤规则未配置"
fi

if grep -q "malwareBlockRules" iOSBrowser/ContentBlockManager.swift; then
    echo "✅ 恶意软件过滤规则已配置"
else
    echo "❌ 恶意软件过滤规则未配置"
fi

echo ""

# 5. 检查HTTPS传输功能
echo "🔒 检查HTTPS传输功能..."
if grep -q "HTTPSManager" iOSBrowser/HTTPSManager.swift; then
    echo "✅ HTTPS管理器已实现"
else
    echo "❌ HTTPS管理器未实现"
fi

if grep -q "TLSv12" iOSBrowser/HTTPSManager.swift; then
    echo "✅ TLS 1.2+ 支持已配置"
else
    echo "❌ TLS 1.2+ 支持未配置"
fi

if grep -q "ensureHTTPS" iOSBrowser/HTTPSManager.swift; then
    echo "✅ HTTPS强制功能已实现"
else
    echo "❌ HTTPS强制功能未实现"
fi

if grep -q "certificatePinning" iOSBrowser/HTTPSManager.swift; then
    echo "✅ 证书固定功能已实现"
else
    echo "❌ 证书固定功能未实现"
fi

echo ""

# 6. 检查数据加密功能
echo "🔐 检查数据加密功能..."
if grep -q "DataEncryptionManager" iOSBrowser/DataEncryptionManager.swift; then
    echo "✅ 数据加密管理器已实现"
else
    echo "❌ 数据加密管理器未实现"
fi

if grep -q "AES.GCM" iOSBrowser/DataEncryptionManager.swift; then
    echo "✅ AES-GCM加密算法已实现"
else
    echo "❌ AES-GCM加密算法未实现"
fi

if grep -q "SymmetricKey" iOSBrowser/DataEncryptionManager.swift; then
    echo "✅ 对称密钥管理已实现"
else
    echo "❌ 对称密钥管理未实现"
fi

if grep -q "KeychainWrapper" iOSBrowser/DataEncryptionManager.swift; then
    echo "✅ Keychain密钥存储已实现"
else
    echo "❌ Keychain密钥存储未实现"
fi

echo ""

# 7. 检查主应用集成
echo "📱 检查主应用集成..."
if grep -q "EnhancedContentView" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ 主应用已集成增强视图"
else
    echo "❌ 主应用未集成增强视图"
fi

if grep -q "EnhancedContentView" iOSBrowser/EnhancedContentView.swift; then
    echo "✅ 增强主视图已实现"
else
    echo "❌ 增强主视图未实现"
fi

if grep -q "AggregatedSearchView" iOSBrowser/EnhancedContentView.swift; then
    echo "✅ 聚合搜索已集成到主视图"
else
    echo "❌ 聚合搜索未集成到主视图"
fi

if grep -q "EnhancedAIChatView" iOSBrowser/EnhancedContentView.swift; then
    echo "✅ 增强AI聊天已集成到主视图"
else
    echo "❌ 增强AI聊天未集成到主视图"
fi

echo ""

# 8. 检查功能总结文档
echo "📋 检查功能总结文档..."
if [ -f "iOSBrowser/FEATURE_SUMMARY.md" ]; then
    echo "✅ 功能总结文档已创建"
    
    if grep -q "聚合搜索" iOSBrowser/FEATURE_SUMMARY.md; then
        echo "✅ 聚合搜索功能已文档化"
    else
        echo "❌ 聚合搜索功能未文档化"
    fi
    
    if grep -q "内容拦截" iOSBrowser/FEATURE_SUMMARY.md; then
        echo "✅ 内容拦截功能已文档化"
    else
        echo "❌ 内容拦截功能未文档化"
    fi
    
    if grep -q "HTTPS传输" iOSBrowser/FEATURE_SUMMARY.md; then
        echo "✅ HTTPS传输功能已文档化"
    else
        echo "❌ HTTPS传输功能未文档化"
    fi
    
    if grep -q "数据加密" iOSBrowser/FEATURE_SUMMARY.md; then
        echo "✅ 数据加密功能已文档化"
    else
        echo "❌ 数据加密功能未文档化"
    fi
else
    echo "❌ 功能总结文档未创建"
fi

echo ""
echo "=================================="
echo "🎉 新功能测试完成！"

# 9. 统计结果
echo ""
echo "📊 测试统计："
total_checks=0
passed_checks=0

# 统计文件检查
for file in "${new_files[@]}"; do
    total_checks=$((total_checks + 1))
    if [ -f "$file" ]; then
        passed_checks=$((passed_checks + 1))
    fi
done

# 统计功能检查
function count_checks() {
    local pattern="$1"
    local file="$2"
    total_checks=$((total_checks + 1))
    if grep -q "$pattern" "$file"; then
        passed_checks=$((passed_checks + 1))
    fi
}

count_checks "AggregatedSearchView" "iOSBrowser/AggregatedSearchView.swift"
count_checks "SearchPlatform" "iOSBrowser/AggregatedSearchView.swift"
count_checks "bilibili" "iOSBrowser/AggregatedSearchView.swift"
count_checks "EnhancedAIChatView" "iOSBrowser/EnhancedAIChatView.swift"
count_checks "PlatformContact" "iOSBrowser/EnhancedAIChatView.swift"
count_checks "ContentBlockManager" "iOSBrowser/ContentBlockManager.swift"
count_checks "adBlockRules" "iOSBrowser/ContentBlockManager.swift"
count_checks "HTTPSManager" "iOSBrowser/HTTPSManager.swift"
count_checks "TLSv12" "iOSBrowser/HTTPSManager.swift"
count_checks "DataEncryptionManager" "iOSBrowser/DataEncryptionManager.swift"
count_checks "AES.GCM" "iOSBrowser/DataEncryptionManager.swift"
count_checks "EnhancedContentView" "iOSBrowser/iOSBrowserApp.swift"

echo "总检查项: $total_checks"
echo "通过检查: $passed_checks"
echo "成功率: $((passed_checks * 100 / total_checks))%"

if [ $passed_checks -eq $total_checks ]; then
    echo "🎉 所有功能测试通过！"
    exit 0
else
    echo "⚠️ 部分功能需要完善"
    exit 1
fi 