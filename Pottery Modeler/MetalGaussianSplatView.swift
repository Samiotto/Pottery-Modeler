//
//  MetalGaussianSplatView.swift
//  Pottery Modeler
//
//  Created by Sam Gamgee on 3/21/26.
//

import SwiftUI
import MetalKit

/// SwiftUI wrapper for Metal-based Gaussian Splat rendering
struct MetalGaussianSplatView: UIViewRepresentable {
    let project: ScanProject
    @Binding var rotation: SIMD2<Float>
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.clearColor = MTLClearColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.0)
        mtkView.delegate = context.coordinator
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false
        mtkView.preferredFramesPerSecond = 60
        
        // Enable multisampling for better quality
        mtkView.sampleCount = 4
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.rotation = rotation
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalGaussianSplatView
        var rotation: SIMD2<Float> = .zero
        var device: MTLDevice?
        var commandQueue: MTLCommandQueue?
        var pipelineState: MTLRenderPipelineState?
        
        init(_ parent: MetalGaussianSplatView) {
            self.parent = parent
            super.init()
            setupMetal()
        }
        
        func setupMetal() {
            guard let device = MTLCreateSystemDefaultDevice() else {
                print("Metal is not supported on this device")
                return
            }
            
            self.device = device
            self.commandQueue = device.makeCommandQueue()
            
            // TODO: Load shaders and create pipeline state
            // This is a placeholder for the actual Gaussian Splat renderer
            // In production, you would load custom Metal shaders here
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            // Handle resize
        }
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let descriptor = view.currentRenderPassDescriptor,
                  let commandQueue = commandQueue else {
                return
            }
            
            // Clear the screen
            descriptor.colorAttachments[0].clearColor = MTLClearColor(
                red: 0.07,
                green: 0.07,
                blue: 0.07,
                alpha: 1.0
            )
            
            guard let commandBuffer = commandQueue.makeCommandBuffer(),
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                return
            }
            
            // TODO: Render Gaussian Splat point cloud
            // This is where you would:
            // 1. Set up vertex buffers with point cloud data
            // 2. Apply rotation matrix based on user interaction
            // 3. Render the Gaussian splats with custom shaders
            // 4. Apply post-processing effects
            
            renderEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

/// Interactive Metal viewport with gesture controls
struct InteractiveMetalView: View {
    let project: ScanProject
    @State private var rotation: SIMD2<Float> = .zero
    @State private var lastDragValue: CGSize = .zero
    
    var body: some View {
        MetalGaussianSplatView(project: project, rotation: $rotation)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let delta = CGSize(
                            width: value.translation.width - lastDragValue.width,
                            height: value.translation.height - lastDragValue.height
                        )
                        
                        rotation.x += Float(delta.height) * 0.01
                        rotation.y += Float(delta.width) * 0.01
                        
                        lastDragValue = value.translation
                    }
                    .onEnded { _ in
                        lastDragValue = .zero
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { scale in
                        // TODO: Implement zoom
                    }
            )
    }
}
