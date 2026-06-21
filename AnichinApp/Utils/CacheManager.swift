import Foundation
import UIKit

actor CacheManager {
    static let shared = CacheManager()
    
    private let imageCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    
    private init() {
        configureCache()
    }
    
    private func configureCache() {
        imageCache.countLimit = 100
        imageCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    // MARK: - Image Cache
    
    func cacheImage(_ image: UIImage, forKey key: String) {
        imageCache.setObject(image, forKey: key as NSString)
    }
    
    func getImage(forKey key: String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }
    
    func removeImage(forKey key: String) {
        imageCache.removeObject(forKey: key as NSString)
    }
    
    func clearImageCache() {
        imageCache.removeAllObjects()
    }
    
    // MARK: - File Cache
    
    func getCacheDirectory() -> URL {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("AnichinCache", isDirectory: true)
    }
    
    func cacheData(_ data: Data, forKey key: String) throws {
        let cacheDir = getCacheDirectory()
        try fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        
        let fileURL = cacheDir.appendingPathComponent(key)
        try data.write(to: fileURL)
    }
    
    func getData(forKey key: String) -> Data? {
        let cacheDir = getCacheDirectory()
        let fileURL = cacheDir.appendingPathComponent(key)
        return try? Data(contentsOf: fileURL)
    }
    
    func removeData(forKey key: String) {
        let cacheDir = getCacheDirectory()
        let fileURL = cacheDir.appendingPathComponent(key)
        try? fileManager.removeItem(at: fileURL)
    }
    
    func clearFileCache() {
        let cacheDir = getCacheDirectory()
        try? fileManager.removeItem(at: cacheDir)
    }
    
    func getCacheSize() -> Int64 {
        let cacheDir = getCacheDirectory()
        
        guard let enumerator = fileManager.enumerator(at: cacheDir, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            if let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
               let fileSize = resourceValues.fileSize {
                totalSize += Int64(fileSize)
            }
        }
        
        return totalSize
    }
}
