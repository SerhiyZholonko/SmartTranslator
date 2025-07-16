import Foundation
import Compression

class SmartCacheManager {
    static let shared = SmartCacheManager()
    
    private var cache: [String: CachedTranslation] = [:]
    private let cacheKey = "smartTranslationCache"
    private var maxCacheSize: Int {
        let userMaxSize = UserDefaults.standard.integer(forKey: "maxCacheSize")
        return (userMaxSize == 0 ? 50 : userMaxSize) * 1024 * 1024 // Convert MB to bytes
    }
    private let compressionThreshold = 1000 // Compress texts longer than 1000 characters
    
    private init() {
        // Defer loading to avoid blocking UI on startup
        Task {
            await MainActor.run {
                loadCache()
            }
        }
        
        // Periodic cache cleanup
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            self.cleanupCache()
        }
    }
    
    // MARK: - Cache Operations
    
    func getCachedTranslation(text: String,
                             sourceLanguage: String,
                             targetLanguage: String) -> (translation: String, alternatives: [String], corrections: [String])? {
        
        let key = CachedTranslation.generateKey(
            text: text,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )
        
        guard var cached = cache[key] else { return nil }
        
        // Update access time and frequency
        cached = CachedTranslation(
            key: cached.key,
            translation: cached.translation,
            alternatives: cached.alternatives,
            corrections: cached.corrections,
            frequency: cached.frequency + 1,
            lastAccessed: Date(),
            compressed: cached.compressed
        )
        
        cache[key] = cached
        saveCache()
        
        return (cached.translation, cached.alternatives, cached.corrections)
    }
    
    func cacheTranslation(text: String,
                         translation: String,
                         alternatives: [String],
                         corrections: [String],
                         sourceLanguage: String,
                         targetLanguage: String) {
        
        let key = CachedTranslation.generateKey(
            text: text,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )
        
        let shouldCompress = text.count > compressionThreshold
        
        let cached = CachedTranslation(
            key: key,
            translation: translation,
            alternatives: alternatives,
            corrections: corrections,
            frequency: 1,
            lastAccessed: Date(),
            compressed: shouldCompress
        )
        
        cache[key] = cached
        
        // Check cache size and cleanup if needed
        if getCurrentCacheSize() > maxCacheSize {
            cleanupCache()
        }
        
        saveCache()
    }
    
    
    // MARK: - Cache Management
    
    private func cleanupCache() {
        // Remove least recently used items if cache is too large
        let sortedCache = cache.values.sorted { $0.lastAccessed < $1.lastAccessed }
        let targetSize = Int(Double(maxCacheSize) * 0.8) // Keep 80% after cleanup
        
        var currentSize = getCurrentCacheSize()
        var itemsToRemove: [String] = []
        
        for item in sortedCache {
            if currentSize <= targetSize { break }
            
            itemsToRemove.append(item.key)
            currentSize -= estimateItemSize(item)
        }
        
        for key in itemsToRemove {
            cache.removeValue(forKey: key)
        }
        
        saveCache()
    }
    
    private func getCurrentCacheSize() -> Int {
        return cache.values.reduce(0) { $0 + estimateItemSize($1) }
    }
    
    private func estimateItemSize(_ item: CachedTranslation) -> Int {
        let textSize = item.translation.utf8.count + 
                      item.alternatives.joined().utf8.count +
                      item.corrections.joined().utf8.count
        return item.compressed ? textSize / 4 : textSize // Assume 4:1 compression ratio
    }
    
    // MARK: - Compression
    
    private func compressString(_ string: String) -> Data? {
        guard let data = string.data(using: .utf8) else { return nil }
        return data.compressed(using: .zlib)
    }
    
    private func decompressData(_ data: Data) -> String? {
        guard let decompressed = data.decompressed(using: .zlib),
              let string = String(data: decompressed, encoding: .utf8) else { return nil }
        return string
    }
    
    // MARK: - Persistence
    
    private func loadCache() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let decoded = try? JSONDecoder().decode([String: CachedTranslation].self, from: data) else {
            return
        }
        cache = decoded
    }
    
    private func saveCache() {
        guard let encoded = try? JSONEncoder().encode(cache) else { return }
        UserDefaults.standard.set(encoded, forKey: cacheKey)
    }
    
    func clearCache() {
        cache.removeAll()
        saveCache()
    }
    
    // MARK: - Public Cache Info
    
    func getCurrentCacheSizeInMB() -> Double {
        return Double(getCurrentCacheSize()) / (1024 * 1024)
    }
    
    func getMaxCacheSizeInMB() -> Int {
        return maxCacheSize / (1024 * 1024)
    }
    
    func getCacheItemCount() -> Int {
        return cache.count
    }
    
    // MARK: - Cache Statistics
    
    func getCacheStatistics() -> (itemCount: Int, sizeInMB: Double, hitRate: Double) {
        let itemCount = cache.count
        let sizeInBytes = getCurrentCacheSize()
        let sizeInMB = Double(sizeInBytes) / (1024 * 1024)
        
        let totalFrequency = cache.values.reduce(0) { $0 + $1.frequency }
        let averageFrequency = itemCount > 0 ? Double(totalFrequency) / Double(itemCount) : 0
        let hitRate = min(averageFrequency / 10.0, 1.0) // Normalize to 0-1
        
        return (itemCount, sizeInMB, hitRate)
    }
}

// MARK: - Data Compression Extension

extension Data {
    func compressed(using algorithm: Compression.Algorithm) -> Data? {
        return self.withUnsafeBytes { bytes in
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
            defer { buffer.deallocate() }
            
            let compressedSize = compression_encode_buffer(
                buffer, count,
                bytes.bindMemory(to: UInt8.self).baseAddress!, count,
                nil, algorithm.algorithm
            )
            
            guard compressedSize > 0 else { return nil }
            return Data(bytes: buffer, count: compressedSize)
        }
    }
    
    func decompressed(using algorithm: Compression.Algorithm) -> Data? {
        return self.withUnsafeBytes { bytes in
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: count * 4)
            defer { buffer.deallocate() }
            
            let decompressedSize = compression_decode_buffer(
                buffer, count * 4,
                bytes.bindMemory(to: UInt8.self).baseAddress!, count,
                nil, algorithm.algorithm
            )
            
            guard decompressedSize > 0 else { return nil }
            return Data(bytes: buffer, count: decompressedSize)
        }
    }
}

extension Compression.Algorithm {
    var algorithm: compression_algorithm {
        switch self {
        case .lzfse: return COMPRESSION_LZFSE
        case .lz4: return COMPRESSION_LZ4
        case .lzma: return COMPRESSION_LZMA
        case .zlib: return COMPRESSION_ZLIB
        default: return COMPRESSION_ZLIB  // Значення за замовчуванням
        }
    }
}
