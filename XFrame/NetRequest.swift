//
//  NetRequest.swift
//  Pods
//
//  Created by 刘强 on 2017/5/31.
//
//

import Foundation

public class NetRequest: NSObject, URLSessionDelegate {
    
    private var header:String = ""
    private var lastResponse:String = ""
    
    public init(url: String, query:[String:Any]? = nil, header: [String:String]? = nil, callback: ((NSDictionary, NetRequest?) -> Void)? = nil)
    {
        super.init()
        self.post(url: url, query: query, header: header, callback: callback)
    }
    
    public func post(url:String, query:[String:Any]? = nil, header: [String:String]? = nil,  callback: ((NSDictionary, NetRequest?) -> Void)? = nil)
    {
        var session = URLSession()
        let _url = URL.init(string: url)
        let request = NSMutableURLRequest.init(url: _url!)
        
        if header != nil
        {
            for i in header!
            {
                request.addValue(i.value, forHTTPHeaderField: i.key)
            }
        }
        
        if query != nil
        {
            //编码POST数据
            request.httpMethod = "POST"
            
            //上传文件必须设置
            let boundary:String = "-------------------XFRAME\(Double(NSDate().timeIntervalSince1970 * 100000))"
            let body = NSMutableData()
            
            self.header = request.httpMethod + " " + url + "\r\n"
            
            for i in query!
            {
                body.append(NSString(format:"\r\n--\(boundary)\r\n" as NSString).data(using: String.Encoding.ascii.rawValue)!)
                
                if i.value is String
                {
                    let string = "Content-Disposition:form-data; name=\"\(i.key)\"\r\n" as NSString
                    let type = "\r\n\(i.value)" as NSString
                    self.header += "\(string as String)\(type as String)\r\n\r\n"
                    
                    //文本类型
                    body.append(NSString(format: string).data(using: String.Encoding.utf8.rawValue)!)
                    body.append(NSString(format: type).data(using: String.Encoding.utf8.rawValue)!)
                    
                }else if i.value is UIImage
                {
                    let string = "Content-Disposition:form-data; name=\"\(i.key)\"; filename=\"xframe.png\"\r\n" as NSString
                    let type = "Content-Type:image/png\r\n\r\n" as NSString
                    self.header += "\(string as String)\(type as String)-----图片数据省略-----\r\n\r\n"
                    
                    //图片类型
                    let imageData = UIImagePNGRepresentation(i.value as! UIImage)! as Data
                    body.append(NSString(format: string).data(using: String.Encoding.ascii.rawValue)!)
                    body.append(NSString(format: type).data(using: String.Encoding.ascii.rawValue)!)
                    body.append(imageData)
                }else if i.value is Data
                {
                    let index = "\(i.key)".index("\(i.key)".startIndex, offsetBy: 1)
                    if "\(i.key)".substring(to: index) == "@"
                    {
                        let file = "\(i.key)".replacingOccurrences(of: "@", with: "")
                        let arr = file.components(separatedBy: ".")
                        if(arr.count > 1)
                        {
                            if let filedata = i.value as? Data
                            {
                                let filetype = arr[1]
                                
                                let string = "Content-Disposition:form-data; name=\"\(arr[0])\"; filename=\"xframe.\(filetype)\"\r\n" as NSString
                                let type = "Content-Type:application/octet-stream\r\n\r\n" as NSString
                                self.header += "\(string as String)\(type as String)-----文件数据省略-----\r\n\r\n"
                                
                                //其他类型
                                body.append(NSString(format: string).data(using: String.Encoding.ascii.rawValue)!)
                                body.append(NSString(format: type).data(using: String.Encoding.ascii.rawValue)!)
                                body.append(filedata)
                            }
                        }
                    }
                }else
                {
                    MLog("没有处理的字段\(i.key),类型为\(type(of: i.value))" )
                }
            }
            
            body.append("\r\n--\(boundary)--\r\n".data(using: String.Encoding.ascii)!)
            request.httpBody = body as Data
            request.setValue("\(body.length)", forHTTPHeaderField: "Content-Length")
            
            let contentType:String="multipart/form-data;boundary=" + boundary
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            
            var _h = ""
            for i in request.allHTTPHeaderFields!
            {
                _h += "\r\n" + (i.key + " : " + i.value)
            }
            
            self.header = _h + self.header
            
        }
        
        if url.lowercased().hasPrefix("https")
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
            var returnDic:NSDictionary = [:]
            
            if(error != nil)
            {
                returnDic = ["code":"600", "data": "", "msg":"超时"]
                
            }else{
                self.lastResponse = String.init(data: data!, encoding: String.Encoding.utf8)!
                
                do {
                    let json:Any = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers)
                    returnDic = json as! NSDictionary
                }catch
                {
//                    if let str = String(data: data!, encoding: String.Encoding.ascii)
                    if let str = String(data: data!, encoding: String.Encoding.utf8)
                    {
                        print(str)
                        
                        returnDic = ["code":"600", "data": "", "msg":str]
                        
                    }
                }
            }
            
            
            if callback != nil
            {
                DispatchQueue.main.async(execute: {
                    callback!(returnDic, self)
                })
            }
        }
        
        task.resume()
    }
    
    public func getHeader() -> String
    {
        return self.header
    }
    
    public func getResponse() -> String
    {
        return self.lastResponse
    }
    
    //服务器证书 需要证书在项目内！
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            let card = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, card)
        }
    }
}
