//
//  MainViewController.swift
//  MapsAOPA
//
//  Created by Konstantin Zyryanov on 3/20/17.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, MapViewControllerDelegate {
    @IBOutlet var mapContainerView : UIView!
    @IBOutlet var menuContainerView : UIView!
    @IBOutlet var menuBackgroundView : UIView!
    @IBOutlet var statusBarBackgroundView : UIView!
    
    @IBOutlet var leftConstraint : NSLayoutConstraint!
    
    private var isMenuHidden : Bool = false
    private var startDragMenuPoint : CGPoint = .zero
    private var startConstant : CGFloat = 0
    
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
    
    var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            UIView.animate(withDuration: 0.25) { 
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override public var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if !self.isMenuHidden {
            return .default
        }
        return self.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bounds = self.statusBarBackgroundView.bounds
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.frame = bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleWidth, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        self.statusBarBackgroundView.addSubview(visualEffectView)
        
        self.setMenuHidden(true, animated: false)
    }
    
    override func setNeedsStatusBarAppearanceUpdate() {
//        self.statusBarBackgroundView.alpha = CGFloat(self.preferredStatusBarStyle == .lightContent)
        super.setNeedsStatusBarAppearanceUpdate()
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.Map.rawValue {
            self.mapViewController = segue.destination as? MapViewController
            self.mapViewController?.delegate = self
        } else if segue.identifier == Segue.Menu.rawValue {
            self.menuViewController = segue.destination as? MenuViewController
        }
    }
    
    private func setMenuHidden(_ hidden: Bool, animated: Bool) {
        self.isMenuHidden = hidden
        let hiddenAlpha = CGFloat(hidden)
        self.menuBackgroundView.isHidden = false
        self.menuContainerView.isHidden = false
        let percent = abs(self.leftConstraint.constant / self.menuContainerView.width)
        self.menuBackgroundView.alpha = 1.0 - percent
        self.menuContainerView.alpha = 1.0 - percent
        self.leftConstraint.constant = -self.menuContainerView.width * CGFloat(hidden)
        UIView.animate(withDuration: 0.25 * TimeInterval(animated), animations: {
            self.menuBackgroundView.alpha = 1.0 - hiddenAlpha
            self.menuContainerView.alpha = 1.0 - hiddenAlpha
            self.view.layoutIfNeeded()
            self.setNeedsStatusBarAppearanceUpdate()
        }) { _ in
            self.menuBackgroundView.isHidden = hidden
            self.menuContainerView.isHidden = hidden
        }
    }
    
    // MARK: - MapViewControllerDelegate
    
    func showMenu() {
        self.setMenuHidden(false, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func tapBackgroundAction(_ sender: UITapGestureRecognizer) {
        self.setMenuHidden(true, animated: true)
    }
    
    @IBAction func panAction(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            self.startDragMenuPoint = sender.location(in: self.view)
            self.startConstant = self.leftConstraint.constant
        case .changed:
            let translation = sender.translation(in: self.view)
            let delta = max(self.startDragMenuPoint.x - self.menuContainerView.width, 0)
            self.leftConstraint.constant = min(0.0, max(-self.menuContainerView.width, self.startConstant + translation.x + delta))
            let percent = abs(self.leftConstraint.constant / self.menuContainerView.width)
            self.menuBackgroundView.alpha = 1.0 - percent
            self.menuContainerView.alpha = 1.0 - percent
            self.view.layoutIfNeeded()
        case .cancelled, .ended, .failed:
            let percent = abs(self.leftConstraint.constant / self.menuContainerView.width)
            self.setMenuHidden(percent > 0.25, animated: true)
        default:
            break
        }
    }
}
