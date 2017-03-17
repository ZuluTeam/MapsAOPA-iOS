//
//  MultipleStatesBarButtonItem.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 4/20/16.
//  Copyright © 2016 Konstantin Zyryanov. All rights reserved.
//

import UIKit

@IBDesignable
class MultipleStatesBarButtonItem: UIBarButtonItem {
    fileprivate let itemAction : ((Int)->())?
    fileprivate let states : [(text: String, color: UIColor)]
    fileprivate var currentState : Int {
        didSet {
            self.updateState()
        }
    }
    fileprivate let font : UIFont
    
    init(states: [(text: String, color: UIColor)], currentState: Int, font: UIFont, action: ((Int)->())?)
    {
        assert(states.count > 0, "States must contain at least one element")
        assert(currentState < states.count, "States count must be greater than current state")
        self.itemAction = action
        self.states = states
        self.currentState = currentState
        self.font = font
        super.init()
        self.target = self
        self.action = #selector(MultipleStatesBarButtonItem.buttonAction(_:))
        let attributes = [ NSFontAttributeName : self.font ]
        self.setTitleTextAttributes(attributes, for: .normal)
        self.updateState()
        
    }
    
    fileprivate func updateState()
    {
        let state = self.states[self.currentState]
        self.title = state.text
        self.tintColor = state.color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonAction(_ sender: AnyObject?)
    {
        self.currentState = (self.currentState + 1) % self.states.count
        self.itemAction?(self.currentState)
    }
}
