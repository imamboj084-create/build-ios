import Foundation
import SwiftData

actor DownloadService {
    static let shared = DownloadService()
    
    private let networkService = NetworkService.shared
    private var activeDownloads: [String: Task<Void, Error>] = [:]
    
    private init() {}
    
    func downloadEpisode(
        episode: Episode,
        donghua: Donghua,
        streamingUrl: String,
        quality: String,
        modelContext: ModelContext,
        progressHandler: @escaping (Double) -> Void
    ) async throws -> DownloadedEpisode {
        let downloadId = "\(donghua.id)-\(episode.id)"
        
        // Check if already downloaded
        let descriptor = FetchDescriptor<DownloadedEpisode>(
            predicate: #Predicate { $0.id == downloadId }
        )
        
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        
        // Download file
        let tempURL = try await networkService.downloadFile(from: streamingUrl) { progress in
            progressHandler(progress)
        }
        
        // Move to permanent location
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let downloadsPath = documentsPath.appendingPathComponent("Downloads", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: downloadsPath, withIntermediateDirectories: true)
        
        let fileName = "\(donghua.title.sanitizedForFilename)_E\(episode.episodeNumber).mp4"
        let finalURL = downloadsPath.appendingPathComponent(fileName)
        
        // Remove existing file if any
        try? FileManager.default.removeItem(at: finalURL)
        
        try FileManager.default.moveItem(at: tempURL, to: finalURL)
        
        // Get file size
        let attributes = try FileManager.default.attributesOfItem(atPath: finalURL.path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        
        // Create database entry
        let downloaded = DownloadedEpisode(
            donghuaId: donghua.id,
            donghuaTitle: donghua.title,
            imageUrl: donghua.imageUrl,
            episodeId: episode.id,
            episodeNumber: episode.episodeNumber,
            episodeTitle: episode.title,
            fileUrl: finalURL.path,
            fileSize: fileSize,
            quality: quality
        )
        
        modelContext.insert(downloaded)
        try modelContext.save()
        
        return downloaded
    }
    
    func deleteDownload(downloadId: String, modelContext: ModelContext) throws {
        let descriptor = FetchDescriptor<DownloadedEpisode>(
            predicate: #Predicate { $0.id == downloadId }
        )
        
        guard let downloaded = try? modelContext.fetch(descriptor).first else {
            return
        }
        
        // Delete file
        let fileURL = URL(fileURLWithPath: downloaded.fileUrl)
        try? FileManager.default.removeItem(at: fileURL)
        
        // Delete from database
        modelContext.delete(downloaded)
        try modelContext.save()
    }
    
    func getDownloadedSize() throws -> Int64 {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let downloadsPath = documentsPath.appendingPathComponent("Downloads", isDirectory: true)
        
        guard let enumerator = FileManager.default.enumerator(at: downloadsPath, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let size = attributes?[.size] as? Int64 {
                totalSize += size
            }
        }
        
        return totalSize
    }
}

extension String {
    var sanitizedForFilename: String {
        let invalid = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        return components(separatedBy: invalid).joined(separator: "_")
    }
}
