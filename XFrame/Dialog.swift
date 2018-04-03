//
//  File.swift
//  XFrame
//
//  Created by 刘强 on 2017/6/2.
//  Copyright © 2017年 XiaoJiao Chen. All rights reserved.
//

import Foundation

public class Dialog {
    public enum ALERTTYPE :String
    {
        case TIME = "time"
        case LOCK = "lock"
        case TRADE = "trade"
        case HELP = "help"
        case SUCCESS = "success"
        case WRONG = "wrong"
        case INFORMATION = "information"
    }
    
    public class func loading(color:String? = nil, icon:UIView? = nil, parent:UIView? = nil, callback: ((AnimateUIView) -> Void)? = nil)
    {
        let color = color != nil ? color : "#5bc0de"
        
        let w:CGFloat = 80
        let iconW = w * 0.6
        let margin:CGFloat = 15
        let h:CGFloat = 80
        
        var loadingBox = AnimateUIView(frame: UIScreen.main.bounds)
        loadingBox.tagName = "Dialog"
        loadingBox.queue = [["transform.scale", 0.8, 1.1, "0.1"], ["transform.scale", 1.1, 1, "0.1"]]
        
        // - 创建loading
        let loading = UIView(frame: CGRect(x: (WINDOW_WIDTH - w) / 2, y: (WINDOW_HEIGHT - h) / 2 - h / 5, width: w, height: h))
        loading.layer.cornerRadius = margin
        loading.backgroundColor = UIColor.colorWithHexString("#FFFFFF")
        
        let icon = (icon == nil ? UIView(frame: CGRect(x: (w - iconW) / 2 , y: (h - iconW) / 2, width: iconW, height: iconW)).icon(name: "loading", fillcolor: color!) : icon!)
        
        icon.layer.animate(type: "transform.rotation", form: 0, to: 2 * CGFloat(Double.pi), duration: 0.8, repeatCount: MAXFLOAT)
        loading.addSubview(icon)
        
        // - 添加关闭动画
        let endFunc = {
            loadingBox.queue = [["transform.scale", 1, 1.1, "0.05"], ["transform.scale", 1.1, 0.8, "0.1"], ["opacity", 1, 0, "0.1"], [{
                loadingBox.layer.removeAllAnimations()
                loadingBox.removeFromSuperview()
                loadingBox = AnimateUIView()
                }]]
        }
        loadingBox.queue.append([endFunc])
        
        loadingBox.addSubview(loading)
        loadingBox.run()
        
        if parent != nil
        {
            parent?.addSubview(loadingBox)
        }else
        {
            UIApplication.shared.keyWindow?.addSubview(loadingBox)
        }
        
        if callback != nil
        {
            callback!(loadingBox)
        }
    }
    
    public class func loadingProgress(color:String? = nil, icon:UIView? = nil, parent: UIView? = nil, callback: ((_ loadingBar: UIView, _ loadingBox: AnimateUIView) -> Void))
    {
        let color = color != nil ? color : "#5bc0de"
        
        //        let font = UIFont.systemFont(ofSize: 16)
        let w = WINDOW_WIDTH / 1.2
        let iconW = w / 5
        let margin:CGFloat = 15
        let h = WINDOW_HEIGHT * 0.3
        
        var loadingBox = AnimateUIView(frame: UIScreen.main.bounds)
        loadingBox.tagName = "Dialog"
        loadingBox.queue = [["transform.scale", 0.8, 1.1, "0.1"], ["transform.scale", 1.1, 1, "0.1"]]
        
        // - 创建loading
        let loading = UIView(frame: CGRect(x: (WINDOW_WIDTH - w) / 2, y: (WINDOW_HEIGHT - h) / 2 - h / 5, width: w, height: h))
        loading.layer.cornerRadius = margin
        loading.backgroundColor = UIColor.colorWithHexString("#FFFFFF")
        
