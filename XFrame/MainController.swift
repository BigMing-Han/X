//
//  MainController.swift
//  xframe
//
//  Created by XiaoJiao Chen on 2017/3/14.
//  Copyright © 2017年 XiaoJiao Chen. All rights reserved.
//

import UIKit

public let WINDOW_WIDTH = UIScreen.main.bounds.width
public let WINDOW_HEIGHT = UIScreen.main.bounds.height
public let NOW_TIME = NSDate().timeIntervalSince1970

public var GLOBAL_CALLBACK:Any?
public var GLOBAL_MAIN_VC:MainController!
public var TOKEN_KEY = ""
public var CER_P12 = ""
public var DEBUG = false

public var XFRAME_VERSION:CGFloat = 0.1
public var KEYBOARD_FOCUS:Any? = nil

public class MainController: TabbarController, CAAnimationDelegate {

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
    }

    public func getViewFrame() -> CGRect
    {
        let navIsHidden:Bool = (self.navigationController?.navigationBar.isHidden)! || (self.navigationController?.isNavigationBarHidden)! ? true : false
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let barHeight = navIsHidden ? 0 : (self.navigationController?.navigationBar.frame.height)! + statusBarHeight
        let tabbarHeight = (self.tabBar.isHidden) ? 0 : self.tabBar.frame.height
        let frame = CGRect(x: 0, y: barHeight, width: self.view.frame.width, height: self.view.frame.height - barHeight - tabbarHeight)
        return frame
    }
    
    //顶部导航
    public func hideNav(_ status: Bool)
    {
        self.navigationController?.isNavigationBarHidden = status
        self.navigationController?.navigationBar.isHidden = status
    }
    
    //获取当前VC
    public func getCurrentViewController() -> UIViewController?
    {
        return self.navigationController?.visibleViewController
    }
    
    
    //获取前一个VC
    public func getPrevViewController() -> UIViewController?
    {
        let nc = self.parent as? UINavigationController
        let views = nc?.viewControllers
        let index = (views?.count)! - 2
        
        if index > 0 && index < (views?.count)!
        {
            return views?[index]
        }else{
            return GLOBAL_MAIN_VC.children[0]
        }
    }

}
