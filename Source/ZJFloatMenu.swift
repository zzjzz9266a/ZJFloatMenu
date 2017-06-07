//
//  PullDownMenu.swift
//  DropDownMenu-Demo
//
//  Created by ZhuFaner on 2017/6/1.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

class FloatMenu: NSObject {
    
    static let share = FloatMenu()
    
    //已选的内容
    public var selected: String?
    
    //选择菜单项的回调
    public var finishCallBack: ((_ index: Int, _ title: String) -> Void)?
    
    //显示的动画类型
    public var showType: ShowType = .fade
    
    //是否显示箭头
    public var showTriangle: Bool = false
    
    //动画时长
    public var duration: TimeInterval = 0.25
    
    //遮罩透明度：0~1
    public var opaque: CGFloat = 0.2
    
    public var tableCornerRadius: CGFloat = 3{
        didSet{
            optionsList.layer.cornerRadius = oldValue
        }
    }
    
    private var mask: MaskView = MaskView(frame: UIScreen.main.bounds)
    
    private var triangle = Triangle()
    
    private var isShown:Bool = false
    
    private var triangleHeight: CGFloat{
        return Triangle.triangleHeight
    }
    
    private var rect: CGRect = CGRect.zero
    
    public var options:Array<String> = [] {//菜单项数据，设置后自动刷新列表
        didSet {
            reload()
        }
    }
    
    //菜单项的每一行行高，默认和本控件一样高，如果为0则和本空间初始高度一样
    private var _rowHeight:CGFloat = 0
    public var rowHeight:CGFloat {
        get{
            if _rowHeight == 0{
                return 44
            }
            return _rowHeight
        }
        set{
            _rowHeight = newValue
            reload()
        }
    }
    
    // 菜单展开的最大高度，当它为0时全部展开
    private var _menuMaxHeight:CGFloat = 0
    public var menuHeight : CGFloat{
        get {
            if _menuMaxHeight == 0{
                return CGFloat(self.options.count) * self.rowHeight
            }
            return min(_menuMaxHeight, CGFloat(self.options.count) * self.rowHeight)
        }
        set {
            _menuMaxHeight = newValue
            reload()
        }
    }
    
    public var menuWidth: CGFloat = 150{
        didSet{
            reload()
        }
    }
    
    public var textColor: UIColor?{
        didSet{
            reload()
        }
    }
    
    public var font: UIFont?{
        didSet{
            reload()
        }
    }

    //下拉列表
    private lazy var optionsList:UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        table.dataSource = self
        table.delegate = self
        table.layer.cornerRadius = self.tableCornerRadius
        table.layer.masksToBounds = true
        table.alpha = 0
        return table
    }()
    
    private var keyWindow: UIWindow?{
        return UIApplication.shared.keyWindow
    }
    
    //最终坐标
    private var originX: CGFloat{
        if menuWidth + rect.origin.x > UIScreen.main.bounds.width{
            return rect.maxX - menuWidth
        }else{
            return rect.origin.x
        }
    }
    
    //最终坐标
    private var originY: CGFloat{
        if menuHeight+rect.origin.y+rect.size.height > UIScreen.main.bounds.height{
            return rect.origin.y - menuHeight - (showTriangle ? triangleHeight : 0)
        }else{
            return rect.maxY + (showTriangle ? triangleHeight : 0)
        }
    }
    
    //初始坐标
    private var startX: CGFloat{
        return menuWidth + rect.origin.x > UIScreen.main.bounds.width ? rect.maxX : rect.origin.x
    }
    
    //初始坐标
    private var startY: CGFloat{
        return menuHeight+rect.origin.y+rect.size.height > UIScreen.main.bounds.height ? rect.origin.y : rect.maxY
    }
    
    override init() {
        super.init()
        mask.addSubview(optionsList)
    }
    
    func show(_ rect: CGRect, options: Array<String>, finish: ((_ index: Int, _ title: String) -> Void)?){
        self.rect = rect
        self.options = options
        self.finishCallBack = finish
        
        mask.frame = UIScreen.main.bounds
        keyWindow?.addSubview(mask)

        optionsList.reloadData()
        
        switch showType{
        case .line:  lineShow()
        case .point: pointShow()
        case .fade:  fadeShow()
        }
        addTriangle()
    }
    
    //绘制箭头
    private func addTriangle(){
        if showTriangle{
            mask.addSubview(triangle)
            
            if menuHeight+rect.origin.y+rect.size.height <= UIScreen.main.bounds.height{    //箭头向上
                triangle.up = true
                triangle.frame = CGRect(x: rect.origin.x+(rect.width-Triangle.triangleWidth)/2, y: rect.maxY, width: Triangle.triangleWidth, height: Triangle.triangleHeight)
            }else{  //箭头向下
                triangle.up = false
                triangle.frame = CGRect(x: rect.origin.x+(rect.width-Triangle.triangleWidth)/2, y: rect.origin.y-Triangle.triangleHeight, width: Triangle.triangleWidth, height: Triangle.triangleHeight)
            }
            triangle.setNeedsDisplay()
            triangle.alpha = 0
            UIView.animate(withDuration: duration, animations: {
                self.triangle.alpha = 1
            })
        }
    }
    
    private func fadeShow(){
        optionsList.frame = CGRect(x: originX, y: originY, width: menuWidth, height: menuHeight)
        optionsList.alpha = 0
        UIView.animate(withDuration: duration, animations: {
            self.optionsList.alpha = 1
            self.mask.backgroundColor = UIColor(white: 0, alpha: self.opaque)
        }) { (finish) in
            if finish{
                self.isShown = true
            }
        }
    }
    
    private func lineShow(){
        optionsList.alpha = 1
        optionsList.frame = CGRect(x: originX, y: startY, width: menuWidth, height: 0)
        UIView.animate(withDuration: duration, animations: {
            self.optionsList.frame = CGRect(x: self.originX, y: self.originY, width: self.menuWidth, height: self.menuHeight)
            self.mask.backgroundColor = UIColor(white: 0, alpha: self.opaque)
        }) { (finish) in
            if finish{
                self.isShown = true
            }
        }
    }
    
    private func pointShow(){
        optionsList.alpha = 1
        optionsList.frame = CGRect(x: startX, y: startY, width: 0, height: 0)
        
        UIView.animate(withDuration: duration, animations: {
            self.optionsList.frame = CGRect(x: self.originX, y: self.originY, width: self.menuWidth, height: self.menuHeight)
            self.mask.backgroundColor = UIColor(white: 0, alpha: self.opaque)
        }) { (finish) in
            if finish{
                self.isShown = true
            }
        }
    }
    
    func hide(){
        UIView.animate(withDuration: duration, animations: {
            self.mask.backgroundColor = UIColor(white: 0, alpha: 0)
            switch self.showType {
            case .line:
                self.optionsList.frame = CGRect(x: self.originX, y: self.startY, width: self.menuWidth, height: 0)
            case .point:
                self.optionsList.frame = CGRect(x: self.startX, y: self.startY, width: 0, height: 0)
                break
            case .fade:
                self.optionsList.alpha = 0
                self.triangle.alpha = 0
            }

        }) { (finish) in
            if finish{
                self.isShown = false
                self.mask.removeFromSuperview()
                self.triangle.removeFromSuperview()
                self.finishCallBack = nil
                self.selected = nil
            }
        }
    }
    
    private func reload(){
        if !self.isShown {
            return
        }
        optionsList.reloadData()
        UIView.animate(withDuration: duration, animations: {
            self.mask.backgroundColor = UIColor(white: 0, alpha: 0.4)
            self.optionsList.frame = CGRect(x: self.originX, y: self.originY, width: self.menuWidth, height: self.menuHeight)
        }) { finish in
            if finish{
                self.isShown = true
            }
        }
    }
}

