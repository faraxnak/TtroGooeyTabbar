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
//    fileprivate var tapGR : UITapGestureRecognizer!
    var delegate : GooeyTabbarMenuItemDelegate!
    
    var leftConst : NSLayoutConstraint!
    
    typealias Tapped = () -> (Bool)
    var tapped : Tapped!
    
    convenience init(name : String, icon : UIImage?, isAvailable : Bool = true, onTap: @escaping () -> (Bool)){
        self.init(frame : CGRect.zero)
        nameLabel = UILabel()
        nameLabel.textColor = UIColor.TtroColors.white.color
        nameLabel.text = name
        
        iconView = UIImageView(image: icon)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)
        iconView.easy.layout([
            Left(60),
            CenterY(),
            Height(*0.9).like(self).with(Priority.medium),
            Height(<=40),
            Width().like(iconView, .height)
        ])
        iconView.image = (iconView.image?.withRenderingMode(.alwaysTemplate))!
        iconView.tintColor = UIColor.TtroColors.white.color
        
        addSubview(nameLabel)
        nameLabel.easy.layout([
            Left(10).to(iconView),
            CenterY().to(iconView),
            Height().like(iconView)
        ])
        
        if isAvailable {
            let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
            addGestureRecognizer(tapGR)
        } else {
            let comingSoonLabel = TtroLabel(font: UIFont.TtroPayWandFonts.regular1.font, color: UIColor.TtroColors.darkBlue.color)
            comingSoonLabel.text = " coming soon "
            comingSoonLabel.backgroundColor = UIColor.TtroColors.cyan.color
            comingSoonLabel.layer.cornerRadius = 5
            comingSoonLabel.layer.masksToBounds = true
            addSubview(comingSoonLabel)
            comingSoonLabel.easy.layout([
                Right(20),
                //            Left(10).to(nameLabel),
                CenterY().to(iconView),
                Height(20),//.like(iconView),
                Width(*0.2).like(self)
                ])
            comingSoonLabel.adjustsFontSizeToFitWidth = true
        }
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
