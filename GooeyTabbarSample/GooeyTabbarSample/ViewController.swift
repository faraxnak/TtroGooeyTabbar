//
//  ViewController.swift
//  GooeyTabbarSample
//
//  Created by Farid on 1/16/17.
//  Copyright © 2017 ParsPay. All rights reserved.
//

import UIKit
import EasyPeasy
import TtroGooeyTabbar
import PayWandBasicElements

class ViewController: UIViewController {
    
    //    @IBOutlet var tabBarViewController: [String]!
    
    var identifires = [String]()
    
    weak var currentViewController: UIViewController?
    var containerView : UIView!
    
    var welcomeLabel : TtroLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initElements()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate var currentPageSelected = 0
    
    var gooeyTabbar : TabbarMenu!
    func initElements(){
        
        self.containerView = UIView()
        view.addSubview(containerView)
        let tabbarHeight : CGFloat = 50
        containerView <- [
            Bottom(tabbarHeight),
            Top(),
            Left(),
            Right()
        ]
        print(containerView.frame)
        
        identifires = ["Account","Card", "History", "Profile", "Bank Account"]
        var tabIcons = [UIImage?]()
        tabIcons.append(#imageLiteral(resourceName: "MenuIcon"))
        tabIcons.append(#imageLiteral(resourceName: "MenuIcon"))
        tabIcons.append(#imageLiteral(resourceName: "MenuIcon"))
        tabIcons.append(#imageLiteral(resourceName: "MenuIcon"))
        tabIcons.append(#imageLiteral(resourceName: "MenuIcon"))
        
        view.layoutIfNeeded()
        containerView.layoutIfNeeded()
        print(containerView.frame)
        
        gooeyTabbar = TabbarMenu(tabbarHeight: tabbarHeight, superVC: self, tabNames: identifires, tabIcons: tabIcons)
        gooeyTabbar.delegate = self
        gooeyTabbar.initButtons()
        
        currentPageSelected = 0
        self.currentViewController = self.storyboard?.instantiateViewController(withIdentifier: identifires[currentPageSelected])
        //self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(self.currentViewController!)
        self.addSubview(self.currentViewController!.view, toView: self.containerView)
        containerView.layoutIfNeeded()
        self.currentViewController?.view.layoutIfNeeded()
//        if let accountPage = currentViewController as? AccountStateViewController {
//            accountPage.actionElasticView.setMasks()
//        }
        
        welcomeLabel = TtroLabel(font: UIFont.TtroPayWandFonts.light3.font, color: UIColor.TtroColors.white.color)
        view.addSubview(welcomeLabel)
        welcomeLabel <- [
            Right(10),
            Bottom(10),
            Width(*0.7).like(view)
        ]
//        let h = DateInRegion(absoluteDate: Date(), in: Region(tz: TimeZone.current, cal: Calendar.current, loc: Locale.current)).hour
//        var greeting = ""
//        if (h < 6){
//            greeting = "Good Evening, "
//        } else if (h < 12) {
//            greeting = "Good Morning, "
//        } else if (h < 17) {
//            greeting = "Good Afternoon, "
//        } else {
//            greeting = "Good Evening, "
//        }
        welcomeLabel.text = "Hi!"
        welcomeLabel.textAlignment = .right
        welcomeLabel.adjustsFontSizeToFitWidth = true
        welcomeLabel.alpha = 0
        
        let openButton = UIButton(type: .custom)
        view.addSubview(openButton)
        openButton <- [
            Height(tabbarHeight),
            Bottom(),
            Width().like(view),
            CenterX()
        ]
        openButton.addTarget(gooeyTabbar, action: #selector(gooeyTabbar.animateMenu), for: UIControlEvents.touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.welcomeLabel.alpha = 1
        }
    }
    
    func addSubview(_ subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        //        var viewBindingsDict = [String: AnyObject]()
        //        viewBindingsDict["subView"] = subView
        //        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
        //            options: [], metrics: nil, views: viewBindingsDict))
        //        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
        //            options: [], metrics: nil, views: viewBindingsDict))
        subView <- Edges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        gooeyTabbar.animateButton?.animate()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
//    func showTransactionResult(lastTransaction : Transaction){
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            // your function here
//        }
//    }
}

extension ViewController : TabbarMenuDelegate {
    func tabbarMenu(menuIndex tabbarMenu : TabbarMenu) -> Int {
        return 0
    }
    
    func tabbarMenu(numberOfMenuItems tabbarMenu : TabbarMenu) -> Int {
        return 5
    }
    
    func tabbarMenu(_ tabbarMenu : TabbarMenu, selectedIndex index : Int){
        if (currentPageSelected == index) {
            return
        }
        let newViewController = self.storyboard?.instantiateViewController(withIdentifier: identifires[index])
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.cycleFromViewController(self.currentViewController!, toViewController: newViewController!)
        self.currentViewController = newViewController
//        if let accountPage = currentViewController as? AccountStateViewController {
//            accountPage.actionElasticView.setMasks()
//        }
        currentPageSelected = index
    }
    
    func cycleFromViewController(_ oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMove(toParentViewController: nil)
        self.addChildViewController(newViewController)
        self.addSubview(newViewController.view, toView:self.containerView!)
        newViewController.view.alpha = 0
        newViewController.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            newViewController.view.alpha = 1
            oldViewController.view.alpha = 0
        }, completion: { finished in
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParentViewController()
            newViewController.didMove(toParentViewController: self)
        })
    }
    
    func tabBarMenu(willShowMenuItems tabbarMenu: TabbarMenu) {
        UIView.animate(withDuration: 0.1) {
            self.welcomeLabel.alpha = 0
        }
    }
    
    func tabBarMenu(menuItemsDidDisappear tabbarMenu: TabbarMenu) {
        UIView.animate(withDuration: 0.3) {
            self.welcomeLabel.alpha = 1
        }
    }
}


