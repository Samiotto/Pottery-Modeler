//
//  ScanProject.swift
//  Pottery Modeler
//
//  Created by Sam Gamgee on 3/21/26.
//

import Foundation
import SwiftData
import UIKit

/// Represents a 3D scanning project
@Model
final class ScanProject {
    var id: UUID
    var title: String
    var createdDate: Date
    var modifiedDate: Date
    
    // Scan metadata
    var algorithm: ScanAlgorithm
    var pointCount: Int
    var vertexCount: Int
    var photoCount: Int
    
    // Processing state
    var isProcessed: Bool
    var processingProgress: Double
    
    // Thumbnail
    @Attribute(.externalStorage)
    var thumbnailData: Data?
    
    // Asset references
    var renderPaths: [String] // Paths to rendered images/animations
    
    init(
        title: String,
        algorithm: ScanAlgorithm = .gaussianSplat,
        createdDate: Date = Date()
    ) {
        self.id = UUID()
        self.title = title
        self.createdDate = createdDate
        self.modifiedDate = createdDate
        self.algorithm = algorithm
        self.pointCount = 0
        self.vertexCount = 0
        self.photoCount = 0
        self.isProcessed = false
        self.processingProgress = 0.0
        self.renderPaths = []
    }
    
    var pointCountFormatted: String {
        if pointCount >= 1_000_000 {
            return String(format: "%.1fM points", Double(pointCount) / 1_000_000.0)
        } else if pointCount >= 1_000 {
            return String(format: "%.1fK points", Double(pointCount) / 1_000.0)
        } else {
            return "\(pointCount) points"
        }
    }
    
    var vertexCountFormatted: String {
        if vertexCount >= 1_000_000 {
            return String(format: "%.1fM", Double(vertexCount) / 1_000_000.0)
        } else if vertexCount >= 1_000 {
            return String(format: "%.1fK", Double(vertexCount) / 1_000.0)
        } else {
            return "\(vertexCount)"
        }
    }
}

/// Scan algorithm type
enum ScanAlgorithm: String, Codable, CaseIterable {
    case gaussianSplat = "Gaussian Splat"
    case sparseMesh = "Sparse Mesh"
    case lidarRaw = "LiDAR Raw"
    
    var icon: String {
        switch self {
        case .gaussianSplat: return "circle.hexagongrid.fill"
        case .sparseMesh: return "square.grid.3x3.fill"
        case .lidarRaw: return "dot.scope"
        }
    }
}

/// Scan telemetry during active scanning
@Observable
final class ScanTelemetry {
    var pointsCollected: Int = 0
    var estimatedMeshSize: Int = 0
    var currentAlgorithm: ScanAlgorithm = .gaussianSplat
    var statusMessage: String = "Ready to scan"
    var isScanning: Bool = false
    var scanProgress: Double = 0.0
    
    var pointsCollectedFormatted: String {
        if pointsCollected >= 1_000_000 {
            return String(format: "%.2fM", Double(pointsCollected) / 1_000_000.0)
        } else if pointsCollected >= 1_000 {
            return String(format: "%.1fK", Double(pointsCollected) / 1_000.0)
        } else {
            return "\(pointsCollected)"
        }
    }
    
    var estimatedMeshSizeFormatted: String {
        if estimatedMeshSize >= 1_000_000 {
            return String(format: "%.1fM vertices", Double(estimatedMeshSize) / 1_000_000.0)
        } else if estimatedMeshSize >= 1_000 {
            return String(format: "%.1fK vertices", Double(estimatedMeshSize) / 1_000.0)
        } else {
            return "\(estimatedMeshSize) vertices"
        }
    }
}
