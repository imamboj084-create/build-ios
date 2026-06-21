import SwiftUI
import SwiftData

struct DetailView: View {
    let donghua: Donghua
    var selectedEpisode: Episode?
    
    @State private var viewModel = DetailViewModel()
    @State private var showPlayer = false
    @State private var episodeToPlay: Episode?
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Image
                heroHeader
                
                // Content
                VStack(alignment: .leading, spacing: 24) {
                    // Title and Actions
                    titleSection
                    
                    // Stats
                    statsSection
                    
                    // Action Buttons
                    actionButtons
                    
                    // Synopsis
                    if let synopsis = viewModel.donghuaDetail?.donghua.synopsis {
                        synopsisSection(synopsis)
                    }
                    
                    // Episodes List
                    if let episodes = viewModel.donghuaDetail?.episodes, !episodes.isEmpty {
                        episodesSection(episodes)
                    }
                }
                .padding()
            }
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDetail(url: donghua.detailUrl, modelContext: modelContext)
            
            if let selected = selectedEpisode {
                episodeToPlay = selected
                showPlayer = true
            }
        }
        .fullScreenCover(isPresented: $showPlayer) {
            if let episode = episodeToPlay,
               let donghuaDetail = viewModel.donghuaDetail {
                PlayerView(
                    episode: episode,
                    donghua: donghuaDetail.donghua,
                    allEpisodes: donghuaDetail.episodes
                )
            }
        }
        .overlay {
            if viewModel.isLoading {
                LoadingView()
            }
        }
    }
    
    private var heroHeader: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: donghua.displayImage) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Rectangle().fill(Color.gray.opacity(0.2))
                }
            }
            .frame(height: 400)
            .clipped()
            
            LinearGradient(
                colors: [.clear, .black],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(height: 400)
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(donghua.displayTitle)
                .font(.title)
                .fontWeight(.bold)
            
            if let alt = donghua.alternativeTitle {
                Text(alt)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: 16) {
            if let rating = donghua.rating {
                statItem(icon: "star.fill", text: String(format: "%.1f", rating), color: .yellow)
            }
            
            statItem(icon: "tv", text: donghua.status.rawValue, color: .green)
            statItem(icon: "film", text: donghua.type.rawValue, color: .blue)
            
            if let total = viewModel.donghuaDetail?.episodes.count {
                statItem(icon: "list.number", text: "\(total) Episode", color: .purple)
            }
        }
    }
    
    private func statItem(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Play/Continue Button
            Button {
                if let lastWatched = viewModel.getLastWatchedEpisode(modelContext: modelContext) {
                    episodeToPlay = lastWatched
                } else if let firstEpisode = viewModel.donghuaDetail?.episodes.first {
                    episodeToPlay = firstEpisode
                }
                showPlayer = true
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text(viewModel.getLastWatchedEpisode(modelContext: modelContext) != nil ? "Lanjutkan" : "Mulai Nonton")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.white)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Bookmark Button
            Button {
                viewModel.toggleBookmark(modelContext: modelContext)
            } label: {
                Image(systemName: viewModel.isBookmarked ? "heart.fill" : "heart")
                    .font(.title3)
                    .frame(width: 50, height: 50)
                    .background(.ultraThinMaterial)
                    .foregroundStyle(viewModel.isBookmarked ? .red : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private func synopsisSection(_ synopsis: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sinopsis")
                .font(.headline)
            
            Text(synopsis)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }
    
    private func episodesSection(_ episodes: [Episode]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Episode (\(episodes.count))")
                .font(.headline)
            
            LazyVStack(spacing: 8) {
                ForEach(episodes) { episode in
                    Button {
                        episodeToPlay = episode
                        showPlayer = true
                    } label: {
                        episodeRow(episode)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private func episodeRow(_ episode: Episode) -> some View {
        HStack {
            // Episode Number Badge
            Text("\(episode.episodeNumber)")
                .font(.headline)
                .fontWeight(.bold)
                .frame(width: 50, height: 50)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Episode \(episode.episodeNumber)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if let progress = getEpisodeProgress(episode) {
                    ProgressView(value: progress)
                        .tint(.red)
                    
                    Text("\(Int(progress * 100))% ditonton")
                        .font(.caption2)
                        .foregroundStyle(.blue)
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
    
    private func getEpisodeProgress(_ episode: Episode) -> Double? {
        let historyId = "\(donghua.id)-\(episode.id)"
        let descriptor = FetchDescriptor<WatchHistory>(
            predicate: #Predicate { $0.id == historyId }
        )
        
        guard let history = try? modelContext.fetch(descriptor).first,
              !history.completed else {
            return nil
        }
        
        return history.progress
    }
}

#Preview {
    NavigationStack {
        DetailView(
            donghua: Donghua(
                id: "btth",
                title: "Battle Through The Heavens Season 5",
                alternativeTitle: "Doupo Cangqiong",
                imageUrl: "",
                detailUrl: "https://anichin.moe/oyen-pertempuran-akhir-sekte-misty-cloud/",
                rating: 9.2,
                status: .ongoing,
                type: .donghua,
                synopsis: "INI ADALAH LANJUTAN DARI DONGHUA OYEN EPISODE 52.",
                genres: ["Action", "Adventure", "Fantasy"],
                releaseDay: "Minggu",
                studio: "Tencent",
                totalEpisodes: 204
            )
        )
    }
    .modelContainer(for: [Bookmark.self, WatchHistory.self, DownloadedEpisode.self], inMemory: true)
}
