import Foundation
import Observation

@Observable
final class SearchViewModel {
    var searchQuery = ""
    var searchResults: [Donghua] = []
    var isSearching = false
    var errorMessage: String?
    
    var selectedGenre: String?
    var selectedStatus: DonghuaStatus?
    var selectedType: DonghuaType?
    
    private let scraperService = ScraperService.shared
    private var searchTask: Task<Void, Never>?
    
    @MainActor
    func search() async {
        // Cancel previous search
        searchTask?.cancel()
        
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }
        
        searchTask = Task {
            isSearching = true
            errorMessage = nil
            
            do {
                try await Task.sleep(nanoseconds: 500_000_000) // Debounce 0.5s
                
                if Task.isCancelled { return }
                
                searchResults = try await scraperService.searchDonghua(query: searchQuery)
            } catch {
                if !Task.isCancelled {
                    errorMessage = "Gagal mencari: \(error.localizedDescription)"
                }
            }
            
            isSearching = false
        }
    }
    
    @MainActor
    func browse() async {
        isSearching = true
        errorMessage = nil
        
        do {
            searchResults = try await scraperService.browseDonghua(
                genre: selectedGenre,
                status: selectedStatus,
                type: selectedType
            )
        } catch {
            errorMessage = "Gagal browse: \(error.localizedDescription)"
        }
        
        isSearching = false
    }
    
    @MainActor
    func clearSearch() {
        searchQuery = ""
        searchResults = []
        searchTask?.cancel()
    }
    
    func resetFilters() {
        selectedGenre = nil
        selectedStatus = nil
        selectedType = nil
    }
}
