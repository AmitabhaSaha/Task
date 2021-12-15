//
//  HomeViewModel.swift
//  Task
//
//  Created by Amitabha Saha on 15/12/21.
//

import Foundation
import UIKit


class HomeViewModel {
    
    public var dataSource: Dynamic<[Image]?> = Dynamic(nil)
    
    private var images: Dynamic<[Image]>? = Dynamic(nil)
    private var searchResultImages: Dynamic<[Image]>? = Dynamic(nil)
    
    func fetchImages() {
        Repository.getImages { result in
            switch result {
                
                case .success(let images):
                    self.images?.value = images
                    self.dataSource.value = images
                
                case .failure(let error):
                    // handle Error Here
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func searchImages(with title: String) {
        if title.isEmpty {
            self.dataSource.value = self.images?.value
        } else {
            self.searchResultImages?.value = images?.value?.filter({ $0.title.lowercased().contains(title.lowercased())})
            self.dataSource.value = searchResultImages?.value
        }
    }
    
    func setUp( cell: UITableViewCell, with model: Image) {
        
        cell.textLabel?.text = model.title
        cell.textLabel?.numberOfLines = -1
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.detailTextLabel?.text = model.getDate()
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
        
        let url = URL(string: model.thumbnail)
        cell.imageView?.kf.indicatorType = .activity
        cell.imageView?.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            cell.layoutSubviews()
        }
    }
}
