//
//  MenuTransitionController.swift
//  MapsAOPA
//
//  Created by Konstantin Zyrianov on 04/04/2017.
//  Copyright © 2017 Konstantin Zyryanov. All rights reserved.
//

import UIKit

class MenuTransitionController : UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    private static let menuWidth : CGFloat = 250.0
    
    var isPresenting : Bool = false
    
    private var tapGestureRecognizer : UITapGestureRecognizer!
    private var panGestureRecognizer : UIPanGestureRecognizer?
    private var edgePanGestureRecognizer : UIScreenEdgePanGestureRecognizer?
    
    private weak var mainViewController : MainViewController!
    weak var menuViewController : MenuViewController?
    private var snapshotView : UIView?
    
    private var isInteractive : Bool = false
    
    init(mainViewController: MainViewController) {
        super.init()
        self.mainViewController = mainViewController
        
        self.edgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgePanAction(_:)))
        self.edgePanGestureRecognizer?.edges = .left
        self.mainViewController.view.addGestureRecognizer(self.edgePanGestureRecognizer!)
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    }
    
    // MARK: - Screen edge pan gesture recognizer
    
    func edgePanAction(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translation(in: sender.view)
        var progress = (translation.x / 200)
        progress = min(max(progress, 0.0), 1.0)
        let shouldCompleteTransition = progress > 0.5
        switch sender.state {
        case .began:
            self.isInteractive = true
            self.mainViewController.performSegue(withIdentifier: Segue.Menu.rawValue, sender: self.mainViewController)
        case .changed:

            self.update(progress)
        case .ended:
            if shouldCompleteTransition {
                self.finish()
            } else {
                self.cancel()
            }
            
        default:
            self.cancel()
        }
    }
    
    override func finish() {
        self.isInteractive = false
        super.finish()
    }
    
    override func cancel() {
        self.isInteractive = false
        super.cancel()
    }
    
    func tapAction(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.menuViewController?.dismiss(animated: true, completion: nil)
            self.menuViewController = nil
        }
    }
    
    // MARK: - View controller animated transitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to) else {
                return
        }
        let containerView = transitionContext.containerView
        let duration = TimeInterval(transitionContext.isAnimated) * self.transitionDuration(using: transitionContext)
        
        if self.isPresenting {
            toViewController.view.frame = fromViewController.view.bounds
            toViewController.view.width = MenuTransitionController.menuWidth
            containerView.addSubview(toViewController.view)
            
            self.snapshotView = fromViewController.view.snapshotView(afterScreenUpdates: false)
            self.snapshotView?.frame = fromViewController.view.bounds
            if let snapshot = self.snapshotView {
                containerView.addSubview(snapshot)
                snapshot.shadowColor = .black
                snapshot.shadowOffset = .zero
                snapshot.shadowRadius = 3.0
                snapshot.shadowOpacity = 1.0
                snapshot.addGestureRecognizer(self.tapGestureRecognizer)
            }
            UIView.animate(withDuration: duration, animations: {
                self.snapshotView?.x = toViewController.view.width
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        } else {
            UIView.animate(withDuration: duration, animations: { 
                self.snapshotView?.x = 0.0
            }, completion: { _ in
                self.menuViewController?.view.removeFromSuperview()
                fromViewController.view.removeFromSuperview()
                self.snapshotView?.removeGestureRecognizer(self.tapGestureRecognizer)
                self.snapshotView?.removeFromSuperview()
                self.snapshotView = nil
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
    
    // MARK: - View controller transitioning delegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = false
        return self
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return isInteractive ? self : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return isInteractive ? self : nil
    }
}
