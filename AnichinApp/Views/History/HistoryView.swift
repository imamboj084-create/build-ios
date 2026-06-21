import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        sort: \WatchHistory.watchedAt,
        order: .reverse
    ) private var allHistory: [WatchHistory]
    
    @State private var showClearAlert = false
    
    var body: some View {
        NavigationStack {
            Group {
                if allHistory.isEmpty {
                    emptyState
                } else {
                    historyList
                }
            }
            .background(Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea())
            .navigationTitle("Riwayat Nonton")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !allHistory.isEmpty {
                    Button {
                        showClearAlert = true
                    } label: {
                        Text("Hapus Semua")
                            .foregroundStyle(.red)
                    }
                }
            }
            .alert("Hapus Riwayat", isPresented: $showClearAlert) {
                Button("Batal", role: .cancel) {}
                Button("Hapus", role: .destructive) {
                    clearAllHistory()
                }
            } message: {
                Text("Yakin ingin menghapus semua riwayat nonton?")
            }
        }
    }
    
    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(allHistory) { history in
                    HistoryCard(history: history)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteHistory(history)
                            } label: {
                                Label("Hapus", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteHistory(history)
                            } label: {
                                Label("Hapus", systemImage: "trash")
                            }
                        }
                }
            }
            .padding()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Belum ada riwayat")
                .font(.headline)
            
            Text("Riwayat nonton akan muncul di sini")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private func deleteHistory(_ history: WatchHistory) {
        withAnimation {
            modelContext.delete(history)
            try? modelContext.save()
        }
    }
    
    private func clearAllHistory() {
        withAnimation {
            for history in allHistory {
                modelContext.delete(history)
            }
            try? modelContext.save()
        }
    }
}

struct HistoryCard: View {
    let history: WatchHistory
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            AsyncImage(url: URL(string: history.imageUrl)) { phase in
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
            .overlay(alignment: .bottom) {
                if history.progress > 0 {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(.gray.opacity(0.5))
                            
                            Rectangle()
                                .fill(.red)
                                .frame(width: geo.size.width * history.progress)
                        }
                        .frame(height: 3)
                    }
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(history.donghuaTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text("Episode \(history.episodeNumber)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 8) {
                    if history.completed {
                        Label("Selesai", systemImage: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    } else {
                        Text("\(Int(history.progress * 100))%")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    }
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text(history.watchedAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: WatchHistory.self, inMemory: true)
}
