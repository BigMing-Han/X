//
//  DownLoadClass.swift
//  v3
//
//  Created by 创造小青年 on 16/9/26.
//  Copyright © 2016年 创造小青年. All rights reserved.
//

import UIKit

public class DownLoad: NSObject, URLSessionDownloadDelegate {
    
    let path = NSHomeDirectory() + "/Documents/"
    fileprivate var downloadTask = [[String:String]]()      //[target!, filename!, director?]
    fileprivate var loading:Bool = false
    fileprivate var callback:Any? = nil
    fileprivate var taskTotalCount:Int = 0
    
    //添加下载任务
    func addDownTask(target:String, filename:String, director:String)
    {
        let task:Dictionary = ["target": target, "filename":filename, "director":director]
        self.downloadTask.append(task)
        self.taskTotalCount += 1
    }
    
    //获取是否下载中
    func getStatus() -> Dictionary<String, Any>
    {
        return ["loading": self.loading, "total": self.taskTotalCount]
    }
    
    //监听下载
    func addListener(_ callback: @escaping (CGFloat) -> Void)
    {
        self.callback = callback
    }
    
    //下载文件
    func run()
    {
        if self.downloadTask.isEmpty
        {
            self.loading = false
        }else{
            self.loading = true
            let tasks:Dictionary = self.downloadTask[0]
            let url = URL(string: tasks["target"]!)
            let request:URLRequest = URLRequest(url: url!)
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
            let task = session.downloadTask(with: request)
            task.resume()
        }
    }
    
    
    /*********开始代理方法*******************************************/
    
    //下载代理方法，下载结束
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        //下载结束
        let tasks:Dictionary = self.downloadTask[0]
        //输出下载文件原来的存放目录
        print("location:\(location)")
        //location位置转换
        let locationPath = location.path
        var documnets = ""
        if tasks["director"] == "temp"
        {
            //拷贝到缓存目录
            documnets = NSTemporaryDirectory() + "/" + tasks["filename"]!
        }else{
            //拷贝到用户目录
            documnets = self.path + tasks["director"]! + "/" + tasks["filename"]!
            print("new location:\(documnets)")
        }
        //创建文件管理器
        let fileManager:FileManager = FileManager.default
        //路径不存在自动创建
        try? fileManager.createDirectory(atPath: path + tasks["director"]!, withIntermediateDirectories: true, attributes: nil)        //判断是否已经存在文件
        let isExist = fileManager.fileExists(atPath: documnets)
        if(isExist)
        {
            //先删除文件
            try? fileManager.removeItem(atPath: documnets)
        }
        try? fileManager.moveItem(atPath: locationPath, toPath: documnets)
        
        //在任务列表移除当前任务
        self.downloadTask.remove(at: 0)
        
        //继续下载任务
        self.run()
    }
    
    //下载代理方法，监听下载进度
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        //获取进度
        let written:CGFloat = (CGFloat)(totalBytesWritten)
//        print("written:\(written)")
        let total:CGFloat = (CGFloat)(totalBytesExpectedToWrite)
//        print("total:\(total)")
        let finish:CGFloat = CGFloat(self.taskTotalCount) - CGFloat(self.downloadTask.count)
//        print("finish:\(finish)")
        let pro:CGFloat = (finish + written/total)/CGFloat(self.taskTotalCount)
        
        //回调
        if self.callback != nil
        {
            (self.callback as! (CGFloat) -> Void)(pro)
        }
    }
    
    //下载代理方法,下载偏移，主要用于暂停续传
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
}


public class Cache
{
    // - 获取缓存路径
    
    public static func path(name: String) -> String
    {
        let cachesPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let cachePath = cachesPaths[0] + "/XFrame/" + name
        
        let fileManager:FileManager = FileManager.default
        try? fileManager.createDirectory(atPath: cachePath, withIntermediateDirectories: true, attributes: nil)
        
        return cachePath
        
    }
    
    // - 获取缓存
    
    public static func get(name: String) -> Data? {
        let documnet = Cache.path(name: name)
        
        //创建文件管理器
        let fileManager:FileManager = FileManager.default
        //判断是否已经存在文件
        let isExist = fileManager.fileExists(atPath: documnet)
        if(isExist)
        {
            
            let data = fileManager.contents(atPath: documnet)
            
            if data != nil
            {
                let expData = fileManager.contents(atPath: documnet + "_expired")
                if expData != nil
                {
                    let str = String(data:expData! ,encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                    
                    if let exp = Double(str!)
                    {
                        if exp < NSDate().timeIntervalSince1970
                        {
                            return nil
                        }
                    }
                }
            }
            
            return data
        }
        
        return nil
    }
    
    // - 设置缓存
    
    public static func set(name: String, value: Data, expired: TimeInterval = 0)
    {
        let documnet = Cache.path(name: name)
        //创建文件管理器
        let fileManager:FileManager = FileManager.default
        let isExist = fileManager.fileExists(atPath: documnet)
        if(isExist)
        {
            try? fileManager.removeItem(atPath: documnet)
        }
        
        do
        {
            let url: URL = URL(fileURLWithPath: documnet)
            try value.write(to: url)
            
            // - 过期时间
            if expired != 0
            {
                try String("\(NSDate().timeIntervalSince1970 + expired)")?.write(to: URL(fileURLWithPath: documnet + "_expired"), atomically: true, encoding: String.Encoding.utf8)
            }
        }catch
        {
            print("错误:\(error)")
        }
    }
    
    
    // - 清除所有
    
    public static func clean(name: String = "")
    {
        let documnet = Cache.path(name: name)
        let fileManager:FileManager = FileManager.default
        try? fileManager.removeItem(atPath: documnet)
    }
}
