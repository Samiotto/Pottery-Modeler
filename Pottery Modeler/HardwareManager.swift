//
//  HardwareManager.swift
//  Pottery Modeler
//
//  Created by Sam Gamgee on 3/21/26.
//

import Foundation
import ARKit
import UIKit

/// Manages hardware capability verification for LiDAR, Neural Engine, and Metal
@Observable
final class HardwareManager {
    
    // MARK: - Properties
    
    var isDeviceSupported: Bool = false
    var hasLiDAR: Bool = false
    var hasNeuralEngine: Bool = false
    var hasMetalSupport: Bool = false
    var deviceModel: String = ""
    var unsupportedReason: String = ""
    
    // MARK: - Initialization
    
    init() {
        checkHardwareCapabilities()
    }
    
    // MARK: - Hardware Detection
    
    private func checkHardwareCapabilities() {
        deviceModel = getDeviceModel()
        hasLiDAR = checkLiDARSupport()
        hasNeuralEngine = checkNeuralEngineSupport()
        hasMetalSupport = checkMetalSupport()
        
        isDeviceSupported = hasLiDAR && hasNeuralEngine && hasMetalSupport
        
        if !isDeviceSupported {
            unsupportedReason = buildUnsupportedReason()
        }
    }
    
    private func checkLiDARSupport() -> Bool {
        // Check if ARKit supports scene reconstruction (requires LiDAR)
        guard ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) else {
            return false
        }
        
        return true
    }
    
    private func checkNeuralEngineSupport() -> Bool {
        // Check for A17 Pro, A18 Pro, or M4 and later
        // These chips have the advanced Neural Engine needed for on-device processing
        let identifier = getDeviceIdentifier()
        
        // iPhone 15 Pro/Pro Max (A17 Pro)
        if identifier.contains("iPhone16,1") || identifier.contains("iPhone16,2") {
            return true
        }
        
        // iPhone 16 Pro/Pro Max (A18 Pro)
        if identifier.contains("iPhone17,1") || identifier.contains("iPhone17,2") {
            return true
        }
        
        // iPad Pro M4 (2024 and later)
        if identifier.contains("iPad16,") {
            return true
        }
        
        // For simulator, allow testing
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    private func checkMetalSupport() -> Bool {
        guard let _ = MTLCreateSystemDefaultDevice() else {
            return false
        }
        return true
    }
    
    private func getDeviceIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    private func getDeviceModel() -> String {
        let identifier = getDeviceIdentifier()
        
        // Map known identifiers to friendly names
        switch identifier {
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
        case "iPhone17,1": return "iPhone 16 Pro"
        case "iPhone17,2": return "iPhone 16 Pro Max"
        case let x where x.hasPrefix("iPad16,"): return "iPad Pro (M4)"
        default:
            #if targetEnvironment(simulator)
            return "Simulator"
            #else
            return "Unknown Device"
            #endif
        }
    }
    
    private func buildUnsupportedReason() -> String {
        var reasons: [String] = []
        
        if !hasLiDAR {
            reasons.append("LiDAR sensor required")
        }
        
        if !hasNeuralEngine {
            reasons.append("A17 Pro/A18 Pro or M4 chip required")
        }
        
        if !hasMetalSupport {
            reasons.append("Metal support required")
        }
        
        if reasons.isEmpty {
            return "Unknown compatibility issue"
        }
        
        return reasons.joined(separator: ", ")
    }
    
    // MARK: - Public Interface
    
    var supportMessage: String {
        if isDeviceSupported {
            return "✓ \(deviceModel) is fully supported"
        } else {
            return "⚠️ \(deviceModel): \(unsupportedReason)"
        }
    }
}

// Add Metal import
import Metal
