//
//  PhotosCollectionViewController.swift
//  Flickr Architecture Viewer
//
//  Created by Taras Parkhomenko on 27/03/2017.
//  Copyright © 2017 Taras Parkhomenko. All rights reserved.
//

import UIKit
import SDWebImage
import Realm
import RealmSwift

private let reuseIdentifier = "PhotoCell"

class PhotosCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var notificationToken:NotificationToken?
    var photos:Results<Photo>?
    var expanded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PhotosNetworking.shared.fetchImages()
        photos = try? Realm().objects(Photo.self).sorted(byKeyPath: "added")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        notificationToken = photos?.addNotificationBlock({ [weak self] (_) in
            self?.collectionView?.reloadData()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        notificationToken?.stop()
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photos = photos else { return 0 }
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        
        cell.photoImageView.contentMode = expanded ? .scaleAspectFit : .scaleAspectFill
        
        let photo = photos![indexPath.row]
        cell.photoImageView.sd_setImage(with: URL(string: expanded ? photo.url : photo.thumbURL)!, placeholderImage: #imageLiteral(resourceName: "Placeholder"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dimension = UIScreen.main.bounds.width / 2 - 0.5
        if (expanded) { return collectionView.bounds.size }
        return CGSize(width: dimension, height: dimension)
    }
    
    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (self.expanded) {
            self.expanded = false
            (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .vertical
            collectionView.isPagingEnabled = false
            collectionView.layer.backgroundColor = UIColor.white.cgColor
            collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        } else {
            self.expanded = true
            (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
            collectionView.isPagingEnabled = true
            collectionView.layer.backgroundColor = UIColor.black.cgColor
            
            collectionView.scrollToItem(at: indexPath, at: .right, animated: false)
        }
        collectionView.reloadData()
    }
}
