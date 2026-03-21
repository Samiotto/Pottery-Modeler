//
//  ProjectWorkspaceView.swift
//  Pottery Modeler
//
//  Created by Sam Gamgee on 3/21/26.
//

import SwiftUI
import SwiftData

/// The Hub: Project management and processing center
struct ProjectWorkspaceView: View {
    @Bindable var project: ScanProject
    @Environment(\.modelContext) private var modelContext
    
    @State private var isProcessing = false
    @State private var showingViewer = false
    @State private var editingTitle = false
    @State private var newTitle = ""
    
    var body: some View {
        ZStack {
            ObsidianTheme.base
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Processing State
                    if !project.isProcessed {
                        processingSection
                    } else {
                        viewerAccessSection
                    }
                    
                    // Metadata
                    metadataSection
                    
                    // Asset Library
                    if !project.renderPaths.isEmpty {
                        assetLibrarySection
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        editingTitle = true
                        newTitle = project.title
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        // Delete project
                    } label: {
                        Label("Delete Project", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(ObsidianTheme.textSecondary)
                }
            }
        }
        .alert("Rename Project", isPresented: $editingTitle) {
            TextField("Project Name", text: $newTitle)
            Button("Cancel", role: .cancel) {
                newTitle = ""
            }
            Button("Save") {
                project.title = newTitle
                project.modifiedDate = Date()
            }
        }
        .fullScreenCover(isPresented: $showingViewer) {
            Viewer3DView(project: project)
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(project.title)
                .font(ObsidianTheme.interFont(size: 32, weight: .bold))
                .foregroundStyle(ObsidianTheme.textPrimary)
            
            HStack(spacing: 12) {
                Label {
                    Text(project.algorithm.rawValue)
                } icon: {
                    Image(systemName: project.algorithm.icon)
                }
                .font(ObsidianTheme.manropeFont(size: 14, weight: .medium))
                .foregroundStyle(ObsidianTheme.tealAccent)
                
                Circle()
                    .fill(ObsidianTheme.textTertiary)
                    .frame(width: 4, height: 4)
                
                Text(project.createdDate, format: .dateTime.month().day().year())
                    .font(ObsidianTheme.manropeFont(size: 14, weight: .regular))
                    .foregroundStyle(ObsidianTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var processingSection: some View {
        VStack(spacing: 20) {
            // Status indicator
            VStack(spacing: 12) {
                Image(systemName: "cpu.fill")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(ObsidianTheme.statusWarning)
                
                Text(isProcessing ? "Processing on Neural Engine" : "Ready to Process")
                    .font(ObsidianTheme.interFont(size: 20, weight: .semibold))
                    .foregroundStyle(ObsidianTheme.textPrimary)
                
                if isProcessing {
                    Text("\(Int(project.processingProgress * 100))% Complete")
                        .font(ObsidianTheme.manropeFont(size: 14, weight: .medium))
                        .foregroundStyle(ObsidianTheme.textSecondary)
                }
            }
            .padding(.vertical, 40)
            
            // Progress bar
            if isProcessing {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(ObsidianTheme.surface2)
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [ObsidianTheme.tealAccent, ObsidianTheme.statusSuccess],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * project.processingProgress, height: 8)
                    }
                }
                .frame(height: 8)
            }
            
            // Process button
            Button {
                startProcessing()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: isProcessing ? "hourglass" : "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text(isProcessing ? "Processing..." : "Process Scan")
                        .font(ObsidianTheme.interFont(size: 17, weight: .semibold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isProcessing ? ObsidianTheme.textSecondary : ObsidianTheme.tealAccent)
                }
            }
            .disabled(isProcessing)
        }
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ObsidianTheme.surface1)
        }
    }
    
    private var viewerAccessSection: some View {
        VStack(spacing: 16) {
            // Success badge
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                Text("Processing Complete")
                    .font(ObsidianTheme.interFont(size: 14, weight: .semibold))
            }
            .foregroundStyle(ObsidianTheme.statusSuccess)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(ObsidianTheme.statusSuccess.opacity(0.15))
            }
            
            // Open 3D Model button
            Button {
                showingViewer = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "view.3d")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Open 3D Model")
                        .font(ObsidianTheme.interFont(size: 17, weight: .semibold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(ObsidianTheme.tealAccent)
                }
            }
        }
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ObsidianTheme.surface1)
        }
    }
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Scan Statistics")
                .font(ObsidianTheme.interFont(size: 20, weight: .bold))
                .foregroundStyle(ObsidianTheme.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetadataCard(
                    title: "Points",
                    value: project.pointCountFormatted,
                    icon: "circle.grid.cross.fill"
                )
                
                MetadataCard(
                    title: "Vertices",
                    value: project.vertexCountFormatted,
                    icon: "triangle.fill"
                )
                
                MetadataCard(
                    title: "Photos",
                    value: "\(project.photoCount)",
                    icon: "camera.fill"
                )
                
                MetadataCard(
                    title: "Algorithm",
                    value: project.algorithm.rawValue,
                    icon: project.algorithm.icon
                )
            }
        }
    }
    
    private var assetLibrarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Previous Renders")
                .font(ObsidianTheme.interFont(size: 20, weight: .bold))
                .foregroundStyle(ObsidianTheme.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(project.renderPaths, id: \.self) { path in
                        RenderThumbnail(path: path)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func startProcessing() {
        isProcessing = true
        project.processingProgress = 0.0
        
        // Simulate Neural Engine processing
        Task {
            while project.processingProgress < 1.0 {
                try? await Task.sleep(for: .milliseconds(100))
                project.processingProgress += 0.01
            }
            
            // Complete processing
            project.isProcessed = true
            project.vertexCount = project.pointCount / 2
            project.modifiedDate = Date()
            isProcessing = false
        }
    }
}

// MARK: - Metadata Card

struct MetadataCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                Text(title.uppercased())
                    .font(ObsidianTheme.manropeFont(size: 11, weight: .bold))
            }
            .foregroundStyle(ObsidianTheme.textTertiary)
            
            Text(value)
                .font(ObsidianTheme.interFont(size: 18, weight: .bold))
                .foregroundStyle(ObsidianTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(ObsidianTheme.surface1)
        }
    }
}

// MARK: - Render Thumbnail

struct RenderThumbnail: View {
    let path: String
    
    var body: some View {
        Rectangle()
            .fill(ObsidianTheme.surface2)
            .aspectRatio(16/9, contentMode: .fit)
            .frame(width: 200)
            .overlay {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(ObsidianTheme.tealAccent)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        ProjectWorkspaceView(project: ScanProject(title: "Pottery Vase"))
    }
    .modelContainer(for: ScanProject.self, inMemory: true)
}
