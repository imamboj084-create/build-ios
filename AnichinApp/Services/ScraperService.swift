import Foundation
import SwiftSoup

actor ScraperService {
    static let shared = ScraperService()
    
    private let baseURL = "https://anichin.moe"
    private let networkService = NetworkService.shared
    
    private init() {}
    
    // MARK: - Home Page
    func fetchHomePage() async throws -> HomePageData {
        let html = try await networkService.fetchHTML(from: baseURL)
        let document = try SwiftSoup.parse(html)
        
        let featured = try parseFeaturedDonghua(document)
        let latest = try parseLatestEpisodes(document)
        let popular = try parsePopularDonghua(document)
        let schedule = try parseSchedule(document)
        
        return HomePageData(
            featured: featured,
            latestEpisodes: latest,
            popular: popular,
            schedule: schedule
        )
    }
    
    private func parseFeaturedDonghua(_ document: Document) throws -> [Donghua] {
        var donghuaList: [Donghua] = []
        
        let items = try document.select("div.acak article")
        
        for item in items {
            if let donghua = try? parseDonghuaCard(item) {
                donghuaList.append(donghua)
            }
        }
        
        return donghuaList
    }
    
    private func parseLatestEpisodes(_ document: Document) throws -> [Episode] {
        var episodes: [Episode] = []
        
        let items = try document.select("div.listupd article")
        
        for item in items {
            if let episode = try? parseEpisodeCard(item) {
                episodes.append(episode)
            }
        }
        
        return episodes
    }
    
    private func parsePopularDonghua(_ document: Document) throws -> [Donghua] {
        var donghuaList: [Donghua] = []
        
        let items = try document.select("div.serieslist article")
        
        for item in items {
            if let donghua = try? parseDonghuaCard(item) {
                donghuaList.append(donghua)
            }
        }
        
        return donghuaList
    }
    
    private func parseSchedule(_ document: Document) throws -> [String: [Donghua]] {
        var schedule: [String: [Donghua]] = [:]
        let days = ["Senin", "Selasa", "Rabu", "Kamis", "Jum'at", "Sabtu", "Minggu"]
        
        for day in days {
            schedule[day] = []
        }
        
        // Parse schedule sections
        let sections = try document.select("div.schedule")
        for section in sections {
            if let dayHeader = try? section.select("h2").first()?.text(),
               days.contains(dayHeader) {
                let items = try section.select("article")
                for item in items {
                    if let donghua = try? parseDonghuaCard(item) {
                        schedule[dayHeader, default: []].append(donghua)
                    }
                }
            }
        }
        
        return schedule
    }
    
    // MARK: - Detail Page
    func fetchDonghuaDetail(url: String) async throws -> DonghuaDetail {
        let html = try await networkService.fetchHTML(from: url)
        let document = try SwiftSoup.parse(html)
        
        let donghua = try parseDonghuaDetailInfo(document, url: url)
        let episodes = try parseEpisodeList(document, donghuaId: donghua.id, donghuaTitle: donghua.title)
        
        return DonghuaDetail(
            donghua: donghua,
            episodes: episodes,
            streamingServers: [],
            relatedDonghua: []
        )
    }
    
    private func parseDonghuaDetailInfo(_ document: Document, url: String) throws -> Donghua {
        let title = try document.select("h1.entry-title").first()?.text() ?? "Unknown"
        let imageUrl = try document.select("div.thumb img").first()?.attr("src") ?? ""
        let synopsis = try document.select("div.entry-content p").first()?.text()
        
        var genres: [String] = []
        let genreElements = try document.select("div.genxed a")
        for genre in genreElements {
            genres.append(try genre.text())
        }
        
        let ratingText = try document.select("div.rating strong").first()?.text() ?? "0"
        let rating = Double(ratingText)
        
        let statusText = try document.select("div.info-content .spe span:contains(Status)").first()?.parent()?.text() ?? ""
        let status = parseStatus(from: statusText)
        
        let typeText = try document.select("div.info-content .spe span:contains(Type)").first()?.parent()?.text() ?? ""
        let type = parseType(from: typeText)
        
        let id = url.components(separatedBy: "/").filter { !$0.isEmpty }.last ?? UUID().uuidString
        
        return Donghua(
            id: id,
            title: title,
            alternativeTitle: nil,
            imageUrl: imageUrl,
            detailUrl: url,
            rating: rating,
            status: status,
            type: type,
            synopsis: synopsis,
            genres: genres,
            releaseDay: nil,
            studio: nil,
            totalEpisodes: nil
        )
    }
    
    private func parseEpisodeList(_ document: Document, donghuaId: String, donghuaTitle: String) throws -> [Episode] {
        var episodes: [Episode] = []
        
        let episodeElements = try document.select("div.eplister ul li")
        
        for (index, element) in episodeElements.enumerated() {
            let episodeLink = try element.select("a").first()
            let episodeUrl = try episodeLink?.attr("href") ?? ""
            let episodeTitle = try episodeLink?.select(".epl-title").first()?.text() ?? "Episode \(index + 1)"
            let episodeNum = try episodeLink?.select(".epl-num").first()?.text() ?? "\(index + 1)"
            
            let episode = Episode(
                id: episodeUrl.components(separatedBy: "/").filter { !$0.isEmpty }.last ?? UUID().uuidString,
                episodeNumber: Int(episodeNum.filter { $0.isNumber }) ?? (index + 1),
                title: episodeTitle,
                donghuaId: donghuaId,
                donghuaTitle: donghuaTitle,
                url: episodeUrl,
                releaseDate: nil,
                thumbnail: nil
            )
            
            episodes.append(episode)
        }
        
        return episodes.reversed()
    }
    
    // MARK: - Episode Streaming Page
    func fetchStreamingSources(episodeUrl: String) async throws -> [StreamingServer] {
        let html = try await networkService.fetchHTML(from: episodeUrl)
        let document = try SwiftSoup.parse(html)
        
        var servers: [StreamingServer] = []
        
        let serverElements = try document.select("select#server option")
        
        for element in serverElements {
            let serverName = try element.text()
            let serverValue = try element.attr("value")
            
            if !serverValue.isEmpty {
                let server = StreamingServer(
                    id: UUID().uuidString,
                    name: serverName,
                    url: serverValue,
                    quality: nil,
                    type: parseServerType(from: serverName)
                )
                servers.append(server)
            }
        }
        
        return servers
    }
    
    // MARK: - Search
    func searchDonghua(query: String, page: Int = 1) async throws -> [Donghua] {
        let searchURL = "\(baseURL)/?s=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&page=\(page)"
        let html = try await networkService.fetchHTML(from: searchURL)
        let document = try SwiftSoup.parse(html)
        
        var results: [Donghua] = []
        let items = try document.select("article.bs")
        
        for item in items {
            if let donghua = try? parseDonghuaCard(item) {
                results.append(donghua)
            }
        }
        
        return results
    }
    
    // MARK: - Browse by Genre/Status
    func browseDonghua(genre: String? = nil, status: DonghuaStatus? = nil, type: DonghuaType? = nil, page: Int = 1) async throws -> [Donghua] {
        var urlComponents = "\(baseURL)/anime/"
        var params: [String] = []
        
        if let genre = genre {
            params.append("genre=\(genre)")
        }
        if let status = status {
            params.append("status=\(status.rawValue.lowercased())")
        }
        if let type = type {
            params.append("type=\(type.rawValue.lowercased())")
        }
        params.append("page=\(page)")
        
        if !params.isEmpty {
            urlComponents += "?" + params.joined(separator: "&")
        }
        
        let html = try await networkService.fetchHTML(from: urlComponents)
        let document = try SwiftSoup.parse(html)
        
        var results: [Donghua] = []
        let items = try document.select("article.bs")
        
        for item in items {
            if let donghua = try? parseDonghuaCard(item) {
                results.append(donghua)
            }
        }
        
        return results
    }
    
    // MARK: - Helpers
    private func parseDonghuaCard(_ element: Element) throws -> Donghua {
        let link = try element.select("a").first()
        let url = try link?.attr("href") ?? ""
        let title = try link?.attr("title") ?? try element.select(".tt").first()?.text() ?? "Unknown"
        let imageUrl = try element.select("img").first()?.attr("src") ?? ""
        
        let ratingText = try element.select(".rating").first()?.text() ?? "0"
        let rating = Double(ratingText.filter { "0123456789.".contains($0) })
        
        let statusText = try element.select(".status").first()?.text() ?? ""
        let status = parseStatus(from: statusText)
        
        let typeText = try element.select(".type").first()?.text() ?? ""
        let type = parseType(from: typeText)
        
        let id = url.components(separatedBy: "/").filter { !$0.isEmpty }.last ?? UUID().uuidString
        
        return Donghua(
            id: id,
            title: title,
            alternativeTitle: nil,
            imageUrl: imageUrl,
            detailUrl: url,
            rating: rating,
            status: status,
            type: type,
            synopsis: nil,
            genres: [],
            releaseDay: nil,
            studio: nil,
            totalEpisodes: nil
        )
    }
    
    private func parseEpisodeCard(_ element: Element) throws -> Episode {
        let link = try element.select("a").first()
        let url = try link?.attr("href") ?? ""
        let title = try link?.attr("title") ?? ""
        
        let episodeText = try element.select(".episode").first()?.text() ?? "1"
        let episodeNumber = Int(episodeText.filter { $0.isNumber }) ?? 1
        
        let donghuaTitle = title.components(separatedBy: "Episode").first?.trimmingCharacters(in: .whitespaces) ?? title
        let donghuaId = url.components(separatedBy: "/").dropLast().last ?? UUID().uuidString
        
        return Episode(
            id: url.components(separatedBy: "/").filter { !$0.isEmpty }.last ?? UUID().uuidString,
            episodeNumber: episodeNumber,
            title: title,
            donghuaId: donghuaId,
            donghuaTitle: donghuaTitle,
            url: url,
            releaseDate: nil,
            thumbnail: try element.select("img").first()?.attr("src")
        )
    }
    
    private func parseStatus(from text: String) -> DonghuaStatus {
        let lowercased = text.lowercased()
        if lowercased.contains("ongoing") {
            return .ongoing
        } else if lowercased.contains("completed") || lowercased.contains("tamat") {
            return .completed
        } else if lowercased.contains("upcoming") {
            return .upcoming
        }
        return .unknown
    }
    
    private func parseType(from text: String) -> DonghuaType {
        let lowercased = text.lowercased()
        if lowercased.contains("movie") {
            return .movie
        } else if lowercased.contains("ona") {
            return .ona
        } else if lowercased.contains("special") {
            return .special
        } else if lowercased.contains("donghua") {
            return .donghua
        }
        return .unknown
    }
    
    private func parseServerType(from name: String) -> StreamingServer.ServerType {
        let lowercased = name.lowercased()
        if lowercased.contains("gdrive") || lowercased.contains("google") {
            return .gdrive
        } else if lowercased.contains("mirror") {
            return .mirrored
        } else if lowercased.contains("direct") {
            return .direct
        }
        return .unknown
    }
}

struct HomePageData {
    let featured: [Donghua]
    let latestEpisodes: [Episode]
    let popular: [Donghua]
    let schedule: [String: [Donghua]]
}
