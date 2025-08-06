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
        return apiKeys[service]
    }
    
    func hasAPIKey(for service: String) -> Bool {
        return apiKeys[service]?.isEmpty == false
    }
    
    private func loadAPIKeys() {
        if let data = UserDefaults.standard.data(forKey: "api_keys"),
           let keys = try? JSONDecoder().decode([String: String].self, from: data) {
            apiKeys = keys
        }
    }
    
    private func saveAPIKeys() {
        if let data = try? JSONEncoder().encode(apiKeys) {
            UserDefaults.standard.set(data, forKey: "api_keys")
        }
    }
} 