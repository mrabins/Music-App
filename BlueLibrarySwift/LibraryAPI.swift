//
//  LibraryAPI.swift
//  BlueLibrarySwift
//
//  Created by Mark Rabins on 7/24/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import UIKit

class LibraryAPI: NSObject {
    
    fileprivate let persistencyManager: PersistencyManager
    fileprivate let httpClient: HTTPClient
    fileprivate let isOnline: Bool
    
    override init() {
        persistencyManager = PersistencyManager()
        httpClient = HTTPClient()
        isOnline = false
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LibraryAPI.downloadImage(_:)), name: NSNotification.Name(rawValue: "BLDownloadImageNotification"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    class var sharedInstance: LibraryAPI {
        
        struct Singleton {
            static let instance = LibraryAPI()
        }
            return Singleton.instance
    }
    
    func getAlbums() -> [Album] {
        return persistencyManager.getAlbums()
    }
    
    func addAlbum(_ album: Album, index: Int) {
        persistencyManager.addAlbum(album, index: index)
        if isOnline {
            httpClient.postRequest("/api/addAlbum", body: album.description)
        }
    }
    
    func deleteAlbum(_ index: Int) {
        persistencyManager.deleteAlbumAtIndex(index)
        if isOnline {
            httpClient.postRequest("/api/deleteAlbum", body: "\(index)")
        }
    }
    
    func downloadImage(_ notification: Notification) {
        //1
        let userInfo = (notification as NSNotification).userInfo as! [String: AnyObject]
        let imageView = userInfo["imageView"] as! UIImageView?
        let coverUrl = userInfo["coverUrl"] as! String
        
        //2
        if let imageViewUnWrapped = imageView {
            imageViewUnWrapped.image = persistencyManager.getImage((coverUrl as NSString).lastPathComponent)
            if imageViewUnWrapped.image == nil {
                //3
                DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
                    let downloadedImage = self.httpClient.downloadImage(coverUrl as String)
                    //4
                    DispatchQueue.main.sync(execute: { () -> Void in
                        imageViewUnWrapped.image = downloadedImage
                        self.persistencyManager.saveImage(downloadedImage, filename: (coverUrl as NSString).lastPathComponent)
                    })
                })
            }
        }
    }
    
    func saveAlbums() {
        persistencyManager.saveAlbums()
    }
}
