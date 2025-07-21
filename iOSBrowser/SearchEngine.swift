import Foundation

// This file now contains both data models.

// MARK: - Web Search Engine Model
struct WebSearchEngine: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let searchUrl: String // Using {query} as placeholder for the search term
    let faviconDomain: String
}

let regularSearchEngines: [WebSearchEngine] = [
    WebSearchEngine(name: "Google", searchUrl: "https://www.google.com/search?q={query}", faviconDomain: "google.com"),
    WebSearchEngine(name: "Bing", searchUrl: "https://www.bing.com/search?q={query}", faviconDomain: "bing.com"),
    WebSearchEngine(name: "DuckDuckGo", searchUrl: "https://duckduckgo.com/?q={query}", faviconDomain: "duckduckgo.com"),
    WebSearchEngine(name: "Baidu", searchUrl: "https://www.baidu.com/s?wd={query}", faviconDomain: "baidu.com")
]

// MARK: - AI Chat Provider Model
struct AIChatProvider: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let apiEndpoint: String
    let modelName: String
    let apiKeyStorageKey: String // Key for UserDefaults
    let logoAssetName: String // Name in Asset Catalog or SF Symbol
    let isSFSymbol: Bool
}

let aiChatProviders: [AIChatProvider] = [
    AIChatProvider(
        name: "DeepSeek",
        apiEndpoint: "https://api.deepseek.com/chat/completions",
        modelName: "deepseek-chat",
        apiKeyStorageKey: "deepseek_api_key",
        logoAssetName: "D", // Corresponds to icon in HTML
        isSFSymbol: true
    ),
    AIChatProvider(
        name: "OpenAI",
        apiEndpoint: "https://api.openai.com/v1/chat/completions",
        modelName: "gpt-4o",
        apiKeyStorageKey: "openai_api_key",
        logoAssetName: "O", // Corresponds to icon in HTML
        isSFSymbol: true
    ),
    AIChatProvider(
        name: "Groq",
        apiEndpoint: "https://api.groq.com/openai/v1/chat/completions",
        modelName: "llama3-70b-8192",
        apiKeyStorageKey: "groq_api_key",
        logoAssetName: "G", // Corresponds to icon in HTML
        isSFSymbol: true
    )
]

// This list is now deprecated in favor of aiChatProviders.
let aiSearchEngines: [WebSearchEngine] = []