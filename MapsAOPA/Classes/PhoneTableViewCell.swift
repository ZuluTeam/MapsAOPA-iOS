//
//  PhoneTableViewCell.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 6/23/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit

class PhoneTableViewCell: DetailsTableViewCell
{
    @IBOutlet weak var typeLabel : UILabel?
    @IBOutlet weak var phoneLabel : UILabel?
    @IBOutlet weak var nameLabel : UILabel?
    
    override var object : [String:AnyObject]? {
        didSet {
            self.updateObject()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.typeLabel?.text = nil
        self.phoneLabel?.text = nil
        self.nameLabel?.text = nil
        self.nameLabel?.hidden = true
    }
    
    // MARK: - Private
    
    private func updateObject()
    {
        self.typeLabel?.text = self.object?["type"] as? String
        self.phoneLabel?.text = self.object?["value"] as? String
        self.nameLabel?.text = self.object?["fio"] as? String
        self.nameLabel?.hidden = self.nameLabel?.text == nil
    }
    
    // MARK: - Actions
    
    @IBAction func addAction(sender: AnyObject?)
    {
        
    }

    // MARK: - DetailsTableViewCell
    
    override static func action(forObject object: AnyObject) {
        if let phone = (object as? [String:AnyObject])?["value"] as? String
        {
            if let url = NSURL(string: "tel://"+phone)
            {
                if UIApplication.sharedApplication().canOpenURL(url)
                {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        }
    }
    
    override static func cellHeight(forObject object: AnyObject) -> CGFloat
    {
        if ((object as? [String:AnyObject])?["fio"]) != nil
        {
            return 90.0
        }
        return 62.0
    }
}
