//
//  DetailsTableViewController.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 6/23/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit
import Sugar

class DetailsTableViewController: UITableViewController {
    
    var viewModel : DetailsViewModel?
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if !UIInterfaceOrientationIsPortrait(toInterfaceOrientation)
        {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.viewModel?.phoneNumber.producer.startWithValues({ [weak self] phone in
            self?.call(phone: phone)
        })
    }

    // MARK: - Table view data source
    
    func object(at indexPath: IndexPath) -> DetailsCellViewModel? {
        return self.viewModel?.cellViewModels[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.title
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.cellViewModels.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.viewModel?.reuseIdentifier ?? "", for: indexPath) as! DetailsTableViewCell
        cell.viewModel = self.object(at: indexPath)
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.viewModel?.selectAction(with: self.object(at: indexPath))
    }
}