        let icon = icon == nil ? UIView(frame: CGRect(x: (w - iconW) / 2 , y: margin * 2, width: iconW, height: iconW)).icon(name: "loading", fillcolor: color!) : icon!
        //        icon.onTap(target: loadingBox, action: #selector(loadingBox.run))
        icon.layer.animate(type: "transform.rotation", form: 0, to: 2 * CGFloat(Double.pi), duration: 0.8, repeatCount: MAXFLOAT)
        loading.addSubview(icon)
        
        
        // - 创建进度条
        let loadingBg = UIView(frame: CGRect(x: margin * 2, y: (icon.frame.maxY) + margin * 2, width: w - margin * 4, height: h * 0.2))
        loadingBg.backgroundColor = UIColor.colorWithHexString("#EEEEEE")
        loadingBg.layer.cornerRadius = loadingBg.frame.height * 0.5
        loading.addSubview(loadingBg)
        
        let loadingBarBg = UIView(frame: CGRect(x: margin / 5, y: margin / 5, width: loadingBg.frame.width - margin / 5 * 2, height: loadingBg.frame.height - margin / 5 * 2))
        loadingBarBg.backgroundColor = UIColor.colorWithHexString("#EEEEEE")
        loadingBarBg.layer.cornerRadius = loadingBarBg.frame.height * 0.5
        loadingBarBg.clipsToBounds = true
        loadingBg.addSubview(loadingBarBg)
        
        let loadingBar = UIView(frame: CGRect(x: 0, y: 0, width: loadingBarBg.frame.width, height: loadingBarBg.frame.height))
        loadingBar.backgroundColor = UIColor.colorWithHexString(color!)
        loadingBar.layer.cornerRadius = loadingBar.frame.height * 0.5
        loadingBarBg.addSubview(loadingBar)
        
        
        loadingBar.frame.origin.x = -loadingBar.frame.width
        
        // - 添加关闭动画
        let endFunc = {
            loadingBox.queue = [["transform.scale", 1, 1.1, "0.05"], ["transform.scale", 1.1, 0.8, "0.1"], ["opacity", 1, 0, "0.1"], [{
                loadingBox.layer.removeAllAnimations()
                loadingBox.removeFromSuperview()
                loadingBox = AnimateUIView()
                }]]
        }
        loadingBox.queue.append([endFunc])
        
        loadingBox.addSubview(loading)
        loadingBox.run()
        
        if parent != nil
        {
            parent?.addSubview(loadingBox)
        }else
        {
            UIApplication.shared.keyWindow?.addSubview(loadingBox)
        }
        
        callback(loadingBar, loadingBox)
    }
    
    // - 弹窗
    public class func alert(content:Any, title: String = "", type: ALERTTYPE, ok: (() -> Void)? = nil, cancel: (() -> Void)? = nil)
    {
        let font = UIFont.systemFont(ofSize: 16)
        let w = WINDOW_WIDTH / 1.2
        let iconW = w / 5
        
        // - 增加内容为UIView的情况
        var contentH:CGFloat = 0
        if content is String
        {
            contentH = (content as! String).heightWithConstrainedWidth(width: w, font: font)
        }else if content is UIView
        {
            contentH = (content as! UIView).frame.height
        }
        
        let titleH = title.heightWithConstrainedWidth(width: w, font: font)
        let margin:CGFloat = 15
        let h = titleH + contentH + margin * 3.5 + iconW
        
        let alert = UIView(frame: CGRect(x: (WINDOW_WIDTH - w) / 2, y: (WINDOW_HEIGHT - h) / 2 - h / 5, width: w, height: h))
        alert.layer.cornerRadius = margin - 10
        alert.backgroundColor = UIColor.colorWithHexString("#FFFFFF")
        
        // - 类型图片
        var type = type.rawValue
        var iconColor = "#5bc0de"
        switch type {
        case "trade":
            iconColor = "#337ab7"
        case "help":
            iconColor = "#f0ad4e"
        case "success":
            iconColor = "#5cb85c"
            break
        case "time":
            iconColor = "#d9534f"
            break
        case "lock":
            iconColor = "#c1c1c1"
            break
        case "wrong":
            iconColor = "#d9534f"
            break
        default:
            type = "information"
        }
        
