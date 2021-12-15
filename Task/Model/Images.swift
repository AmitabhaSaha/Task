//
//  Images.swift
//  Task
//
//  Created by Amitabha Saha on 15/12/21.
//

import Foundation

struct Image: Codable {
    
    var id: String
    var subreddit: String
    var title: String
    var thumbnail: String
    var url: String
    var author_fullname: String
    var created_utc: Int
    var is_video: Bool
    
    func getDate() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(created_utc) / 1000)
        return  "\(date)"
    }
    
    func isFavorite() -> Bool {
        return CoreDataManager.manager.getFavoriteStatus(for: self.id)
    }
    
    func setFavorite(isFav: Bool) {
        CoreDataManager.manager.save(image: self, isFav: isFav)
    }
}

struct ImageData: Codable {
    var kind: String
    var data: Image
}

struct ImageList: Codable {
    var after: String
    var children: [ImageData]
}

struct ImageListData: Codable {
    var data: ImageList
    var kind: String
}
