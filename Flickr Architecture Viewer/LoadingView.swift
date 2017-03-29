//
//  LoadingView.swift
//  Flickr Architecture Viewer
//
//  Created by Taras Parkhomenko on 29/03/2017.
//  Copyright © 2017 Taras Parkhomenko. All rights reserved.
//

import UIKit
class LoadingView: UIView {
    class func showIn(superView: UIView) -> LoadingView {
        let loadingView = LoadingView(frame: superView.bounds)
        
        loadingView.isOpaque = false
        
        let background = UIView(frame: loadingView.frame)
        loadingView.backgroundColor = UIColor(red: CGFloat(0.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(0.5))
        loadingView.addSubview(background)
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        
        indicator.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
        
        indicator.center = superView.center
        
        loadingView.addSubview(indicator)
        
        indicator.startAnimating()
        
        superView.addSubview(loadingView)
        
        let animation = CATransition()
        animation.type = kCATransitionFade
        superView.layer.add(animation, forKey: "layerAnimation")
        return loadingView
    }
    
    func remove() {
        let animation = CATransition()
        animation.type = kCATransitionFade
        superview?.layer.add(animation, forKey: "layerAnimation")

        super.removeFromSuperview()
    }
}
