//
//  WkClass.swift
//  v3
//
//  Created by 创造小青年 on 16/9/26.
//  Copyright © 2016年 创造小青年. All rights reserved.
//

import WebKit
import UIKit

public class WKWeb: WKWebView, WKNavigationDelegate, WKScriptMessageHandler {
    public var progressView:UIProgressView?
    public var timer:Timer!
    public var callback:((WKWeb, Bool) -> Void)? = nil
    public var canLoading:Bool = false
    
    public init(frame: CGRect, script:String = "")
    {
        //配置wk
        let config = WKWebViewConfiguration()
        //创建交互方法
        let userContent = WKUserContentController()
        
        let initScript = WKUserScript(source: "window.xframe = {apptoken: '\(System.appToken.get())'};" + script, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        userContent.addUserScript(initScript)
        
        config.userContentController = userContent
        super.init(frame: frame, configuration: config)
        
        //定义交互方法名称
        userContent.add(self, name: "NativeMethod")
        
        self.navigationDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //开启进度条
    public func progress(navbar: UINavigationBar)
    {
        self.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        self.progressView = UIProgressView(frame: CGRect(x: 0, y: 44-1, width: UIScreen.main.bounds.size.width, height: 1))
        self.progressView?.trackTintColor = UIColor.clear
        self.progressView?.progressTintColor = UIColor.blue
        navbar.addSubview(self.progressView!)
    }
    
    //    //刷新页面
    //    func reload()
    //    {
    //        self.reloadFromOrigin()
    //    }
    
    //设置监听
    public func addListener(callback: @escaping (WKWeb, Bool) -> Void)
    {
        self.callback = callback
    }
    
    //设置浏览器信息
    public func setUserAgent(info:String)
    {
        //改变浏览器useragent
        self.runScript("navigator.userAgent") { (resp, error) in
            let userAgent = resp as! String
            let result = userAgent + " " + info
            if #available(iOS 9.0, *) {
                self.customUserAgent = result
            } else {
                UserDefaults.standard.register(defaults: ["UserAgent" : result])
            }
            //            print("浏览器设置为\(result)")
        }
    }
    
    //设置浏览器滚动样式
    public func scrollSetting(type: Int)
    {
        switch type{
        case 2:
            self.scrollView.isScrollEnabled = false
        case 1:
            self.scrollView.bounces = false
        case 3:
            self.scrollView.bouncesZoom = false
        default:
            break
        }
    }
    
    public func runScript(_ script:String, callback: ((Any?, Error?) -> Void)?)
    {
        self.evaluateJavaScript(script, completionHandler: callback)
    }
    
    //加载方式
    public func loadHTMLType(_ loadtype:String, url:String, query:String? = nil, isTemp:Bool? = false)
    {
        let queryStr = query != nil && query != "" ? "?" + query! : ""
        
        switch loadtype{
        case "resource":
            var resource = Bundle.main.path(forResource: url, ofType:"html")!
            if #available(iOS 9.0, *) {
                resource += queryStr
            } else {
                let html = NSTemporaryDirectory() + url.replacingOccurrences(of: "/", with: "_") + ".html"
                if !FileManager.default.fileExists(atPath: html){
                    try! FileManager.default.copyItem(atPath: resource, toPath: html)
                }
                resource = html + queryStr
            }
            
            let nsurl = NSURL(string: "file://" + resource)
            let requst = NSMutableURLRequest(url: nsurl! as URL)
            requst.httpMethod = "GET"
            self.load(requst as URLRequest)
            
            break;
        case "local":
            
            let fileurl = isTemp! ? NSTemporaryDirectory() + url : NSHomeDirectory() + "/Documents/html/" + url
            let resource = fileurl + queryStr
            let nsurl = NSURL(string: "file:/" + resource)
            let requst = NSMutableURLRequest(url: nsurl! as URL)
            requst.httpMethod = "GET"
            self.load(requst as URLRequest)
            
            break;
        default:
            self.load(URLRequest(url: URL(string: url)!))
            break;
        }
    }
    
    //前端JS交互函数
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
    {
        if "NativeMethod" == message.name {
            _ = WKNative(message.body, self)
        }
    }
    
    public func didReceiveMemoryWarning() {
        print("WK内存回收")
        self.load(NSURLRequest.init(url: NSURL.init(string: "about:blank")! as URL) as URLRequest)
        self.stopLoading()
        if self.progressView != nil
        {
            self.progressView?.removeFromSuperview()
            self.removeObserver(self, forKeyPath: "estimatedProgress")
        }
        
        self.configuration.userContentController.removeScriptMessageHandler(forName: "NativeMethod")
        // Dispose of any resources that can be recreated.
    }
    
}


//加载状态回调
private typealias wkNavigationDelegate = WKWeb
extension wkNavigationDelegate {
    
    //准备加载页面
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector:#selector(self.timeout), userInfo: nil, repeats: true)
    }
    
    //超时
    func timeout()
    {
        self.timer.invalidate()
    }
    
    //隐藏进度条
    func hideProgress()
    {
        if self.progressView != nil
        {
            self.progressView?.setProgress(0, animated: false)
        }
        self.timer.invalidate()
    }
    
    //内容开始
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!)
    {
        self.timer.invalidate()
    }
    //内容结束
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        //回调
        if self.callback != nil
        {
            (self.callback!)(self, true)
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector:#selector(self.hideProgress), userInfo: nil, repeats: true)
    }
    
    //加载失败
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
    {
        print("加载失败")
        NSLog(error.localizedDescription)
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector:#selector(self.hideProgress), userInfo: nil, repeats: true)
    }
    //加载失败
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error : Error)
    {
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector:#selector(self.hideProgress), userInfo: nil, repeats: true)
        print("开始失败\(error)")
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            self.progressView?.setProgress(Float(self.estimatedProgress), animated: true)
            //            print(self.estimatedProgress)
        }
    }
    
    /***跳转事件****/
    //接收到服务器跳转请求的代理
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!)
    {
        //        McDebugClass.log("接收到服务器跳转请求的代理")
    }
    
    //在收到响应后，决定是否跳转的代理
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void)
    {
        decisionHandler(WKNavigationResponsePolicy.allow)
    }
    
    //在发送请求之前，决定是否跳转的代理
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        //        McDebugClass.log("在发送请求之前，决定是否跳转的代理\(webView.url!)")
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    //验证证书
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
        {
            let card:URLCredential? = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, card)
        }
    }
}
