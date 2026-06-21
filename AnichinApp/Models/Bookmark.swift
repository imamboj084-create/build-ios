import Foundation
import SwiftData

@Model
final class Bookmark {
    @Attribute(.unique) var donghuaId: String
    var title: String
    var imageUrl: String
    var detailUrl: String
    var addedDate: Date
    var lastEpisodeWatched: Int?
    var totalEpisodes: Int?
    
    init(donghuaId: String, title: String, imageUrl: String, detailUrl: String, lastEpisodeWatched: Int? = nil, totalEpisodes: Int? = nil) {
        self.donghuaId = donghuaId
        self.title = title
        self.imageUrl = imageUrl
        self.detailUrl = detailUrl
        self.addedDate = Date()
        self.lastEpisodeWatched = lastEpisodeWatched
        self.totalEpisodes = totalEpisodes
    }
    
    var progress: Double {
        guard let watched = lastEpisodeWatched,
              let total = totalEpisodes,
              total > 0 else {
            return 0
        }
        return Double(watched) / Double(total)
    }
}
