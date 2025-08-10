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
    var lastResetDate: Date = Date()
    
    private let dailyLimit = 10 // Free tier limit
    
    var canUseToday: Bool {
        // Reset if it's a new day
        if !Calendar.current.isDate(lastResetDate, inSameDayAs: Date()) {
            return true
        }
        return dailyUsage < dailyLimit
    }
    
    var remainingDailyUsage: Int {
        // Reset if it's a new day
        if !Calendar.current.isDate(lastResetDate, inSameDayAs: Date()) {
            return dailyLimit
        }
        return max(0, dailyLimit - dailyUsage)
    }
    
    mutating func recordUsage() {
        // Reset if it's a new day
        if !Calendar.current.isDate(lastResetDate, inSameDayAs: Date()) {
            dailyUsage = 0
            lastResetDate = Date()
        }
        
        dailyUsage += 1
    }
}