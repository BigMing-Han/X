//
//  List.swift
//  XFrame
//
//  Created by 刘强 on 2017/5/13.
//  Copyright © 2017年 XiaoJiao Chen. All rights reserved.
//

import UIKit

public class ListView: UIScrollView, UIScrollViewDelegate {
    
    private var callback:[Any?] = []
    private var contentHeight:CGFloat = 0
    private var titles:[UILabel] = []
    private var values:[UILabel] = []
    
    // - 刷新控制
    private var oldFrame:CGRect?
    private var lockOffset:CGPoint?
    private var startRefresh:Any?
    private var topRefreshHeight:CGFloat = 60
    private var topRefreshView:UIView?
    private var topRefreshStep:Any?
    private var bottomRefreshHeight:CGFloat = 60
    private var bottomRefreshView:UIView?
    private var bottomRefreshStep:Any?
    
    // - 微调变量
    public var margin:CGFloat = 0
    public var marginColor:UIColor = UIColor.clear
    public var itemColor:UIColor = UIColor.white
    public var clickEnabled:Bool = true
    public var titleFont:UIFont = UIFont.systemFont(ofSize: 14)
    public var valueFont:UIFont = UIFont.systemFont(ofSize: 14)
    // - 记录时间
    private var lastClick:UIView?
    
    // - 对象记录
    public var items:[UIView] = []
    
