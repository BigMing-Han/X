//
//  Alert.swift
//  xframe
//
//  Created by XiaoJiao Chen on 2017/5/6.
//  Copyright © 2017年 XiaoJiao Chen. All rights reserved.
//

import UIKit

public class Alert: UIView , CAAnimationDelegate{
    private var params:[String:String]?
    
    public init(frame: CGRect, params:[String:String]? = nil) {
        super.init(frame: frame)
        
        if params != nil
        {
            self.params = params
        }else{
            self.params = ["type":"default"]
        }
        
        self.create()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //创建UI
    private func create()
    {
        if self.params == nil
        {
            return
        }
        switch self.params?["type"] {
        default:
            let _ = self.alert(title: self.params?["title"], content: self.params?["content"], width: nil, height: nil)
            break
        }
    }
    
    override public func removeFromSuperview() {
        self.layer.animate(type: "opacity", form: 1, to: 0, duration: 0.2, delegate: self, timing: kCAMediaTimingFunctionEaseOut)
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        super.removeFromSuperview()
    }
    
}
