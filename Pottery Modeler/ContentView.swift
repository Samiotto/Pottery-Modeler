//
//  ContentView.swift
//  Pottery Modeler
//
//  Created by Sam Gamgee on 3/9/26.
//

import SwiftUI
import SwiftData

/// Legacy ContentView - Replaced by GalleryView
/// Kept for reference during migration
struct ContentView: View {
    var body: some View {
        GalleryView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ScanProject.self, inMemory: true)
}
