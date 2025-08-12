import Foundation

// MARK: - Groq Chat API Models

struct GroqChatRequest: Codable {
    let model: String
    let messages: [GroqMessage]
    let temperature: Double?
    let maxTokens: Int?
    let stream: Bool?
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature, stream
        case maxTokens = "max_tokens"
    }
}

struct GroqMessage: Codable {
    let role: String
    let content: String
}

struct GroqChatResponse: Codable {
    let id: String?
    let object: String?
    let created: TimeInterval?
    let model: String?
    let choices: [GroqChoice]
    let usage: GroqUsage?
}

struct GroqChoice: Codable {
    let index: Int?
    let message: GroqMessage
    let logprobs: String?
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index, message, logprobs
        case finishReason = "finish_reason"
    }
}

struct GroqUsage: Codable {
    let promptTokens: Int?
    let completionTokens: Int?
    let totalTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

struct GroqError: Codable {
    let error: GroqErrorDetail
}

struct GroqErrorDetail: Codable {
    let message: String
    let type: String?
    let param: String?
    let code: String?
}

// MARK: - Usage Tracking

struct GroqUsageTracker: Codable {
    var dailyUsage: Int = 0
    var dailyTokensUsed: Int = 0
    var perKeyUsage: [String: Int] = [:] // Track tokens per API key
    var lastResetDate: Date = Date()
    
    // Updated limits based on Groq Free tier (as of 2024)
    private let dailyRequestLimit = 14400 // 14,400 requests per day
    private let hourlyRequestLimit = 600 // ~480-600 requests per hour (14400/24)
    private let dailyTokenLimit = 25000 // Estimated daily token limit for free tier
    private let perKeyTokenLimit = 12500 // Per API key token limit (half of daily for 2 keys)
    
    var canUseToday: Bool {
        // Reset if it's a new day
        if !Calendar.current.isDate(lastResetDate, inSameDayAs: Date()) {
            return true
        }
        return dailyUsage < dailyRequestLimit && dailyTokensUsed < dailyTokenLimit
    }
    
    var remainingDailyUsage: Int {
        // Reset if it's a new day
        if !Calendar.current.isDate(lastResetDate, inSameDayAs: Date()) {
            return dailyRequestLimit
        }
        return max(0, dailyRequestLimit - dailyUsage)
    }
    
    var remainingDailyTokens: Int {
        // Reset if it's a new day
        if !Calendar.current.isDate(lastResetDate, inSameDayAs: Date()) {
            return dailyTokenLimit
        }
        return max(0, dailyTokenLimit - dailyTokensUsed)
    }
    
    var usagePercentage: Double {
        // Reset if it's a new day
        if !Calendar.current.isDate(lastResetDate, inSameDayAs: Date()) {
            return 0.0
        }
        return Double(dailyUsage) / Double(dailyRequestLimit) * 100.0
    }
    
    var tokenUsagePercentage: Double {
        // Reset if it's a new day
        if !Calendar.current.isDate(lastResetDate, inSameDayAs: Date()) {
            return 0.0
        }
        return Double(dailyTokensUsed) / Double(dailyTokenLimit) * 100.0
    }
    
    mutating func recordUsage(tokensUsed: Int = 0, apiKey: String? = nil) {
        // Reset if it's a new day
        if !Calendar.current.isDate(lastResetDate, inSameDayAs: Date()) {
            dailyUsage = 0
            dailyTokensUsed = 0
            perKeyUsage.removeAll()
            lastResetDate = Date()
        }
        
        dailyUsage += 1
        dailyTokensUsed += tokensUsed
        
        // Track per-key usage
        if let apiKey = apiKey {
            let keyPrefix = getKeyPrefix(apiKey)
            perKeyUsage[keyPrefix, default: 0] += tokensUsed
            
            let keyUsage = perKeyUsage[keyPrefix] ?? 0
            let keyUsagePercent = Double(keyUsage) / Double(perKeyTokenLimit) * 100.0
            
            // Enhanced log with per-key information
            print("📊 Groq Usage - Global: \(dailyUsage)/\(dailyRequestLimit) (\(String(format: "%.1f", usagePercentage))%), Tokens: \(dailyTokensUsed)/\(dailyTokenLimit) (\(String(format: "%.1f", tokenUsagePercentage))%)")
            print("🔑 Key Usage (\(keyPrefix)): \(keyUsage)/\(perKeyTokenLimit) tokens (\(String(format: "%.1f", keyUsagePercent))%)")
            print("⏰ Rate: \(currentHourlyRate)/\(hourlyRequestLimit) requests/hour, Remaining today: \(remainingDailyUsage) requests, \(remainingDailyTokens) tokens")
        } else {
            // Fallback log without per-key info
            print("📊 Groq Usage - Requests: \(dailyUsage)/\(dailyRequestLimit) (\(String(format: "%.1f", usagePercentage))%), Tokens: \(dailyTokensUsed)/\(dailyTokenLimit) (\(String(format: "%.1f", tokenUsagePercentage))%)")
            print("⏰ Remaining today: \(remainingDailyUsage) requests, \(remainingDailyTokens) tokens")
        }
    }
    
    // Get first 8 characters of API key for identification
    private func getKeyPrefix(_ apiKey: String) -> String {
        return String(apiKey.prefix(8))
    }
    
    // Reset daily usage manually
    mutating func resetDaily() {
        dailyUsage = 0
        dailyTokensUsed = 0
        perKeyUsage.removeAll()
        lastResetDate = Date()
    }
    
    // Get usage for specific API key
    func getKeyUsage(_ apiKey: String) -> Int {
        let keyPrefix = getKeyPrefix(apiKey)
        return perKeyUsage[keyPrefix] ?? 0
    }
    
    // Get usage percentage for specific API key
    func getKeyUsagePercentage(_ apiKey: String) -> Double {
        let keyUsage = getKeyUsage(apiKey)
        return Double(keyUsage) / Double(perKeyTokenLimit) * 100.0
    }
    
    // Check if specific API key can be used (hasn't exceeded its limit)
    func canUseKey(_ apiKey: String) -> Bool {
        let keyUsage = getKeyUsage(apiKey)
        return keyUsage < perKeyTokenLimit
    }
    
    // Calculate current hourly request rate (approximate)
    var currentHourlyRate: Int {
        let now = Date()
        let hoursPassedToday = Calendar.current.component(.hour, from: now)
        let minutesPassedInHour = Calendar.current.component(.minute, from: now)
        
        // If it's early in the day, estimate based on current hour
        if hoursPassedToday == 0 {
            return dailyUsage * 60 / max(1, minutesPassedInHour)
        }
        
        // Calculate average requests per hour so far today
        return dailyUsage / max(1, hoursPassedToday)
    }
    
    // Get detailed usage statistics
    var detailedStats: String {
        let requestPercent = String(format: "%.1f", usagePercentage)
        let tokenPercent = String(format: "%.1f", tokenUsagePercentage)
        let hourlyRate = currentHourlyRate
        
        return """
        📊 Daily Usage: \(dailyUsage)/\(dailyRequestLimit) requests (\(requestPercent)%)
        🪙 Token Usage: \(dailyTokensUsed)/\(dailyTokenLimit) tokens (\(tokenPercent)%)
        ⏰ Current Rate: \(hourlyRate)/\(hourlyRequestLimit) requests/hour
        📈 Remaining: \(remainingDailyUsage) requests, \(remainingDailyTokens) tokens
        """
    }
}