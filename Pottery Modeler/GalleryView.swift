//
//  GalleryView.swift
//  Pottery Modeler
//
//  Created by Sam Gamgee on 3/21/26.
//

import SwiftUI
import SwiftData

/// Main entry point: Procreate-style gallery of scan projects
struct GalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScanProject.modifiedDate, order: .reverse) private var projects: [ScanProject]
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var showingScanner = false
    @State private var showingSettings = false
    @State private var showingImport = false
    @State private var selectedProject: ScanProject?
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    private var gridColumns: [GridItem] {
        let columnCount = isIPad ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: columnCount)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                ObsidianTheme.base
                    .ignoresSafeArea()
                
                if projects.isEmpty {
                    emptyStateView
                } else {
                    projectGridView
                }
            }
            .navigationTitle("Projects")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            showingImport = true
                        } label: {
                            Label("Import", systemImage: "square.and.arrow.down")
                                .foregroundStyle(ObsidianTheme.textSecondary)
                        }
                        
                        Button {
                            showingSettings = true
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                                .foregroundStyle(ObsidianTheme.textSecondary)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    newScanButton
                }
            }
            .sheet(isPresented: $showingScanner) {
                ScannerView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingImport) {
                ImportView()
            }
            .navigationDestination(item: $selectedProject) { project in
                ProjectWorkspaceView(project: project)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Subviews
    
    private var newScanButton: some View {
        Button {
            showingScanner = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                Text("New Scan")
                    .font(ObsidianTheme.interFont(size: 17, weight: .semibold))
            }
            .foregroundStyle(ObsidianTheme.tealAccent)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(ObsidianTheme.tealAccent.opacity(0.15))
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "cube.transparent")
                .font(.system(size: 80, weight: .thin))
                .foregroundStyle(ObsidianTheme.textTertiary)
            
            VStack(spacing: 8) {
                Text("No Projects Yet")
                    .font(ObsidianTheme.interFont(size: 24, weight: .semibold))
                    .foregroundStyle(ObsidianTheme.textPrimary)
                
                Text("Create your first 3D scan to get started")
                    .font(ObsidianTheme.interFont(size: 16, weight: .regular))
                    .foregroundStyle(ObsidianTheme.textSecondary)
            }
            
            Button {
                showingScanner = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Start New Scan")
                }
                .font(ObsidianTheme.interFont(size: 17, weight: .semibold))
                .foregroundStyle(.black)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background {
                    Capsule()
                        .fill(ObsidianTheme.tealAccent)
                }
            }
        }
    }
    
    private var projectGridView: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(projects) { project in
                    ProjectCard(project: project)
                        .onTapGesture {
                            selectedProject = project
                        }
                }
            }
            .padding()
        }
    }
}

// MARK: - Project Card

struct ProjectCard: View {
    let project: ScanProject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail
            thumbnailView
            
            // Metadata
            VStack(alignment: .leading, spacing: 6) {
                Text(project.title)
                    .font(ObsidianTheme.interFont(size: 16, weight: .semibold))
                    .foregroundStyle(ObsidianTheme.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(project.createdDate, format: .dateTime.month().day())
                        .font(ObsidianTheme.manropeFont(size: 13, weight: .regular))
                        .foregroundStyle(ObsidianTheme.textSecondary)
                    
                    Circle()
                        .fill(ObsidianTheme.textTertiary)
                        .frame(width: 3, height: 3)
                    
                    Text(project.pointCountFormatted)
                        .font(ObsidianTheme.manropeFont(size: 13, weight: .medium))
                        .foregroundStyle(ObsidianTheme.tealAccent)
                }
                
                if project.isProcessed {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                        Text("Processed")
                            .font(ObsidianTheme.interFont(size: 11, weight: .medium))
                    }
                    .foregroundStyle(ObsidianTheme.statusSuccess)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                        Text("Pending")
                            .font(ObsidianTheme.interFont(size: 11, weight: .medium))
                    }
                    .foregroundStyle(ObsidianTheme.statusWarning)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ObsidianTheme.surface1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: ObsidianTheme.shadowElevated, radius: 8, y: 4)
    }
    
    private var thumbnailView: some View {
        Group {
            if let thumbnailData = project.thumbnailData,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(4/3, contentMode: .fill)
            } else {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ObsidianTheme.surface2,
                                ObsidianTheme.surface3
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(4/3, contentMode: .fill)
                    .overlay {
                        Image(systemName: project.algorithm.icon)
                            .font(.system(size: 40, weight: .ultraLight))
                            .foregroundStyle(ObsidianTheme.textTertiary)
                    }
            }
        }
        .clipped()
    }
}

// MARK: - Placeholder Views

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                ObsidianTheme.base.ignoresSafeArea()
                
                Text("Settings")
                    .font(ObsidianTheme.interFont(size: 20, weight: .medium))
                    .foregroundStyle(ObsidianTheme.textPrimary)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(ObsidianTheme.tealAccent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct ImportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                ObsidianTheme.base.ignoresSafeArea()
                
                Text("Import 3D Model")
                    .font(ObsidianTheme.interFont(size: 20, weight: .medium))
                    .foregroundStyle(ObsidianTheme.textPrimary)
            }
            .navigationTitle("Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(ObsidianTheme.tealAccent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    GalleryView()
        .modelContainer(for: ScanProject.self, inMemory: true)
}
