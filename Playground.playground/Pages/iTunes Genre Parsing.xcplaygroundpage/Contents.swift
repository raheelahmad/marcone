//: [Previous](@previous)
import Foundation

let genresURLString = "http://itunes.apple.com/WebObjects/MZStoreServices.woa/ws/genres"

enum SomeError: Error { case some }

struct SearchedPodcast {
    let title: String
    let feedURL: String
    let imageURL: String?
}

struct Category {
    let name: String
    let id: String
    let podcasts: [SearchedPodcast]
    let sub: [Category]
}

func categoriesFrom(json categoriesJSON: [String: Any]) -> [Category] {
    let result: [Category] = categoriesJSON.flatMap {
        if let name = ($0.value as? [String: Any])?["name"] as? String {
            if let subJSON = ($0.value as? [String: Any])?["subgenres"] as? [String: Any] {
                let sub = categoriesFrom(json: subJSON)
                return Category(name: name, id: $0.key, podcasts: [], sub: sub)
            } else {
                return Category(name: name, id: $0.key, podcasts: [], sub: [])
            }
        } else {
            return nil
        }
    }
    return result
}

func fetchCategories() throws -> [Category] {
    let filePath = Bundle.main.path(forResource:"itunes_genres", ofType: "json")
    let contentData = FileManager.default.contents(atPath: filePath!)!

    let json = try JSONSerialization.jsonObject(with: contentData, options: []) as! [String: Any]
    let podcastGenres = json["26"] as! [String: Any]
    let genres = podcastGenres["subgenres"] as! [String: Any]
    return categoriesFrom(json: genres)
}

typealias JSON = [String: Any]

extension Dictionary where Key == String {
    func nestedJSON(key: String)  -> JSON? {
        return self[key] as? JSON
    }
    func nestedArray(key: String)  -> [JSON] {
        return self[key] as? [JSON] ?? []
    }
}

func fetchPodcast(for category: Category) throws -> [SearchedPodcast] {
    let id = category.id
    let categoryURL = URL(string: "https://itunes.apple.com/search?term=podcast&genreId=\(id)&limit=5")!
    let categoriesData = try Data(contentsOf: categoryURL)
    let json = try JSONSerialization.jsonObject(with: categoriesData, options: []) as? [String: Any]
    let podcasts: [SearchedPodcast] = json!.nestedArray(key: "results").flatMap {
        if let title = $0["trackName"] as? String, let feedURL = $0["feedUrl"] as? String {
            let imageURL = ($0["artworkUrl600"] ?? $0["artworkUrl100"] ?? $0["artworkUrl60"] ?? $0["artworkUrl30"]) as? String
            return SearchedPodcast(title: title, feedURL: feedURL, imageURL: imageURL)
        } else {
            return nil
        }
    }
    return podcasts
}

let categories: [Category] = try fetchCategories()
categories.count
let res: [SearchedPodcast] = try categories.map {
    try fetchPodcast(for: $0)
    }.flatMap { $0 }
let empty = res.filter { $0.imageURL == nil }
empty.count


//: [Next](@next)
