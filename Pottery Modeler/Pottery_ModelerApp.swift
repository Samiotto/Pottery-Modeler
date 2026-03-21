//
//  Pottery_ModelerApp.swift
//  Pottery Modeler
//
//  Created by Sam Gamgee on 3/9/26.
//

import SwiftUI
import SwiftData

@main
struct Pottery_ModelerApp: App {
    @State private var hardwareManager = HardwareManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ScanProject.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if hardwareManager.isDeviceSupported {
                GalleryView()
            } else {
                UnsupportedDeviceView(hardwareManager: hardwareManager)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
/// View shown when device doesn't meet hardware requirements
struct UnsupportedDeviceView: View {
    let hardwareManager: HardwareManager
    
    var body: some View {
        ZStack {
            ObsidianTheme.base
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 80, weight: .light))
                    .foregroundStyle(ObsidianTheme.statusWarning)
                
                VStack(spacing: 12) {
                    Text("Device Not Supported")
                        .font(ObsidianTheme.interFont(size: 28, weight: .bold))
                        .foregroundStyle(ObsidianTheme.textPrimary)
                    
                    Text(hardwareManager.supportMessage)
                        .font(ObsidianTheme.interFont(size: 16, weight: .regular))
                        .foregroundStyle(ObsidianTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Required Hardware:")
                        .font(ObsidianTheme.interFont(size: 14, weight: .semibold))
                        .foregroundStyle(ObsidianTheme.textSecondary)
                    
                    RequirementRow(
                        label: "LiDAR Sensor",
                        isMet: hardwareManager.hasLiDAR
                    )
                    
                    RequirementRow(
                        label: "A17 Pro / A18 Pro / M4",
                        isMet: hardwareManager.hasNeuralEngine
                    )
                    
                    RequirementRow(
                        label: "Metal Support",
                        isMet: hardwareManager.hasMetalSupport
                    )
                }
                .padding(20)
                .frame(maxWidth: 400)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(ObsidianTheme.surface1)
                }
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}

struct RequirementRow: View {
    let label: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(isMet ? ObsidianTheme.statusSuccess : ObsidianTheme.statusError)
            
            Text(label)
                .font(ObsidianTheme.interFont(size: 15, weight: .medium))
                .foregroundStyle(ObsidianTheme.textPrimary)
            
            Spacer()
        }
    }
}

