import SwiftUI
import AVKit
import SwiftData

struct PlayerView: View {
    let episode: Episode
    let donghua: Donghua
    let allEpisodes: [Episode]
    
    @State private var viewModel = PlayerViewModel()
    @State private var showControls = true
    @State private var showServerSelection = false
    @State private var autoHideTask: Task<Void, Never>?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Video Player
            if let player = viewModel.player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showControls.toggle()
                        }
                        scheduleAutoHide()
                    }
            } else {
                LoadingView()
            }
            
            // Controls Overlay
            if showControls {
                VStack(spacing: 0) {
                    // Top Bar
                    topBar
                    
                    Spacer()
                    
                    // Center Controls
                    centerControls
                    
                    Spacer()
                    
                    // Bottom Bar
                    bottomBar
                }
                .transition(.opacity)
            }
            
            // Server Selection Sheet
            if showServerSelection {
                serverSelectionSheet
            }
        }
        .statusBar(hidden: !showControls)
        .persistentSystemOverlays(showControls ? .visible : .hidden)
        .task {
            await viewModel.loadStreamingSources(episodeUrl: episode.url)
            
            // Load saved progress
            if let savedTime = viewModel.loadSavedProgress(
                episode: episode,
                donghua: donghua,
                modelContext: modelContext
            ) {
                viewModel.seek(to: savedTime)
            }
            
            // Auto play
            if let firstSource = viewModel.streamingSources.first {
                await viewModel.selectSource(firstSource)
                viewModel.play()
            }
            
            scheduleAutoHide()
        }
        .onDisappear {
            // Save watch progress
            viewModel.saveWatchHistory(
                episode: episode,
                donghua: donghua,
                modelContext: modelContext
            )
        }
    }
    
    private var topBar: some View {
        HStack {
            // Back Button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(donghua.displayTitle)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("Episode \(episode.episodeNumber)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Server Selection
            Button {
                showServerSelection.toggle()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "server.rack")
                    Text(viewModel.selectedSource?.name ?? "Server")
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.black.opacity(0.7), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var centerControls: some View {
        HStack(spacing: 60) {
            // Previous Episode
            if let prevEpisode = getPreviousEpisode() {
                Button {
                    playEpisode(prevEpisode)
                } label: {
                    Image(systemName: "backward.end.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            
            // Play/Pause
            Button {
                if viewModel.isPlaying {
                    viewModel.pause()
                } else {
                    viewModel.play()
                }
            } label: {
                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                    .frame(width: 80, height: 80)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            // Next Episode
            if let nextEpisode = getNextEpisode() {
                Button {
                    playEpisode(nextEpisode)
                } label: {
                    Image(systemName: "forward.end.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private var bottomBar: some View {
        VStack(spacing: 12) {
            // Progress Slider
            VStack(spacing: 4) {
                Slider(
                    value: Binding(
                        get: { viewModel.currentTime },
                        set: { viewModel.seek(to: $0) }
                    ),
                    in: 0...max(viewModel.duration, 1)
                )
                .tint(.red)
                
                HStack {
                    Text(formatTime(viewModel.currentTime))
                        .font(.caption)
                        .monospacedDigit()
                    
                    Spacer()
                    
                    Text(formatTime(viewModel.duration))
                        .font(.caption)
                        .monospacedDigit()
                }
                .foregroundStyle(.secondary)
            }
            
            // Next Episode Preview
            if let nextEpisode = getNextEpisode(),
               viewModel.duration > 0,
               viewModel.currentTime >= viewModel.duration * 0.9 {
                nextEpisodePreview(nextEpisode)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var serverSelectionSheet: some View {
        VStack(spacing: 0) {
            Spacer()
            
            GlassCard {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Pilih Server")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            showServerSelection = false
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(viewModel.streamingSources) { server in
                                Button {
                                    Task {
                                        await viewModel.selectSource(server)
                                        viewModel.play()
                                        showServerSelection = false
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(server.name)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            Text(server.type.rawValue)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        if viewModel.selectedSource?.id == server.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.green)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(viewModel.selectedSource?.id == server.id ? Color.green.opacity(0.2) : Color.white.opacity(0.1))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxHeight: 300)
                }
                .padding()
            }
            .padding()
        }
        .background(Color.black.opacity(0.5).ignoresSafeArea())
        .onTapGesture {
            showServerSelection = false
        }
    }
    
    private func nextEpisodePreview(_ nextEpisode: Episode) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Selanjutnya")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("Episode \(nextEpisode.episodeNumber)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            Button {
                playEpisode(nextEpisode)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "play.fill")
                    Text("Putar")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.white)
                .foregroundStyle(.black)
                .clipShape(Capsule())
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func playEpisode(_ newEpisode: Episode) {
        // Save current progress
        viewModel.saveWatchHistory(
            episode: episode,
            donghua: donghua,
            modelContext: modelContext
        )
        
        // This would require navigation logic
        // For now, just notify user
    }
    
    private func getPreviousEpisode() -> Episode? {
        allEpisodes.first { $0.episodeNumber == episode.episodeNumber - 1 }
    }
    
    private func getNextEpisode() -> Episode? {
        allEpisodes.first { $0.episodeNumber == episode.episodeNumber + 1 }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN && !seconds.isInfinite else {
            return "00:00"
        }
        
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
    private func scheduleAutoHide() {
        autoHideTask?.cancel()
        
        autoHideTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            
            if !Task.isCancelled && viewModel.isPlaying {
                withAnimation {
                    showControls = false
                }
            }
        }
    }
}

#Preview {
    PlayerView(
        episode: Episode(
            id: "1",
            episodeNumber: 204,
            title: "Episode 204",
            donghuaId: "btth",
            donghuaTitle: "Battle Through The Heavens",
            url: "",
            releaseDate: nil,
            thumbnail: nil
        ),
        donghua: Donghua(
            id: "btth",
            title: "Battle Through The Heavens",
            alternativeTitle: nil,
            imageUrl: "",
            detailUrl: "",
            rating: 9.2,
            status: .ongoing,
            type: .donghua,
            synopsis: nil,
            genres: [],
            releaseDay: nil,
            studio: nil,
            totalEpisodes: nil
        ),
        allEpisodes: []
    )
    .modelContainer(for: [WatchHistory.self], inMemory: true)
}
