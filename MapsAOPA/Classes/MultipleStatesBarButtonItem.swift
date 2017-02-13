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
    fileprivate let states : [AnyObject]
    fileprivate var currentState : Int
    
    init(states: [AnyObject], currentState: Int, action: ((Int)->())?)
    {
        assert(states.count > 0, "States must contains at least one element")
        assert(currentState < states.count, "States count must be greater than current state")
        self.itemAction = action
        self.states = states
        self.currentState = currentState
        super.init()
        self.target = self
        self.action = #selector(MultipleStatesBarButtonItem.buttonAction(_:))
        self.updateState()
    }
    
    fileprivate func updateState()
    {
        let state = self.states[self.currentState]
        switch state {
        case let value as String:
            self.title = value
            self.target = self
            self.action = #selector(MultipleStatesBarButtonItem.buttonAction(_:))
        case let value as UIImage:
            self.image = value
            self.target = self
            self.action = #selector(MultipleStatesBarButtonItem.buttonAction(_:))
        default: break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonAction(_ sender: AnyObject?)
    {
        self.currentState = (self.currentState + 1) % self.states.count
        self.updateState()
        self.itemAction?(self.currentState)
    }
}
