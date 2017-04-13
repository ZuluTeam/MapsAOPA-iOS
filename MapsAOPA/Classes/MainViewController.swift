//
//  MainViewController.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 3/20/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    fileprivate var searchController : UISearchController!
    fileprivate var transitionController : MenuTransitionController?
    
    fileprivate lazy var viewModel : MapViewModel = MapViewModel()
    fileprivate lazy var loadingViewModel : LoadingViewModel = LoadingViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingViewModel.loadAirfields()
        
        self.transitionController = MenuTransitionController(mainViewController: self)
        
        self.definesPresentationContext = true
        let searchResultsController = MainSearchViewController(viewModel: self.viewModel)
        searchResultsController.modalPresentationStyle = .currentContext
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = searchResultsController
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        self.navigationItem.titleView = searchController.searchBar
        
        
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.Menu.rawValue {
            self.searchController.searchBar.resignFirstResponder()
            if let navigationController = segue.destination as? UINavigationController,
                let destination = navigationController.topViewController as? MenuViewController {
                self.transitionController?.menuNavigationController = navigationController
                destination.viewModel = self.loadingViewModel
                navigationController.transitioningDelegate = self.transitionController
            }
        } else if segue.identifier == Segue.Map.rawValue {
            if let destination = segue.destination as? MapViewController {
                destination.viewModel = self.viewModel
                destination.loadingViewModel = self.loadingViewModel
            }
        }
    }
    
    // MARK: - Actions
}
