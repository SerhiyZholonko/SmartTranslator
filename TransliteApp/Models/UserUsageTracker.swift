import Foundation

// MARK: - User Usage Tracking (separate from API limits)

struct UserUsageTracker: Codable {
    var dailyTranslations: Int = 0
    var lastResetDate: Date = Date()
    
    // User-friendly daily limit for the app (not API limit)
    private let dailyUserLimit = 20 // User can make 20 translations per day
    
    var canTranslateToday: Bool {
        // Reset if it's a new day
        if !Calendar.current.isDate(lastResetDate, inSameDayAs: Date()) {
            return true
        }
        return dailyTranslations < dailyUserLimit
    }
    
    var remainingDailyTranslations: Int {
        // Reset if it's a new day
        if !Calendar.current.isDate(lastResetDate, inSameDayAs: Date()) {
            return dailyUserLimit
        }
        return max(0, dailyUserLimit - dailyTranslations)
    }
    
    var usagePercentage: Double {
        // Reset if it's a new day
        if !Calendar.current.isDate(lastResetDate, inSameDayAs: Date()) {
            return 0.0
        }
        return Double(dailyTranslations) / Double(dailyUserLimit) * 100.0
    }
    
    mutating func recordTranslation() {
        // Reset if it's a new day
        if !Calendar.current.isDate(lastResetDate, inSameDayAs: Date()) {
            dailyTranslations = 0
            lastResetDate = Date()
        }
        
        dailyTranslations += 1
        
        // Log usage
        print("👤 User Usage: \(dailyTranslations)/\(dailyUserLimit) translations (\(String(format: "%.1f", usagePercentage))%), Remaining: \(remainingDailyTranslations)")
    }
    
    // Reset daily usage manually
    mutating func resetDaily() {
        dailyTranslations = 0
        lastResetDate = Date()
    }
    
    // Get status message
    var statusMessage: String {
        if dailyTranslations >= dailyUserLimit {
            return "❌ Денний ліміт вичерпано (\(dailyTranslations)/\(dailyUserLimit))"
        } else {
            let remaining = remainingDailyTranslations
            return "✅ Доступно \(remaining) з \(dailyUserLimit) перекладів"
        }
    }
}