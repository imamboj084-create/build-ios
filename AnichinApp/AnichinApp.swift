import SwiftUI
import SwiftData

@main
struct AnichinApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Bookmark.self, WatchHistory.self, DownloadedEpisode.self)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .preferredColorScheme(.dark)
        }
    }
}
