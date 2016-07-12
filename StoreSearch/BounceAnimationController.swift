//
//  BounceAnimationController.swift
//  StoreSearch
//
//  Created by Ike Mattice on 7/12/16.
//  Copyright © 2016 Ike Mattice. All rights reserved.
//

import UIKit

class BounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.2
    }
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey), let toView = transitionContext.viewForKey(UITransitionContextToViewKey), let containerView = transitionContext.containerView() {
            
            toView.frame = transitionContext.finalFrameForViewController(toViewController)
            
            containerView.addSubview(toView)
            //begins view at 70% of size
            toView.transform = CGAffineTransformMakeScale(0.7, 0.7)
            
            UIView.animateKeyframesWithDuration(transitionDuration(transitionContext), delay: 0, options: .CalculationModeCubic, animations: {
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.334, animations: {
                    //inflates view to 120% of size
                    toView.transform = CGAffineTransformMakeScale(1.2, 1.2)
                })
                UIView.addKeyframeWithRelativeStartTime(0.334, relativeDuration: 0.333, animations: {
                    //deflates to 90% of size
                    toView.transform = CGAffineTransformMakeScale(0.9, 0.9)
                })
                UIView.addKeyframeWithRelativeStartTime(0.666, relativeDuration: 0.333, animations: {
                    //finally is restored to original size
                    toView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                })
                }, completion: { finished in
                    transitionContext.completeTransition(finished)
            })
        }   
    }
}
