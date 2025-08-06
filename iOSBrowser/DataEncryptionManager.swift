//
//  DataEncryptionManager.swift
//  iOSBrowser
//
//  数据加密管理器 - 加密本地用户存储数据
//

import Foundation
import CryptoKit
import Security

class DataEncryptionManager: ObservableObject {
    static let shared = DataEncryptionManager()
    
    @Published var isEncryptionEnabled = true
    @Published var encryptionStats = EncryptionStats()
    
    private let keychain = KeychainWrapper.standard
    private let encryptionKeyIdentifier = "iOSBrowserEncryptionKey"
    
    private init() {
        loadSettings()
        setupEncryptionKey()
    }
    
    // MARK: - 设置加密密钥
    private func setupEncryptionKey() {
        if !keychain.hasValue(forKey: encryptionKeyIdentifier) {
            // 生成新的加密密钥
            let key = SymmetricKey(size: .bits256)
            let keyData = key.withUnsafeBytes { Data($0) }
            
            do {
                try keychain.set(keyData, forKey: encryptionKeyIdentifier)
                print("✅ 加密密钥已生成并保存")
            } catch {
                print("❌ 保存加密密钥失败: \(error)")
            }
        }
    }
    
    // MARK: - 获取加密密钥
    private func getEncryptionKey() -> SymmetricKey? {
        guard let keyData = keychain.data(forKey: encryptionKeyIdentifier) else {
            print("❌ 无法获取加密密钥")
            return nil
        }
        
        return SymmetricKey(data: keyData)
    }
    
    // MARK: - 设置管理
    private func loadSettings() {
        let defaults = UserDefaults.standard
        isEncryptionEnabled = defaults.bool(forKey: "encryption_enabled")
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(isEncryptionEnabled, forKey: "encryption_enabled")
    }
    
