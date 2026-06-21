import Foundation
import SwiftUI

enum AppConstants {
    static let baseURL = "https://anichin.moe"
    static let appName = "Anichin"
    static let bundleIdentifier = "com.anichin.app"
    
    enum Notifications {
        static let newEpisodeIdentifier = "new-episode"
        static let dailyReminderIdentifier = "daily-reminder"
    }
    
    enum Storage {
        static let maxDownloadSize: Int64 = 10_000_000_000 // 10GB
        static let downloadsFolder = "Downloads"
    }
    
    enum Cache {
        static let imageMemoryCapacity = 50_000_000 // 50MB
        static let imageDiskCapacity = 100_000_000 // 100MB
    }
}

enum AppColor {
    static let background = Color(red: 0.05, green: 0.05, blue: 0.1)
    static let cardBackground = Color.white.opacity(0.1)
    static let accent = Color.blue
    static let success = Color.green
    static let error = Color.red
    static let warning = Color.orange
}

enum AppFont {
    static let largeTitle = Font.system(size: 34, weight: .bold)
    static let title = Font.system(size: 28, weight: .bold)
    static let title2 = Font.system(size: 22, weight: .bold)
    static let headline = Font.system(size: 17, weight: .semibold)
    static let body = Font.system(size: 17, weight: .regular)
    static let callout = Font.system(size: 16, weight: .regular)
    static let subheadline = Font.system(size: 15, weight: .regular)
    static let footnote = Font.system(size: 13, weight: .regular)
    static let caption = Font.system(size: 12, weight: .regular)
    static let caption2 = Font.system(size: 11, weight: .regular)
}

enum Genre: String, CaseIterable {
    case action = "Action"
    case adventure = "Adventure"
    case comedy = "Comedy"
    case drama = "Drama"
    case fantasy = "Fantasy"
    case historical = "Historical"
    case horror = "Horror"
    case martialArts = "Martial Arts"
    case mystery = "Mystery"
    case romance = "Romance"
    case sciFi = "Sci-fi"
    case sliceOfLife = "Slice of Life"
    case sports = "Sports"
    case supernatural = "Supernatural"
    case thriller = "Thriller"
    case cultivation = "Cultivation"
    case urbanFantasy = "Urban Fantasy"
    case xuanhuan = "Xuanhuan"
    case xianxia = "Xianxia"
    case wuxia = "Wuxia"
}
