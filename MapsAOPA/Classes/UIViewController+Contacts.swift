//
//  UIViewController+Contacts.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 3/14/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

extension UIViewController : MFMailComposeViewControllerDelegate {
    
    func call(phone: String?) {
        if let phone = phone?.replace(" ", with: ""), let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
            let alert = UIAlertController(title: nil, message: "\(phone)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Button_Cancel".localized, style: .cancel))
            alert.addAction(UIAlertAction(title: "Call_Alert_Action".localized, style: .default, handler: { _ in
                UIApplication.shared.openURL(url)
            }))
            self.present(alert, animated: true)
        }
    }
    
    func mail(to email: String?) {
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
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func open(url: String?) {
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
