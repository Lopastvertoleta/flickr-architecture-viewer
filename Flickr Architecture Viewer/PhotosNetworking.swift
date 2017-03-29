//
//  PhotosNetworking.swift
//  Flickr Architecture Viewer
//
//  Created by Taras Parkhomenko on 27/03/2017.
//  Copyright © 2017 Taras Parkhomenko. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Realm
import RealmSwift
import SDWebImage

class PhotosNetworking {
    private init () {}
    
    private let apiEndpoint = "https://api.flickr.com/services/rest/?method=flickr.photos."
    private let apiKey = "a34fea0febe0337dfce218f05c8c9e52"
    private let realm = try? Realm()
    private let pageSize = 20
    private var page: Int {
        get {
            guard let photos = realm?.objects(Photo.self) else { return 1 }
            return Int(ceil(Double(photos.count / pageSize)))
        }
    }
    private var needMore = true
    
    static let shared = PhotosNetworking()
    
    private func makeRequestUrl(withMethod method: String, page: Int) -> String {
        return "\(apiEndpoint)\(method)&page=\(page)&per_page=\(pageSize)&api_key=\(apiKey)&format=json&nojsoncallback=1&text=architecture"
    }
    
    private func composeImageURLs(withPhoto photo:JSON) -> (String, String)? {
        guard
            let farm = photo["farm"].int,
            let server = photo["server"].string,
            let id = photo["id"].string,
            let secret = photo["secret"].string else { return nil }
        
        let urlString = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)"
        return (
            urlString.appending("_n.jpg"),
            urlString.appending("_h.jpg")
        )
    }
    
    private func parseAndPersist(data: Data?, needPurge: Bool) {
        guard let data = data, let photos = JSON(data)["photos"]["photo"].array, let realm = realm
            else { return }
        do {
            try realm.write {
                if (needPurge) { realm.deleteAll() }
                realm.add(photos.reduce([], { (result, photoJSON) -> [Photo] in
                    guard let urls = self.composeImageURLs(withPhoto: photoJSON)
                        else { return result }
                    let photoURL = URL(string: urls.1)
                    
                    if (!SDWebImageManager.shared().cachedImageExists(for: photoURL)) {
                        SDWebImageManager.shared().downloadImage(with: photoURL, options: .retryFailed, progress: { (_, _) in }) { (_, _, _, _, _) in}
                    }
                    let photo = Photo()
                    photo.thumbURL = urls.0
                    photo.url = urls.1
                    return result + [photo]
                }))
            }
        } catch { print(error) }
    }
    
    func fetchImages(onFinish: @escaping () -> Void) {
        Alamofire.request(makeRequestUrl(withMethod: "search", page: 1)).responseJSON { (response) in
            self.parseAndPersist(data: response.data, needPurge: true)
            onFinish()
        }
    }
    
    func fetchMoreImages() {
        if (needMore) {
            needMore = false
            Alamofire.request(makeRequestUrl(withMethod: "search", page: page + 1)).responseJSON { (response) in
                self.parseAndPersist(data: response.data, needPurge: false)
                self.needMore = true
            }
        }
    }
}
