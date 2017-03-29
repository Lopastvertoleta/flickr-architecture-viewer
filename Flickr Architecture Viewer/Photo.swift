//
//  Photo.swift
//  Flickr Architecture Viewer
//
//  Created by Taras Parkhomenko on 27/03/2017.
//  Copyright © 2017 Taras Parkhomenko. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Photo: Object {
    dynamic var thumbURL = ""
    dynamic var url = ""
    dynamic var added = NSDate()
}
