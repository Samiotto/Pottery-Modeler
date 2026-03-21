//
//  ScannerView.swift
//  Pottery Modeler
//
//  Created by Sam Gamgee on 3/21/26.
//

import SwiftUI
import ARKit
import RealityKit
import SwiftData

/// Full-screen scanner with ARKit/LiDAR integration
struct ScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var telemetry = ScanTelemetry()
    @State private var isScanning = false
    @State private var scanProgress: Double = 0.0
    @State private var showingSaveDialog = false
    @State private var projectTitle = ""
    
    var body: some View {
        ZStack {
            // AR Camera Viewport
            ARViewContainer(telemetry: telemetry, isScanning: $isScanning)
                .ignoresSafeArea()
            
            // UI Overlay
            VStack {
                topBar
                
                Spacer()
                
                VStack(spacing: 20) {
                    telemetryPanel
                    statusPill
                    controlsBar
                }
                .padding(.bottom, 40)
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .alert("Save Scan", isPresented: $showingSaveDialog) {
            TextField("Project Name", text: $projectTitle)
            Button("Cancel", role: .cancel) {
                projectTitle = ""
            }
            Button("Save") {
                saveScan()
            }
        } message: {
            Text("Enter a name for this scan project")
        }
    }
    
    // MARK: - Subviews
    
    private var topBar: some View {
        HStack {
            Button {
                if isScanning {
                    stopScanning()
                }
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(ObsidianTheme.textPrimary)
                    .frame(width: 44, height: 44)
                    .background {
                        Circle()
                            .fill(.ultraThinMaterial)
                    }
            }
            
            Spacer()
            
            // Algorithm Selector
            Picker("Algorithm", selection: $telemetry.currentAlgorithm) {
                ForEach(ScanAlgorithm.allCases, id: \.self) { algorithm in
                    Text(algorithm.rawValue)
                        .tag(algorithm)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 400)
            .glassMaterial()
        }
    }
    
    private var telemetryPanel: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text("POINTS COLLECTED")
                    .font(ObsidianTheme.manropeFont(size: 10, weight: .bold))
                    .foregroundStyle(ObsidianTheme.textTertiary)
                
                Text(telemetry.pointsCollectedFormatted)
                    .font(ObsidianTheme.interFont(size: 24, weight: .bold))
                    .foregroundStyle(ObsidianTheme.tealAccent)
            }
            
            Divider()
                .frame(height: 40)
                .background(ObsidianTheme.textTertiary.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("EST. MESH SIZE")
                    .font(ObsidianTheme.manropeFont(size: 10, weight: .bold))
                    .foregroundStyle(ObsidianTheme.textTertiary)
                
                Text(telemetry.estimatedMeshSizeFormatted)
                    .font(ObsidianTheme.interFont(size: 24, weight: .bold))
                    .foregroundStyle(ObsidianTheme.textSecondary)
            }
            
            Spacer()
        }
        .padding()
        .glassMaterial()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var statusPill: some View {
        Text(telemetry.statusMessage)
            .font(ObsidianTheme.interFont(size: 14, weight: .medium))
            .foregroundStyle(ObsidianTheme.textPrimary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .glassMaterial(tint: ObsidianTheme.tealAccent.opacity(0.1))
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }
    
    private var controlsBar: some View {
        HStack(spacing: 40) {
            // Gallery button
            Button {
                // Open photo library
            } label: {
                Image(systemName: "photo.stack")
                    .font(.system(size: 24))
                    .foregroundStyle(ObsidianTheme.textSecondary)
            }
            
            // Shutter button
            ShutterButton(
                isScanning: $isScanning,
                progress: telemetry.scanProgress
            ) {
                toggleScanning()
            }
            
            // Settings button
            Button {
                // Open scan settings
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 24))
                    .foregroundStyle(ObsidianTheme.textSecondary)
            }
        }
    }
    
    // MARK: - Actions
    
    private func toggleScanning() {
        if isScanning {
            stopScanning()
        } else {
            startScanning()
        }
    }
    
    private func startScanning() {
        isScanning = true
        telemetry.isScanning = true
        telemetry.statusMessage = "Move device slowly to fill gaps"
        
        // Simulate scanning progress
        Task {
            while isScanning {
                try? await Task.sleep(for: .milliseconds(100))
                telemetry.pointsCollected += Int.random(in: 100...500)
                telemetry.estimatedMeshSize = telemetry.pointsCollected / 3
                telemetry.scanProgress = min(telemetry.scanProgress + 0.005, 1.0)
            }
        }
    }
    
    private func stopScanning() {
        isScanning = false
        telemetry.isScanning = false
        telemetry.statusMessage = "Scan complete"
        
        // Show save dialog
        showingSaveDialog = true
    }
    
    private func saveScan() {
        let project = ScanProject(
            title: projectTitle.isEmpty ? "Scan \(Date().formatted(date: .abbreviated, time: .shortened))" : projectTitle,
            algorithm: telemetry.currentAlgorithm
        )
        project.pointCount = telemetry.pointsCollected
        project.photoCount = Int.random(in: 20...50)
        
        modelContext.insert(project)
        try? modelContext.save()
        
        dismiss()
    }
}

// MARK: - Shutter Button

struct ShutterButton: View {
    @Binding var isScanning: Bool
    var progress: Double
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer ring
                Circle()
                    .strokeBorder(ObsidianTheme.textSecondary.opacity(0.3), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(ObsidianTheme.tealAccent, lineWidth: 4)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                // Inner button
                Circle()
                    .fill(isScanning ? ObsidianTheme.statusError : ObsidianTheme.tealAccent)
                    .frame(width: isScanning ? 30 : 64, height: isScanning ? 30 : 64)
                    .animation(.spring(response: 0.3), value: isScanning)
            }
        }
    }
}

// MARK: - ARView Container

struct ARViewContainer: UIViewRepresentable {
    let telemetry: ScanTelemetry
    @Binding var isScanning: Bool
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .mesh
        configuration.planeDetection = [.horizontal, .vertical]
        
        // Check for LiDAR support
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            arView.session.run(configuration)
        }
        
        // Add spatial grid overlay
        context.coordinator.setupGridOverlay(in: arView)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.isScanning = isScanning
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(telemetry: telemetry)
    }
    
    class Coordinator: NSObject {
        let telemetry: ScanTelemetry
        var isScanning: Bool = false
        var gridEntity: ModelEntity?
        
        init(telemetry: ScanTelemetry) {
            self.telemetry = telemetry
        }
        
        func setupGridOverlay(in arView: ARView) {
            // Create a spatial grid overlay
            let gridMesh = MeshResource.generatePlane(width: 5, depth: 5)
            var material = UnlitMaterial()
            material.color = .init(tint: .white.withAlphaComponent(0.1))
            
            gridEntity = ModelEntity(mesh: gridMesh, materials: [material])
            
            let anchor = AnchorEntity(world: [0, 0, -2])
            anchor.addChild(gridEntity!)
            
            arView.scene.addAnchor(anchor)
        }
    }
}

#Preview {
    ScannerView()
        .modelContainer(for: ScanProject.self, inMemory: true)
}