extension FloatMenu: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "")
        if selected == options[indexPath.row]{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        cell.textLabel?.font = font
        cell.textLabel?.textColor = textColor
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        finishCallBack?(indexPath.row, options[indexPath.row])
        hide()
    }
}

fileprivate extension UIView{
    var origin: CGPoint{
        set{
            self.frame = CGRect(x: newValue.x, y: newValue.y, width: width, height: height)
        }
        get{
            return frame.origin
        }
    }
    
    var x: CGFloat{
        set{
            let origin = self.origin
            self.origin = CGPoint(x: newValue, y: origin.y)
        }
        get{
            return origin.x
        }
    }
    
    var y: CGFloat{
        set{
            let origin = self.origin
            self.origin = CGPoint(x: origin.x, y: newValue)
        }
        get{
            return origin.y
        }
    }
    
    var size: CGSize{
        set{
            let bounds = self.bounds
            self.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: newValue.width, height: newValue.height)
        }
        get{
            return bounds.size
        }
    }
    
    var width: CGFloat{
        set{
            size = CGSize(width: newValue, height: size.height)
        }
        get{
            return size.width
        }
    }
    
    var height: CGFloat{
        set{
            size = CGSize(width: width, height: newValue)
        }
        get{
            return size.height
        }
    }
}

fileprivate class MaskView: UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0, alpha: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor(white: 0, alpha: 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        FloatMenu.share.hide()
    }
}

fileprivate class Triangle: UIView{
    static var triangleWidth: CGFloat = 16
    
    static var triangleHeight: CGFloat = 8
    
    private var triangleLayer: CAShapeLayer?
    
    //箭头方向
    public var up: Bool = true
    
    override func draw(_ rect: CGRect) {
        triangleLayer?.removeFromSuperlayer()
        triangleLayer = nil
        let path = UIBezierPath()
        let trianglePoint = CGPoint(x: width/2, y: up ? 0 : height)
        path.move(to: trianglePoint)
        let triangleY = up ? (trianglePoint.y + Triangle.triangleHeight) : (trianglePoint.y - Triangle.triangleHeight)
        path.addLine(to: CGPoint(x: trianglePoint.x - Triangle.triangleWidth * 0.5, y: triangleY))
        path.addLine(to: CGPoint(x: trianglePoint.x + Triangle.triangleWidth * 0.5, y: triangleY))
        triangleLayer = CAShapeLayer()
        triangleLayer!.path = path.cgPath
        triangleLayer!.fillColor = UIColor.white.cgColor
        triangleLayer!.strokeColor = UIColor.white.cgColor
        layer.addSublayer(triangleLayer!)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: Triangle.triangleWidth, height: Triangle.triangleHeight))
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
