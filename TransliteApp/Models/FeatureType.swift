import SwiftUI

enum FeatureType: String, CaseIterable {
    case textTranslator = "text_translator"
    case voiceChat = "voice_chat"
    case cameraTranslator = "camera_translator"
    case fileTranslator = "file_translator"
    
    var localizedTitle: String {
        switch self {
        case .textTranslator: return "text_translator".localized
        case .voiceChat: return "voice_chat".localized
        case .cameraTranslator: return "camera_translator".localized
        case .fileTranslator: return "file_translator".localized
        }
    }
    
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