import Foundation
import BackgroundTasks

actor BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    private let taskIdentifier = "com.anichin.app.refresh"
    
    private init() {}
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            Task {
                await self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // 1 hour
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) async {
        // Schedule next refresh
        scheduleAppRefresh()
        
        // Create expiration handler
        task.expirationHandler = {
            // Clean up any ongoing tasks
        }
        
        do {
            // Fetch latest episodes
            let scraperService = ScraperService.shared
            let homeData = try await scraperService.fetchHomePage()
            
            // Check for new episodes and send notifications
            for episode in homeData.latestEpisodes.prefix(5) {
                // Send notification logic here
            }
            
            task.setTaskCompleted(success: true)
        } catch {
            task.setTaskCompleted(success: false)
        }
    }
}
