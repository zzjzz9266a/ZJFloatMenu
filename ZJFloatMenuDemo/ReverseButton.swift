//
//  ReverseButton.swift
//  crm
//
//  Created by ZhuFaner on 2017/5/17.
//  Copyright © 2017年 北京水木优品科技有限公司. All rights reserved.
//

import UIKit

@IBDesignable
class ReverseButton: UIButton {
    
    @IBInspectable var padding: CGFloat = 0

    override func layoutSubviews() {
        super.layoutSubviews()
        guard currentImage != nil, titleLabel != nil else { return }
        titleEdgeInsets = UIEdgeInsets(top: 0, left: -currentImage!.size.width-padding/2, bottom: 0, right: currentImage!.size.width+padding/2)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: titleLabel!.bounds.width+padding/2, bottom: 0, right: -titleLabel!.bounds.width-padding/2)
    }
    
    @IBInspectable var borderColor: UIColor?{
        didSet{
            layer.borderColor = borderColor?.cgColor
            setTitleColor(borderColor, for: .normal)
        }
    }
    
    @IBInspectable var borderWidth: CGFloat{
        set{
            layer.borderWidth = newValue
        }
        get{
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat{
        set{
            layer.cornerRadius = newValue
        }
        get{
            return layer.cornerRadius
        }
    }

}
