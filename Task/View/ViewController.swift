//
//  ViewController.swift
//  Task
//
//  Created by Amitabha Saha on 15/12/21.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initSearchController()
        
        viewModel.fetchImages()
        viewModel.dataSource.bind(listener: { [weak self] value in
            self?.tableView.reloadData()
        })
    }
    
    private func initSearchController() {
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Images"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let details = segue.destination as? DetailsViewController{
            
            if let row = tableView.indexPathForSelectedRow?.row {
                details.viewModel.dataSource.value = viewModel.dataSource.value??[row]
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.value??.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageItemCell", for: indexPath)
        if let model = viewModel.dataSource.value??[indexPath.row] {
            viewModel.setUp(cell: cell, with: model)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetails", sender: nil)
    }
}


extension ViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        viewModel.searchImages(with: searchBar.text ?? "")
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
    }
}
