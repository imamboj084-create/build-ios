import Foundation
import Observation

@Observable
final class HomeViewModel {
    var featured: [Donghua] = []
    var latestEpisodes: [Episode] = []
    var popular: [Donghua] = []
    var schedule: [String: [Donghua]] = [:]
    var continueWatching: [WatchHistory] = []
    
    var isLoading = false
    var errorMessage: String?
    
    private let scraperService = ScraperService.shared
    
    @MainActor
    func loadHomePage() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await scraperService.fetchHomePage()
            featured = data.featured
            latestEpisodes = data.latestEpisodes
            popular = data.popular
            schedule = data.schedule
        } catch {
            errorMessage = "Gagal memuat data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func refresh() async {
        await loadHomePage()
    }
    
    var todaySchedule: [Donghua] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "EEEE"
        let today = formatter.string(from: Date())
        
        // Map English to Indonesian day names
        let dayMapping: [String: String] = [
            "Monday": "Senin",
            "Tuesday": "Selasa",
            "Wednesday": "Rabu",
            "Thursday": "Kamis",
            "Friday": "Jum'at",
            "Saturday": "Sabtu",
            "Sunday": "Minggu"
        ]
        
        let indonesianDay = dayMapping[today] ?? today
        return schedule[indonesianDay] ?? []
    }
}
