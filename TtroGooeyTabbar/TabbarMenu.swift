//
//  TabbarMenu.swift
//  GooeyTabbar
//
//  Created by KittenYang on 11/16/15.
//  Copyright © 2015 KittenYang. All rights reserved.
//

import UIKit
import EasyPeasy
import PayWandBasicElements

public protocol TabbarMenuDelegate : NSObjectProtocol {

    func tabbarMenu(menuIndex tabbarMenu : TabbarMenu) -> Int
    
    func tabbarMenu(_ tabbarMenu : TabbarMenu, selectedIndex index : Int)
    
    func tabbarMenu(numberOfMenuItems tabbarMenu : TabbarMenu) -> Int
    
    func tabBarMenu(willShowMenuItems tabbarMenu : TabbarMenu)
    
    func tabBarMenu(menuItemsDidDisappear tabbarMenu : TabbarMenu)
}

public class TabbarMenu: UIView{
    
    var opened : Bool = false
    
    fileprivate var normalRect : UIView!
    fileprivate var springRect : UIView!
//    private var keyWindow  : UIWindow!
    fileprivate var blurView   : UIVisualEffectView!
    fileprivate var displayLink : CADisplayLink!
    fileprivate var animationCount : Int = 0
    fileprivate var diff : CGFloat = 0
    fileprivate var terminalFrame : CGRect?
    fileprivate var initialFrame : CGRect?
    fileprivate var animatingInitialFrame : CGRect?
    fileprivate var animatingTerminalFrame : CGRect?
    var animateButton : AnimatedButton?
    
    var scrollDownButton : UIButton?
    
    //let TOPSPACE : CGFloat = 200 //留白
    
    let topSpace : CGFloat = UIScreen.main.bounds.height/4
    var offset : CGFloat = 0
    
    fileprivate var tabbarheight : CGFloat? //tabbar高度
    
    fileprivate var superView : UIView!
    
    var items = [GooeyTabbarMenuItem]()
    
    public var delegate : TabbarMenuDelegate!
    
    var tabNames = [String]()
    var tabIcons = [UIImage?]()
    var tabAvailablity = [Bool]()
    
    var isAnimating = false;
    
    var scrollView : UIScrollView!
    
    
    
    public init(tabbarHeight : CGFloat, superVC : UIViewController, tabNames : [String], tabIcons : [UIImage?], tabAvailablity: [Bool])
    {
//        let statusBarFrame = UIApplication.shared.statusBarFrame
        if (!UIApplication.shared.isStatusBarHidden || UIApplication.shared.statusBarFrame.height > 30){
            offset = UIApplication.shared.statusBarFrame.height - 20
        }
        
        tabbarheight = tabbarHeight
        terminalFrame = CGRect(x: 0, y: topSpace, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        initialFrame = CGRect(x: 0, y: UIScreen.main.bounds.height - tabbarHeight - offset, width: terminalFrame!.width, height: terminalFrame!.height) //TOPSPACE
        animatingInitialFrame = CGRect(x: 0, y: UIScreen.main.bounds.height - tabbarHeight - topSpace - offset, width: terminalFrame!.width, height: terminalFrame!.height)
        animatingTerminalFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        super.init(frame: initialFrame!)
        //super.init(frame : terminalFrame!)
        //opened = true
        self.superView = superVC.view
        //delegate = superVC
        self.tabNames = tabNames
        self.tabIcons = tabIcons
        self.tabAvailablity = tabAvailablity
        setUpViews()
        
        //initButtons()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override public func draw(_ rect: CGRect)
    {
        let path = UIBezierPath()
        
        if (animationCount == 0){
            path.move(to: CGPoint(x: 0, y: self.frame.height))
            path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
            path.addLine(to: CGPoint(x: self.frame.width, y: 0)) //TOPSPACE
            path.addQuadCurve(to: CGPoint(x: 0, y: 0), controlPoint: CGPoint(x: self.frame.width/2, y: -diff)) // TOPSPACE
            path.close()
        } else {
            path.move(to: CGPoint(x: 0, y: self.frame.height))
            path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
            path.addLine(to: CGPoint(x: self.frame.width, y: topSpace))
            path.addQuadCurve(to: CGPoint(x: 0, y: topSpace), controlPoint: CGPoint(x: self.frame.width/2, y: topSpace-diff))
            path.close()
        }
        
//        print("=====\(diff)")
        
        let context = UIGraphicsGetCurrentContext()
        context?.addPath(path.cgPath)
        //UIColor(colorLiteralRed: 50/255.0, green: 58/255.0, blue: 68/255.0, alpha: 1.0).set()
        UIColor.TtroColors.darkBlue.color.set()
        context?.fillPath()
    }
    
    
    fileprivate func setUpViews()
    {
        //keyWindow = UIApplication.sharedApplication().keyWindow
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.frame = self.bounds
        blurView.alpha = 0.0
        blurView.isHidden = true
        superView.addSubview(blurView)
        
        self.backgroundColor = UIColor.clear
        superView.addSubview(self)
        
        normalRect = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 30 - 50, width: 30, height: 30))
        normalRect.backgroundColor = UIColor.blue
        normalRect.isHidden = true
        superView.addSubview(normalRect)
        
        springRect = UIView(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - 30/2, y: normalRect.frame.origin.y, width: 30, height: 30))
        springRect.backgroundColor = UIColor.yellow
        springRect.isHidden = true
        superView.addSubview(springRect)
        
