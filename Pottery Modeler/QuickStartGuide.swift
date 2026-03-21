//
//  QuickStartGuide.swift
//  Pottery Modeler
//
//  Created by Sam Gamgee on 3/21/26.
//

import SwiftUI

/*
 
 QUICK START GUIDE
 =================
 
 Welcome to the Pottery Scanner codebase! This file provides a quick reference
 for understanding and extending the architecture.
 
 
 ## Navigation Flow
 
 1. App Launch → HardwareManager checks device compatibility
 2. GalleryView → Browse existing projects or create new scan
 3. ScannerView → Capture 3D data using LiDAR
 4. ProjectWorkspaceView → Process and manage scan
 5. Viewer3DView → View and export 3D model
 
 
 ## Key Files to Customize
 
 ### Design Customization
 
 File: ObsidianTheme.swift
 
 - Change colors by modifying the hex values
 - Adjust glassMaterial() modifier for blur intensity
 - Customize typography fonts and weights
 
 Example:
 ```swift
 // Change teal accent to purple
 static let tealAccent = Color(hex: "#b794f6")
 ```
 
 
 ### Add New Scan Algorithm
 
 File: ScanProject.swift
 
 1. Add case to ScanAlgorithm enum:
 ```swift
 enum ScanAlgorithm: String, Codable, CaseIterable {
     case gaussianSplat = "Gaussian Splat"
     case sparseMesh = "Sparse Mesh"
     case lidarRaw = "LiDAR Raw"
     case photogrammetry = "Photogrammetry"  // NEW
     
     var icon: String {
         switch self {
         case .gaussianSplat: return "circle.hexagongrid.fill"
         case .sparseMesh: return "square.grid.3x3.fill"
         case .lidarRaw: return "dot.scope"
         case .photogrammetry: return "camera.on.rectangle.fill"  // NEW
         }
     }
 }
 ```
 
 2. Algorithm will automatically appear in ScannerView picker
 
 
 ### Implement Metal Renderer
 
 File: MetalGaussianSplatView.swift
 
 In Coordinator.setupMetal():
 ```swift
 // 1. Create shader library
 let library = device.makeDefaultLibrary()
 let vertexFunction = library?.makeFunction(name: "gaussianSplatVertex")
 let fragmentFunction = library?.makeFunction(name: "gaussianSplatFragment")
 
 // 2. Create pipeline descriptor
 let pipelineDescriptor = MTLRenderPipelineDescriptor()
 pipelineDescriptor.vertexFunction = vertexFunction
 pipelineDescriptor.fragmentFunction = fragmentFunction
 pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
 
 // 3. Create pipeline state
 pipelineState = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
 ```
 
 In Coordinator.draw(in:):
 ```swift
 // 1. Set pipeline state
 renderEncoder.setRenderPipelineState(pipelineState!)
 
 // 2. Set vertex buffers
 renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
 
 // 3. Draw primitives
 renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: pointCount)
 ```
 
 
 ### Add ARKit Processing
 
 File: ScannerView.swift
 
 In ARViewContainer.Coordinator, implement ARSessionDelegate:
 ```swift
 class Coordinator: NSObject, ARSessionDelegate {
     func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
         for anchor in anchors {
             if let meshAnchor = anchor as? ARMeshAnchor {
                 // Extract vertex data
                 let vertices = meshAnchor.geometry.vertices
                 let faces = meshAnchor.geometry.faces
                 
                 // Update telemetry
                 telemetry.pointsCollected += vertices.count
                 
                 // Store mesh data
                 // processMeshData(vertices, faces)
             }
         }
     }
 }
 ```
 
 
 ### Add Export Format
 
 File: Viewer3DView.swift
 
 1. Add case to ExportFormat enum:
 ```swift
 enum ExportFormat: String, CaseIterable {
     case usdz = "USDZ"
     case obj = "OBJ"
     case ply = "PLY"
     case gltf = "glTF"
     case fbx = "FBX"  // NEW
 }
 ```
 
 2. Implement export in exportModel():
 ```swift
 private func exportModel() {
     switch selectedFormat {
     case .usdz:
         // Export USDZ
     case .obj:
         // Export OBJ
     case .fbx:
         // Export FBX (NEW)
         exportAsFBX()
     // ... other cases
     }
 }
 ```
 
 
 ### Create Custom Glass Component
 
 Example custom button with glass effect:
 ```swift
 struct GlassButton: View {
     let title: String
     let icon: String
     let action: () -> Void
     
     var body: some View {
         Button(action: action) {
             HStack(spacing: 8) {
                 Image(systemName: icon)
                 Text(title)
             }
             .font(ObsidianTheme.interFont(size: 16, weight: .semibold))
             .foregroundStyle(ObsidianTheme.tealAccent)
             .padding(.horizontal, 20)
             .padding(.vertical, 12)
             .glassMaterial()
         }
     }
 }
 ```
 
 
 ## Common Tasks
 
 ### Add Sample Data for Testing
 
 In GalleryView preview:
 ```swift
 #Preview {
     let container = try! ModelContainer(
         for: ScanProject.self,
         configurations: ModelConfiguration(isStoredInMemoryOnly: true)
     )
     
     // Add sample projects
     let project1 = ScanProject(title: "Ceramic Vase", algorithm: .gaussianSplat)
     project1.pointCount = 2_400_000
     project1.vertexCount = 1_200_000
     project1.isProcessed = true
     container.mainContext.insert(project1)
     
     let project2 = ScanProject(title: "Clay Bowl", algorithm: .sparseMesh)
     project2.pointCount = 1_800_000
     container.mainContext.insert(project2)
     
     return GalleryView()
         .modelContainer(container)
 }
 ```
 
 
 ### Test Without LiDAR Device
 
 In HardwareManager.swift, add debug override:
 ```swift
 init(debugMode: Bool = false) {
     if debugMode {
         // Override for testing
         isDeviceSupported = true
         hasLiDAR = true
         hasNeuralEngine = true
         hasMetalSupport = true
         deviceModel = "Debug Mode"
     } else {
         checkHardwareCapabilities()
     }
 }
 ```
 
 In App:
 ```swift
 @State private var hardwareManager = HardwareManager(debugMode: true)
 ```
 
 
 ### Add Haptic Feedback
 
 Create a haptic manager:
 ```swift
 import UIKit
 
 class HapticManager {
     static let shared = HapticManager()
     
     private let impact = UIImpactFeedbackGenerator(style: .medium)
     private let selection = UISelectionFeedbackGenerator()
     private let notification = UINotificationFeedbackGenerator()
     
     func impact() {
         impact.impactOccurred()
     }
     
     func selection() {
         selection.selectionChanged()
     }
     
     func success() {
         notification.notificationOccurred(.success)
     }
     
     func error() {
         notification.notificationOccurred(.error)
     }
 }
 ```
 
 Use in buttons:
 ```swift
 Button {
     HapticManager.shared.impact()
     action()
 } label: {
     // ...
 }
 ```
 
 
 ## Architecture Patterns
 
 ### SwiftData Models
 - Use @Model for persistent data
 - Use @Query in views for reactive updates
 - Use @Bindable for two-way binding
 
 ### Observable Objects
 - Use @Observable macro for view models
 - No need for @Published or ObservableObject protocol
 - Automatic SwiftUI dependency tracking
 
 ### View Modifiers
 - Create reusable modifiers in ObsidianTheme.swift
 - Use .modifier() or direct function call
 
 ### Navigation
 - Use NavigationStack for linear flows
 - Use .navigationDestination(item:) for typed navigation
 - Use .sheet() and .fullScreenCover() for modals
 
 
 ## Performance Tips
 
 1. Use LazyVGrid/LazyVStack for long lists
 2. Mark expensive computations with @State private var
 3. Use .task() for async operations
 4. Profile Metal rendering with Xcode Instruments
 5. Use @Attribute(.externalStorage) for large data
 
 
 ## Resources
 
 - ARKit: https://developer.apple.com/arkit/
 - Metal: https://developer.apple.com/metal/
 - SwiftData: https://developer.apple.com/swiftdata/
 - RealityKit: https://developer.apple.com/realitykit/
 
 
 Happy coding! 🎨✨
 
 */

// This file is documentation only - no executable code needed
