import SwiftUI
import SwiftData

struct DownloadsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        sort: \DownloadedEpisode.downloadedAt,
        order: .reverse
    ) private var downloads: [DownloadedEpisode]
    
    @State private var totalSize: String = "0 MB"
    @State private var showClearAlert = false
    
    var body: some View {
        NavigationStack {
            Group {
                if downloads.isEmpty {
                    emptyState
                } else {
                    downloadsList
                }
            }
            .background(Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea())
            .navigationTitle("Download")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !downloads.isEmpty {
                        Menu {
                            Button {
                                calculateTotalSize()
                            } label: {
                                Label("Refresh Storage", systemImage: "arrow.clockwise")
                            }
                            
                            Button(role: .destructive) {
                                showClearAlert = true
                            } label: {
                                Label("Hapus Semua", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .task {
                calculateTotalSize()
            }
            .alert("Hapus Semua Download", isPresented: $showClearAlert) {
                Button("Batal", role: .cancel) {}
                Button("Hapus", role: .destructive) {
                    clearAllDownloads()
                }
            } message: {
                Text("Yakin ingin menghapus semua file download?")
            }
        }
    }
    
    private var downloadsList: some View {
        VStack(spacing: 0) {
            // Storage Info
            storageInfo
            
            // Downloads List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(downloads, id: \.id) { download in
                        DownloadCard(download: download)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteDownload(download)
                                } label: {
                                    Label("Hapus", systemImage: "trash")
                                }
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    deleteDownload(download)
                                } label: {
                                    Label("Hapus File", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding()
            }
        }
    }
    
    private var storageInfo: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Download")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(downloads.count) Episode")
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Storage")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(totalSize)
                        .font(.headline)
                }
            }
            .padding()
        }
        .padding()
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Belum ada download")
                .font(.headline)
            
            Text("Episode yang didownload akan muncul di sini")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private func deleteDownload(_ download: DownloadedEpisode) {
        withAnimation {
            do {
                try DownloadService.shared.deleteDownload(downloadId: download.id, modelContext: modelContext)
                calculateTotalSize()
            } catch {
                print("Error deleting download: \(error)")
            }
        }
    }
    
    private func clearAllDownloads() {
        withAnimation {
            for download in downloads {
                try? DownloadService.shared.deleteDownload(downloadId: download.id, modelContext: modelContext)
            }
            calculateTotalSize()
        }
    }
    
    private func calculateTotalSize() {
        Task {
            let size = (try? await DownloadService.shared.getDownloadedSize()) ?? 0
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            totalSize = formatter.string(fromByteCount: size)
        }
    }
}

struct DownloadCard: View {
    let download: DownloadedEpisode
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            AsyncImage(url: URL(string: download.imageUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.gray)
                        }
                }
            }
            .frame(width: 100, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .center) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                    .shadow(radius: 5)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(download.donghuaTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text("Episode \(download.episodeNumber)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 8) {
                    Text(download.quality)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.3))
                        .clipShape(Capsule())
                    
                    Text(download.formattedFileSize)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text(download.downloadedAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "play.circle.fill")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    DownloadsView()
        .modelContainer(for: DownloadedEpisode.self, inMemory: true)
}