        animateButton = AnimatedButton(frame: CGRect(x: 0, y: (tabbarheight! - 30)/2, width: 50, height: 30))
        self.addSubview(animateButton!)
        animateButton!.didTapped = { (button) -> () in
            self.triggerAction()
        }
        
        scrollView = UIScrollView()
        addSubview(scrollView)
        scrollView.easy.layout([
            Top(5).to(animateButton!),
            Width().like(self),
            Bottom(tabbarheight!).to(self, .bottom),
//            Bottom().to(self, .bottom),
            CenterX()
        ])
        
        //scrollView.contentSize = CGSize(width: 400, height: 1000)
        
        scrollView.indicatorStyle = .white
        scrollView.isScrollEnabled = true
        
        scrollDownButton = UIButton(type: .custom)
        addSubview(scrollDownButton!)
        scrollDownButton?.easy.layout( [
            Height(tabbarheight!),
            //Bottom(),
//            Top().to(containerView),
            Bottom(),
            Width().like(self),
            CenterX()
            ])
        //openButton.backgroundColor = UIColor.orange
        scrollDownButton?.addTarget(self, action: #selector(scrollDownMenu), for: UIControlEvents.touchUpInside)
        scrollDownButton?.setImage(#imageLiteral(resourceName: "down"), for: UIControlState.normal)
        scrollDownButton?.imageView?.contentMode = .scaleAspectFit
        scrollDownButton?.isHidden = true
    }
    
    func triggerAction()
    {
        if animateButton!.animating {
            return
        }
        self.isAnimating = true
        
        if !opened {
            opened = true
            
            startAnimation()
            setStartAnimationFrames()
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.springRect.center = CGPoint(x: self.springRect.center.x, y: self.springRect.center.y - 40)
            }) { (finish) -> Void in
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                    self.frame = self.animatingTerminalFrame!
                    }, completion: nil)
                self.showMenuButtons()
                UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseOut, animations: { () -> Void in
                    self.normalRect.center = CGPoint(x: self.normalRect.center.x, y: 100)
                    self.blurView.alpha = 1.0
                    }, completion: nil)
                
                UIView.animate(withDuration: 0.5, delay: 0.15, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: { () -> Void in
                    self.springRect.center = CGPoint(x: self.springRect.center.x, y: 100)
                    }, completion: { (finish) -> Void in
                        self.finishAnimation()
                        self.isAnimating = false
                })
            }
        } else {
            /**
             *  收缩
             */
            opened = false
            startAnimation()
            hideMenuButtons()
            hideMenu()
        }
    }
    
    func hideMenu(){
        let delay = 0.3
        UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseOut, animations: { () -> Void in
            self.frame = self.animatingInitialFrame!
            }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseOut, animations: { () -> Void in
            self.normalRect.center = CGPoint(x: self.normalRect.center.x, y: UIScreen.main.bounds.size.height - 30 - 50)
            self.blurView.alpha = 0.0
            }, completion: nil)
        UIView.animate(withDuration: 0.2, delay: delay, options: .curveEaseOut, animations: { () -> Void in
            self.springRect.center = CGPoint(x: self.springRect.center.x, y: UIScreen.main.bounds.size.height - 30 - 50 + 10)
            }, completion: { (finish) -> Void in
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                    self.springRect.center = CGPoint(x: self.springRect.center.x, y: UIScreen.main.bounds.size.height - 30 - 50 - 40)
                    }, completion: { (finish) -> Void in
                        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                            self.springRect.center = CGPoint(x: self.springRect.center.x, y: UIScreen.main.bounds.size.height - 30 - 50)
                            }, completion: { (finish) -> Void in
                                self.finishAnimation()
                                self.setEndAnimationFrames()
                        })
                })
        })
    }
    
    func setEndAnimationFrames() {
        self.blurView.isHidden = true
        self.frame = self.initialFrame!
        self.setNeedsDisplay()
        self.animateButton?.frame = CGRect(x: 0, y: (self.tabbarheight! - 30)/2, width: 50, height: 30)
    }
    
    func setStartAnimationFrames() {
        self.frame = animatingInitialFrame!
        animateButton?.frame = CGRect(x: 0, y: topSpace + (tabbarheight! - 30)/2, width: 50, height: 30)
        self.setNeedsDisplay()
        self.blurView.isHidden = false
    }
    
    
    @objc fileprivate func update(_ displayLink: CADisplayLink)
    {
        let normalRectLayer = normalRect.layer.presentation()
        let springRectLayer = springRect.layer.presentation()
        
        let normalRectFrame = (normalRectLayer!.value(forKey: "frame")! as AnyObject).cgRectValue
        let springRectFrame = (springRectLayer!.value(forKey: "frame")! as AnyObject).cgRectValue
        
        diff = (normalRectFrame?.origin.y)! - (springRectFrame?.origin.y)!
        
        self.setNeedsDisplay()
    }
    
    fileprivate func startAnimation()
    {
        if displayLink == nil
        {
            self.displayLink = CADisplayLink(target: self, selector: #selector(self.update(_:)))
            self.displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        }
        animationCount += 1
    }
    
    fileprivate func finishAnimation()
    {
        
        animationCount -= 1
        if animationCount == 0
        {
            displayLink.invalidate()
            displayLink = nil
        }
    }
    
    
}

