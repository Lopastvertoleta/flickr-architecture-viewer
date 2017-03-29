//
//  File.swift
//  Flickr Architecture Viewer
//
//  Created by Taras Parkhomenko on 29/03/2017.
//  Copyright © 2017 Taras Parkhomenko. All rights reserved.
//

import Foundation
import NYTPhotoViewer
import SDWebImage

class PresentedPhoto:NSObject, NYTPhoto {
    let image:UIImage?
    var imageData: Data?
    var placeholderImage: UIImage? = #imageLiteral(resourceName: "Placeholder")
    
    var attributedCaptionTitle: NSAttributedString? = NSAttributedString(string: "")
    let attributedCaptionSummary: NSAttributedString? = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.gray])
    let attributedCaptionCredit: NSAttributedString? = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: UIColor.darkGray])
    init(with image:UIImage, data: Data) {
        self.image = image
        self.imageData = data
    }
}