        let icon = UIView(frame: CGRect(x: (w - iconW) / 2 , y: margin, width: iconW, height: iconW)).icon(name: type, fillcolor: iconColor)
        alert.addSubview(icon)
        
        // - 标题内容
        
        let titleLabel = UILabel(frame: CGRect(x: margin, y: icon.frame.maxY, width: w - margin * 2, height: titleH + margin * 1.5))
        titleLabel.text = title == "" ? "系统提示" : title
        titleLabel.font = font
        titleLabel.textAlignment = .center
        alert.addSubview(titleLabel)
        
        
        // content - 字符串
        var contentFrame:CGRect!
        if content is String
        {
            let contentLalbel = UILabel(frame: CGRect(x: margin, y: titleLabel.frame.maxY, width: w - margin * 2, height: contentH))
            contentLalbel.text = content as? String
            contentLalbel.font = UIFont.systemFont(ofSize: 14)
            contentLalbel.textAlignment = .center
            contentLalbel.numberOfLines = 0
            alert.addSubview(contentLalbel)
            contentFrame = contentLalbel.frame
        }else if let view = content as? UIView
        {
            // - 增加内容是UIView的情况
            alert.addSubview(view)
            view.frame.origin.y += titleLabel.frame.maxY
            contentFrame = view.frame
        }
        
        
        var alertBox = AnimateUIView(frame: UIScreen.main.bounds)
        alertBox.tagName = "Dialog"
        alertBox.queue = [["transform.scale", 0.8, 1.1, "0.1"], ["transform.scale", 1.1, 1, "0.1"]]
        
        // - 添加关闭动画
        let endFunc = {
            alertBox.queue = [["transform.scale", 1, 1.1, "0.05"], ["transform.scale", 1.1, 0.8, "0.1"], ["opacity", 1, 0, "0.1"], [{
                alertBox.layer.removeAllAnimations()
                alertBox.removeFromSuperview()
                alertBox = AnimateUIView()
                }]]
        }
        alertBox.queue.append([endFunc])
        
