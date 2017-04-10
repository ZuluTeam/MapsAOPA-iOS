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
    
    var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            UIView.animate(withDuration: 0.25) { 
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override public var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            if let destination = segue.destination as? MenuViewController {
                self.transitionController?.menuViewController = destination
                destination.viewModel = self.viewModel
                destination.transitioningDelegate = self.transitionController
            }
        }
    }
    
    // MARK: - Actions
}
