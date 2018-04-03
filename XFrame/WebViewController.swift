//
//  NavigationController.swift
//  xframe
//
//  Created by XiaoJiao Chen on 2017/3/15.
//  Copyright © 2017年 XiaoJiao Chen. All rights reserved.
//

import UIKit

public class WebViewController: UIViewController {
    
    public var url:String?
    public var local:String?
    public var resource:String?
    public var temp:String?
    public var wkweb:WKWeb!
    public var hideNav:Bool = true
    public var hideProgress:Bool = true
    public var wkframe:CGRect? = nil
    public var query:String?
    
    private var callback:Any?
    
    public init(url: String, frame: CGRect? = nil, query: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
        self.wkframe = frame
        self.query = query
    }
    
    public init(local: String, frame: CGRect? = nil, query: String? = nil)
    {
        super.init(nibName: nil, bundle: nil)
        self.local = local
        self.wkframe = frame
        self.query = query
    }
    
    public init(resource: String, frame: CGRect? = nil, query: String? = nil)
    {
        super.init(nibName: nil, bundle: nil)
        self.resource = resource
        self.wkframe = frame
        self.query = query
    }
    
    public init(temp: String, frame: CGRect? = nil, query: String? = nil)
    {
        super.init(nibName: nil, bundle: nil)
        self.temp = temp
        self.wkframe = frame
        self.query = query
    }
    
    public func addWkWeb(frame: CGRect)
    {
//        print("wk:\(frame)")
        self.wkweb = WKWeb(frame: frame)
        
        if self.hideProgress
        {
            self.wkweb.progress(navbar: (GLOBAL_MAIN_VC.navigationController?.navigationBar)!)
        }

        if self.url != nil
        {
            self.wkweb.loadHTMLType("net", url: self.url!)
        }else if self.local != nil{
            self.wkweb.loadHTMLType("local", url: self.local!, query:self.query)
        }else if self.resource != nil{
            self.wkweb.loadHTMLType("resource", url: self.resource!, query:self.query)
        }else if self.temp != nil{
            self.wkweb.loadHTMLType("local", url: self.temp!, query:self.query, isTemp: true)
        }
        
        self.view.addSubview(wkweb)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //事件回调监听
    public func addListener(didLoad:  @escaping (WKWeb) -> Void)
    {
        self.callback = didLoad
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        GLOBAL_MAIN_VC.hideNav(self.hideNav)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        GLOBAL_MAIN_VC.hideNav(self.hideNav)
        let frame = (self.wkframe != nil ? self.wkframe! : GLOBAL_MAIN_VC.getViewFrame())
        self.addWkWeb(frame: frame)
        
        //实现回调
        if self.callback != nil
        {
            (self.callback as! (WKWeb) -> Void)(self.wkweb)
        }
    }
    
    
    override public func didReceiveMemoryWarning() {
        self.wkweb.didReceiveMemoryWarning()
        print("WKVC内存回收")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
