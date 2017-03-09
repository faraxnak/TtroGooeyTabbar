//
//  GooeyTabbarMenuItem.swift
//  RadiusBlurMenu
//
//  Created by Farid on 9/27/16.
//  Copyright © 2016 Farid. All rights reserved.
//

import UIKit
import EasyPeasy
import PayWandBasicElements

protocol GooeyTabbarMenuItemDelegate : NSObjectProtocol {
    
    func gooeyTabbarMenuItem(itemSelected item : GooeyTabbarMenuItem)
}

class GooeyTabbarMenuItem : UIView {
    
    var iconView : UIImageView!
    var nameLabel : UILabel!
    fileprivate var tapGR : UITapGestureRecognizer!
    var delegate : GooeyTabbarMenuItemDelegate!
    
    var leftConst : NSLayoutConstraint!
    
    typealias Tapped = () -> (Bool)
    var tapped : Tapped!
    
    convenience init(name : String, icon : UIImage?, onTap: @escaping () -> (Bool)){
        self.init(frame : CGRect.zero)
        nameLabel = UILabel()
        nameLabel.textColor = UIColor.TtroColors.white.color
        nameLabel.text = name
        
        iconView = UIImageView(image: icon)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)
        iconView <- [
            Left(60),
            CenterY(),
            Height(*0.9).like(self).with(Priority.mediumPriority),
            Height(<=40).with(Priority.highPriority),
            Width().like(iconView, .height)
        ]
        iconView.image = (iconView.image?.withRenderingMode(.alwaysTemplate))!
        iconView.tintColor = UIColor.TtroColors.white.color
        
        addSubview(nameLabel)
        nameLabel <- [
            Left(10).to(iconView),
            CenterY().to(iconView),
            Height().like(iconView)
        ]
        
        tapGR = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        addGestureRecognizer(tapGR)
        
        tapped = onTap
    }
    
    func onTap(_ sender : AnyObject){
        //delegate.gooeyTabbarMenuItem(itemSelected: self)
        if (tapped()){
            nameLabel.textColor = UIColor.TtroColors.cyan.color
            iconView.tintColor = UIColor.TtroColors.cyan.color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
