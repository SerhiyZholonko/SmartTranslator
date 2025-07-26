//
//  TransliteAppApp.swift
//  TransliteApp
//
//  Created by apple on 06.07.2025.
//

import SwiftUI

@main
struct TransliteAppApp: App {
    @State private var warmupText = ""
    @State private var showLaunchScreen = true
    
    init() {
        // Preload critical services in background
        Task {
            _ = BasicOfflineTranslation.shared
            _ = FlashcardManager.shared
            _ = TranslationHistoryManager.shared
            _ = SmartCacheManager.shared
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunchScreen {
                    EnhancedLaunchScreenView {
                        // Animation completed, show main app
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showLaunchScreen = false
                        }
                    }
                    .transition(.opacity)
                } else {
                    ContentView()
                        .transition(.opacity)
                }
                
                // Hidden TextEditor to warm up the component
                TextEditor(text: $warmupText)
                    .frame(width: 1, height: 1)
                    .opacity(0)
                    .allowsHitTesting(false)
            }
        }
    }
}