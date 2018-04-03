//
//  Https.swift
//  gotoplay
//
//  Created by 韩赛明 on 2017/4/8.
//  Copyright © 2017年 韩赛明. All rights reserved.
//

import UIKit
public class Https: NSObject,URLSessionDelegate {
    
    let boundary:String="-------------------21212222222222222222222"
    var session = URLSession()
    
    //数据请求
    init(url:String,body:Dictionary<String,String>?,callback:@escaping (NSDictionary) -> ()) {
        super.init()
        if body == nil
        {
            post(url, nil, callback)
        }
        else
        {
            post(url, self.handleBody(BodyDic: body!), callback)
        }
    }
    //带参数的上传文件
    init(url:String,filebody:Dictionary<String,Any>,callback:@escaping (NSDictionary) -> ())
    {
        super.init()
        postUpImage(url, self.handleFileBody(BodyDic: filebody), callback)
    }
    func post(_ url:String, _ query:String?,_ callback:@escaping (NSDictionary) -> ())
    {
        let _url = URL.init(string: url)
        let request = NSMutableURLRequest.init(url: _url!)
        //编码POST数据
        request.timeoutInterval = 10
        request.httpMethod = "POST"
        if query != nil
        {
            print("开始请求接口" + url + "?" + query!)
            //设置请求体
            let param:String = String(format: query!)
            request.httpBody = param.data(using: String.Encoding.utf8)
        }
        if DEBUG == false
        {
            //ptths模式启动代理
            let configuration = URLSessionConfiguration.default
            session = URLSession(configuration: configuration,delegate: self, delegateQueue:OperationQueue.main)
        }
        else
        {
            //非https模式下
            session = URLSession.shared
        }
        let task = session.dataTask(with: request as URLRequest) { (data, resp, error) in
            if(error != nil)
            {
                print(error!)
            }else{
                do {
//                    print(data!)
                    let json:Any = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers)
                    let json2dict = json as! NSDictionary
                    callback(json2dict)
                }catch
                {
                    
                }
            }
        }
        task.resume()
    }
    func postUpImage(_ url:String,_ query:NSMutableData,_ callback:@escaping (NSDictionary) -> ())
    {
        let _url = URL.init(string: url)
        let request = NSMutableURLRequest.init(url: _url!)
        request.httpMethod="POST"//设置请求方式
        //上传文件必须设置
        let contentType:String="multipart/form-data;boundary="+boundary
        request.addValue(contentType, forHTTPHeaderField:"Content-Type")
        request.httpBody = query as Data
        request.setValue("multipart/form-data;boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("\(query.length)", forHTTPHeaderField: "Content-Length")
        if DEBUG == false
        {
            //ptths模式启动代理
            let configuration = URLSessionConfiguration.default
            session = URLSession(configuration: configuration,delegate: self, delegateQueue:OperationQueue.main)
        }
        else
        {
            //非https模式下
            session = URLSession.shared
        }
        let task = session.dataTask(with: request as URLRequest) { (data, resp, error) in
            if(error != nil)
            {
                print(error!)
            }else{
                do {
                    let json:Any = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers)
                    let json2dict = json as! NSDictionary
                    callback(json2dict)
                    
                }catch
                {
                    
                }
            }
        }
        task.resume()
    }
    //服务器证书 需要证书在项目内！
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            let card = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, card)
        }
    }
    //表单处理 只有参数版本
    private func handleBody(BodyDic:Dictionary<String,String>) -> String
    {
        let keys = Array(BodyDic.keys)
        var values = Array<Any>()
        for a in 0..<keys.count
        {
            let value = BodyDic["\(keys[a])"]
            values.append(value!)
        }
        var str:String = ""
        for b in 0..<keys.count
        {
            str += "\(keys[b])=\(values[b])"
            
            if b != keys.count-1
            {
                str += "&"
            }
        }
        return str
    }
    
    private func handleFileBody(BodyDic:Dictionary<String,Any>) -> NSMutableData
    {
        let keys = Array(BodyDic.keys)
        var values = Array<Any>()
        for a in 0..<keys.count {
            let value = BodyDic["\(keys[a])"]
            values.append(value!)
        }
        
        let body=NSMutableData()
        
        for b in 0..<keys.count
        {
            if keys[b] == "file"
            {
                let filedic = values[b] as! Dictionary<String,Any>
                let fileKeys = Array(filedic.keys)
                var fileValues = Array<Any>()
                for c in 0..<fileKeys.count {
                    let value:Any = filedic["\(fileKeys[c])"]!
                    fileValues.append(value)
                }
                for d in 0..<fileKeys.count
                {
                    if ((fileValues[d] as? UIImage) != nil)
                    {
                        let ima = fileValues[d] as! UIImage
                        let imageData = UIImagePNGRepresentation(ima)! as NSData//把图片转成data
                        if b == 0
                        {
                            body.append(NSString(format:"--\(boundary)\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
                        }
                        else
                        {
                            body.append(NSString(format:"\r\n--\(boundary)\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
                        }
                        body.append(NSString(format:"Content-Disposition:form-data;name=\"\(fileKeys[d])\";filename=\"user.jpg\"\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
                        body.append("Content-Type:image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
                        body.append(imageData as Data)
                    }

                }
            }
            else
            {
                if b == 0
                {
                    body.append(NSString(format:"--\(boundary)\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
                }
                else
                {
                    body.append(NSString(format:"\r\n--\(boundary)\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
                }
                // 拼接参数名
                body.append(NSString(format:"Content-Disposition:form-data;name=\r\n\"\(keys[b])\"\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
                // 拼接参数值
                body.append(NSString(format:"\r\n\(values[b])" as NSString).data(using: String.Encoding.utf8.rawValue)!)
            }
        }
        body.append(NSString(format:"\r\n--\(boundary)--" as NSString).data(using: String.Encoding.utf8.rawValue)!)
        return body
    }
   
}
