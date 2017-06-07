//
//  ExampleViewController.swift
//  DropDownMenu-Demo
//
//  Created by ZhuFaner on 2017/6/6.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {
    
    var selectedTitle: String?
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var opaqueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FloatMenu.share.menuWidth = 200
        FloatMenu.share.textColor = UIColor.darkGray
        FloatMenu.share.font = UIFont.systemFont(ofSize: 14)
    }
    
    @IBAction func arrowShowChanged(_ sender: UISwitch) {
        FloatMenu.share.showTriangle = sender.isOn
    }

    @IBAction func ShowTypeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            FloatMenu.share.showType = .fade
        case 1:
            FloatMenu.share.showType = .line
        case 2:
            FloatMenu.share.showType = .point
        default:
            break
        }
    }
    
    @IBAction func opaqueChanged(_ sender: UISlider) {
        opaqueLabel.text = "遮罩透明度：\(sender.value)"
        FloatMenu.share.opaque = CGFloat(sender.value)
    }

    @IBAction func buttonClick(_ sender: UIButton) {
        guard let rect = sender.superview?.convert(sender.frame, to: nil) else {return}
        let options = ["天气太冷了","没睡好觉，困死了","就是不想上班"]
        
        FloatMenu.share.selected = label.text
        FloatMenu.share.show(rect, options: options) { (_, text) in
            self.label.text = text
        }
    }
    @IBAction func buttonItemClick(_ sender: UIBarButtonItem) {
        let rect = CGRect(x: UIScreen.main.bounds.width - 48, y: 36, width: 40, height: 20)
        let options = ["天气太冷了","没睡好觉，困死了","就是不想上班"]
        FloatMenu.share.selected = label.text
        FloatMenu.share.show(rect, options: options) { (_, text) in
            self.label.text = text
        }
    }
    
}
