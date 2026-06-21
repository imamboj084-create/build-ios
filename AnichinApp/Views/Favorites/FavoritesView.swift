import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        sort: \Bookmark.addedDate,
        order: .reverse
    ) private var bookmarks: [Bookmark]
    
    var body: some View {
        NavigationStack {
            Group {
                if bookmarks.isEmpty {
                    emptyState
                } else {
                    favoritesGrid
                }
            }
            .background(Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea())
            .navigationTitle("Favorit")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Bookmark.self) { bookmark in
                DetailView(
                    donghua: Donghua(
                        id: bookmark.donghuaId,
                        title: bookmark.title,
                        alternativeTitle: nil,
                        imageUrl: bookmark.imageUrl,
                        detailUrl: bookmark.detailUrl,
                        rating: nil,
                        status: .unknown,
                        type: .donghua,
                        synopsis: nil,
                        genres: [],
                        releaseDay: nil,
                        studio: nil,
                        totalEpisodes: bookmark.totalEpisodes
                    )
                )
            }
        }
    }
    
    private var favoritesGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 16
            ) {
                ForEach(bookmarks, id: \.donghuaId) { bookmark in
                    NavigationLink(value: bookmark) {
                        FavoriteCard(bookmark: bookmark)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            deleteBookmark(bookmark)
                        } label: {
                            Label("Hapus dari Favorit", systemImage: "heart.slash")
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Belum ada favorit")
                .font(.headline)
            
            Text("Donghua favorit akan muncul di sini")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private func deleteBookmark(_ bookmark: Bookmark) {
        withAnimation {
            modelContext.delete(bookmark)
            try? modelContext.save()
        }
    }
}

struct FavoriteCard: View {
    let bookmark: Bookmark
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Poster
            AsyncImage(url: URL(string: bookmark.imageUrl)) { phase in
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
            .frame(height: 240)
            .clipped()
            .overlay(alignment: .topTrailing) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .padding(8)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                Text(bookmark.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .frame(height: 40, alignment: .top)
                
                if let progress = bookmark.lastEpisodeWatched,
                   let total = bookmark.totalEpisodes {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(progress)/\(total) Episode")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        ProgressView(value: bookmark.progress)
                            .tint(.blue)
                    }
                }
                
                Text("Ditambahkan \(bookmark.addedDate, style: .relative)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: Bookmark.self, inMemory: true)
}
