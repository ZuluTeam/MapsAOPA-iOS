//
//  PointsFilterInputViewFactory.swift
//  MapsAOPA
//
//  Created by Konstantin Zyrianov on 30/03/2017.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import UIKit

class PointsFilterKeyView : UIView, UIKeyInput {
    var settingsType : AnyClass?
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        self.addGestureRecognizer(self.tapGestureRecognizer)
    }
    
    public var hasText: Bool { return false }
    
    public func insertText(_ text: String) {
    }
    
    public func deleteBackward() {
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputView: UIView? {
        return PointsFilterInputViewFactory.inputView(for: self.settingsType)
    }
    
    func tapAction(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.becomeFirstResponder()
        }
    }
}

class PointsFilterInputViewFactory {
    static func inputView(for settingsType: AnyClass?) -> UIView? {
        if let type = settingsType {
            switch type {
            case is PointsFilter.Base.Type:
                return PointsFilterBaseInputView.view()
            case is PointsFilter.Extended.Type:
                return PointsFilterExtendedInputView.view()
            case is Settings.Units.Type:
                return UnitsSettingsInputView.view()
            default:
                return nil
            }
        }
        return nil
    }
}

class PointsFilterBaseInputView : UIView {
    @IBOutlet var airportsSegmentedControl : UISegmentedControl!
    @IBOutlet var heliportsSegmentedControl : UISegmentedControl!
    
    class func view() -> UIView? {
        if let views = Bundle.main.loadNibNamed("PointFilterInputViews", owner: nil) {
            for view in views {
                if view is PointsFilterBaseInputView {
                    return view as? UIView
                }
            }
        }
        return nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.airportsSegmentedControl.removeAllSegments()
        self.airportsSegmentedControl.insertSegment(withTitle: PointsFilterState.none.localized, at: PointsFilterState.none.rawValue, animated: false)
        self.airportsSegmentedControl.insertSegment(withTitle: PointsFilterState.active.localized, at: PointsFilterState.active.rawValue, animated: false)
        self.airportsSegmentedControl.insertSegment(withTitle: PointsFilterState.all.localized, at: PointsFilterState.all.rawValue, animated: false)
        self.airportsSegmentedControl.selectedSegmentIndex = Settings.current.pointsFilter.value.airportsState.rawValue
        
        self.heliportsSegmentedControl.removeAllSegments()
        self.heliportsSegmentedControl.insertSegment(withTitle: PointsFilterState.none.localized, at: PointsFilterState.none.rawValue, animated: false)
        self.heliportsSegmentedControl.insertSegment(withTitle: PointsFilterState.active.localized, at: PointsFilterState.active.rawValue, animated: false)
        self.heliportsSegmentedControl.insertSegment(withTitle: PointsFilterState.all.localized, at: PointsFilterState.all.rawValue, animated: false)
        self.heliportsSegmentedControl.selectedSegmentIndex = Settings.current.pointsFilter.value.heliportsState.rawValue
    }
    
    @IBAction func airportsFilterChanged(_ sender: UISegmentedControl) {
        if let state = PointsFilterState(rawValue: sender.selectedSegmentIndex) {
            var filter = Settings.current.pointsFilter.value
            filter.airportsState = state
            Settings.current.pointsFilter.value = filter
        }
    }
    
    @IBAction func heliportsFilterChanged(_ sender: UISegmentedControl) {
        if let state = PointsFilterState(rawValue: sender.selectedSegmentIndex) {
            var filter = Settings.current.pointsFilter.value
            filter.heliportsState = state
            Settings.current.pointsFilter.value = filter
        }
    }
}

class PointsFilterExtendedInputView : UIView {
    @IBOutlet var fuelButtonsContainer : UIView!
    @IBOutlet var minRunwayLengthTextView : UITextField!
    @IBOutlet var belongsButtonsContainer : UIView!
    @IBOutlet var hardSurfaceSwitch : UISwitch!
    @IBOutlet var lightsSwitch : UISwitch!
    @IBOutlet var internationalSwitch : UISwitch!
    
    class func view() -> UIView? {
        if let views = Bundle.main.loadNibNamed("PointFilterInputViews", owner: nil) {
            for view in views {
                if view is PointsFilterExtendedInputView {
                    return view as? UIView
                }
            }
        }
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Fill with changing settings
    }
    
    @IBAction func minRunwayLengthChanged(_ sender: UITextField) {
        
    }
    
    @IBAction func hardSurfaceSwitchChanged(_ sender: UISwitch) {
        
    }
    
    @IBAction func lightsSwitchChanged(_ sender: UISwitch) {
        
    }
    
    @IBAction func internationalSwitchChanged(_ sender: UISwitch) {
        
    }
}

class UnitsSettingsInputView : UIView {
    @IBOutlet var distanceSegmentedControl : UISegmentedControl!
    @IBOutlet var pressureSegmentedControl : UISegmentedControl!
    
    class func view() -> UIView? {
        if let views = Bundle.main.loadNibNamed("PointFilterInputViews", owner: nil) {
            for view in views {
                if view is UnitsSettingsInputView {
                    return view as? UIView
                }
            }
        }
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Fill with changing settings
    }
    
    @IBAction func distanceFilterChanged(_ sender: UISegmentedControl) {
        
    }
    
    @IBAction func pressureFilterChanged(_ sender: UISegmentedControl) {
        
    }
}

