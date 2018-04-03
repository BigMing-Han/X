//
//  Keyboard.swift
//  XFrame
//
//  Created by XiaoJiao Chen on 2017/6/5.
//  Copyright © 2017年 XiaoJiao Chen. All rights reserved.
//

import Foundation

public class Keyboard: NSObject
{
    public var keyboardBox:AnimateUIView?
    private(set) var value:[String] = []
    private var inputs:[UITextField] = []
    private var callback:Any?
    
    deinit {
        self.deinitKeyboard()
        print("键盘销毁")
    }
    
    // - 密码键盘
    public func safeKeyboard(count: Int = 6, callback: ((String) -> Void)? = nil)
    {
        if !((UIApplication.shared.keyWindow?.getSubviewByTagName(tagName: "Keyboard").isEmpty)!)
        {
            return
        }
        
        self.callback = callback
        
        var margin:CGFloat = 0.4
        let h = WINDOW_HEIGHT / 3.2
        let keyboardBox = AnimateUIView(frame: CGRect(x: 0, y: WINDOW_HEIGHT - h, width: WINDOW_WIDTH, height: h))
        keyboardBox.tagName = "Keyboard"
        
        keyboardBox.queue = [["position.y", WINDOW_HEIGHT + h / 2, WINDOW_HEIGHT - h / 2, "0.1"]]
        
        keyboardBox.backgroundColor = UIColor.colorWithHexString("#F9F9F9")
        
        let keyboard = UIView(frame: CGRect(x: 0, y: 0, width: keyboardBox.frame.width + margin, height: keyboardBox.frame.height))
        //        keyboard.backgroundColor = keyboardBox.backgroundColor
        
        var left:CGFloat = 0
        var top:CGFloat = 0
        let keys:[Any] = ["", "1","2","3","4","5","6","7","8","9", "","0", UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200)).icon(name: "key-delete", fillcolor: "#AAAAAA")]
        let keyFunc:[Int:Selector] = [12: #selector(self.delete)]
        
        for i in 1...12
        {
            let frame = keyboard.frame
            let key = UILabel(frame: CGRect(x: left, y: top, width: frame.width / 3 - margin, height: frame.height / 4 - margin))
            //            key.backgroundColor = UIColor.colorWithHexString("#F9F9F9")
            keyboard.addSubview(key)
            
            if keys[i] is String
            {
                key.text = keys[i] as? String
                key.textAlignment = .center
            }else if let view = keys[i] as? UIView
            {
                let min = key.frame.width > key.frame.height ? key.frame.height : key.frame.width
                let deleteIcon = UIImageView(image: view.toImage().scaleImage(scaleSize: min * 0.5 / view.frame.width))
                deleteIcon.center = key.center
                keyboard.addSubview(deleteIcon)
            }
            left = CGFloat(i % 3) * (key.frame.width + margin)
            if i > 0 && CGFloat(i % 3) == 0
            {
                top = key.frame.maxY + margin
            }
            
            if let f = keyFunc[i]
            {
                key.onTap(target: self, action: f)
            }else
            {
                key.onTap(target: self, action: #selector(self.onkeydown))
            }
        }
        
        margin = CGFloat(count - 1) / 5
        left = 0
        let inputW = (keyboardBox.frame.width + margin) / CGFloat(count)
        let inputBox = UIView(frame: CGRect(x: 0, y: -inputW, width: keyboardBox.frame.width,  height: inputW + margin))
        inputBox.backgroundColor = keyboardBox.backgroundColor
        keyboardBox.addSubview(inputBox)
        for i in 1...count
        {
            let input = UITextField(frame: CGRect(x: left, y: 0, width: inputW - margin, height: inputW - margin))
            
            input.isEnabled = false
            input.isSecureTextEntry = true
            input.backgroundColor = UIColor.colorWithHexString("#FFFFFF")
            input.textAlignment = .center
            inputBox.addSubview(input)
            
            left = CGFloat(i % count) * (inputW)
            
            self.inputs.append(input)
        }
        
        keyboardBox.addSubview(keyboard)
        
        self.keyboardBox = keyboardBox
        self.keyboardBox?.run()
        UIApplication.shared.keyWindow?.addSubview(self.keyboardBox!)
    }
    
    public func onkeydown(_ recognizer: UITapGestureRecognizer)
    {
        if let label = recognizer.view as? UILabel
        {
            if self.value.count < self.inputs.count
            {
                self.value.append(label.text!)
                self.setValue()
                label.font = UIFont.systemFont(ofSize: label.font.pointSize + 5)
                label.backgroundColor = UIColor.colorWithHexString("#FFFFFF")
                _ = delay(0.1, task: {
                    label.font = UIFont.systemFont(ofSize: label.font.pointSize - 5)
                    label.backgroundColor = UIColor.clear
                })
                
                if self.callback != nil && self.value.count == self.inputs.count
                {
                    (self.callback as! (String) -> Void)(self.value.joined())
                }
            }
        }
    }
    
    // - 提示错误
    public func worng()
    {
        let w = self.keyboardBox?.frame.width
        self.keyboardBox?.queue = [
            ["opacity", 1, 0.75, "0.1"],
            ["position.x", w! / 2, w! / 2 + 10, "0.1"],
            ["position.x", w! / 2 + 10, w! / 2 - 10, "0.1"],
            ["position.x", w! / 2 - 10, w! / 2 + 10, "0.05"],
            ["position.x", w! / 2 + 10, w! / 2 - 10, "0.05"],
            ["position.x", w! / 2 - 10, w! / 2 + 10, "0.05"],
            ["position.x", w! / 2 + 10, w! / 2, "0.1"],
            ["opacity", 0.75, 1, "0.1"],
            [{
                self.value = []
                self.setValue()
                }]
        ]
        
        self.keyboardBox?.run()
    }
    
    // - 更新值
    
    private func setValue()
    {
        for i in 0..<self.inputs.count
        {
            if i < self.value.count
            {
                //                self.inputs[i].text = self.value[i]
                self.inputs[i].text = "*"
            }else
            {
                self.inputs[i].text = ""
            }
        }
    }
    
    public func removeKeyboard()
    {
        // - 添加关闭动画
        let h = self.keyboardBox?.frame.height
        
        self.keyboardBox?.queue = [
            ["position.y", WINDOW_HEIGHT - h! / 2, WINDOW_HEIGHT + h! / 2, "0.1"],
            [{
                self.deinitKeyboard()
                }]
        ]
        
        //        self.keyboardBox?.queue.append([endFunc])
        
        self.keyboardBox?.run()
    }
    
    func deinitKeyboard()
    {
        self.keyboardBox?.layer.removeAllAnimations()
        self.keyboardBox?.removeFromSuperview()
        self.keyboardBox = nil
    }
    
    public func setting()
    {
        print("设置")
    }
    
    public func delete()
    {
        if self.value.count == 0
        {
            self.removeKeyboard()
        }else
        {
            self.value.removeLast()
            self.setValue()
        }
    }
}
