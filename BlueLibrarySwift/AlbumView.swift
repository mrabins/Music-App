//
//  AlbumView.swift
//  BlueLibrarySwift
//
//  Created by Mark Rabins on 7/23/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import UIKit

class AlbumView: UIView {
    
    fileprivate var coverImage: UIImageView!
    fileprivate var indicator: UIActivityIndicatorView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    init(frame: CGRect, albumCover: String) {
        super.init(frame: frame)
        commonInit()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BLDownloadImageNotification"), object: self, userInfo: ["imageView": coverImage, "coverUrl": albumCover])
    }
    
    func commonInit() {
        backgroundColor = UIColor.black
        coverImage = UIImageView(frame: CGRect(x: 5, y: 5, width: frame.size.width - 10, height: frame.size.height - 10))
        addSubview(coverImage)
        coverImage.addObserver(self, forKeyPath: "image", options: [], context: nil)
        
        indicator = UIActivityIndicatorView()
        indicator.center = center
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.startAnimating()
        addSubview(indicator)
    }
    
    deinit {
        coverImage.removeObserver(self, forKeyPath: "image")
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "image" {
            indicator.stopAnimating()
        }
    }
    
    func highlightAlbum(_ didHighlightView: Bool) {
        if didHighlightView == true {
            backgroundColor = UIColor.white
        } else {
            backgroundColor = UIColor.black
        }
    }
    
    

}
