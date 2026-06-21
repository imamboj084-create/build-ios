import Foundation

struct Donghua: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let alternativeTitle: String?
    let imageUrl: String
    let detailUrl: String
    let rating: Double?
    let status: DonghuaStatus
    let type: DonghuaType
    let synopsis: String?
    let genres: [String]
    let releaseDay: String?
    let studio: String?
    let totalEpisodes: Int?
    
    var displayTitle: String {
        title
    }
    
    var displayImage: URL? {
        URL(string: imageUrl)
    }
}

enum DonghuaStatus: String, Codable, CaseIterable {
    case ongoing = "Ongoing"
    case completed = "Completed"
    case upcoming = "Upcoming"
    case unknown = "Unknown"
}

enum DonghuaType: String, Codable, CaseIterable {
    case donghua = "Donghua"
    case ona = "ONA"
    case movie = "Movie"
    case special = "Special"
    case unknown = "Unknown"
}

struct Episode: Identifiable, Codable, Hashable {
    let id: String
    let episodeNumber: Int
    let title: String
    let donghuaId: String
    let donghuaTitle: String
    let url: String
    let releaseDate: Date?
    let thumbnail: String?
    
    var displayTitle: String {
        "Episode \(episodeNumber)"
    }
}

struct StreamingServer: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let url: String
    let quality: String?
    let type: ServerType
    
    enum ServerType: String, Codable {
        case direct = "Direct"
        case gdrive = "Google Drive"
        case mirrored = "Mirrored"
        case unknown = "Unknown"
    }
}

struct DonghuaDetail {
    let donghua: Donghua
    let episodes: [Episode]
    let streamingServers: [StreamingServer]
    let relatedDonghua: [Donghua]
}
