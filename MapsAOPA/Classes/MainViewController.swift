//
//  MainViewController.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 3/20/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet var mapContainerView : UIView!
    @IBOutlet var menuContainerView : UIView!
    
    fileprivate weak var mapViewController : MapViewController? {
        didSet {
            mapViewController?.viewModel = self.viewModel
        }
    }
    fileprivate weak var menuViewController : MenuViewController? {
        didSet {
            menuViewController?.viewModel = self.viewModel
        }
    }
    
    fileprivate lazy var viewModel : MapViewModel = MapViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.Map.rawValue {
            self.mapViewController = segue.destination as? MapViewController
        } else if segue.identifier == Segue.Menu.rawValue {
            self.menuViewController = segue.destination as? MenuViewController
        }
    }

}
