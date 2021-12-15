//
//  DetailsViewController.swift
//  Task
//
//  Created by Amitabha Saha on 16/12/21.
//

import UIKit
import Kingfisher

class DetailsViewController: UIViewController {
    
    var viewModel = DetailsViewModel()
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let button = UIBarButtonItem(image: UIImage(named: ""), style: .plain, target: self, action: #selector(action))
        self.navigationItem.rightBarButtonItem = button
        
        viewModel.dataSource.bind(listener: { [weak self] imageItem in
            
            self?.titleLabel.text = imageItem??.title
            self?.authorLabel.text = imageItem??.author_fullname
            
            if imageItem??.isFavorite() == false {
                self?.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart")
            } else {
                self?.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
            }
            
            if let imageURL = imageItem??.url {
                let url = URL(string: imageURL)
                self?.image?.kf.indicatorType = .activity
                self?.image?.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "placeholder"),
                    options: [
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                    ])
                {
                    result in
                    self?.image.layoutSubviews()
                }
            }
        })
    }
    
    @objc func action() {
        if viewModel.dataSource.value??.isFavorite() == false {
            self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
            viewModel.dataSource.value??.setFavorite(isFav: true)
        } else {
            self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart")
            viewModel.dataSource.value??.setFavorite(isFav: false)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
