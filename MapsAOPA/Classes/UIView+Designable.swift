//
//  UIView+Designable.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 2/27/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable
    var borderWidth : CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var cornerRadius : CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = newValue != 0
        }
    }
    
    @IBInspectable
    var borderColor : UIColor? {
        get {
            if let color = self.layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var shadowOffset : CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor : UIColor? {
        get {
            if let color = self.layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            self.layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var shadowRadius : CGFloat {
        get {
            return self.layer.shadowRadius
        }
        set {
            self.layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity : CGFloat {
        get {
            return CGFloat(self.layer.shadowOpacity)
        }
        set {
            self.layer.shadowOpacity = Float(newValue)
        }
    }
    
}

@IBDesignable
class DesignableUIView : UIView {}

@IBDesignable
class DesignableUIButton : UIButton {}
