//
//  PointsFilterInputViewFactory.swift
//  MapsAOPA
//
//  Created by Konstantin Zyrianov on 30/03/2017.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import Foundation
import UIKit

class PointsFilterInputViewFactory {
    static func inputView(for settingsType: AnyClass) -> UIView? {
        switch settingsType {
        case is PointsFilter.Base.Type:
            return PointsFilterBaseInputView.view()
        case is PointsFilter.Extended.Type:
            return PointsFilterExtendedInputView.view()
        case is Settings.Units.Type:
            return UnitsFilterInputView.view()
        default:
            return nil
        }
    }
}

class PointsFilterBaseInputView : UIView {
    class func view() -> UIView? {
        let view = Bundle.main.loadNibNamed("PointsFilterBaseInputView", owner: nil)?.first as? PointsFilterBaseInputView
        return view
    }
    
    init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Fill with changing settings
    }
}

class PointsFilterExtendedInputView : UIView {
    class func view() -> UIView? {
        let view = Bundle.main.loadNibNamed("PointsFilterExtendedInputView", owner: nil)?.first as? PointsFilterExtendedInputView
        return view
    }
    
    init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Fill with changing settings
    }
}

class UnitsFilterInputView : UIView {
    class func view() -> UIView? {
        let view = Bundle.main.loadNibNamed("UnitsFilterInputView", owner: nil)?.first as? UnitsFilterInputView
        return view
    }
    
    init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Fill with changing settings
    }
}

