//
//  Swiper.swift
//  xframe
//
//  Created by XiaoJiao Chen on 2017/5/8.
//  Copyright © 2017年 XiaoJiao Chen. All rights reserved.
//

import UIKit

public class Swiper: UIScrollView, UIScrollViewDelegate {
    
    private var on_click:Any?
    private var on_animate:Any?
    private var childs:[Any] = []
    public var current_index:Int = 0
    public var active_index:Int? = nil
    private var show_count:CGFloat = 1
    private var last_offset:CGPoint? = nil
    private var tabs_view:UIScrollView?
    //状态栏
    private var status:Bool?
    //指示条
    public var bar:UIView?
    private var bar_scale:CGFloat = 0.5
    //锁定
    private var click_lock:Bool = false
    private var scroll_lock:Bool = false
    //绑定的swiper
    private var other:Swiper?
    //是否触发自动
    public var auto_move:Bool = false
    //动画速度
    public var animate_speed:CGFloat = 0.2
    
    /**************** colors
     text:文字颜色
     selected: 选择后文字颜色
     bar: 指示条宽颜色
     bg: 背景颜色
     ****************/
    
    /**************** param
     fontsize:文字大小
     status: 顶部状条占位
     barScale: 指示条宽比例
     barHeight: 指示条高
     barYPosition: Y轴偏移量
     barCornerRadius: 底部条圆角
     ****************/
    
