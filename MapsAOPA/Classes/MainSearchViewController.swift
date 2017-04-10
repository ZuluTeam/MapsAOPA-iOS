//
//  MainSearchViewController.swift
//  MapsAOPA
//
//  Created by Konstantin Zyrianov on 04/04/2017.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import UIKit

class MainSearchViewController: UITableViewController, UISearchResultsUpdating {
    var viewModel : MapViewModel
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.foundedPoints.producer.startWithValues { [weak self] points in
            self?.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.foundedPoints.value.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "SearchCell")
        if nil == cell {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SearchCell")
        }
        let pointModel = self.viewModel.foundedPoints.value[indexPath.row]
        cell.textLabel?.text = pointModel.title
        cell.detailTextLabel?.text = pointModel.region
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let pointModel = self.viewModel.foundedPoints.value[indexPath.row]
        self.viewModel.selectedPoint.value = (pointModel, true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Search Results Updating
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        self.viewModel.searchPoints(with: searchText ?? "")
    }
}
