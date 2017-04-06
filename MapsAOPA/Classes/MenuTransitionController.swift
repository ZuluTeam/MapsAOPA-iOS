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
    
    private var tapGestureRecognizer : UITapGestureRecognizer?
    private var panGestureRecognizer : UIPanGestureRecognizer?
    private var edgePanGestureRecognizer : UIScreenEdgePanGestureRecognizer?
    
    private weak var mainViewController : MainViewController!
    weak var menuViewController : MenuViewController?
    
    init(mainViewController: MainViewController) {
        super.init()
        self.mainViewController = mainViewController
        
        self.edgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgePanAction(_:)))
        self.edgePanGestureRecognizer?.edges = .left
        self.mainViewController.view.addGestureRecognizer(self.edgePanGestureRecognizer!)
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        UIApplication.shared.delegate?.window??.addGestureRecognizer(self.tapGestureRecognizer!)
        self.tapGestureRecognizer?.isEnabled = false
    }
    
    // MARK: - Screen edge pan gesture recognizer
    
    func edgePanAction(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translation(in: sender.view)
        var progress = (translation.x / 200)
        progress = min(max(progress, 0.0), 1.0)
        let shouldCompleteTransition = progress > 0.5
        switch sender.state {
        case .began:
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
            if let window = fromViewController.view.window  {
                toViewController.view.frame = window.bounds
                toViewController.view.width = MenuTransitionController.menuWidth
                fromViewController.view.superview?.insertSubview(toViewController.view, belowSubview: fromViewController.view)
                fromViewController.view.shadowColor = .black
                fromViewController.view.shadowOffset = .zero
                fromViewController.view.shadowRadius = 3.0
                fromViewController.view.shadowOpacity = 1.0
                UIView.animateKeyframes(
                    withDuration: duration,
                    delay: 0.0,
                    options: .calculationModeCubic,
                    animations: {
                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                            fromViewController.view.x = toViewController.view.width
                        })
                }, completion: { _ in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    self.tapGestureRecognizer?.isEnabled = !transitionContext.transitionWasCancelled
                })
            }
        } else {
            UIView.animateKeyframes(
                withDuration: duration,
                delay: 0.0,
                options: .calculationModeCubic,
                animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                        toViewController.view.x = 0.0
                    })
            }, completion: { _ in
                fromViewController.view.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                self.tapGestureRecognizer?.isEnabled = transitionContext.transitionWasCancelled
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
        return self
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self
    }
}
