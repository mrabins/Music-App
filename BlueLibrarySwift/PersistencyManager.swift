//
//  PersistencyManager.swift
//  BlueLibrarySwift
//
//  Created by Mark Rabins on 7/24/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import UIKit

class PersistencyManager: NSObject {
    
    private var albums = [Album]()
    
    override init() {
        // Dummy list of Albums
        
        let album1 = Album(title: "Best of Bowie",
                           artist:  "David Bowie",
                           genre:  "Pop",
                           coverUrl: "http://a4.mzstatic.com/us/r30/Music6/v4/e3/e5/22/e3e522f1-7b50-dc6b-d263-60f35d5e14f7/cover170x170.jpeg",
                           year:  "1992")
        
        let album2 = Album(title: "It's My Life",
                           artist: "No Doubt",
                           genre: "Pop",
                           coverUrl:"https://images-na.ssl-images-amazon.com/images/I/51AMwXvnnrL.jpg",
                           year: "2003")
        
        let album3 = Album(title: "Nothing Like The Sun",
                           artist: "Sting",
                           genre: "Pop",
                           coverUrl: "http://cdn.sting.com/non_secure/images/20110419/discography/nothing_like_the_sun/400.jpg",
                           year: "1999")
        
        let album4 = Album(title: "Staring at the Sun",
                           artist: "U2",
                           genre: "Pop",
                           coverUrl: "http://eil.com/images/main/U2+Staring+At+The+Sun+-+Sealed+82069.jpg",
                           year: "2000")
        
        let album5 = Album(title: "American Pie",
                           artist: "Madonna",
                           genre: "Pop",
                           coverUrl: "http://4.bp.blogspot.com/_ZTkJMTu5-fQ/SXep_a3tV8I/AAAAAAAAARI/om7tPxO42Co/s400/pie.jpg",
                           year: "2000")
        
    albums = [album1, album2, album3, album4, album5]
        
    }
    
    func getAlbums() -> [Album] {
        return albums
    }
    
    func addAlbum(album: Album, index: Int) {
        if (albums.count >= index) {
            albums.insert(album, atIndex: index)
        } else {
            albums.append(album)
        }
    }
    
    func deleteAlbumAtIndex(index: Int) {
        albums.removeAtIndex(index)
    }
    
    func saveImage(image: UIImage, filename: String) {
        let path = NSHomeDirectory().stringByAppendingString("/Documents/\(filename)")
        let data = UIImagePNGRepresentation(image)
        data?.writeToFile(path, atomically: true)
    }
    
    func getImage(filename: String) -> UIImage? {
        var error: NSError?
        let path = NSHomeDirectory().stringByAppendingString("/Documents\(filename)")
        let data: NSData?
        do {
            data = try NSData(contentsOfFile: path, options: .UncachedRead)
        } catch let error1 as NSError {
            error = error1
            data = nil
        }
        if let unwrappedError = error {
            return nil
        } else {
            return UIImage(data: data!)
        }
    }
}