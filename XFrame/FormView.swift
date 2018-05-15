//
//  Form.swift
//  XFrame
//
//  Created by 刘强 on 2017/5/16.
//  Copyright © 2017年 XiaoJiao Chen. All rights reserved.
//

import UIKit

public class FormView: UIScrollView, UITextFieldDelegate {
    
    private var oldFrame:CGRect!
    private var childs:[Any?] = []
    private var onchange:[Any?] = []
    private var onblur:[Any?] = []
    private var contentHeight:CGFloat = 0
    public var margin:CGFloat = 0
    public var marginColor:UIColor = UIColor.clear
    public var itemColor:UIColor = UIColor.white
    public var params:[[String:String]?] = []
    private var titles:[UILabel] = []
    private var values:[UILabel] = []
    private var keyboardNotification:NSNotification? = nil
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.oldFrame = frame
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addInput(type:String, height:CGFloat, params:[String:String]? = nil ,onchange: ((Any?) -> Void)? = nil ,onblur: ((Any?) -> Void)? = nil) -> Any? {
        
        let value:String = ""
        let placeholder:String = ""
        let bgColor:UIColor = self.backgroundColor != nil ? self.backgroundColor! : UIColor.clear
        
        self.onchange.append(onchange != nil ? onchange : nil)
        self.onblur.append(onblur != nil ? onblur : nil)
        
        var text:Any? = nil
        
        switch type {
        case "text":
            let input = self.text(height: height, value: value) as! UITextField
            
            input.delegate = self
            input.tag = 1000 + self.childs.count
            
            input.backgroundColor = bgColor
            input.placeholder = placeholder
            
            input.addTarget(self, action: #selector(textFieldChanged), for: UIControlEvents.editingChanged)
            
            text = input
            break
            
        case "NText":
            let input = self.text(height: height, value: value) as! UITextField
            
            input.delegate = self
            input.tag = 1000 + self.childs.count
            
            input.typingAttributes = params
            input.backgroundColor = bgColor
            //            input.text = value != "" ? value :
            input.clearButtonMode = UITextFieldViewMode.whileEditing
            input.textAlignment = .center
            let frame = CGRect(x: 0, y: 0, width: height, height: height)
            
            input.leftViewMode = UITextFieldViewMode.always
            input.leftView = UIView(frame: frame)
            input.leftView?.onTap(target: self, action: #selector(NTextSub))
            input.leftView?.addSubview(UIView(frame: CGRect(x: height * 0.25, y: height * 0.25, width: height * 0.5, height: height * 0.5)).icon(name: "sub"))
            
            input.rightViewMode = UITextFieldViewMode.always
            input.rightView = UIView(frame: frame)
            input.rightView?.onTap(target: self, action: #selector(NTextAdd))
            input.rightView?.addSubview(UIView(frame: CGRect(x: height * 0.25, y: height * 0.25, width: height * 0.5, height: height * 0.5)).icon(name: "add"))
            
            input.keyboardType = .decimalPad
            
            input.addTarget(self, action: #selector(textFieldChanged), for: UIControlEvents.editingChanged)
            
            text = input
            break
            
        default:
            break
        }
        
        self.params.append(params)
        self.childs.append(text)
        return text
    }
    
    /***
     NText相关操作
     ***/
    
    @objc public func NTextAdd(recognizer: UITapGestureRecognizer)
    {
        NTtextAction(view: recognizer.view!, type: "add")
    }
    
    @objc public func NTextSub(recognizer: UITapGestureRecognizer)
    {
        NTtextAction(view: recognizer.view!, type: "sub")
    }
    
    private func NTtextAction(view:UIView, type:String)
    {
        
        if let text = view.superview as? UITextField
        {
            let value = text.text?.toCGFloat()
            let index = text.tag - 1000
            let param = self.params[index]
            let unit:String? = param?["unit"] != nil ? param?["unit"] : "0"
            
            //键盘收缩
            self.keyboardOff()
            
            switch type {
            case "add":
                let v = value! + (unit?.toCGFloat())!
                text.text = self.unitFormat(index: index, text: "\(v)")
                break
                
            case "sub":
                let v = value! - (unit?.toCGFloat())!
                text.text = self.unitFormat(index: index, text: "\(v)")
                break
                
            default:
                break
                
            }
            
            for i in view.subviews
            {
                i.layer.animate(type: "transform.scale", form: 0.5, to: 1, duration: 0.2)
            }
            
            self.textFieldChanged(text)
        }
    }
    
    
    /***
     get 操作
     ***/
    public func getChild(row:Int) -> Any?
    {
        return self.childs[row]
    }
    
    //
    public func unitFormat(index:Int, text:String) -> String
    {
        let param = self.params[index]
        let unit:String? = param?["unit"] != nil ? param?["unit"] : ""
        let length = unit?.lengthOfBytes(using: String.Encoding.utf8)
        //        print("index:\(index) text:\(text)")
        if param?["validate"] == "number"
        {
            if let value = Double(text)
            {
                var v = CGFloat(value)
                let max:String? = param?["maxValue"]
                let min:String? = param?["minValue"]
                
                if max != nil
                {
                    v = v < max!.toCGFloat() ? v : max!.toCGFloat()
                }
                
                if min != nil
                {
                    v = v > min!.toCGFloat() ? v : min!.toCGFloat()
                }
                
                if length! > 2
                {
                    return String(format: "%.\((length! - 2))f", v)
                }else
                {
                    return "\(Int(v))"
                }
            }
            
            return ""
        }else
        {
            return text
        }
    }
    
    //text类型创建
    private func text(height:CGFloat, value:String? = nil) -> Any{
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: height)
        let input = UITextField(frame: frame)
        self.addItem(view: input)
        return input
    }
    
    //添加项目根据高度···
    public func addItem(view:UIView)
    {
        let viewBoxFrame = CGRect(x: 0, y: self.contentHeight, width: self.frame.width, height: view.frame.maxY + self.margin)
        let viewbox = UIView(frame: viewBoxFrame)
        viewbox.backgroundColor = self.marginColor
        viewbox.addSubview(view)
        
        //自动叠加内容高度
        self.contentHeight += viewbox.frame.height
        self.addSubview(viewbox)
        
        //更新当前contentsize
        self.updateContentHeight()
    }
    
    private func updateContentHeight()
    {
        self.contentSize = CGSize(width: self.frame.width, height: self.contentHeight)
    }
    
    //获取当前高度
    public func getContentHeight() -> CGFloat
    {
        return self.contentHeight
    }
    
    //判断是否数字
    private func onlyNumber(str: String) -> Bool
    {
        let length = str.lengthOfBytes(using: String.Encoding.utf8)
        for loopIndex in 0..<length {
            let char = (str as NSString).character(at: loopIndex)
            if (char >= 48 && char <= 57) || char == 46
            {
                continue
            }else
            {
                return false
            }
        }
        return true
    }
    
    @objc public func textFieldChanged(_ textField: UITextField)
    {
        //        print("变化完毕\(textField.text!)")
        //格式化数据
        let index = textField.tag - 1000
        let unitText = self.unitFormat(index: index, text: textField.text!)
        if unitText.lengthOfBytes(using: String.Encoding.utf8) <= (textField.text?.lengthOfBytes(using: String.Encoding.utf8))!
        {
            textField.text = unitText
        }
        
        //改变回调
        if let onchange = self.onchange[index]
        {
            (onchange as! (Any?) -> Void)(textField)
        }
    }
    
    //键盘弹出
    @objc public func keyboardWillShow(notification:NSNotification)
    {
        //公共事件保存为全局变量
        self.keyboardNotification = notification
        
        self.keyboardShowHide(notification: notification, callback: { (intersection) in
            
            if let textfield = KEYBOARD_FOCUS as? UITextField
            {
                let nowMinY = (textfield.superview?.frame.maxY)! + self.frame.minY
                //                print("========\(self.frame.origin)==========\(intersection)")
                if nowMinY > intersection.minY
                {
                    let cha = nowMinY - intersection.minY
                    self.frame.origin.y = self.oldFrame.origin.y - cha
                }
            }
        })
    }
    
    @objc public func keyboardWillHide(notification:NSNotification)
    {
        self.keyboardShowHide(notification: notification, callback: { (intersection) in
            self.frame.origin.y = self.oldFrame.origin.y
            self.keyboardNotification = nil
        })
    }
    
    //键盘回收
    public func keyboardOff()
    {
        if let view = KEYBOARD_FOCUS as? UIView
        {
            view.superview?.endEditing(true)
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //键盘
    private func keyboardShowHide(notification:NSNotification, callback: @escaping ((CGRect) -> Void))
    {
        if let userinfo = notification.userInfo
        {
            if let value = userinfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
                let duration = userinfo[UIKeyboardAnimationDurationUserInfoKey] as? Double,
                let curve = userinfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt
            {
                let frame = value.cgRectValue
                let intersection = frame.intersection(self.frame)
                //改变下约束
                
                UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: curve), animations: {
                    (callback as (CGRect) -> Void)(intersection)
                }, completion: nil)
            }
        }
    }
    
    //UITextFieldDelegate
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        //        print("获得焦点")
        KEYBOARD_FOCUS = textField
        if self.keyboardNotification != nil
        {
            if self.frame.origin.y != self.oldFrame.origin.y
            {
                self.keyboardWillHide(notification: self.keyboardNotification!)
            }else
            {
                self.keyboardWillShow(notification: self.keyboardNotification!)
            }
        }else
        {
            //监听键盘弹出通知
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        //        print("失去焦点")
        let index = textField.tag - 1000
        //改变回调
        if let onblur = self.onblur[index]
        {
            (onblur as! (Any?) -> Void)(textField)
        }
    }
    
    //值改变
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let index = textField.tag - 1000
        if let param = self.params[index]?["validate"]
        {
            if param == "number"
            {
                return self.onlyNumber(str: string)
            }
        }
        
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let index = textField.tag - 1000
        if index == self.childs.count - 1
        {
            self.keyboardOff()
        }else
        {
            if let text = self.childs[(index+1)] as? UITextField
            {
                text.becomeFirstResponder()
            }
        }
        
        return true
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        print("=======>这里")
        self.keyboardOff()
    }
}

public class FormInput: UIView
{
    private var onclick:Any?
    private(set) var isChecked = false
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.onTap(target: self, action: #selector(self.toggleCheck))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // - checkbox
    // - labelOption [文字内容: 文字大小]
    public func initCheckbox(_ labelOption: [String:CGFloat]? = nil)
    {
        let w = self.frame.width > self.frame.height ? self.frame.height : self.frame.width
        let checkbox = UIView(frame: CGRect(x: 0, y: 0, width: w, height: w))
        self.addSubview(checkbox)
        
        if labelOption != nil && labelOption?.count == 1
        {
            for i in labelOption!
            {
                let label = UILabel()
                label.font = UIFont.systemFont(ofSize: i.value)
                label.frame.size = CGSize(width: i.key.widthWithConstrainedWidth(width: WINDOW_WIDTH, WithFont: label.font), height: self.frame.height)
                label.frame.origin = CGPoint(x: self.frame.maxX + 5, y: 0)
                label.text = i.key
                label.adjustsFontSizeToFitWidth = true
                print(label.frame)
                self.frame.size.width = label.frame.maxX
                self.addSubview(label)
            }
        }
        
        checkbox.layer.borderWidth = 1
        checkbox.layer.cornerRadius = w * 0.2
        
        if self.isChecked
        {
            let icon = UIView(frame: CGRect(x: w * 0.1, y: w * 0.1, width: w * 0.8, height: w * 0.8)).icon(name: "ok", fillcolor: "#4E4E4E")
            checkbox.layer.borderColor = UIColor.colorWithHexString("#4E4E4E").cgColor
            checkbox.addSubview(icon)
        }else
        {
            checkbox.layer.borderColor = UIColor.colorWithHexString("#CCCCCC").cgColor
            for i in checkbox.subviews
            {
                i.removeFromSuperview()
            }
        }
    }
    
    public func setcheck(_ b:Bool)
    {
        self.isChecked = b
        self.initCheckbox()
    }
    
    @objc public func toggleCheck()
    {
        let status = self.isChecked ? false : true
        self.setcheck(status)
        
        if self.onclick != nil
        {
            (self.onclick as! () -> Void)()
        }
    }
    
    public func addListener(onclick: @escaping () -> Void)
    {
        self.onclick = onclick
    }
}