    // MARK: - 加密数据
    func encryptData(_ data: Data) throws -> Data {
        guard isEncryptionEnabled else { return data }
        
        guard let key = getEncryptionKey() else {
            throw EncryptionError.keyNotFound
        }
        
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            let encryptedData = sealedBox.combined
            
            guard let result = encryptedData else {
                throw EncryptionError.encryptionFailed
            }
            
            updateStats(operation: .encrypt, success: true)
            return result
        } catch {
            updateStats(operation: .encrypt, success: false)
            throw EncryptionError.encryptionFailed
        }
    }
    
    // MARK: - 解密数据
    func decryptData(_ data: Data) throws -> Data {
        guard isEncryptionEnabled else { return data }
        
        guard let key = getEncryptionKey() else {
            throw EncryptionError.keyNotFound
        }
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            
            updateStats(operation: .decrypt, success: true)
            return decryptedData
        } catch {
            updateStats(operation: .decrypt, success: false)
            throw EncryptionError.decryptionFailed
        }
    }
    
    // MARK: - 加密字符串
    func encryptString(_ string: String) throws -> String {
        guard let data = string.data(using: .utf8) else {
            throw EncryptionError.invalidData
        }
        
        let encryptedData = try encryptData(data)
        return encryptedData.base64EncodedString()
    }
    
    // MARK: - 解密字符串
    func decryptString(_ encryptedString: String) throws -> String {
        guard let data = Data(base64Encoded: encryptedString) else {
            throw EncryptionError.invalidData
        }
        
        let decryptedData = try decryptData(data)
        
        guard let string = String(data: decryptedData, encoding: .utf8) else {
            throw EncryptionError.invalidData
        }
        
        return string
    }
    
    // MARK: - 加密字典
    func encryptDictionary(_ dictionary: [String: Any]) throws -> Data {
        let jsonData = try JSONSerialization.data(withJSONObject: dictionary)
        return try encryptData(jsonData)
    }
    
    // MARK: - 解密字典
    func decryptDictionary(_ data: Data) throws -> [String: Any] {
        let decryptedData = try decryptData(data)
        return try JSONSerialization.jsonObject(with: decryptedData) as? [String: Any] ?? [:]
    }
    
    // MARK: - 安全存储
    func secureStore(_ data: Data, forKey key: String) throws {
        let encryptedData = try encryptData(data)
        UserDefaults.standard.set(encryptedData, forKey: key)
    }
    
    func secureRetrieve(forKey key: String) throws -> Data {
        guard let encryptedData = UserDefaults.standard.data(forKey: key) else {
            throw EncryptionError.dataNotFound
        }
        
        return try decryptData(encryptedData)
    }
    
    // MARK: - 安全存储字符串
    func secureStoreString(_ string: String, forKey key: String) throws {
        let encryptedString = try encryptString(string)
        UserDefaults.standard.set(encryptedString, forKey: key)
    }
    
    func secureRetrieveString(forKey key: String) throws -> String {
        guard let encryptedString = UserDefaults.standard.string(forKey: key) else {
            throw EncryptionError.dataNotFound
        }
        
        return try decryptString(encryptedString)
    }
    
    // MARK: - 安全存储字典
    func secureStoreDictionary(_ dictionary: [String: Any], forKey key: String) throws {
        let encryptedData = try encryptDictionary(dictionary)
        UserDefaults.standard.set(encryptedData, forKey: key)
    }
    
    func secureRetrieveDictionary(forKey key: String) throws -> [String: Any] {
        guard let encryptedData = UserDefaults.standard.data(forKey: key) else {
            throw EncryptionError.dataNotFound
        }
        
        return try decryptDictionary(encryptedData)
    }
    
    // MARK: - 更新统计
    private func updateStats(operation: EncryptionOperation, success: Bool) {
        DispatchQueue.main.async {
            switch operation {
            case .encrypt:
                self.encryptionStats.encryptionAttempts += 1
                if success {
                    self.encryptionStats.successfulEncryptions += 1
                } else {
                    self.encryptionStats.failedEncryptions += 1
                }
            case .decrypt:
                self.encryptionStats.decryptionAttempts += 1
                if success {
                    self.encryptionStats.successfulDecryptions += 1
                } else {
                    self.encryptionStats.failedDecryptions += 1
                }
            }
        }
    }
    
    // MARK: - 获取加密统计
    func getEncryptionStats() -> EncryptionStats {
        return encryptionStats
    }
    
    // MARK: - 重置加密密钥
    func resetEncryptionKey() throws {
        // 删除旧密钥
        keychain.removeObject(forKey: encryptionKeyIdentifier)
        
        // 生成新密钥
        setupEncryptionKey()
        
        print("✅ 加密密钥已重置")
    }
    
    // MARK: - 验证加密状态
    func verifyEncryption() -> Bool {
        let testString = "test_encryption"
        
        do {
            let encrypted = try encryptString(testString)
            let decrypted = try decryptString(encrypted)
            return testString == decrypted
        } catch {
            print("❌ 加密验证失败: \(error)")
            return false
        }
    }
}

// MARK: - 错误类型
enum EncryptionError: Error, LocalizedError {
    case keyNotFound
    case encryptionFailed
    case decryptionFailed
    case invalidData
    case dataNotFound
    
    var errorDescription: String? {
        switch self {
        case .keyNotFound:
            return "加密密钥未找到"
        case .encryptionFailed:
            return "加密失败"
        case .decryptionFailed:
            return "解密失败"
        case .invalidData:
            return "无效数据"
        case .dataNotFound:
            return "数据未找到"
        }
    }
}

// MARK: - 加密操作类型
enum EncryptionOperation {
    case encrypt
    case decrypt
}

// MARK: - 加密统计
struct EncryptionStats {
    var encryptionAttempts = 0
    var successfulEncryptions = 0
    var failedEncryptions = 0
    var decryptionAttempts = 0
    var successfulDecryptions = 0
    var failedDecryptions = 0
    
    var encryptionSuccessRate: Double {
        guard encryptionAttempts > 0 else { return 0 }
        return Double(successfulEncryptions) / Double(encryptionAttempts) * 100
    }
    
    var decryptionSuccessRate: Double {
        guard decryptionAttempts > 0 else { return 0 }
        return Double(successfulDecryptions) / Double(decryptionAttempts) * 100
    }
}

// MARK: - KeychainWrapper 简化实现
class KeychainWrapper {
    static let standard = KeychainWrapper()
    
    private init() {}
    
    func set(_ data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    func data(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            return nil
        }
        
        return result as? Data
    }
    
    func hasValue(forKey key: String) -> Bool {
        return data(forKey: key) != nil
    }
    
    func removeObject(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Keychain错误
enum KeychainError: Error {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case deleteFailed(OSStatus)
} 