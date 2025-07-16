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
    
    init() {
        // Preload critical services in background
        Task {
            _ = BasicOfflineTranslation.shared
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                
                // Hidden TextEditor to warm up the component
                TextEditor(text: $warmupText)
                    .frame(width: 1, height: 1)
                    .opacity(0)
                    .allowsHitTesting(false)
            }
        }
    }
}