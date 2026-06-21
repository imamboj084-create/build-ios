import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case httpError(statusCode: Int)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "URL tidak valid"
        case .noData:
            return "Tidak ada data"
        case .decodingError:
            return "Gagal memproses data"
        case .networkError(let error):
            return "Error jaringan: \(error.localizedDescription)"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        }
    }
}

actor NetworkService {
    static let shared = NetworkService()
    
    private let session: URLSession
    private let cache = URLCache(memoryCapacity: 50_000_000, diskCapacity: 100_000_000)
    
    private init() {
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.timeoutIntervalForRequest = 30
        config.httpAdditionalHeaders = [
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        ]
        self.session = URLSession(configuration: config)
    }
    
    func fetchHTML(from urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw NetworkError.decodingError
        }
        
        return html
    }
    
    func fetchData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
    
    func downloadFile(from urlString: String, progressHandler: @escaping (Double) -> Void) async throws -> URL {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (asyncBytes, response) = try await session.bytes(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        let totalBytes = httpResponse.expectedContentLength
        var downloadedBytes: Int64 = 0
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        guard let fileHandle = try? FileHandle(forWritingTo: tempURL) else {
            throw NetworkError.noData
        }
        
        for try await byte in asyncBytes {
            let data = Data([byte])
            try fileHandle.write(contentsOf: data)
            downloadedBytes += 1
            
            if totalBytes > 0 {
                let progress = Double(downloadedBytes) / Double(totalBytes)
                progressHandler(progress)
            }
        }
        
        try fileHandle.close()
        return tempURL
    }
}
