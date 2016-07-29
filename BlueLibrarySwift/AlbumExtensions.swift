//
//  AlbumExtensions.swift
//  BlueLibrarySwift
//
//  Created by Mark Rabins on 7/24/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import Foundation

extension Album {
    func ae_tableRepresentation() -> (titles: [String], values: [String]) {
        return(["Artist", "Album", "Genre", "Year"], [artist, title, genre, year])
    }
}
