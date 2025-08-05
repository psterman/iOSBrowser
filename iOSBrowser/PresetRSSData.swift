//
//  PresetRSSData.swift
//  iOSBrowser
//
//  预设RSS数据源 - 中文主流RSS分类
//

import Foundation

// MARK: - RSS数据结构
struct PresetRSSSource: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let url: String
    let category: String
}

struct PresetRSSCategory {
    let name: String
    let icon: String
    let sources: [PresetRSSSource]
}

// MARK: - 预设RSS分类数据
struct PresetRSSCategories {
    static let allCategories: [PresetRSSCategory] = [
        // 新闻资讯
        PresetRSSCategory(
            name: "📰 新闻资讯",
            icon: "newspaper.fill",
            sources: [
                PresetRSSSource(
                    id: "xinhua",
                    name: "新华网",
                    description: "新华网最新新闻",
                    url: "http://www.xinhuanet.com/politics/news_politics.xml",
                    category: "news"
                ),
                PresetRSSSource(
                    id: "people",
                    name: "人民网",
                    description: "人民网时政新闻",
                    url: "http://www.people.com.cn/rss/politics.xml",
                    category: "news"
                ),
                PresetRSSSource(
                    id: "cctv",
                    name: "央视新闻",
                    description: "央视新闻最新报道",
                    url: "https://news.cctv.com/2019/07/gaiban/cmsdatainterface/page/news_1.jsonp",
                    category: "news"
                ),
                PresetRSSSource(
                    id: "caixin",
                    name: "财新网",
                    description: "财新网最新资讯",
                    url: "http://www.caixin.com/rss/all.xml",
                    category: "news"
                )
            ]
        ),
        
        // 科技数码
        PresetRSSCategory(
            name: "💻 科技数码",
            icon: "laptopcomputer",
            sources: [
                PresetRSSSource(
                    id: "36kr",
                    name: "36氪",
                    description: "36氪科技资讯",
                    url: "https://36kr.com/feed",
                    category: "tech"
                ),
                PresetRSSSource(
                    id: "ithome",
                    name: "IT之家",
                    description: "IT之家科技新闻",
                    url: "https://www.ithome.com/rss/",
                    category: "tech"
                ),
                PresetRSSSource(
                    id: "cnbeta",
                    name: "cnBeta",
                    description: "cnBeta科技资讯",
                    url: "https://www.cnbeta.com/backend.php",
                    category: "tech"
                ),
                PresetRSSSource(
                    id: "pingwest",
                    name: "PingWest",
                    description: "PingWest科技媒体",
                    url: "https://www.pingwest.com/feed",
                    category: "tech"
                )
            ]
        ),
        
        // 财经商业
        PresetRSSCategory(
            name: "💰 财经商业",
            icon: "chart.line.uptrend.xyaxis",
            sources: [
                PresetRSSSource(
                    id: "wallstreetcn",
                    name: "华尔街见闻",
                    description: "华尔街见闻财经资讯",
                    url: "https://wallstreetcn.com/feed",
                    category: "finance"
                ),
                PresetRSSSource(
                    id: "yicai",
                    name: "第一财经",
                    description: "第一财经最新资讯",
                    url: "https://www.yicai.com/rss/all.xml",
                    category: "finance"
                ),
                PresetRSSSource(
                    id: "jiemian",
                    name: "界面新闻",
                    description: "界面新闻财经频道",
                    url: "https://www.jiemian.com/lists/426.xml",
                    category: "finance"
                )
            ]
        ),
        
        // 娱乐八卦
        PresetRSSCategory(
            name: "🎬 娱乐八卦",
            icon: "tv.fill",
            sources: [
                PresetRSSSource(
                    id: "sina_ent",
                    name: "新浪娱乐",
                    description: "新浪娱乐最新资讯",
                    url: "http://rss.sina.com.cn/ent/star.xml",
                    category: "entertainment"
                ),
                PresetRSSSource(
                    id: "163_ent",
                    name: "网易娱乐",
                    description: "网易娱乐频道",
                    url: "http://ent.163.com/special/00031K7Q/rss_newsent.xml",
                    category: "entertainment"
                )
            ]
        ),
        
        // 体育运动
        PresetRSSCategory(
            name: "⚽ 体育运动",
            icon: "sportscourt.fill",
            sources: [
                PresetRSSSource(
                    id: "sina_sports",
                    name: "新浪体育",
                    description: "新浪体育最新资讯",
                    url: "http://rss.sina.com.cn/sports/roll.xml",
                    category: "sports"
                ),
                PresetRSSSource(
                    id: "163_sports",
                    name: "网易体育",
                    description: "网易体育频道",
                    url: "http://sports.163.com/special/00051K7Q/rss_newssports.xml",
                    category: "sports"
                ),
                PresetRSSSource(
                    id: "hupu",
                    name: "虎扑体育",
                    description: "虎扑体育资讯",
                    url: "https://voice.hupu.com/rss.xml",
                    category: "sports"
                )
            ]
        ),
        
        // 生活时尚
        PresetRSSCategory(
            name: "🌸 生活时尚",
            icon: "heart.fill",
            sources: [
                PresetRSSSource(
                    id: "elle",
                    name: "ELLE中国",
                    description: "ELLE时尚资讯",
                    url: "http://www.ellechina.com/rss/all/",
                    category: "lifestyle"
                ),
                PresetRSSSource(
                    id: "cosmopolitan",
                    name: "时尚COSMO",
                    description: "时尚COSMO最新资讯",
                    url: "http://www.cosmopolitan.com.cn/rss/all/",
                    category: "lifestyle"
                )
            ]
        ),
        
        // 汽车频道
        PresetRSSCategory(
            name: "🚗 汽车频道",
            icon: "car.fill",
            sources: [
                PresetRSSSource(
                    id: "autohome",
                    name: "汽车之家",
                    description: "汽车之家最新资讯",
                    url: "https://www.autohome.com.cn/rss/all.xml",
                    category: "auto"
                ),
                PresetRSSSource(
                    id: "pcauto",
                    name: "太平洋汽车",
                    description: "太平洋汽车网资讯",
                    url: "http://www.pcauto.com.cn/rss/news.xml",
                    category: "auto"
                )
            ]
        ),
        
        // 游戏动漫
        PresetRSSCategory(
            name: "🎮 游戏动漫",
            icon: "gamecontroller.fill",
            sources: [
                PresetRSSSource(
                    id: "gamersky",
                    name: "游民星空",
                    description: "游民星空游戏资讯",
                    url: "https://www.gamersky.com/rss/rss.xml",
                    category: "gaming"
                ),
                PresetRSSSource(
                    id: "17173",
                    name: "17173",
                    description: "17173游戏门户",
                    url: "http://www.17173.com/rss/allnews.xml",
                    category: "gaming"
                ),
                PresetRSSSource(
                    id: "acfun",
                    name: "AcFun",
                    description: "AcFun弹幕视频网",
                    url: "http://www.acfun.cn/rss/feed.xml",
                    category: "gaming"
                )
            ]
        ),
        
        // 教育学习
        PresetRSSCategory(
            name: "📚 教育学习",
            icon: "book.fill",
            sources: [
                PresetRSSSource(
                    id: "zhihu_daily",
                    name: "知乎日报",
                    description: "知乎日报精选",
                    url: "http://feeds.feedburner.com/zhihu-daily",
                    category: "education"
                ),
                PresetRSSSource(
                    id: "guokr",
                    name: "果壳网",
                    description: "果壳网科学人",
                    url: "http://www.guokr.com/rss/",
                    category: "education"
                )
            ]
        ),
        
        // 健康医疗
        PresetRSSCategory(
            name: "🏥 健康医疗",
            icon: "cross.fill",
            sources: [
                PresetRSSSource(
                    id: "dxy",
                    name: "丁香园",
                    description: "丁香园医学资讯",
                    url: "http://www.dxy.cn/rss/all.xml",
                    category: "health"
                ),
                PresetRSSSource(
                    id: "39health",
                    name: "39健康网",
                    description: "39健康网资讯",
                    url: "http://www.39.net/rss/all.xml",
                    category: "health"
                )
            ]
        )
    ]
}