        // - 存在确定按钮
        if ok != nil || cancel != nil
        {
            let okBtn = UILabel(frame: CGRect(x: margin, y: contentFrame.maxY + margin, width: w / 2 - margin * 1.5, height: titleH + margin))
            okBtn.text = "确定"
            okBtn.tagName = "ok"
            okBtn.textAlignment = .center
            okBtn.backgroundColor = UIColor.colorWithHexString("#8CD4F5")
            okBtn.layer.cornerRadius = alert.layer.cornerRadius
            okBtn.layer.masksToBounds = true
            okBtn.font = UIFont.systemFont(ofSize: 14)
            okBtn.textColor = UIColor.white
            okBtn.onTap(target: alertBox, action: #selector(alertBox.onclick))
            alert.addSubview(okBtn)
            
            let cancelBtn = UILabel(frame: okBtn.frame)
            cancelBtn.text = "取消"
            cancelBtn.textAlignment = .center
            cancelBtn.backgroundColor = UIColor.colorWithHexString("#c1c1c1")
            cancelBtn.layer.cornerRadius = alert.layer.cornerRadius
            cancelBtn.layer.masksToBounds = true
            cancelBtn.font = UIFont.systemFont(ofSize: 14)
            cancelBtn.textColor = UIColor.white
            cancelBtn.frame.origin.x = okBtn.frame.maxX + margin
            cancelBtn.tagName = "cancel"
            cancelBtn.onTap(target: alertBox, action: #selector(alertBox.onclick))
            alert.addSubview(cancelBtn)
            
            alert.frame.size.height += okBtn.frame.height + margin
            
            
            // - 设定回调事件
            alertBox.callback = [
                "ok" : {
                    ok!()
                    alertBox.run()
                },
                "cancel": {
                    cancel!()
                    alertBox.run()
                }
            ]
            
        }else
        {
            // - 关闭按钮
            let closeW:CGFloat = titleH * 0.8
            let close = UIView(frame: CGRect(x: w - margin - closeW, y: margin + titleH * 0.1, width: closeW, height: closeW)).icon(name: "close", fillcolor: "#666666")
            alert.addSubview(close)
            
            let btnview = UIView(frame: close.frame)
            btnview.frame.origin.x -= 15
            btnview.frame.origin.y -= 15
            btnview.frame.size.width += 30
            btnview.frame.size.height += 30
            alert.addSubview(btnview)
            btnview.onTap(target: alertBox, action: #selector(alertBox.run))
            
            titleLabel.onTap(target: alertBox, action: #selector(alertBox.run))
            // - 点击图标继续运行
            icon.onTap(target: alertBox, action: #selector(alertBox.run))
        }
        
        alertBox.addSubview(alert)
        alertBox.run()
        
        UIApplication.shared.keyWindow?.addSubview(alertBox)
    }
    
    // - 弹出通知
    public class func notice(content: String, title:String? = nil, color:UIColor? = nil, bgcolor:UIColor? = nil, onclick: (() -> Void)? = nil)
    {
        let bgcolor = bgcolor == nil ? UIColor.colorWithHexString("#FFFFFF") : bgcolor
        let color = color == nil ? UIColor.colorWithHexString("#4E4E4E") : color
        
        let font = UIFont.systemFont(ofSize: 16)
        let w = WINDOW_WIDTH
        let iconW = "高度".heightWithConstrainedWidth(width: w, font: font)
        let contentH = content.heightWithConstrainedWidth(width: w, font: font)
        let margin:CGFloat = 15
        let h = (iconW == contentH ? iconW : contentH) + margin * 2
        
        //        print(GLOBAL_MAIN_VC.getViewFrame())
        
        var preFrame = CGPoint(x: 0, y: UIApplication.shared.statusBarFrame.height)
        let preViews = UIApplication.shared.keyWindow?.getSubviewByTagName(tagName: "notice:*")
        if let last = preViews?.last
        {
            preFrame.y = (last.frame.origin.y + last.frame.height)
        }
        
        var noticeBox = AnimateUIView(frame: CGRect(x: 0, y: preFrame.y, width: WINDOW_WIDTH, height: h))
        noticeBox.tagName = "Dialog"
        noticeBox.backgroundColor = bgcolor
        noticeBox.tagName = "notice:\((preViews?.count)!)"
        noticeBox.queue = [["position.y", -h / 2, h + preFrame.y, "0.1"], ["position.y", h + preFrame.y, h / 2 + preFrame.y, "0.2"]]
        // - 添加关闭动画
        let endFunc = {
            
            noticeBox.queue = [["position.x", w / 2, w / 2 + 10, "0.1"], ["opacity", 1, 0.5, "0.1"], ["position.x", w / 2 + 10, -w / 2, "0.1"], [{
                noticeBox.layer.removeAllAnimations()
                noticeBox.removeFromSuperview()
                var noticeNum = 0
                if let tagName = noticeBox.tagName
                {
                    let split = tagName.components(separatedBy: ":")
                    noticeNum = Int(split[1].toCGFloat())
                }
                noticeBox = AnimateUIView()
                let others = UIApplication.shared.keyWindow?.getSubviewByTagName(tagName: "notice:*")
                if (others?.count)! > 0
                {
                    for i:UIView in others!
                    {
                        let split = i.tagName?.components(separatedBy: ":")
                        if Int((split?[1].toCGFloat())!) > noticeNum
                        {
                            i.layer.animate(type: "position.y", to: i.frame.minY - h / 2, duration: 0.1)
                            i.frame.origin.y -= h
                        }
                    }
                }
                }]]
        }
        noticeBox.queue.append([endFunc])
        
        let icon = UIView(frame: CGRect(x: margin , y: margin, width: iconW, height: iconW)).icon(name: "information", fillcolor: "#5bc0de")
        noticeBox.addSubview(icon)
        
        // - 关闭按钮
        let closeW:CGFloat = iconW
        let close = UIView(frame: CGRect(x: w - margin - closeW, y: margin, width: closeW, height: closeW)).icon(name: "close", fillcolor: "#666666")
        noticeBox.addSubview(close)
        close.onTap(target: noticeBox, action: #selector(noticeBox.run))
        
        
        let noticeClickArea = UIView(frame: CGRect(x: 0, y: 0, width: noticeBox.frame.width - iconW, height: noticeBox.frame.height))
        noticeBox.addSubview(noticeClickArea)
        
        var notice = UILabel()
        
        if title != nil
        {
            let titleW = noticeBox.frame.width - iconW - margin * 4 - closeW
            let titleH = (title?.heightWithConstrainedWidth(width: titleW, font: font))!
            let noticeTitle = UILabel(frame: CGRect(x: icon.frame.maxX + margin, y: margin / 2, width: titleW, height: titleH))
            
            noticeTitle.text = title
            noticeTitle.textColor = color
            noticeTitle.font = UIFont.boldSystemFont(ofSize: 14)
            noticeClickArea.addSubview(noticeTitle)
            
            notice = UILabel(frame: CGRect(x: noticeTitle.frame.minX
                , y: noticeTitle.frame.maxY, width: noticeTitle.frame.width, height: h - margin - noticeTitle.frame.height))
        }else{
            notice = UILabel(frame: CGRect(x: icon.frame.maxX + margin
                , y: 0, width: noticeBox.frame.width - iconW - margin * 4 - closeW, height: h))
        }
        
        notice.font = UIFont.systemFont(ofSize: 12)
        notice.text = content
        notice.textColor = color
        
        // - 存在点击事件
        if onclick != nil
        {
            noticeClickArea.tagName = "onclick"
            noticeClickArea.onTap(target: noticeBox, action: #selector(noticeBox.onclick))
            // - 设定回调事件
            noticeBox.callback = [
                "onclick" : {
                    onclick!()
                    noticeBox.run()
                }
            ]
            
        }else
        {
            noticeClickArea.onTap(target: noticeBox, action: #selector(noticeBox.run))
        }
        
        
        noticeClickArea.addSubview(notice)
        noticeBox.run()
        
        UIApplication.shared.keyWindow?.addSubview(noticeBox)
    }
    
    
    // - 删除所有弹窗
    public class func removeAll(parent:UIView? = nil)
    {
        let view = parent != nil ? parent : UIApplication.shared.keyWindow
        
        for i in (view?.getSubviewByTagName(tagName: "Dialog"))!
        {
            i.removeFromSuperview()
            if let animateview = i as? AnimateUIView
            {
                animateview.run()
            }
        }
    }
    
    // - 添加遮罩层
    public class func createMask(tagName:String? = nil, parent:UIView? = nil) -> UIView?
    {
        let tagName = tagName == nil ? "DialogMask" : tagName!
        
        let view = parent != nil ? parent : UIApplication.shared.keyWindow
        
        // - 创建透明背景
        if (view?.getSubviewByTagName(tagName: tagName).isEmpty)!
        {
            let mask = UIView(frame: UIScreen.main.bounds)
            mask.tagName = tagName
            mask.backgroundColor = UIColor.colorWithHexString("#000000", 0.5)
            view?.addSubview(mask)
            return mask
        }
        
        return nil
    }
    
    // - 手动删除遮罩
    public class func removeMask(tagName:String? = nil, parent:UIView? = nil)
    {
        let tagName = tagName == nil ? "DialogMask" : tagName!
        
        let view = parent != nil ? parent : UIApplication.shared.keyWindow
        
        for i in (view?.getSubviewByTagName(tagName: tagName))!
        {
            i.removeFromSuperview()
        }
    }
}