//MARK add menu buttons
extension TabbarMenu {
    public func changeSelectedButton(newSelectedIndex : Int){
        for (index ,item) in self.items.enumerated() {
            if (index != newSelectedIndex){
                item.nameLabel.textColor = UIColor.TtroColors.white.color
                item.iconView.tintColor = UIColor.TtroColors.white.color
            } else {
                item.nameLabel.textColor = UIColor.TtroColors.cyan.color
                item.iconView.tintColor = UIColor.TtroColors.cyan.color
            }
        }
    }
    
    public func initButtons(){
        for i in 0..<delegate.tabbarMenu(numberOfMenuItems: self) {
            let item = GooeyTabbarMenuItem(name: tabNames[i], icon: tabIcons[i], isAvailable: tabAvailablity[safee: i] ?? false, onTap: {
                if (self.opened && !self.animateButton!.animating && !self.isAnimating){
                    self.delegate.tabbarMenu(self, selectedIndex: i)
                    self.animateButton?.animate()
                    for item in self.items {
                        item.nameLabel.textColor = UIColor.TtroColors.white.color
                        item.iconView.tintColor = UIColor.TtroColors.white.color
                    }
                    return true
                } else {
                    return false
                }
                
            })
            //item.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(item)
            if (i == 0){
                item.easy.layout(Top()) //Top(5).to(animateButton!)
                item.nameLabel.textColor = UIColor.TtroColors.cyan.color
                item.iconView.tintColor = UIColor.TtroColors.cyan.color
            } else {
                item.easy.layout(Top(20).to(items[i-1]))
            }
            
            item.easy.layout([
                Width().like(self),
                Height(40)
            ])
            
            var constant = frame.width/3
            item.alpha = 0.0
            if (opened){
                constant = 0.0
                item.alpha = 1
            }
            item.leftConst = item.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: constant)
            item.leftConst.isActive = true
            
            items.append(item)
        }
        
        //items.last! <- Bottom().to(scrollView, .bottom)
    }
    
    func showMenuButtons(){
        delegate.tabBarMenu(willShowMenuItems: self)
        let baseDelay = 0.1
        let delay = 0.1
        let duration = 0.3
        for i in 0..<items.count {
            UIView.animate(withDuration: duration, delay: delay * Double(i) + baseDelay, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.items[i].leftConst.constant = 0
                self.layoutIfNeeded()
                self.items[i].alpha = 1
                }, completion: nil)
        }
        
    }
    
    func hideMenuButtons(){
        
        let delay = 0.1
        let duration = 0.35
        for i in stride(from: (items.count - 1), to: -1, by: -1) {
            UIView.animate(withDuration: duration, delay: delay * Double(items.count - 1 - i), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveLinear, animations: {
                self.items[i].leftConst.constant = self.frame.width/3
                self.layoutIfNeeded()
                self.items[i].alpha = 0
                }, completion: { (_) in
                    self.delegate.tabBarMenu(menuItemsDidDisappear: self)
            })
        }
    }
    
    @objc public func scrollDownMenu(_ sender: UIButton){
        scrollView.scrollToBottom()
    }
    
    @objc public func openMenu(_ sender: UIButton){
        if (opened){
            if scrollDownButton?.isHidden != true {
                scrollDownMenu(sender)
            }
        } else {
            animateButton?.animate()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let item = items.first,
            scrollView != nil {
            let height = item.frame.height * CGFloat(items.count) + CGFloat(items.count * 20)
            scrollView.contentSize = CGSize(width: item.frame.width,
                                            height: height)
            scrollView.flashScrollIndicators()
            if (scrollView.frame.height < scrollView.contentSize.height) {
                scrollDownButton?.isHidden = false
            }
        }
    }
}


