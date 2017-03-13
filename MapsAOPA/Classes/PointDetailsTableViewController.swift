//
//  PointDetailsTableViewController.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 3/13/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import UIKit
import MessageUI

class PointDetailsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    var pointDetailsViewModel : PointDetailsViewModel? {
        didSet {
            self.tableView?.reloadData()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 300
    }

    // MARK: - Table view data source
    
    private func cellIdentifier(for object: PointDetailsViewModel.TableObject) -> String {
        let object = (object.text != nil, object.details != nil, object.value != nil, object.items != nil, object.imageURL != nil)
        switch object {
        case (_, _, _, _, true): return "ImageDetailsCell"
        case (_, _, _, true, _): return "ItemsDetailsCell"
        case (true, true, true, _, _): return "ValueDetailsCell"
        case (true, true, _, _, _): return "DetailedDetailsCell"
        default:
            return "TextDetailsCell"
        }
    }
    
    func object(at indexPath: IndexPath) -> PointDetailsViewModel.TableObject {
        return self.pointDetailsViewModel!.tableViewObjects[indexPath.section].objects[indexPath.row]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.pointDetailsViewModel?.tableViewObjects.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pointDetailsViewModel?.tableViewObjects[section].objects.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = self.object(at: indexPath)
        let identifier = self.cellIdentifier(for: object)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DetailsCell
        
        cell.configure(with: object)
        (cell as! UITableViewCell).setNeedsLayout()
        if nil != object.action {
            (cell as! UITableViewCell).selectionStyle = .gray
        } else {
            (cell as! UITableViewCell).selectionStyle = .none
        }
        return cell as! UITableViewCell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.pointDetailsViewModel!.tableViewObjects[section]
        return section.sectionTitle
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let object = self.object(at: indexPath)
        if let action = object.action {
            switch action {
            case .call: self.call(phone: object.value)
            case .mail: self.mail(to: object.value)
            case .web: self.open(url: object.value)
            }
        }
    }
    
    // MARK: - Private
    
    private func call(phone: String?) {
        if let phone = phone?.replace(" ", with: ""), let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
            let alert = UIAlertController(title: nil, message: "\(phone)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Button_Cancel".localized, style: .cancel))
            alert.addAction(UIAlertAction(title: "Call_Alert_Action".localized, style: .default, handler: { _ in
                UIApplication.shared.openURL(url)
            }))
            self.present(alert, animated: true)
        }
    }
    
    private func mail(to email: String?) {
        guard let email = email else {
            return
        }
        if MFMailComposeViewController.canSendMail()
        {
            let controller = MFMailComposeViewController()
            controller.setToRecipients([ email ])
            controller.mailComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        else
        {
            if let url = URL(string: "mailto:?to=\(email)"), UIApplication.shared.canOpenURL(url)
            {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    private func open(url: String?) {
        if var website = url {
            if(!website.contains("://")) {
                website = "http://" + website
            }
            if let url = URL(string: website), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
    }

}
