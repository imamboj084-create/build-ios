import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        filter: #Predicate<WatchHistory> { !$0.completed },
        sort: \WatchHistory.watchedAt,
        order: .reverse
    ) private var continueWatching: [WatchHistory]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Hero Section
                    if let hero = viewModel.featured.first {
                        HeroSection(donghua: hero)
                    }
                    
                    // Continue Watching
                    if !continueWatching.isEmpty {
                        SectionView(title: "Lanjut Menonton") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 12) {
                                    ForEach(continueWatching.prefix(10), id: \.id) { history in
                                        ContinueWatchingCard(history: history)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Today's Schedule
                    if !viewModel.todaySchedule.isEmpty {
                        SectionView(title: "Jadwal Hari Ini") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 12) {
                                    ForEach(viewModel.todaySchedule) { donghua in
                                        NavigationLink(value: donghua) {
                                            DonghuaCard(donghua: donghua, size: .medium)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Latest Episodes
                    if !viewModel.latestEpisodes.isEmpty {
                        SectionView(title: "Episode Terbaru") {
                            VStack(spacing: 12) {
                                ForEach(viewModel.latestEpisodes.prefix(5)) { episode in
                                    NavigationLink(value: episode) {
                                        EpisodeCard(episode: episode, thumbnail: episode.thumbnail)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Popular
                    if !viewModel.popular.isEmpty {
                        SectionView(title: "Populer") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 12) {
                                    ForEach(viewModel.popular) { donghua in
                                        NavigationLink(value: donghua) {
                                            DonghuaCard(donghua: donghua, size: .medium)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Featured
                    if viewModel.featured.count > 1 {
                        SectionView(title: "Rekomendasi") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 12) {
                                    ForEach(viewModel.featured.dropFirst()) { donghua in
                                        NavigationLink(value: donghua) {
                                            DonghuaCard(donghua: donghua, size: .large)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .background {
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.1),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            .navigationTitle("Anichin")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refresh()
            }
            .navigationDestination(for: Donghua.self) { donghua in
                DetailView(donghua: donghua)
            }
            .navigationDestination(for: Episode.self) { episode in
                // Navigate to donghua detail first
                if let donghua = viewModel.featured.first(where: { $0.id == episode.donghuaId }) {
                    DetailView(donghua: donghua, selectedEpisode: episode)
                }
            }
        }
        .task {
            if viewModel.featured.isEmpty {
                await viewModel.loadHomePage()
            }
        }
        .overlay {
            if viewModel.isLoading && viewModel.featured.isEmpty {
                LoadingView()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            content
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            GlassCard {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    Text("Memuat...")
                        .font(.headline)
                }
                .padding(32)
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Bookmark.self, WatchHistory.self, DownloadedEpisode.self], inMemory: true)
}
