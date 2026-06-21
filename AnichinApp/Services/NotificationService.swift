import Foundation
import UserNotifications

actor NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        return granted
    }
    
    func scheduleNewEpisodeNotification(donghua: Donghua, episode: Episode) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Episode Baru! 🎬"
        content.body = "\(donghua.title) - Episode \(episode.episodeNumber) sudah tersedia"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(donghua.id)-\(episode.id)",
            content: content,
            trigger: trigger
        )
        
        try await UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleDailyReleaseReminder(day: String, donghuaList: [Donghua]) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Jadwal Hari Ini - \(day)"
        
        let titles = donghuaList.prefix(3).map { $0.title }.joined(separator: ", ")
        let moreCount = max(0, donghuaList.count - 3)
        
        if moreCount > 0 {
            content.body = "\(titles) dan \(moreCount) lainnya akan rilis hari ini"
        } else {
            content.body = "\(titles) akan rilis hari ini"
        }
        
        content.sound = .default
        
        // Schedule for 9 AM
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily-\(day)",
            content: content,
            trigger: trigger
        )
        
        try await UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification(identifier: String) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() async {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func getBadgeCount() async -> Int {
        return await UNUserNotificationCenter.current().deliveredNotifications().count
    }
    
    func setBadgeCount(_ count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count)
    }
}
