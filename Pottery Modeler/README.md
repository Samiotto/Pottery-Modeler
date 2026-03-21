# Pottery Scanner - Professional 3D Gaussian Splatting Suite

A high-performance iOS and iPadOS app for creating professional 3D scans using LiDAR, Neural Engine, and Metal rendering with Gaussian Splatting technology.

## Architecture Overview

This SwiftUI application follows a modular architecture with clear separation of concerns:

### Core Files

1. **ObsidianTheme.swift** - Design system implementation
   - "The Obsidian Lens" design language
   - Dark mode color palette (#131313 base, #c3f5ff teal accent)
   - Glassmorphism effects and glass material modifiers
   - Typography system (Inter and Manrope fonts)

2. **ScanProject.swift** - Data models
   - `ScanProject` - SwiftData model for scan projects
   - `ScanAlgorithm` - Enum for Gaussian Splat, Sparse Mesh, LiDAR Raw
   - `ScanTelemetry` - Observable class for live scanning metrics

3. **HardwareManager.swift** - Device capability verification
   - Checks for LiDAR support (ARKit scene reconstruction)
   - Validates Neural Engine (A17 Pro, A18 Pro, M4+)
   - Verifies Metal support
   - Provides user-friendly error messages

4. **MetalGaussianSplatView.swift** - 3D rendering
   - UIViewRepresentable wrapper for MTKView
   - Metal-based Gaussian Splat renderer placeholder
   - Gesture-based rotation controls
   - Ready for custom Metal shader integration

### Views

#### 1. GalleryView.swift - Main Entry Point
- Procreate-style project grid (2 columns on iPhone, 3 on iPad)
- Top navigation with "New Scan" CTA (teal accent)
- Project cards showing:
  - High-res thumbnails
  - Project title and date
  - Point cloud density (e.g., "2.4M points")
  - Processing status badges
- Empty state with call-to-action
- Navigation to Settings, Import, and Scanner views

#### 2. ScannerView.swift - ARKit/LiDAR Scanner
- Full-screen ARView camera viewport
- Spatial grid overlay using RealityKit
- Top controls:
  - Algorithm selector (segmented control)
  - Close button
- Live telemetry panel (bottom):
  - Points collected
  - Estimated mesh size
  - High-density information display
- Custom shutter button with progress ring
- Status pill: "Move device slowly to fill gaps"
- Save dialog for completed scans

#### 3. ProjectWorkspaceView.swift - The Hub
- Project header with title and metadata
- Processing state:
  - **Unprocessed**: "Process Scan" button with Neural Engine indicator
  - **Processing**: Progress bar with percentage
  - **Processed**: "Open 3D Model" button
- Scan statistics grid:
  - Points, Vertices, Photos, Algorithm
  - Glassmorphic cards with icons
- Asset library:
  - Horizontal scroll of rendered images/animations
  - Placeholder thumbnails with play icons

#### 4. Viewer3DView.swift - 3D Renderer
- Full-screen Metal viewport with InteractiveMetalView
- Floating metadata badge (top-left):
  - "Live Renderer" status indicator
  - Project title
  - Vertex count, algorithm, points
- Floating action bar (bottom):
  - Capture static image
  - Generate turntable animation
  - Export model (USDZ, OBJ, PLY, glTF)
- Gesture controls:
  - Drag to rotate
  - Pinch to zoom (ready for implementation)

### Navigation Flow

```
App Launch
    ↓
Hardware Check
    ↓
GalleryView (Entry Point)
    ├─→ Scanner View (New Scan)
    │       ↓
    │   Save Scan → Back to Gallery
    │
    ├─→ Project Card Tap
    │       ↓
    │   ProjectWorkspaceView
    │       ├─→ Process Scan (if unprocessed)
    │       └─→ Open 3D Model
    │               ↓
    │           Viewer3DView
    │               ├─→ Capture Image
    │               ├─→ Generate Animation
    │               └─→ Export Model
    │
    ├─→ Settings View
    └─→ Import View
```

## Technical Features

### Modern SwiftUI
- Uses `@Observable` macro for state management
- SwiftData for persistent storage
- `@Query` for reactive data fetching
- `@Bindable` for two-way binding with model objects

### Hardware Requirements
- **iPhone**: 15 Pro/Pro Max and later (A17 Pro, A18 Pro)
- **iPad**: iPad Pro M4 and later
- **Required**: LiDAR sensor, Neural Engine, Metal support

### ARKit Integration
- `ARWorldTrackingConfiguration` with scene reconstruction
- LiDAR-powered mesh generation
- Real-time point cloud visualization
- Spatial grid overlay using RealityKit

### Metal Rendering
- Custom MTKView for Gaussian Splat rendering
- 60fps real-time rendering
- 4x MSAA for quality
- Placeholder for custom shader pipeline

### Responsive Design
- Adapts to iPhone and iPad screen sizes
- Uses `horizontalSizeClass` for layout decisions
- Dynamic grid columns (2 on iPhone, 3 on iPad)
- Universal navigation patterns

## Design System: "The Obsidian Lens"

### Color Palette
- **Base**: #131313 (Deep obsidian)
- **Teal Accent**: #c3f5ff (Active states, CTAs)
- **Surface Layers**: #1a1a1a, #232323, #2d2d2d
- **Status Colors**: 
  - Success: #4dffb0
  - Warning: #ffb84d
  - Error: #ff5757

### Typography
- **Primary**: Inter (information density, UI labels)
- **Secondary**: Manrope (rounded, technical data)
- Weights: Regular, Medium, Semibold, Bold

### UI Philosophy
- Procreate-inspired "recessed" interface
- UI is secondary to content/artwork
- Glassmorphism with backdrop blur
- Tonal layering instead of borders
- High-density information design

### Components
- Glass material modifier for panels
- Circular buttons with backdrop blur
- Capsule-shaped CTAs with teal accent
- Progress rings and status pills
- Floating metadata badges

## Next Steps for Implementation

### 1. Metal Shader Development
```swift
// Implement custom Gaussian Splat shaders
// - Vertex shader for point positioning
// - Fragment shader for Gaussian rendering
// - Normal and lighting calculations
```

### 2. ARKit Session Management
```swift
// Enhance ARViewContainer Coordinator
// - Implement ARSessionDelegate
// - Process mesh anchors
// - Extract point cloud data
// - Handle tracking quality
```

### 3. Neural Engine Processing
```swift
// Integrate Core ML for processing
// - Point cloud optimization
// - Mesh reconstruction
// - Texture generation
// - Model compression
```

### 4. Export Pipeline
```swift
// Complete export functionality
// - USDZ generation with Reality Composer Pro
// - OBJ/PLY file writing
// - glTF conversion
// - Share sheet integration
```

### 5. Asset Management
```swift
// Implement render caching
// - Turntable animation generation
// - Thumbnail creation
// - File system management
// - iCloud sync support
```

## Building and Running

### Requirements
- Xcode 15.0+
- iOS 17.0+ deployment target
- Physical device with LiDAR (Simulator will show unsupported device screen)

### Setup
1. Open `Pottery Modeler.xcodeproj`
2. Select your development team
3. Build and run on a supported device

### Testing on Simulator
The app includes simulator support for UI development. Hardware checks will show the unsupported device screen, but you can modify `HardwareManager` to bypass checks during development.

## Code Organization

```
Pottery Modeler/
├── App/
│   ├── Pottery_ModelerApp.swift     # App entry point
│   └── ContentView.swift             # Legacy wrapper
│
├── Design System/
│   └── ObsidianTheme.swift           # Colors, typography, modifiers
│
├── Models/
│   ├── ScanProject.swift             # SwiftData models
│   └── Item.swift                    # Legacy model
│
├── Managers/
│   └── HardwareManager.swift         # Device capability checks
│
├── Views/
│   ├── GalleryView.swift             # Main gallery
│   ├── ScannerView.swift             # AR scanner
│   ├── ProjectWorkspaceView.swift    # Project hub
│   └── Viewer3DView.swift            # 3D viewer
│
└── Rendering/
    └── MetalGaussianSplatView.swift  # Metal renderer
```

## Performance Considerations

- SwiftData automatic persistence
- Lazy loading with LazyVGrid
- External storage for thumbnail data
- Metal 60fps rendering target
- Neural Engine async processing
- Responsive gesture handling

## Accessibility

- VoiceOver labels on all interactive elements
- Semantic color usage (success, warning, error)
- High contrast design with dark mode
- Dynamic type support (consider adding)
- Haptic feedback for key actions (consider adding)

---

**Created**: March 21, 2026  
**Platform**: iOS 17.0+, iPadOS 17.0+  
**Language**: Swift 5.9+  
**Frameworks**: SwiftUI, SwiftData, ARKit, RealityKit, Metal, Core ML