    //创建tabs
    public init(frame: CGRect, count: CGFloat, tabs: [String], colors:[String:UIColor]? = nil,param:[String:String]? = nil) {
        super.init(frame: frame)
        self.tabs_view = UIScrollView(frame: frame)
        self.show_count = count
        let one_width:CGFloat = frame.width / count
        self.tabs_view?.contentSize = CGSize(width: one_width * CGFloat(tabs.count), height: frame.height)
        self.tabs_view?.showsHorizontalScrollIndicator = false
        for i in 0..<tabs.count
        {
            //创建tab
            let tab = UIButton(frame: CGRect(x: one_width * CGFloat(i), y: 0, width: one_width, height: frame.height))
            self.childs.append(tab)
            
            //创建文字
            var fontsize:CGFloat = 14
            tab.setTitle(tabs[i], for: UIControlState.normal)
            if param?["fontsize"] != nil
            {
                fontsize = (param?["fontsize"]?.toCGFloat())!
            }
            tab.titleLabel?.font = UIFont.systemFont(ofSize: fontsize)
            
            if param?["status"] != nil
            {
                self.status = true
                tab.titleEdgeInsets = UIEdgeInsets(top: 20, left: 0.0, bottom: 0.0, right: 0.0)
            }
            
            if colors?["text"] != nil
            {
                tab.setTitleColor(colors?["text"], for: UIControlState.normal)
                if colors?["selected"] != nil
                {
                    tab.setTitleColor(colors?["selected"], for: UIControlState.selected)
                    tab.isSelected = false
                }
            }
            
            self.tabs_view?.addSubview(tab)
            
            //绑定点击事件
            tab.addTarget(self, action: #selector(self.onClick), for: UIControlEvents.touchUpInside)
        }
        
        // 创建指示条
        if colors?["bar"] != nil
        {
            //设置bar长度比例
            if param?["barScale"] != nil
            {
                self.bar_scale = (param?["barScale"]?.toCGFloat())!
            }
            
            //设置bar高度
            var bar_height:CGFloat = 3
            if param?["barHeight"] != nil
            {
                bar_height = (param?["barHeight"]?.toCGFloat())!
            }
            
            let yposition = param?["barYPosition"] != nil ? (param?["barYPosition"]?.toCGFloat())! : 0
            self.bar = UIView(frame: CGRect(x: 0, y: self.frame.height - bar_height - yposition, width: one_width, height: bar_height))
            let bar = UIView(frame: CGRect(x: one_width * (1 - self.bar_scale) / 2, y: 0, width: one_width * self.bar_scale, height: bar_height))
            bar.backgroundColor = colors?["bar"]!
            if param?["barCornerRadius"] != nil {
                bar.layer.cornerRadius = (param?["barCornerRadius"]?.toCGFloat())!
                bar.layer.masksToBounds = true
            }
            self.bar?.addSubview(bar)
            self.tabs_view?.addSubview(self.bar!)
        }
        
        //背景图片
        if colors?["bg"] != nil
        {
            self.backgroundColor = colors?["bg"]
        }
        
        self.addSubview(self.tabs_view!)
        
    }
    
    public init(frame: CGRect, count:CGFloat, views:[Any])
    {
        super.init(frame: frame)
        
        self.show_count = count
        let one_width:CGFloat = frame.width / count
        self.contentSize = CGSize(width: one_width * CGFloat(views.count), height: self.frame.height)
        self.showsHorizontalScrollIndicator = false
        
        for i in 0..<views.count
        {
            if let view = views[i] as? UIView
            {
                view.frame = CGRect(x: one_width * CGFloat(i), y: 0, width: one_width, height: frame.height)
                self.childs.append(view)
                self.addSubview(view)
            }
        }
        
        self.last_offset = self.contentOffset
        self.delegate = self
        self.bounces = false
        self.active_index = 0
        self.decelerationRate = 0
    }
    
    public func setBackBtn(btn: UIButton)
    {
        if self.bar != nil{
            self.tabs_view?.frame = CGRect(x: btn.frame.width, y: 0, width: (self.tabs_view?.frame.width)! - btn.frame.width, height: (self.tabs_view?.frame.height)!)
            btn.frame = CGRect(x: 0, y: 0, width: btn.frame.width, height: btn.frame.height)
            if self.status!
            {
                btn.titleEdgeInsets = UIEdgeInsets(top: 20, left: 0.0, bottom: 0.0, right: 0.0)
                btn.imageEdgeInsets = UIEdgeInsets(top: 20, left: -btn.frame.width/2, bottom: 0.0, right: 0.0)
            }
            self.addSubview(btn)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //设置
    
    //绑定点击
    public func addListener(onclick: @escaping (Swiper) -> Void)
    {
        self.on_click = onclick
    }
    
    //绑定动画
    public func addListener(animate: @escaping (Swiper) -> Void)
    {
        self.on_animate = animate
    }
    
    //点击操作
    @objc public func onClick(btn: UIButton)
    {
        self.onClickAction(btn: btn)
        
        if self.on_click != nil
        {
            (self.on_click as! (Swiper) -> Void)(self)
        }
        
        // 绑定操作
        if self.other != nil
        {
            self.other?.toIndex(index: self.active_index!, isclick: true)
        }
        
        // - 将当前值改成目标值
        self.current_index = self.active_index!
    }
    
    //点击重复调用
    public func onClickAction(btn: UIButton)
    {
        if self.click_lock {
            return
        }
        
        self.click_lock = true
        
        for i in self.childs
        {
            if let b = i as? UIButton
            {
                b.isSelected = b == btn ? true : false
            }
        }
        
        //swift 浮点转整型出错 直接截取制服穿后转整型
        let index:CGFloat = btn.frame.minX / self.frame.width * self.show_count
        let show_countStr = "\(index)"
        let component = show_countStr.components(separatedBy: ".")
        let showCount = component[0]
        self.active_index = Int(showCount)
        
        if self.bar != nil
        {
            UIView.animate(withDuration: TimeInterval(self.animate_speed), animations: {
                let frame = self.bar?.frame
                let x = (frame?.width)! * index
                self.bar?.frame = CGRect(x: x, y: (frame?.minY)!, width: (frame?.width)!, height: (frame?.height)!)
                self.click_lock = false
            })
        }else{
            self.click_lock = false
        }
    }
    
    //指定跳转
    public func toIndex(index:Int, isclick:Bool = false)
    {
        let maxindex = index < self.childs.count ? index : self.childs.count - 1
        let one_width:CGFloat = self.frame.width / self.show_count
        var point = CGPoint(x: one_width * CGFloat(maxindex), y: self.contentOffset.y)
        self.last_offset = point
        
        if self.bar != nil
        {
            if !isclick
            {
                if let btn = self.childs[maxindex] as? UIButton
                {
                    self.onClickAction(btn: btn)
                }
            }
            
            let maxX = ((self.tabs_view?.contentSize.width)! - (self.tabs_view?.frame.width)!)
            
            if point.x > maxX
            {
                point = CGPoint(x: maxX, y: point.y)
            }
            
            UIView.animate(withDuration: TimeInterval(self.animate_speed), animations: {
                self.tabs_view?.contentOffset = point
                self.active_index = maxindex
                self.scroll_lock = false
            })
            
        }else{
            
            UIView.animate(withDuration: TimeInterval(self.animate_speed), animations: {
                self.contentOffset = point
                self.active_index = maxindex
                self.scroll_lock = false
            })
        }
    }
    
    //双控绑定
    public func bind(other: Swiper)
    {
        self.other = other
    }
    
    private func scrollViewAnimateActiveIndex(_ scrollView: UIScrollView, target:CGPoint? = nil) -> Int
    {
        let point = scrollView.contentOffset
        let cha = (point.x) - (self.last_offset?.x)!
        let target_cha = target != nil ? (target?.x)! - (self.last_offset?.x)! : cha
        
        if Math.abs(number: cha / scrollView.frame.width) > 0.2 || Math.abs(number: target_cha / scrollView.frame.width) > 0.2
        {
            //计算下一个目标INDEX
            let index = cha / scrollView.frame.width > 0 ? self.active_index! + 1 : self.active_index! - 1
            return index < 0 ? 0 : index
        }else{
            return self.current_index
        }
    }
    
    private func scrollAnimate(scrollView: UIScrollView, target:CGPoint? = nil)
    {
        if self.scroll_lock
        {
            return
        }
        
        self.scroll_lock =  true
        
        self.active_index = self.scrollViewAnimateActiveIndex(scrollView, target: target)
        
        let targetOffset = CGPoint(x: scrollView.frame.width * CGFloat(self.active_index!), y: scrollView.contentOffset.y)
        
        //动画开始
        if self.active_index != self.current_index
        {
            UIView.animate(withDuration: TimeInterval(self.animate_speed), animations: {
                scrollView.contentOffset = targetOffset
            }, completion: { (finished) in
                self.last_offset = targetOffset
                self.current_index = self.active_index!
                if self.on_animate != nil
                {
                    (self.on_animate as! (Swiper) -> Void)(self)
                }
                // 绑定操作
                if self.other != nil
                {
                    self.other?.toIndex(index: self.active_index!)
                }
                
                self.scrollViewReset(scrollView)
            })
        }else
        {
            scrollView.setContentOffset(targetOffset, animated: true)
            if self.last_offset == targetOffset
            {
                self.scrollViewReset(scrollView)
            }
        }
    }
    
    //滚动状态修复
    public func scrollViewReset(_ scrollView: UIScrollView)
    {
        self.last_offset = scrollView.contentOffset
        self.scroll_lock = false
        scrollView.isScrollEnabled = true
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollView.isDecelerating && !self.scroll_lock && self.auto_move
        {
            let activeIndex = scrollViewAnimateActiveIndex(scrollView)
            //第二个lock是避免计算时差
            if !self.scroll_lock && activeIndex != self.current_index
            {
                scrollView.isScrollEnabled = false
                //                print("activeIndex:\(activeIndex) isDragging:\(scrollView.isDragging) isDecelerating:\(scrollView.isDecelerating)")
                self.scrollAnimate(scrollView: scrollView)
            }
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //        print("end:\(scrollView.contentOffset)  decelerate:\(decelerate) isDragging:\(scrollView.isDragging) isDecelerating:\(scrollView.isDecelerating)")
        if !scrollView.isDragging
        {
            self.scrollAnimate(scrollView: scrollView)
        }
    }
    
    //scollview减速将要结束代理
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //        print("willend:\(scrollView.contentOffset)  \(velocity) \(targetContentOffset.pointee) isDragging:\(scrollView.isDragging) isDecelerating:\(scrollView.isDecelerating)")
        if scrollView.isDragging
        {
            let target = targetContentOffset.pointee
            targetContentOffset.pointee = scrollView.contentOffset
            self.scrollAnimate(scrollView: scrollView, target: target)
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollViewReset(scrollView)
    }
}

