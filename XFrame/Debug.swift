//
//  Debug.swift
//  XFrame
//
//  Created by 刘强 on 2017/5/18.
//  Copyright © 2017年 XiaoJiao Chen. All rights reserved.
//

import UIKit

public class Debug: NSObject {
    public func run(className:String, paramName:[String:String]? = nil)
    {
        switch className {
            

        case "RunApp":
            
            break
            
        default:
            if let cls = NSClassFromString((Bundle.main.object(forInfoDictionaryKey: "CFBundleName")! as AnyObject).description + "." + className) as? NSObject.Type{
                let obj = cls.init()
                let funcName = paramName?["funcName"]!
                let functionSelector = Selector(funcName!)
                if obj.responds(to: functionSelector) {
                    obj.perform(functionSelector)
                } else {
                    print("方法未找到！")
                }
            } else {
                print("类未找到！")
            }
            
            break
        }
        
    }
    
    public func test()
    {
        GLOBAL_MAIN_VC.hideNav(true)
        self.run(className: "List")
    }
}
