import SwiftUI

enum FeatureType: String, CaseIterable {
    case textTranslator = "Text\nTranslator"
    case voiceChat = "Voice\nChat"
    case cameraTranslator = "Camera\nTranslator"
    case fileTranslator = "File\nTranslator"
    
    var icon: String {
        switch self {
        case .textTranslator: return "fi-sr-text"
        case .voiceChat: return "voice"
        case .cameraTranslator: return "fi-sr-camera"
        case .fileTranslator: return "fi-sr-picture"
        }
    }
    
    var isTextIcon: Bool {
        return self == .textTranslator
    }
    
    var iconBackgroundColor: Color {
        return Color(red: 0.4, green: 0.5, blue: 1.0)
    }
    
    var requiresPremium: Bool {
        switch self {
        case .textTranslator, .voiceChat: return false
        case .cameraTranslator, .fileTranslator: return true
        }
    }
}

extension FeatureType: Identifiable {
    var id: String { rawValue }
}