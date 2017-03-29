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
import Alamofire
import NYTPhotoViewer

private let reuseIdentifier = "PhotoCell"

class PhotosCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var notificationToken:NotificationToken?
    var photos:Results<Photo>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.refreshControl = UIRefreshControl()
        collectionView?.refreshControl?.beginRefreshing()
        collectionView?.refreshControl?.addTarget(self, action: #selector(PhotosCollectionViewController.onRefresh), for: .valueChanged)
        
        PhotosNetworking.shared.fetchImages()
        photos = try? Realm().objects(Photo.self).sorted(byKeyPath: "added")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        notificationToken = photos?.addNotificationBlock({ [weak self] (_) in
            self?.collectionView?.refreshControl?.endRefreshing()
            self?.collectionView?.reloadData()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        notificationToken?.stop()
    }
    
    func onRefresh() {
        PhotosNetworking.shared.fetchImages()
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photos = photos else { return 0 }
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        
        cell.photoImageView.contentMode = .scaleAspectFill
        
        let photo = photos![indexPath.row]
        cell.photoImageView.sd_setImage(with:
            URL(string: !NetworkReachabilityManager()!.isReachable && SDWebImageManager.shared().cachedImageExists(for: URL(string: photo.url)) ? photo.url : photo.thumbURL)!,
            placeholderImage: #imageLiteral(resourceName: "Placeholder")
        )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(collectionView.frame.size)
        
        var dimension:CGFloat
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            dimension = UIDevice.current.orientation.isLandscape ?
                (UIScreen.main.bounds.width / 4 - 1)
            :
                (UIScreen.main.bounds.width / 3 - 1)
        } else {
            dimension = UIDevice.current.orientation.isLandscape ?
                (UIScreen.main.bounds.width / 3 - 1)
            :
                (UIScreen.main.bounds.width / 2 - 0.5)
        }

        return CGSize(width: dimension, height: dimension)
    }
    
    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos![indexPath.row]
        let loading = LoadingView.showIn(superView: view)
            SDWebImageManager.shared().downloadImage(with: URL(string: photo.url), options: .retryFailed, progress: { (_, _) in }, completed: { (image, error, type, flag, url) in
                if let image = image {
                    let photoToPresent = PresentedPhoto(with: image, data: UIImagePNGRepresentation(image)!)
                self.present(NYTPhotosViewController(photos: [photoToPresent]), animated: true, completion: nil)
                } else {
                    let noPhotoAlert = UIAlertController(title: "No image available", message: "Sorry, bigger image is not available", preferredStyle: .alert)
                    noPhotoAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(noPhotoAlert , animated: true, completion: nil)
                }
                loading.remove()
                
            })
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let loadDistance:CGFloat = -50;
        let offset:CGFloat = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
        let dimension:CGFloat = scrollView.contentSize.height
        
        if offset > dimension + loadDistance { PhotosNetworking.shared.fetchMoreImages() }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        collectionView?.collectionViewLayout.invalidateLayout()
        
    }
}
