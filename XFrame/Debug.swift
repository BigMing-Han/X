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
            
        case "Form":
            let vc = UIViewController()
            vc.automaticallyAdjustsScrollViewInsets = false
            vc.view.backgroundColor = UIColor.red
            
            GLOBAL_MAIN_VC.hideNav(false)
            
            let frame = GLOBAL_MAIN_VC.getViewFrame()
            
            let inputHeight:CGFloat = 50
            let form = FormView(frame: frame)
            form.margin = 30
            
            var t = form.addInput(type: "text", height: inputHeight, params: ["validate":"number"]) as! UITextField
            t.backgroundColor = UIColor.white
            t = form.addInput(type: "text", height: inputHeight, params: ["validate":"number"]) as! UITextField
            t.backgroundColor = UIColor.white
            t = form.addInput(type: "text", height: inputHeight, params: ["validate":"number"]) as! UITextField
            t.backgroundColor = UIColor.white
            t = form.addInput(type: "text", height: inputHeight, params: ["validate":"number"]) as! UITextField
            t.backgroundColor = UIColor.white
            t = form.addInput(type: "text", height: inputHeight, params: ["validate":"number"]) as! UITextField
            t.backgroundColor = UIColor.white
            t = form.addInput(type: "text", height: inputHeight, params: ["validate":"number"]) as! UITextField
            t.backgroundColor = UIColor.white
            t = form.addInput(type: "text", height: inputHeight, params: ["validate":"number"]) as! UITextField
            t.backgroundColor = UIColor.white
            t = form.addInput(type: "text", height: inputHeight, params: ["validate":"number"]) as! UITextField
            t.backgroundColor = UIColor.white
            t = form.addInput(type: "text", height: inputHeight, params: ["validate":"number"]) as! UITextField
            t.backgroundColor = UIColor.white
            
            let a = form.addInput(type: "NText", height: inputHeight, params: ["value": "0.00", "unit": "0.01", "minValue" : "1.00", "validate":"number"]) as! UITextField
            a.leftView?.backgroundColor = UIColor.yellow
            a.rightView?.backgroundColor = UIColor.yellow
            
            vc.view.addSubview(form)
            GLOBAL_MAIN_VC.pushViewController(vc: vc, animated: true)
            
            break
            
        case "List":
            let vc = UIViewController()
            
            vc.automaticallyAdjustsScrollViewInsets = false
            vc.view.backgroundColor = UIColor.white
            
            let frame = GLOBAL_MAIN_VC.getViewFrame()
            
            let list = ListView(frame: frame, params: ["margin":CGFloat(5)])
            //                list.itemBackgroundColor = UIColor.gray
            list.backgroundColor = UIColor.red
            
            let icon = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            list.addItem(height: 50, title: ["测试内容": UIColor.white], icon: icon.icon(image: "close"), arrow: true, callback: {
                print("点击")
            })
            
            list.addListener(refresh: { (type) in
                
                
                let _ = delay(2, task: {
                    
                    let add = UIView(frame: CGRect(x: 0, y: 0, width: list.frame.width, height: 60))
                    
                    add.backgroundColor = UIColor.yellow
                    
                    list.addItem(view: add)
                    
                    list.endRefresh()
                })
                
            }, topStep: { (top) in
                
                if top.alpha != 1
                {
                    var a = Math.abs(number: list.contentOffset.y / 60)
                    a = a > 1 ? 1 : a
                    top.alpha = a
                }
            })
            
            vc.view.addSubview(list)
            GLOBAL_MAIN_VC.pushViewController(vc: vc, animated: true)
            
            
            break
            
        case "Swiper":
            //                GLOBAL_MAIN_VC.navigationController?.navigationBar.isHidden = false
            
            let vc = UIViewController()
            //取消scrollview自动改变Y坐标
            vc.automaticallyAdjustsScrollViewInsets = false
            vc.view.backgroundColor = UIColor.white
            
            let frame = GLOBAL_MAIN_VC.getViewFrame()
            
            let swiper = Swiper(frame: CGRect.init(x: frame.minX, y:frame.minY, width: frame.width, height: 60), count: 5, tabs: ["滑板", "巴士", "帆船", "飞碟"], colors: ["bar": UIColor.yellow, "text": UIColor.white, "bg": UIColor.red, "selected": UIColor.yellow], param:["status":"on"])
            vc.view.addSubview(swiper)
            
            //初始化SVG
            //                let svgreader = SvgReader(frame: CGRect(x: frame.minX, y: frame.minY + 60, width: frame.width, height: frame.width))
            //                svgreader.open(filepath: Bundle.main.bundlePath + "/iconfont.js", ["icon-skate__easyic", "icon-Bus__easyicon", "icon-boat__easyico2", "icon-ufo__easyicon", "icon-xiangzuojiantou"])
            //                le
            let frame2 = CGRect(x: frame.minX, y: frame.minY + 60, width: frame.width, height: frame.width)
            let backImage:UIImage = UIView(frame: frame2).icon(image: "left").reSizeImage(reSize: CGSize(width: 30, height: 30))
            let backbtn = UIButton(frame: CGRect(x: 0, y: 0, width: (frame.width / 5), height: 60))
            backbtn.setTitleColor(UIColor.white, for: UIControlState.normal)
            backImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            backbtn.setImage(backImage.setColor(color: UIColor.white), for: UIControlState.normal)
            backbtn.setImage(backImage.setColor(color: UIColor.yellow), for: UIControlState.selected)
            
            backbtn.addTarget(GLOBAL_MAIN_VC, action: #selector(GLOBAL_MAIN_VC.loadView), for: UIControlEvents.touchUpInside)
            
            swiper.setBackBtn(btn: backbtn)
            
            var views:[UIView] = []
            var v = UIView(frame: frame2)
            v.backgroundColor = UIColor.red
            views.append(v)
            
            v = UIView(frame: frame2)
            v.backgroundColor = UIColor.blue
            views.append(v)
            
            v = UIView(frame: frame2)
            v.backgroundColor = UIColor.yellow
            
            views.append(v)
            
            v = UIView(frame: frame2)
            v.backgroundColor = UIColor.gray
            views.append(v)
            
            
            let swiper2 = Swiper(frame: frame2, count: 1, views: views)
            swiper2.auto_move = true
            vc.view.addSubview(swiper2)
            
            swiper2.bind(other: swiper)
            swiper.bind(other: swiper2)
            
            GLOBAL_MAIN_VC.pushViewController(vc: vc, animated: true)
            break
            
        case "Dialog":
            
            //            let label = UILabel(frame: CGRect(x: 0, y: 0, width: WINDOW_WIDTH, height: 60))
            //            label.setAttrText(texts: [
            //                ["测试文字" : [12 : UIColor.gray]],
            //                ["有色文字" : [12 : UIColor.red]],
            //                ["其他文字" : [12 : UIColor.gray]]
            //                ])
            //            let checkbox = FormInput(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
            //            checkbox.initCheckbox()
            //            checkbox.addListener(onclick: {
            //                if checkbox.isChecked
            //                {
            //                    print("选中")
            //                }else
            //                {
            //                    print("取消")
            //                }
            //            })
            //
            
            let keyboard = Keyboard()
            keyboard.safeKeyboard(callback: { (password) in
                if password == "758690"
                {
                    Dialog.alert(content:  "输入的密码是\(password)" + "恭喜登陆成功", title: "标题", type: Dialog.ALERTTYPE.TRADE, ok: {
                        print("点击确认")
                        keyboard.removeKeyboard()
                    }, cancel: {
                        print("点击取消")
                        keyboard.removeKeyboard()
                    })
                    
                    
                }else{
                    keyboard.worng()
                }
            })
            
            break
            
        case "SVG":
            
            //                let paramName = dic["paramName"] as? NSDictionary
            
            let vc = UIViewController()
            let svc = UIScrollView(frame: vc.view.frame)
            let svgreader = SvgReader(frame: vc.view.frame)
            svgreader.open(filepath: Bundle.main.bundlePath + "/iconfont.js", [(paramName?["url"]!)!])
            //                svgreader.open(filepath: Bundle.main.bundlePath + "/iconfont.js", ["icon-loading"])
            
            vc.view.backgroundColor = UIColor.white
            svc.addSubview(svgreader.getIcon(name: "icon-loading"))
            //                svc.contentSize.width = 1024
            //                svc.contentSize.height = 1024
            //                svc.backgroundColor = UIColor.red
            vc.view.addSubview(svc)
            GLOBAL_MAIN_VC.pushViewController(vc: vc, animated: true)
            GLOBAL_MAIN_VC.navigationController?.navigationBar.isHidden = false
            break
            
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
