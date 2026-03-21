//
//  Viewer3DView.swift
//  Pottery Modeler
//
//  Created by Sam Gamgee on 3/21/26.
//

import SwiftUI

/// Full-screen 3D Gaussian Splat viewer with Metal rendering
struct Viewer3DView: View {
    let project: ScanProject
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingExportSheet = false
    @State private var isGeneratingAnimation = false
    @State private var showingMetadata = true
    
    var body: some View {
        ZStack {
            // Metal viewport
            InteractiveMetalView(project: project)
                .ignoresSafeArea()
            
            // UI Overlays
            VStack {
                topBar
                
                Spacer()
                
                if showingMetadata {
                    metadataBadge
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Spacer()
                
                actionBar
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .statusBarHidden()
        .sheet(isPresented: $showingExportSheet) {
            ExportOptionsView(project: project)
        }
    }
    
    // MARK: - Subviews
    
    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(ObsidianTheme.textPrimary)
                    .frame(width: 44, height: 44)
                    .glassMaterial()
            }
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.3)) {
                    showingMetadata.toggle()
                }
            } label: {
                Image(systemName: showingMetadata ? "info.circle.fill" : "info.circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(ObsidianTheme.tealAccent)
                    .frame(width: 44, height: 44)
                    .glassMaterial()
            }
        }
    }
    
    private var metadataBadge: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(ObsidianTheme.statusSuccess)
                        .frame(width: 8, height: 8)
                    
                    Text("LIVE RENDERER")
                        .font(ObsidianTheme.manropeFont(size: 11, weight: .bold))
                        .foregroundStyle(ObsidianTheme.textSecondary)
                }
                
                Text(project.title)
                    .font(ObsidianTheme.interFont(size: 16, weight: .semibold))
                    .foregroundStyle(ObsidianTheme.textPrimary)
                
                Divider()
                    .background(ObsidianTheme.textTertiary.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 6) {
                    MetadataRow(
                        label: "Vertices",
                        value: project.vertexCountFormatted
                    )
                    
                    MetadataRow(
                        label: "Algorithm",
                        value: project.algorithm.rawValue
                    )
                    
                    MetadataRow(
                        label: "Points",
                        value: project.pointCountFormatted
                    )
                }
            }
            
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: 300)
        .glassMaterial()
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }
    
    private var actionBar: some View {
        HStack(spacing: 16) {
            ActionButton(
                icon: "camera.fill",
                label: "Capture",
                action: captureImage
            )
            
            ActionButton(
                icon: isGeneratingAnimation ? "hourglass" : "film.fill",
                label: isGeneratingAnimation ? "Generating..." : "Animation",
                action: generateAnimation,
                isDisabled: isGeneratingAnimation
            )
            
            ActionButton(
                icon: "square.and.arrow.up.fill",
                label: "Export",
                action: { showingExportSheet = true }
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .glassMaterial()
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }
    
    // MARK: - Actions
    
    private func captureImage() {
        // TODO: Capture current viewport as image
        print("Capturing image...")
    }
    
    private func generateAnimation() {
        isGeneratingAnimation = true
        
        // Simulate animation generation
        Task {
            try? await Task.sleep(for: .seconds(3))
            isGeneratingAnimation = false
            
            // Add render path to project
            // project.renderPaths.append("animation_\(Date().timeIntervalSince1970).mp4")
        }
    }
}

// MARK: - Metadata Row

struct MetadataRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(ObsidianTheme.manropeFont(size: 12, weight: .medium))
                .foregroundStyle(ObsidianTheme.textTertiary)
            
            Spacer()
            
            Text(value)
                .font(ObsidianTheme.manropeFont(size: 12, weight: .semibold))
                .foregroundStyle(ObsidianTheme.textPrimary)
        }
    }
}

// MARK: - Action Button

struct ActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                
                Text(label)
                    .font(ObsidianTheme.interFont(size: 12, weight: .medium))
            }
            .foregroundStyle(isDisabled ? ObsidianTheme.textTertiary : ObsidianTheme.tealAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .disabled(isDisabled)
    }
}

// MARK: - Export Options

struct ExportOptionsView: View {
    let project: ScanProject
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedFormat: ExportFormat = .usdz
    @State private var includeTextures = true
    @State private var optimizeForAR = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ObsidianTheme.base.ignoresSafeArea()
                
                Form {
                    Section {
                        Picker("Format", selection: $selectedFormat) {
                            ForEach(ExportFormat.allCases, id: \.self) { format in
                                Text(format.rawValue).tag(format)
                            }
                        }
                        
                        Toggle("Include Textures", isOn: $includeTextures)
                        Toggle("Optimize for AR", isOn: $optimizeForAR)
                    }
                    
                    Section {
                        Button {
                            exportModel()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Export Model")
                                    .font(ObsidianTheme.interFont(size: 17, weight: .semibold))
                                Spacer()
                            }
                        }
                        .foregroundStyle(ObsidianTheme.tealAccent)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Export Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(ObsidianTheme.textSecondary)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func exportModel() {
        // TODO: Implement model export
        print("Exporting as \(selectedFormat.rawValue)...")
        dismiss()
    }
}

enum ExportFormat: String, CaseIterable {
    case usdz = "USDZ"
    case obj = "OBJ"
    case ply = "PLY"
    case gltf = "glTF"
}

#Preview {
    Viewer3DView(project: ScanProject(title: "Preview Model"))
}
