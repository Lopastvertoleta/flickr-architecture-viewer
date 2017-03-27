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

class PhotosNetworking {
    private init () {}
    
    private let apiEndpoint = "https://api.flickr.com/services/rest/?method=flickr.photos."
    private let apiKey = "a34fea0febe0337dfce218f05c8c9e52"
    private let realm = try? Realm()
    static let shared = PhotosNetworking()
    
    private func makeRequestUrl(withMethod method: String, page: Int) -> String {
        return "\(apiEndpoint)\(method)&page=\(page)&per_page=20&api_key=\(apiKey)&format=json&nojsoncallback=1&text=architecture"
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
    
    private func parseAndPersist(data: Data?) -> Bool {
        guard let data = data, let photos = JSON(data)["photos"]["photo"].array, let realm = realm
            else { return false }
        do {
            try realm.write {
                realm.add(photos.reduce([], { (result, photoJSON) -> [Photo] in
                    guard let urls = self.composeImageURLs(withPhoto: photoJSON)
                        else { return result }
                    let photo = Photo()
                    photo.thumbURL = urls.0
                    photo.url = urls.1
                    return result + [photo]
                }))
            }
            return true
        } catch  {
            return false
        }
    }
    
    func fetchImages() {
        Alamofire.request(makeRequestUrl(withMethod: "search", page: 1)).responseJSON { (response) in
            if self.parseAndPersist(data: response.data) {
                print("success")
            } else {
                print("failure")
            }
        }
    }
}
