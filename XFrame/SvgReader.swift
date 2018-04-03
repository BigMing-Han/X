//
//  XmlReader.swift
//  xframe
//
//  Created by XiaoJiao Chen on 2017/4/12.
//  Copyright © 2017年 XiaoJiao Chen. All rights reserved.
//

import Foundation
import UIKit

public class SvgReader: UIView {
    private var svgDatas: Dictionary<String,[[[String]]]> = Dictionary()
    private var svgColors: Dictionary<String, [String]> = Dictionary()
    
    // - 创建单文件缓存  配合Cache
    public func build()
    {
        for i in self.svgDatas
        {
            Cache.set(name: "icon/" + i.key + ".path", value: "\(i.value)".data(using: String.Encoding.utf8)!)
        }
        
        for i in self.svgColors
        {
            Cache.set(name: "icon/" + i.key + ".color", value: "\(i.value)".data(using: String.Encoding.utf8)!)
        }
    }
    
    
    
    
    public func open(filepath: String, _ names : [String]? = nil) {
        do
        {
            var name = ".*?"
            if names != nil && (names?.count)! > 0
            {
                var hasCache = true
                for i in names!
                {
                    let path = Cache.get(name: "icon/" + i + ".path")
                    if path == nil
                    {
                        hasCache = false
                    }else{
                        let pathJson:Any = try JSONSerialization.jsonObject(with: path!, options:JSONSerialization.ReadingOptions.mutableContainers)
                        self.svgDatas[i] = (pathJson as! [[[String]]])
                        
                        if let color = Cache.get(name: "icon/" + i + ".color")
                        {
                            let colorJson:Any = try JSONSerialization.jsonObject(with: color, options:JSONSerialization.ReadingOptions.mutableContainers)
                            self.self.svgColors[i] = (colorJson as! [String])
                        }
                    }
                }
                
                if hasCache
                {
                    return
                }
                
                name = (names?.joined(separator: "|"))!
            }
            
            let str = try NSString(contentsOfFile: filepath, encoding: String.Encoding.utf8.rawValue) as String
            
            //正则寻找glyph
            //            let pattern = "\\sd=\".*?z\""
            let pattern = "<symbol id=\"(" + name + ")\".*?symbol>"
            let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.dotMatchesLineSeparators)
            let resArray = regex.matches(in: str as String, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, str.characters.count))
            for result : NSTextCheckingResult in resArray
            {
                let d = str.substring(with: str.nsrange(from: result.range)!) as String
                let name = d.getContent(start: "id=\"", end: "\"")
                var data = d
                var color = ""
                var b = true
                while b {
                    //获取颜色
                    color = data.getContent(start: "fill=\"", end: "\"")
                    if color == ""
                    {
                        color = "#000000"
                    }
                    
                    if self.svgColors[name] == nil
                    {
                        self.svgColors[name] = []
                    }else
                    {
                        self.svgColors[name]!.append(color)
                    }
                    
                    data = data.getContent(start: "<path d=\"", end: "\"")
                    if data != ""
                    {
                        if self.svgDatas[name] == nil
                        {
                            self.svgDatas[name] = [self.getdata(data)]
                        }else
                        {
                            self.svgDatas[name]!.append(self.getdata(data))
                        }
                        data = d.getContent(start: data, end: "")
                    }else
                    {
                        b = data != ""
                    }
                }
            }
            
            //自动更新图标缓存
            self.build()
            
        }catch
        {
            print(filepath)
            print(error)
        }
    }
    
    //绘制图片
    public func getIcon(name: String, fillcolor: String = "", bordercolor: String = "") -> UIView
    {
        let rview = UIView(frame: self.frame)
        if self.svgDatas[name] == nil
        {
            return rview
        }
        var scale:CGFloat = 1
        if rview.frame.width < rview.frame.height
        {
            scale = rview.frame.width / 1024
        }else{
            scale = rview.frame.height / 1024
        }
        
        
        //        let length = 1
        let datas = self.svgDatas[name]
        let colors = self.svgColors[name]
        let length = datas!.count
        
        for i in 0..<length
        {
            let color = UIColor.colorWithHexString(fillcolor != "" ? fillcolor : (colors?[i] != nil ? colors![i] : "#000000")).cgColor
            let layer = ShapeLayer()
            layer.SvgPaths(datas: (datas?[i])!, width: 1, color: color, scale: scale, border: bordercolor)
            rview.layer.addSublayer(layer)
        }
        
        return rview
    }
    
    //整理数据
    private func getdata(_ d: String) -> [[String]]
    {
        var data:[String] = []
        var action:[[String]] = [[String]]()
        
        var tempData = [String]()
        var tempString = ""
        var actionStr = ""
        let chars = ((d + "z").replacingOccurrences(of: "-", with: " -").replacingOccurrences(of: "e -", with: "e-")).characters
        
        
        for i in chars
        {
            actionStr = self.checkAction(char: i)
            
            if data.count < 1 && actionStr != "M" || String(i) == "\"" || String(i) == "\n"
            {
                continue
            }
            
            if actionStr != "" && data.count > 0
            {
                data.append("")
                for j in data
                {
                    if data[0] == j || j.trimmingCharacters(in: CharacterSet.whitespaces) == ""
                    {
                        if tempString != ""
                        {
                            tempData.append(tempString)
                            tempString = ""
                        }
                        if j.trimmingCharacters(in: CharacterSet.whitespaces) != ""
                        {
                            tempData.append(j)
                        }
                    }else
                    {
                        tempString = tempString + j
                    }
                }
                
                action.append(tempData)
                data = []
                tempData = []
                
            }
            
            data.append(String(i))
        }
        
        return action
    }
    
    //判断动作节点
    private func checkAction(char:Any) -> String
    {
        var index = ""
        if ((char as? Character) != nil)
        {
            index.append(char as! Character)
        }else if ((char as? String) != nil)
        {
            index = char as! String
        }else
        {
            return ""
        }
        let actions = ["M","L","H","V","C","S","Q","T","A","Z"]
        for i in actions
        {
            if index.uppercased() == i
            {
                return i
            }
        }
        return ""
    }
}
