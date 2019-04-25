//
//  NativeClass.swift
//  mylovekids
//
//  Created by 创造小青年 on 2016/12/7.
//  Copyright © 2016年 创造小青年. All rights reserved.
//icon-ambulance__ea

import WebKit
import Foundation

public class WKNative: NSObject, UIWebViewDelegate {
    
    init(_ m: Any, _ wk: WKWebView?)
    {
        super.init()
        if wk == nil
        {
            print("WK组件为定义")	
            return
        }
        if let dic = m as? NSDictionary,
            let action = (dic["action"] as AnyObject).description,
            let option = (dic["option"] as AnyObject?),
            let callback = (dic["callback"] as AnyObject).description
        {
            switch action {
                
            case "Window":
                var vc:WebViewController!
                if option["url"] != nil
                {
                    vc = WebViewController(url: option["url"] as! String, query: option["query"] as? String)
                }
                
                if option["local"] != nil
                {
                    vc = WebViewController(url: option["local"] as! String, query: option["query"] as? String)
                }
                
                if option["resource"] != nil
                {
                    vc = WebViewController(url: option["resource"] as! String, query: option["query"] as? String)
                }
                
                if option["temp"] != nil
                {
                    vc = WebViewController(url: option["temp"] as! String, query: option["query"] as? String)
                }
                
                if vc != nil
                {
                    GLOBAL_MAIN_VC.pushViewController(vc: vc, animated: true)
                }
                break
                
            case "getCurrentViewController":
                if let param = option as? [String:Any]
                {
                    if let obj = GLOBAL_MAIN_VC.getCurrentViewController()
                    {
                        if let property = param["property"] as? [String:Any]
                        {
                            for i in property
                            {
                                let _ = obj.setValueOfProperty(property: i.key, value: i.value as AnyObject)
                            }
                        }
                        
                        let funcName = param["funcName"] as! String
                        print(funcName)
                        
                        let functionSelector = Selector(funcName)
                        if obj.responds(to: functionSelector) {
                            obj.perform(functionSelector)
                        } else {
                            print("方法未找到！")
                        }
                    }
                }
                break
                
            case "createClassByString":
                if let param = option as? [String:Any]
                {
                
                    
                    if let obj = self.getClassFormString(className: param["name"] as? String)
                    {
                        if let property = param["property"] as? [String:Any]
                        {
                            for i in property
                            {
                                print(i.key)
                                print(i.value)
                                
                                let _ = obj.setValueOfProperty(property: i.key, value: i.value as AnyObject)
                            }
                        }
                        let funcName = param["funcName"] as! String
                        let functionSelector = Selector(funcName)
                        if obj.responds(to: functionSelector) {
                            obj.perform(functionSelector)
                        } else {
                            print("方法未找到！")
                        }
                    }
                }
                break
                
            case "pushViewController":
                print(option)
                if let param = option as? [String:Any]
                {
                    let obj = self.getClassFormString(className: param["name"] as? String)
                    if let vc = obj as? UIViewController
                    {
                        if let property = param["property"] as? [String:String]
                        {
                            for i in property
                            {
                                let _ = vc.setValueOfProperty(property: i.key, value: i.value as AnyObject)
                            }
                        }
                        
                        GLOBAL_MAIN_VC.pushViewController(vc: vc, animated: true)
                    }else {
                        print("类未找到！")
                    }
                }
                break
                
            case "getObjectProperty":
                if let param = option as? [String:Any]
                {
                    let obj = self.getClassFormString(className: param["className"] as? String)
                    if let property = obj?.getValueOfProperty(property: param["property"]! as! String)
                    {
                        let js = callback.replacingOccurrences(of: ":DATA", with: property as! String)
                        print(js)
                        wk?.evaluateJavaScript(js, completionHandler: { (a, e) in
                            if e != nil
                            {
                                print("\(action)回调出错:\(e!)")
                            }else if a != nil
                            {
                                print(a!)
                            }
                        })
                    }else
                    {
                        print("获取\(param["className"]!)属性\(param["property"]!)失败")
                    }
                }
                break
                
            default:
                let debug = Debug()
                debug.run(className: action, paramName: option as? [String : String])
                break
            }
        }
    }
    
    fileprivate func addListener(callback: @escaping (String) -> Void)
    {
        GLOBAL_CALLBACK = callback
    }
    
    //获取动态对象
    private func getClassFormString(className: String?) -> NSObject?
    {
        if className == nil
        {
            return nil
        }
        
        let nsName = Bundle.main.infoDictionary?["CFBundleExecutable"] as! String
        let clsName:AnyClass! = NSClassFromString(nsName + "." + className!)

        if let objCls = clsName as? NSObject.Type
        {
            return objCls.init()
        }else{
            return nil
        }
    }
}
