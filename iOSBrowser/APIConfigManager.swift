import Foundation

class APIConfigManager: ObservableObject {
    static let shared = APIConfigManager()
    
    @Published var apiKeys: [String: String] = [:]
    
    private init() {
        loadAPIKeys()
    }
    
    func setAPIKey(for service: String, key: String) {
        apiKeys[service] = key
        saveAPIKeys()
    }
    
    func getAPIKey(for service: String) -> String? {
        // 添加安全检查
        guard !service.isEmpty else { return nil }
        return apiKeys[service]
    }
    
    func hasAPIKey(for service: String) -> Bool {
        // 添加安全检查
        guard !service.isEmpty else { return false }
        // 使用安全的字符串检查
        if let key = apiKeys[service] {
            return !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return false
    }
    
    private func loadAPIKeys() {
        // 添加错误处理
        do {
            if let data = UserDefaults.standard.data(forKey: "api_keys"),
               let keys = try? JSONDecoder().decode([String: String].self, from: data) {
                apiKeys = keys
            }
        } catch {
            print("⚠️ APIConfigManager加载失败: \(error.localizedDescription)")
            // 重置为默认状态
            apiKeys = [:]
        }
    }
    
    private func saveAPIKeys() {
        // 添加错误处理
        do {
            if let data = try? JSONEncoder().encode(apiKeys) {
                UserDefaults.standard.set(data, forKey: "api_keys")
                UserDefaults.standard.synchronize()
            }
        } catch {
            print("⚠️ APIConfigManager保存失败: \(error.localizedDescription)")
        }
    }
} 