    public init(frame: CGRect, params:[String:Any]? = nil) {
        super.init(frame: frame)
        
        if let margin = params?["margin"] as? CGFloat
        {
            self.margin = margin
        }
        
        if let marginColor = params?["marginColor"] as? UIColor
        {
            self.marginColor = marginColor
        }
        
        if let itemColor = params?["itemColor"] as? UIColor
        {
            self.itemColor = itemColor
        }
        
        if let itemBackgroundColor = params?["itemBackgroundColor"] as? UIColor
        {
            self.marginColor = itemBackgroundColor
        }
        
        self.oldFrame = self.frame
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //设置内容高度
    public func setContentHeight(height: CGFloat)
    {
        self.contentHeight = height
        self.updateContentHeight()
    }
    
    //更新当前高度
    private func updateContentHeight()
    {
        if self.delegate != nil
        {
            if self.contentHeight > self.frame.height
            {
                self.contentSize = CGSize(width: (self.oldFrame?.width)!, height: self.contentHeight)
            }else
            {
                self.contentSize = CGSize(width: (self.oldFrame?.width)!, height: (self.oldFrame?.height)! + 1)
            }
        }else
        {
            self.contentSize = CGSize(width: (self.oldFrame?.width)!, height: self.contentHeight)
        }
    }
    
    
    //设置函数 - title
    public func setTitle(row:Int, text:String?)
    {
        if self.titles.count > row && text != nil
        {
            self.titles[row].text = text!
        }
    }
    
    // - value
    public func setValue(row:Int, text:String?)
    {
        if self.values.count > row && text != nil
        {
            let label = self.values[row]
            label.text = text!
            let width = label.text?.widthWithConstrainedWidth(width: self.frame.width, WithFont: label.font)
            let cha = Math.abs(number: width! - label.frame.width)
            
            label.frame = CGRect(x: label.frame.minX - cha, y: 0, width: width!, height: label.frame.height)
        }
    }
    
    // - 设置结束
    
    //添加函数 - height
    
    public func addItem(height:CGFloat, title:[String:UIColor]? = nil, icon:UIImage? = nil, arrow:Bool? = false, callback: (() -> Void)? = nil)
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: height))
        view.backgroundColor = self.itemColor
        self.addItem(view: view, title: title, icon: icon, arrow: arrow, callback: callback)
    }
    
    //添加函数 - view
    public func addItem(view:UIView, title:[String:UIColor]? = nil, icon:UIImage? = nil, arrow:Bool? = false, callback: (() -> Void)? = nil)
    {
        var left:CGFloat = 0
        var titleColor:UIColor = UIColor.black
        var titleContent:String = ""
        let titleHeight:CGFloat = titleContent.heightWithConstrainedWidth(width: view.frame.width, font: self.valueFont)
        var titleLeft:UILabel = UILabel()
        var titleRight:UILabel = UILabel()
        
        if title != nil
        {
            for i in title!
            {
                titleColor = i.value
                titleContent = i.key
            }
        }
        
        let picH = titleHeight > 0 ? titleHeight * 0.6 : view.frame.height * 0.6
        let margin = (view.frame.height - picH) / 2
        
        if icon != nil
        {
            let scale = picH / (icon?.size.height)!
            let img = icon?.scaleImage(scaleSize: scale).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            let imgview = UIImageView(image: img)
            imgview.frame = CGRect(x: margin, y: margin, width: (img?.size.width)!, height: (img?.size.height)!)
            view.addSubview(imgview)
            left = imgview.frame.maxX + margin
        }
        
        if arrow!
        {
            var img = UIView(frame: CGRect(x: 0, y: 0, width: picH * 5, height: picH * 5)).icon(image: "right").scaleImage(scaleSize: 0.2)
            img = img.setColor(color: titleColor)
            let imgview = UIImageView(image: img)
            imgview.frame = CGRect(x: view.frame.width - img.size.width - margin, y: margin, width: (img.size.width), height: (img.size.height))
            imgview.alpha = 0.5
            view.addSubview(imgview)
        }
        
        if title != nil {
            if icon == nil
            {
                left = view.frame.height * 0.4
            }
            
            let titles = NSString(string: titleContent).components(separatedBy: "=")
            let labelW = view.frame.width - left - (arrow! ? view.frame.height : 0)
            var rightW:CGFloat = 0
            
            //第二title放在右侧
            if titles.count == 2
            {
                //取出实际宽度并且作为优先宽度
                let titleWidth = titles[1].widthWithConstrainedWidth(width: labelW, WithFont: self.valueFont)
                let label = UILabel(frame: CGRect(x: labelW - titleWidth + left - (arrow! ? 0 : picH), y: 0, width: titleWidth, height: view.frame.height))
                rightW = titleWidth
                label.text = titles[1]
                label.textColor = titleColor
                label.font = self.valueFont
                label.alpha = 0.5
                view.addSubview(label)
                
                titleRight = label
            }
            
            let label = UILabel(frame: CGRect(x: left, y: 0, width: labelW - rightW, height: view.frame.height))
            label.text = titles[0]
            label.textColor = titleColor
            label.font = self.titleFont
            view.addSubview(label)
            
            titleLeft = label
        }
        
        //全局记录对象
        self.items.append(view)
        
        //使用容器加载定位简化
        let viewbox = UIView(frame: CGRect(x: 0, y: self.contentHeight, width: self.frame.width, height: view.frame.height + self.margin))
        viewbox.backgroundColor = self.marginColor
        viewbox.addSubview(view)
        
        //添加透明按钮，用于添加操作
        if self.clickEnabled
        {
            let button = UIButton(frame: view.frame)
            button.addTarget(self, action: #selector(self.touchUpInside), for: UIControlEvents.touchUpInside)
            button.tag = 10000 + self.titles.count
            viewbox.addSubview(button)
        }
        
        self.titles.append(titleLeft)
        self.values.append(titleRight)
        
        self.contentHeight += viewbox.frame.height
        self.addSubview(viewbox)
        
        let append:Any? = callback != nil ? callback! : nil
        self.callback.append(append)
        
        self.updateContentHeight()
        
        //更新记录FRAME
        
        if self.bottomRefreshView?.alpha == 1
        {
            self.bottomRefreshView?.superview?.frame.origin.y = self.contentHeight
        }
    }
    
    @objc public func touchUpInside(btn: UIButton)
    {
        btn.backgroundColor = UIColor.colorWithHexString("#000000", 0.05)
        
        let tag = btn.tag - 10000
        let cb:Any? = self.callback[tag]
        
        self.lastClick = self.items[tag]
        
        if cb != nil
        {
            (cb as! () -> Void)()
        }
        
        let _ = delay(0.1) {
            btn.backgroundColor = UIColor.clear
        }
    }
    
    // - 添加结束
    
    //get 函数 - value
    public func getValue(row:Int) -> String
    {
        if self.values.count > row
        {
            let label = self.values[row]
            return label.text!
        }
        
        return ""
    }
    
    
    // - 监听刷新事件
    public func addListener(topview: UIView? = nil, bottomview: UIView? = nil, refresh: @escaping (String) -> Void, topStep: ((UIView) -> Void)? = nil, bottomStep: ((UIView) -> Void)? = nil)
    {
        //        print("监听刷新")
        
        //添加代理
        self.delegate = self
        
        self.startRefresh = refresh
        self.topRefreshStep = topStep
        self.bottomRefreshStep = bottomStep
        
        //超出显示
        self.clipsToBounds = false
        
        
        //增加顶部无限高度占位VIEW
        let bottom_View = UIView(frame: CGRect(x: WINDOW_WIDTH - self.frame.width - self.frame.minX, y: -WINDOW_HEIGHT, width: WINDOW_WIDTH, height: WINDOW_HEIGHT))
        bottom_View.backgroundColor = self.backgroundColor
        self.addSubview(bottom_View)
        //设置BOTTOM VIEW
        if bottomview != nil
        {
            
        }else
        {
            let refreshView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.bottomRefreshHeight))
            let loadingHeight = self.bottomRefreshHeight * 0.6
            let loading = UIView(frame: CGRect(x: (refreshView.frame.width - loadingHeight) / 2, y: (self.bottomRefreshHeight - loadingHeight) / 2, width: loadingHeight, height: loadingHeight)).icon(name: "loading")
            loading.tintColor = UIColor.white
            loading.layer.animate(type: "transform.rotation", form: 0, to: 2 * CGFloat(Double.pi), duration: 0.8, repeatCount: MAXFLOAT)
            
            refreshView.addSubview(loading)
            self.bottomRefreshView = refreshView
            
            bottom_View.addSubview(refreshView)
        }
        
        self.bottomRefreshView?.alpha = 0
        
        //增加顶部无限高度占位VIEW
        let top_View = UIView(frame: CGRect(x: WINDOW_WIDTH - self.frame.width - self.frame.minX, y: -WINDOW_HEIGHT, width: WINDOW_WIDTH, height: WINDOW_HEIGHT))
        top_View.backgroundColor = self.backgroundColor
        self.addSubview(top_View)
        
        //设置TOP VIEW
        if topview != nil
        {
            
        }else
        {
            let refreshView = UIView(frame: CGRect(x: 0, y: top_View.frame.height - self.topRefreshHeight, width: self.frame.width, height: self.topRefreshHeight))
            let loadingHeight = self.topRefreshHeight * 0.6
            let loading = UIView(frame: CGRect(x: (refreshView.frame.width - loadingHeight) / 2, y: (self.topRefreshHeight - loadingHeight) / 2, width: loadingHeight, height: loadingHeight)).icon(name: "loading")
            loading.tintColor = UIColor.white
            loading.layer.animate(type: "transform.rotation", form: 0, to: 2 * CGFloat(Double.pi), duration: 0.8, repeatCount: MAXFLOAT)
            
            refreshView.addSubview(loading)
            self.topRefreshView = refreshView
            
            top_View.addSubview(refreshView)
        }
        
        self.topRefreshView?.alpha = 0
    }
    
    public func endRefresh()
    {
        UIView.animate(withDuration: 0.2, animations: {
            self.frame.origin.y = (self.oldFrame?.origin.y)!
            self.frame.size.height = (self.oldFrame?.size.height)!
            self.topRefreshView?.alpha = 0
            self.bottomRefreshView?.alpha = 0
        })
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if self.frame == self.oldFrame
        {
            if scrollView.contentOffset.y < 10 - self.topRefreshHeight
            {
                self.lockOffset = scrollView.contentOffset
                //显示顶部LOADING VIEW
                self.topRefreshView?.alpha = 1
                //                print("下拉刷新")
            }else if self.contentHeight >= self.contentSize.height
            {
                if scrollView.contentSize.height - scrollView.contentOffset.y < scrollView.frame.height - self.bottomRefreshHeight
                {
                    //                    print("上拉刷新")
                    self.lockOffset = scrollView.contentOffset
                    //父级容器位置更新
                    self.bottomRefreshView?.superview?.frame.origin.y = self.contentHeight
                    UIView.animate(withDuration: 0.2, animations: {
                        self.bottomRefreshView?.alpha = 1
                    })
                }
            }
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let target = self.lockOffset
        {
            scrollView.contentOffset.y = (target.y) + Math.abs(number: (self.oldFrame?.origin.y)! - self.frame.origin.y)
        }
        
        if self.topRefreshStep != nil
        {
            (self.topRefreshStep as! (UIView) -> Void)(self.topRefreshView!)
        }
        
        if self.bottomRefreshStep != nil
        {
            (self.bottomRefreshStep as! (UIView) -> Void)(self.bottomRefreshView!)
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.lockOffset != nil
        {
            //            print("结束")
            
            var type = ""
            
            UIView.animate(withDuration: 0.2, animations: {
                if (self.lockOffset?.y)! < CGFloat(0)
                {
                    //下拉
                    type = "TOP"
                    self.frame.origin.y = (self.oldFrame?.origin.y)! + self.topRefreshHeight
                    self.frame.size.height = (self.oldFrame?.size.height)! - self.topRefreshHeight
                }else if self.contentHeight >= self.contentSize.height
                {
                    //上拉
                    type = "BOTTOM"
                    self.frame.size.height = (self.oldFrame?.size.height)! - self.topRefreshHeight
                }
            }, completion: { (b) in
                self.lockOffset = nil
                (self.startRefresh as! (String) -> Void)(type)
            })
        }
    }
    
    
    // - 栅格样式
    public func getHList(count: Int, height: CGFloat = 100, callback: (UIView) -> Void)
    {
        let frame = self.frame
        let width:CGFloat = frame.width / CGFloat(count)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: height))
        
        for i in 0..<count
        {
            let v = UIView(frame: CGRect(x: CGFloat(i) * width, y: 0, width: width, height: view.frame.height))
            view.addSubview(v)
        }
        
        view.backgroundColor = self.itemColor
        self.addItem(view: view)
        
        //方法回调
        callback(view)
    }
    
    // - 获取最后一次点击的对象
    public func getLastClickView() -> UIView
    {
        return self.lastClick!
    }
}
