import Foundation
import AVKit
import Observation
import SwiftData

@Observable
final class PlayerViewModel {
    var streamingSources: [StreamingServer] = []
    var selectedSource: StreamingServer?
    var player: AVPlayer?
    var isLoading = false
    var errorMessage: String?
    
    var currentTime: Double = 0
    var duration: Double = 0
    var isPlaying = false
    
    private let scraperService = ScraperService.shared
    private var timeObserver: Any?
    
    @MainActor
    func loadStreamingSources(episodeUrl: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            streamingSources = try await scraperService.fetchStreamingSources(episodeUrl: episodeUrl)
            
            if let firstSource = streamingSources.first {
                selectedSource = firstSource
            }
        } catch {
            errorMessage = "Gagal memuat server: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func selectSource(_ source: StreamingServer) {
        selectedSource = source
        setupPlayer(url: source.url)
    }
    
    @MainActor
    func setupPlayer(url: String) {
        guard let videoURL = URL(string: url) else {
            errorMessage = "URL tidak valid"
            return
        }
        
        // Clean up existing player
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        player = AVPlayer(url: videoURL)
        
        // Add time observer
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
            
            if let duration = self?.player?.currentItem?.duration.seconds,
               !duration.isNaN {
                self?.duration = duration
            }
        }
        
        // Observe playback status
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.isPlaying = false
        }
    }
    
    @MainActor
    func play() {
        player?.play()
        isPlaying = true
    }
    
    @MainActor
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    @MainActor
    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime)
    }
    
    @MainActor
    func saveWatchHistory(
        episode: Episode,
        donghua: Donghua,
        modelContext: ModelContext
    ) {
        let historyId = "\(donghua.id)-\(episode.id)"
        
        let descriptor = FetchDescriptor<WatchHistory>(
            predicate: #Predicate { $0.id == historyId }
        )
        
        let completed = duration > 0 && currentTime >= duration * 0.9
        
        if let existing = try? modelContext.fetch(descriptor).first {
            existing.currentTime = currentTime
            existing.duration = duration
            existing.completed = completed
            existing.watchedAt = Date()
        } else {
            let history = WatchHistory(
                donghuaId: donghua.id,
                donghuaTitle: donghua.title,
                imageUrl: donghua.imageUrl,
                episodeId: episode.id,
                episodeNumber: episode.episodeNumber,
                episodeTitle: episode.title,
                currentTime: currentTime,
                duration: duration,
                completed: completed
            )
            modelContext.insert(history)
        }
        
        // Update bookmark progress
        let bookmarkDescriptor = FetchDescriptor<Bookmark>(
            predicate: #Predicate { $0.donghuaId == donghua.id }
        )
        
        if let bookmark = try? modelContext.fetch(bookmarkDescriptor).first {
            if let currentEpisode = bookmark.lastEpisodeWatched {
                bookmark.lastEpisodeWatched = max(currentEpisode, episode.episodeNumber)
            } else {
                bookmark.lastEpisodeWatched = episode.episodeNumber
            }
        }
        
        try? modelContext.save()
    }
    
    func loadSavedProgress(episode: Episode, donghua: Donghua, modelContext: ModelContext) -> Double? {
        let historyId = "\(donghua.id)-\(episode.id)"
        
        let descriptor = FetchDescriptor<WatchHistory>(
            predicate: #Predicate { $0.id == historyId }
        )
        
        guard let history = try? modelContext.fetch(descriptor).first,
              !history.completed else {
            return nil
        }
        
        return history.currentTime
    }
    
    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
    }
}
