import Foundation
import SwiftData

@Model
final class WatchHistory {
    @Attribute(.unique) var id: String
    var donghuaId: String
    var donghuaTitle: String
    var imageUrl: String
    var episodeId: String
    var episodeNumber: Int
    var episodeTitle: String
    var watchedAt: Date
    var currentTime: Double
    var duration: Double
    var completed: Bool
    
    init(
        donghuaId: String,
        donghuaTitle: String,
        imageUrl: String,
        episodeId: String,
        episodeNumber: Int,
        episodeTitle: String,
        currentTime: Double = 0,
        duration: Double = 0,
        completed: Bool = false
    ) {
        self.id = "\(donghuaId)-\(episodeId)"
        self.donghuaId = donghuaId
        self.donghuaTitle = donghuaTitle
        self.imageUrl = imageUrl
        self.episodeId = episodeId
        self.episodeNumber = episodeNumber
        self.episodeTitle = episodeTitle
        self.watchedAt = Date()
        self.currentTime = currentTime
        self.duration = duration
        self.completed = completed
    }
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
    
    var formattedProgress: String {
        let minutes = Int(currentTime / 60)
        let totalMinutes = Int(duration / 60)
        return "\(minutes)/\(totalMinutes) min"
    }
}

@Model
final class DownloadedEpisode {
    @Attribute(.unique) var id: String
    var donghuaId: String
    var donghuaTitle: String
    var imageUrl: String
    var episodeId: String
    var episodeNumber: Int
    var episodeTitle: String
    var downloadedAt: Date
    var fileUrl: String
    var fileSize: Int64
    var quality: String
    
    init(
        donghuaId: String,
        donghuaTitle: String,
        imageUrl: String,
        episodeId: String,
        episodeNumber: Int,
        episodeTitle: String,
        fileUrl: String,
        fileSize: Int64,
        quality: String
    ) {
        self.id = "\(donghuaId)-\(episodeId)"
        self.donghuaId = donghuaId
        self.donghuaTitle = donghuaTitle
        self.imageUrl = imageUrl
        self.episodeId = episodeId
        self.episodeNumber = episodeNumber
        self.episodeTitle = episodeTitle
        self.downloadedAt = Date()
        self.fileUrl = fileUrl
        self.fileSize = fileSize
        self.quality = quality
    }
    
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
}
