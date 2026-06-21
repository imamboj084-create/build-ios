import Foundation
import Observation
import SwiftData

@Observable
final class DetailViewModel {
    var donghuaDetail: DonghuaDetail?
    var isBookmarked = false
    var isLoading = false
    var errorMessage: String?
    
    private let scraperService = ScraperService.shared
    
    @MainActor
    func loadDetail(url: String, modelContext: ModelContext) async {
        isLoading = true
        errorMessage = nil
        
        do {
            donghuaDetail = try await scraperService.fetchDonghuaDetail(url: url)
            
            // Check if bookmarked
            if let detail = donghuaDetail {
                let descriptor = FetchDescriptor<Bookmark>(
                    predicate: #Predicate { $0.donghuaId == detail.donghua.id }
                )
                isBookmarked = (try? modelContext.fetch(descriptor).first) != nil
            }
        } catch {
            errorMessage = "Gagal memuat detail: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func toggleBookmark(modelContext: ModelContext) {
        guard let detail = donghuaDetail else { return }
        
        let descriptor = FetchDescriptor<Bookmark>(
            predicate: #Predicate { $0.donghuaId == detail.donghua.id }
        )
        
        if let existing = try? modelContext.fetch(descriptor).first {
            // Remove bookmark
            modelContext.delete(existing)
            isBookmarked = false
        } else {
            // Add bookmark
            let bookmark = Bookmark(
                donghuaId: detail.donghua.id,
                title: detail.donghua.title,
                imageUrl: detail.donghua.imageUrl,
                detailUrl: detail.donghua.detailUrl,
                totalEpisodes: detail.episodes.count
            )
            modelContext.insert(bookmark)
            isBookmarked = true
        }
        
        try? modelContext.save()
    }
    
    func getLastWatchedEpisode(modelContext: ModelContext) -> Episode? {
        guard let detail = donghuaDetail else { return nil }
        
        let descriptor = FetchDescriptor<WatchHistory>(
            predicate: #Predicate { $0.donghuaId == detail.donghua.id },
            sortBy: [SortDescriptor(\.watchedAt, order: .reverse)]
        )
        
        guard let history = try? modelContext.fetch(descriptor).first else {
            return nil
        }
        
        return detail.episodes.first { $0.episodeNumber == history.episodeNumber }
    }
    
    func getNextEpisode(after episode: Episode) -> Episode? {
        guard let detail = donghuaDetail else { return nil }
        return detail.episodes.first { $0.episodeNumber == episode.episodeNumber + 1 }
    }
}
