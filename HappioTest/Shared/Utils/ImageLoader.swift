//
//  ImageLoader.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import UIKit

protocol ImageLoaderProtocol: Sendable {
    func loadImage(from url: URL) async -> UIImage?
    func cancelLoad(for url: URL) async
    func clearCache() async
}

actor ImageLoader: ImageLoaderProtocol {
    
    static let shared = ImageLoader()
    
    private let cache = NSCache<NSURL, UIImage>()
    private var activeTasks: [URL: Task<UIImage?, Never>] = [:]
    
    init() {
        cache.countLimit = 200
        cache.totalCostLimit = 100 * 1024 * 1024
    }
    
    func loadImage(from url: URL) async -> UIImage? {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached
        }
        
        if let existingTask = activeTasks[url] {
            return await existingTask.value
        }
        
        let task = Task<UIImage?, Never> { [weak self] in
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                guard !Task.isCancelled else { return nil }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    return nil
                }
                
                guard let image = UIImage(data: data) else {
                    return nil
                }
                
                await self?.store(image, for: url, cost: data.count)
                return image
            } catch is CancellationError {
                return nil
            } catch {
                return nil
            }
        }
        
        activeTasks[url] = task
        let result = await task.value
        activeTasks.removeValue(forKey: url)
        
        return result
    }
    
    func cancelLoad(for url: URL) {
        activeTasks[url]?.cancel()
        activeTasks.removeValue(forKey: url)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    private func store(_ image: UIImage, for url: URL, cost: Int) {
        cache.setObject(image, forKey: url as NSURL, cost: cost)
    }
}
