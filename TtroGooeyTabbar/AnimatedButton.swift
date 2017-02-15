//
//  AnimatedButton.swift
//  GooeyTabbar
//
//  Created by KittenYang on 11/16/15.
//  Copyright © 2015 KittenYang. All rights reserved.
//

import UIKit

class AnimatedButton: UIButton, CAAnimationDelegate
{
    /// 按钮的回调
    var didTapped : ((_ button:UIButton)->())?
    
    fileprivate var firstLine : CALayer!
    fileprivate var secondLine : CALayer!
    fileprivate var thirdLine : CALayer!
    var animating : Bool = false
    /// 是否打开
    fileprivate var opened : Bool = false
    /// 是否正在动画中
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLines()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    fileprivate func setUpLines() {
        firstLine = CALayer()
        firstLine.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - 10)
        firstLine.bounds = CGRect(x: 0, y: 0, width: self.frame.width/2, height: 3)
        setLineSetting(firstLine)
        self.layer.addSublayer(firstLine)
        
        secondLine = CALayer()
        secondLine.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + 10)
        secondLine.bounds = CGRect(x: 0, y: 0, width: self.frame.width/2, height: 3)
        setLineSetting(secondLine)
        self.layer.addSublayer(secondLine)
        
        thirdLine = CALayer()
        thirdLine.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        thirdLine.bounds = CGRect(x: 0, y: 0, width: self.frame.width/2, height: 3)
        setLineSetting(thirdLine)
        self.layer.addSublayer(thirdLine)
        
        self.addTarget(self, action: #selector(self.animate), for: .touchUpInside)
    }
    
    
    fileprivate func setLineSetting(_ line:CALayer) {
        line.backgroundColor = UIColor.white.cgColor
        line.cornerRadius = line.frame.height / 2
    }
    
    
    @objc func animate() {
        
        if animating {
            return
        }
        
        didTapped?(self)
        animating = true
        if !opened {
            opened = true
            
            let moveUp = CABasicAnimation(keyPath: "transform.translation.y")
            moveUp.duration = 0.3
            moveUp.delegate = self
            moveUp.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            moveUp.toValue = -10.0
            moveUp.fillMode = kCAFillModeForwards
            moveUp.isRemovedOnCompletion = false
            secondLine.add(moveUp, forKey: "moveUp_2")
            
            let moveDown = CABasicAnimation(keyPath: "transform.translation.y")
            moveDown.duration = 0.3
            moveDown.delegate = self
            moveDown.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            moveDown.toValue = 10.0
            moveDown.fillMode = kCAFillModeForwards
            moveDown.isRemovedOnCompletion = false
            firstLine.add(moveDown, forKey: "moveDown_1")
            
            let fade = CABasicAnimation(keyPath: "opacity")
            fade.duration = 0.3
            fade.delegate = self
            fade.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            fade.toValue = 0
            fade.fromValue = 1
            fade.fillMode = kCAFillModeForwards
            fade.isRemovedOnCompletion = false
            thirdLine.add(fade, forKey: "fadeOut")
            
        }else{
            opened = false
            
            let rotation_second = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            rotation_second.duration = 0.3
            rotation_second.values = [45 * (M_PI/180),70 * (M_PI/180),0]
            rotation_second.keyTimes = [0.0,0.4,1.0]
            rotation_second.fillMode = kCAFillModeForwards
            rotation_second.isRemovedOnCompletion = false
            rotation_second.delegate = self
            secondLine.add(rotation_second, forKey: "rotation_second_close")
            
            let rotation_first = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            rotation_first.duration = 0.4
            rotation_first.values = [135 * (M_PI/180),170 * (M_PI/180),0]
            rotation_first.keyTimes = [0.0,0.4,1.0]
            rotation_first.fillMode = kCAFillModeForwards
            rotation_first.isRemovedOnCompletion = false
            rotation_first.delegate = self
            firstLine.add(rotation_first, forKey: "rotation_first_close")
            
            let fade = CABasicAnimation(keyPath: "opacity")
            fade.duration = 0.3
            fade.delegate = self
            fade.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            fade.toValue = 1
            fade.fromValue = 0
            fade.fillMode = kCAFillModeForwards
            fade.isRemovedOnCompletion = false
            thirdLine.add(fade, forKey: "fadeIn")
            
        }
        
    }
    
    
    func animationDidStart(_ anim: CAAnimation) {
        
        
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim == secondLine.animation(forKey: "moveUp_2") {
            let rotation_second = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            rotation_second.duration = 0.5
            rotation_second.values = [0,70 * (M_PI/180),45 * (M_PI/180)]
            rotation_second.keyTimes = [0.0,0.6,1.0]
            rotation_second.fillMode = kCAFillModeForwards
            rotation_second.isRemovedOnCompletion = false
            secondLine.add(rotation_second, forKey: "rotation_second_open")
            
        }else if anim == firstLine.animation(forKey: "moveDown_1") {
            let rotation_first = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            rotation_first.duration = 0.6
            rotation_first.values = [0,170 * (M_PI/180),135 * (M_PI/180)]
            rotation_first.keyTimes = [0.0,0.6,1.0]
            rotation_first.fillMode = kCAFillModeForwards
            rotation_first.isRemovedOnCompletion = false
            rotation_first.delegate = self
            firstLine.add(rotation_first, forKey: "rotation_first_open")
            
        }else if anim == secondLine.animation(forKey: "rotation_second_close") {
            let moveUp = CABasicAnimation(keyPath: "transform.translation.y")
            moveUp.duration = 0.2
            moveUp.delegate = self
            moveUp.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            moveUp.toValue = 0.0
            moveUp.fillMode = kCAFillModeForwards
            moveUp.isRemovedOnCompletion = false
            secondLine.add(moveUp, forKey: "moveDown_2")
            
        }else if anim == firstLine.animation(forKey: "rotation_first_close") {
            let moveDown = CABasicAnimation(keyPath: "transform.translation.y")
            moveDown.duration = 0.2
            moveDown.delegate = self
            moveDown.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            moveDown.toValue = 0.0
            moveDown.fillMode = kCAFillModeForwards
            moveDown.isRemovedOnCompletion = false
            firstLine.add(moveDown, forKey: "moveUp_1")
            
        }
        
        if anim == firstLine.animation(forKey: "rotation_first_open")  || anim == firstLine.animation(forKey: "moveUp_1"){
            animating = false
        }
    }
    
}





