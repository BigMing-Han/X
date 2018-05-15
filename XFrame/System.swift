//
//  SystemController.swift
//  xframe
//
//  Created by XiaoJiao Chen on 2017/3/27.
//  Copyright © 2017年 XiaoJiao Chen. All rights reserved.
//

import UIKit

public enum System {
    case appId, appName, appToken, appVersion, appBuildVersion, systemType, deviceModel, deviceId, deviceName
    case network, connectionType
    case screenWidth, screenHeight, statusBarAppearance
    case wgtRootDir, fsDir, cacheDir
    case appParam
    
    public func get() -> String {
        var infoDic = Bundle.main.infoDictionary
        switch self {
        case .appId:
            return infoDic?["CFBundleIdentifier"] as! String
        case .appName:
            return infoDic?["CFBundleName"] as! String
        case .appToken:
            return self.createToken(str: infoDic?["CFBundleIdentifier"] as! String, key: TOKEN_KEY)
        case .appVersion:
            return infoDic?["CFBundleShortVersionString"] as! String
        case .appBuildVersion:
            return infoDic?["CFBundleVersion"] as! String
        case .systemType:
            return UIDevice.current.systemName.lowercased()
        case .deviceModel:
            return UIDevice.current.model
        case .deviceId:
            return (UIDevice.current.identifierForVendor?.uuidString)!
        case .deviceName:
            return UIDevice.current.name
        default:
            return ""
        }
    }
    
    func createToken(str: String, key: String) -> String
    {
        var base64String = key.base64_encode()
        var keyarr = Array<Int>()
        for i in (base64String.unicodeScalars)
        {
            keyarr.append(Int(i.value))
        }
        
        base64String = str.base64_encode()
        var strarr = Array<Int>()
        for i in (base64String.unicodeScalars)
        {
            strarr.append(Int(i.value))
        }
        let length = keyarr.count > strarr.count ? keyarr.count : strarr.count
        var token = ""
        for i in 0..<length
        {
            if i < keyarr.count
            {
                if i < strarr.count
                {
                    if strarr[i] > keyarr[i]
                    {
                        strarr[i] = strarr[i] - keyarr[i]
                    }else
                    {
                        strarr[i] = keyarr[i] - strarr[i]
                        token = "\(token)~"
                    }
                    
                    if strarr[i] <= 32
                    {
                        strarr[i] += 32
                        token = "\(token)|"
                    }
                }else{
                    strarr[i] = keyarr[i]
                    token = "\(token)|"
                }
            }
            
            token = "\(token)\(Character(UnicodeScalar(strarr[i])!))"
        }
        
        return token.base64_encode()
    }
}

class Math
{
    static func rand(min: Int, max: Int) -> Int
    {
        if min > max
        {
            return -1
        }
        let i = max - min
        let f = Int(arc4random_uniform(UInt32(i)))
        let r = f + min
        return r
    }
    
    static func abs(number: CGFloat) -> CGFloat
    {
        if number < 0
        {
            return -1 * number
        }else
        {
            return number
        }
    }
    
    static func toFixed(float: CGFloat, num: Int) -> CGFloat
    {
        let w = pow(10, CGFloat(num)) as CGFloat
        let result = CGFloat(Int(float * w)) / w
        return result
    }
    
    static func toDegrees(radians: CGFloat) -> CGFloat
    {
        return (radians) * (180.0 / CGFloat(Double.pi))
    }
    
    static func toRadians(angle: CGFloat) -> CGFloat
    {
        return (angle) / 180.0 * CGFloat(Double.pi)
    }
}

extension String
{
    /**
     将当前字符串拼接到document目录后面
     */
    public func documentDir() -> String
    {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!  as NSString
        return path.appendingPathComponent((self as NSString).lastPathComponent)
    }
    public func base64_encode() -> String
    {
        let utf8EncodeData = self.data(using: String.Encoding.utf8, allowLossyConversion: true)
        let base64 = utf8EncodeData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: UInt(0)))
        return base64!
    }
    
    public func toCGFloat() -> CGFloat
    {
        var cgFloat: CGFloat = 0
        if let doubleValue = Double(self)
        {
            cgFloat = CGFloat(doubleValue)
        }
        return cgFloat
    }
    
    public func nsrange(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from..<to
    }
    
    public func getContent(start:String, end:String) -> String
    {
        var nsstr = self as NSString
        if nsstr.range(of: start).length == 0
        {
            return ""
        }
        var find = nsstr.range(of: start).location + start.lengthOfBytes(using: String.Encoding.utf8)
        nsstr = nsstr.substring(from: find) as NSString
        
        if end != "" && nsstr.range(of: end).length > 0
        {
            find = nsstr.range(of: end).location
            nsstr = nsstr.substring(to: find) as NSString
        }
        return nsstr as String
    }
    
    public func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [kCTFontAttributeName as NSAttributedStringKey: font], context: nil)
        return boundingBox.height
    }
    
    public func widthWithConstrainedWidth(width: CGFloat, WithFont font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [kCTFontAttributeName as NSAttributedStringKey: font], context: nil)
        return boundingBox.width
    }
    
    public func isNumber() -> Bool
    {
        let scan: Scanner = Scanner(string: self)
        var val:Int = 0
        return scan.scanInt(&val) && scan.isAtEnd
    }
}

extension UIColor {
    public class func colorWithHexString(_ hex:String, _ alpha:CGFloat = 1) ->UIColor {
        
        var cString = hex.trimmingCharacters(in:CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            let index = cString.index(cString.startIndex, offsetBy:1)
            cString = cString.substring(from: index)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.red
        }
        
        let rIndex = cString.index(cString.startIndex, offsetBy: 2)
        let rString = cString.substring(to: rIndex)
        let otherString = cString.substring(from: rIndex)
        let gIndex = otherString.index(otherString.startIndex, offsetBy: 2)
        let gString = otherString.substring(to: gIndex)
        let bIndex = cString.index(cString.endIndex, offsetBy: -2)
        let bString = cString.substring(from: bIndex)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
}

extension UIView {
    // - 添加字符串标记
    public var tagName:String? {
        set {
            // - ?? UnsafeRawPointer
            let key: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "tagName".hashValue)
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        
        get {
            let key: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "tagName".hashValue)
            return objc_getAssociatedObject(self, key) as? String
        }
    }
    
    // - 更具tagName获取VIew
    public func getSubviewByTagName(tagName: String) -> [UIView]
    {
        var split:[String] = []
        if let _ = tagName.characters.index(of: "*")
        {
            split = tagName.components(separatedBy: "*")
        }
        
        var all:[UIView] = []
        
        for i in self.subviews
        {
            if i.tagName == nil
            {
                continue
            }
            
            if split.count > 0
            {
                var result:UIView? = i
                
                for find in split
                {
                    if find == "" || find == "*"
                    {
                        continue
                    }
                    if let _ = i.tagName?.range(of: find)
                    {
                        //查找到内容进入待观察状态
                    }else
                    {
                        //一旦有不匹配信息直接判定为非
                        result = nil
                    }
                }
                
                if result != nil
                {
                    //                    return result
                    all.append(result!)
                }
            }else if i.tagName == tagName
            {
                //                return i
                all.append(i)
            }
        }
        
        return all
    }
    
    public func icon(image:Any) -> UIImage
    {
        var img:UIImage!
        if (image as? String) != nil
        {
            img = self.icon(name: image as! String).toImage()
        }else if image as? UIImage != nil
        {
            img = image as! UIImage
        }
        
        return img
    }
    
    public func icon(name:String, fillcolor:String = "", bordercolor:String = "") -> UIView
    {
        let id = "icon-" + name
        let svgreader = self.icon(resource: [id], jsname: "Frameworks/XFrame.framework/xframe.icon.js")
        return svgreader.getIcon(name: id, fillcolor: fillcolor, bordercolor: bordercolor)
    }
    
    //MARK: -设置存放在缓存下的路径-
    public func newIcon(resource: [String], jsname: String) -> SvgReader
    {
        
        var filepath:String = Cache.path(name: jsname)
        
        if #available(iOS 9.0, *) {
        }else{
            let toPath = NSTemporaryDirectory() + "xframe"
            if !FileManager.default.fileExists(atPath: toPath){
                try! FileManager.default.copyItem(atPath: filepath, toPath: toPath)
            }
            filepath = toPath + "/" + jsname
        }
        let svgreader = SvgReader(frame: self.frame)
        svgreader.open(filepath: filepath, resource)
        return svgreader

    }
    
    public func icon(resource: [String], jsname: String) -> SvgReader
    {
        var filepath:String = Bundle.main.path(forAuxiliaryExecutable: jsname)!
        
        if #available(iOS 9.0, *) {
        }else{
            let toPath = NSTemporaryDirectory() + "xframe"
            if !FileManager.default.fileExists(atPath: toPath){
                try! FileManager.default.copyItem(atPath: filepath, toPath: toPath)
            }
            
            filepath = toPath + "/" + jsname
        }
        
        let svgreader = SvgReader(frame: self.frame)
        svgreader.open(filepath: filepath, resource)
        
        return svgreader
    }
    
    public func toImage() -> UIImage
    {
        UIGraphicsBeginImageContext(self.bounds.size)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    public func loading(image: UIImage, color: UIColor? = nil, frame: CGRect? = nil) -> UIImageView
    {
        let loadingMask = UIView(frame: self.frame)
        loadingMask.backgroundColor = UIColor.colorWithHexString("#FFFFFF")
        self.addSubview(loadingMask)
        
        var imageView:UIImageView?
        if color != nil
        {
            imageView = UIImageView(image: image.withRenderingMode(UIImageRenderingMode.alwaysTemplate))
            imageView?.tintColor = color
        }else
        {
            imageView = UIImageView(image: image)
        }
        let vwidth = self.frame.width
        let vheight = self.frame.height
        let iwidth = image.size.width
        let iheight = image.size.height
        imageView?.frame = frame != nil ? frame! : CGRect(x: (vwidth - iwidth) / 2, y: (vheight - iheight) / 2, width: iwidth, height: iheight)
        self.addSubview(imageView!)
        
        return imageView!
    }
    
    public func alert(title:String? = nil, content:String? = "", width:CGFloat? = nil, height:CGFloat? = nil) -> UIView
    {
        /*遮罩*/
        let mask = UIView(frame: self.frame)
        mask.backgroundColor = UIColor.colorWithHexString("#000000")
        mask.alpha = 0.75
        self.addSubview(mask)
        
        /*主体*/
        let w = width != nil ? width : WINDOW_WIDTH * 0.8
        let h = height != nil ? height : WINDOW_HEIGHT * 0.15
        let x = (WINDOW_WIDTH - w!) / 2
        let y = (WINDOW_HEIGHT - h!) / 2
        
        if title != nil
        {
            /*头部*/
            let top = UIView(frame: CGRect(x: x, y: y - 40, width: w!, height: 40))
            top.addCorner(corner: [UIRectCorner.topLeft , UIRectCorner.topRight], size: CGSize(width: 5, height: 5))
            top.backgroundColor = UIColor.colorWithHexString("#72D1FF")
            //边距10
            let topLabel = UILabel(frame: CGRect(x: top.frame.minX + 10, y: top.frame.minY, width: top.frame.width - 20, height: top.frame.height))
            topLabel.text = title!
            topLabel.textColor = UIColor.colorWithHexString("#FFFFFF")
            self.addSubview(top)
            self.addSubview(topLabel)
        }
        
        let body = UIView(frame: CGRect(x: x, y: y, width: w!, height: h!))
        body.backgroundColor = UIColor.colorWithHexString("#FFFFFF")
        if title != nil
        {
            body.addCorner(corner: [UIRectCorner.bottomLeft , UIRectCorner.bottomRight], size: CGSize(width: 5, height: 5))
        }else{
            body.layer.cornerRadius = 5
        }
        //边距10
        let bodyLabel = UILabel(frame: CGRect(x: body.frame.minX + 10, y: body.frame.minY, width: body.frame.width - 20, height: body.frame.height))
        bodyLabel.textAlignment = NSTextAlignment.center
        bodyLabel.text = content
        bodyLabel.numberOfLines = 3
        self.addSubview(body)
        self.addSubview(bodyLabel)
        
        //添加点击删除操作
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.removeFromSuperview))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)
        
        return self
    }
    
    // - 绑定点击事件
    public func onTap(target: AnyObject, action: Selector)
    {
        if target.responds(to: action)
        {
            if !self.isUserInteractionEnabled
            {
                self.isUserInteractionEnabled = true
            }else if let gesture = self.gestureRecognizers
            {
                for i in gesture
                {
                    if i is UITapGestureRecognizer
                    {
                        print("清除已有点击事件")
                        self.removeGestureRecognizer(i)
                    }
                }
            }
            let tap = UITapGestureRecognizer(target: target, action: action)
            self.addGestureRecognizer(tap)
        }else
        {
            print("点击事件不存在")
        }
    }
    
    //圆角控制
    //[UIRectCorner.topLeft , UIRectCorner.topRight]
    public func addCorner(corner: UIRectCorner, size: CGSize)
    {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corner, cornerRadii: size)
        let layer = CAShapeLayer()
        layer.frame = bounds
        layer.path = path.cgPath
        self.layer.mask = layer
    }
}

extension CGPoint
{
    public func toDistance(point: CGPoint) -> CGFloat
    {
        let disx = self.x - point.x
        let disy = self.y - point.y
        
        let dis = sqrt(pow(disx, 2) + pow(disy, 2))
        
        return CGFloat(dis)
    }
    
    public func towPRGetCircleCenter(point: CGPoint, r: CGFloat) -> [CGPoint]
    {
        let p1 = self
        let p2 = point
        
        var mid_x:CGFloat = 0.0
        var mid_y:CGFloat = 0.0
        var c1x:CGFloat = 0.0
        var c2x:CGFloat = 0.0
        var c1y:CGFloat = 0.0
        var c2y:CGFloat = 0.0
        let k:CGFloat = (p2.x == p1.x) ? 0 : (p2.y - p1.y) / (p2.x - p1.x)
        var k_verticle:CGFloat = 0.0
        
        if Math.abs(number: k) < 0.1
        {
            c1x = (p1.x + p2.x) / 2
            c2x = (p1.x + p2.x) / 2
            c1y = p1.y + sqrt(r * r - (p1.x - p2.x) * (p1.x - p2.x) / 4)
            c2y = p2.y - sqrt(r * r - (p1.x - p2.x) * (p1.x - p2.x) / 4)
            if c1x == c2x
            {
                if c1y == c2y
                {
                    c1y = self.y
                    c2y = self.y
                }else if Math.abs(number: c1y - p1.y) != Math.abs(number: c1y - p2.y) || Math.abs(number: c2y - p1.y) != Math.abs(number: c2y - p2.y)
                {
                    c1y = (p1.y + p2.y) / 2
                    c2y = c1y
                }
            }
        }else
        {
            k_verticle = -1.0 / k
            mid_x = (p1.x + p2.x) / 2
            mid_y = (p1.y + p2.y) / 2
            let a = 1.0 + k_verticle * k_verticle
            let b = -2 * mid_x - k_verticle * k_verticle * CGFloat(p1.x + p2.x)
            let c = mid_x * mid_x + k_verticle * k_verticle * (p1.x + p2.x) * (p1.x + p2.x) / 4 -
                (r * r - ((mid_x - p1.x) * (mid_x - p1.x) + (mid_y - p1.y) * (mid_y - p1.y)))
            c1x = (-1.0 * b + sqrt(b * b - 4 * a * c)) / (2 * a)
            c2x = (-1.0 * b - sqrt(b * b - 4 * a * c)) / (2 * a)
            c1y = k_verticle * c1x - k_verticle * mid_x + mid_y
            c2y = k_verticle * c2x - k_verticle * mid_x + mid_y
        }
        
        let center1:CGPoint = CGPoint(x: c1x, y: c1y)
        let center2:CGPoint = CGPoint(x: c2x, y: c2y)
        
        return [center1, center2]
    }
}

extension UIImageView
{
    //加载网络图片
    public func getNetImage(url: String, defaultImage: String? = nil, isCache: Bool = true, callback: (() -> Void)? = nil)
    {
        //设置默认图片
        if defaultImage != nil {
            self.image = UIImage(named: defaultImage!)
        }
        
        //是否进行缓存处理
        if isCache {
            //缓存管理类
            let data:Data? = Cache.get(name: url)
            
            if data != nil {
                self.image = UIImage(data: data!)
                
                if callback != nil
                {
                    callback!()
                }
                
                return
            }
        }
        
        //创建URL对象
        let _url = URL(string:url)!
        //创建请求对象
        let request = URLRequest(url: _url)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            if error != nil{
                print(error.debugDescription)
            }else{
                //缓存数据
                Cache.set(name: url, value: data!)
                
                //将图片数据赋予UIImage
                DispatchQueue.main.async {
                    self.image = UIImage(data:data!)
                    
                    if callback != nil
                    {
                        callback!()
                    }
                }
            }
        }) as URLSessionTask
        
        //使用resume方法启动任务
        dataTask.resume()
    }
}

extension UIImage
{
    /**
     *  图片大小长度压缩
     */
    public func compressImage(maxLength: Int) -> UIImage? {
        let newSize = self.YSscaleImage(imageLength: 1024)
        let newImage = self.reSizeImage(reSize: newSize)
        var compress:CGFloat = 1
        var data = UIImageJPEGRepresentation(newImage, compress)
        while (data?.count)! > maxLength && compress > 0.01 {
            compress -= 0.02
            data = UIImageJPEGRepresentation(newImage, compress)
        }
        let image:UIImage = UIImage.init(data: data!)!
        return image
    }
    func  YSscaleImage(imageLength: CGFloat) -> CGSize {
        var newWidth:CGFloat = 0.0
        var newHeight:CGFloat = 0.0
        let width = self.size.width
        let height = self.size.height
        if (width > imageLength || height > imageLength){
            if (width > height) {
                newWidth = imageLength;
                newHeight = newWidth * height / width;
            }else if(height > width){
                newHeight = imageLength;
                newWidth = newHeight * width / height;
            }else{
                newWidth = imageLength;
                newHeight = imageLength;
            }
        }
        return CGSize(width: newWidth, height: newHeight)
    }
    
    /**
     *  重设图片大小
     */
    public func reSizeImage(reSize:CGSize)->UIImage {
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale)
        self.draw(in: CGRect(x:0.0, y:0.0, width:reSize.width, height:reSize.height))
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return reSizeImage
    }
    
    /**
     *  等比率缩放
     */
    public func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width:self.size.width * scaleSize, height:self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
    
    //重写图片颜色
    public func setColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context!.setBlendMode(CGBlendMode.normal)
        let rect = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height))
        context?.clip(to: rect, mask: cgImage!)
        color.setFill()
        context?.fill(rect)
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    //图片方向操作
    /*
     - rawVlue
     
     0 默认
     1 180旋转
     2 逆时针90
     3 顺时针90
     4 水平翻转 UP
     5 水平翻转 DOWN
     6 垂直翻转 LEFT
     7 垂直翻转 RIGHT
     
     */
    public func flip(rawValue:Int) -> UIImage
    {
        let filpImageOrientation = (rawValue) % 8
        return UIImage(cgImage: self.cgImage!, scale: self.scale, orientation: UIImageOrientation(rawValue: filpImageOrientation)!)
    }
}

extension UIButton {
    //图片上文字下的按钮
    public func MCButton(title: String = "", image: [UIImage] = [])
    {
        let titleMinHeight = title.heightWithConstrainedWidth(width: self.frame.width, font: (self.titleLabel?.font)!) * 1.1
        var scale:CGFloat = 1
        
        self.backgroundColor = UIColor.red
        
        if title != ""{
            self.setTitle(title, for: UIControlState.normal)
            self.titleLabel?.adjustsFontSizeToFitWidth = true
            scale = 0.8
        }
        
        if image.count > 0
        {
            scale = (self.frame.height - titleMinHeight) / image[0].size.height
            self.setImage(image[0].scaleImage(scaleSize: scale).withRenderingMode(UIImageRenderingMode.alwaysOriginal), for: UIControlState.normal)
        }
        
        if image.count > 1
        {
            scale = (self.frame.height - titleMinHeight) / image[1].size.height
            self.setImage(image[1].scaleImage(scaleSize: scale).withRenderingMode(UIImageRenderingMode.alwaysOriginal), for: UIControlState.selected)
        }
        
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        
        self.titleEdgeInsets = UIEdgeInsets(top: (self.imageView?.frame.size.height)!, left: 0.0 - (self.imageView?.frame.size.width)!, bottom: 0.0, right: 0.0)
        
        let imageTop:CGFloat = title == "" ? 0.0 : 0.0 - (self.imageView?.frame.size.height)! * 0.6
        
        self.imageEdgeInsets = UIEdgeInsets(top: imageTop, left: 0.0, bottom: 0.0, right: 0.0 - (self.titleLabel?.bounds.size.width)!)
    }
    
}





extension NSObject{
    
    /**
     获取对象对于的属性值，无对于的属性则返回NIL
     - parameter property: 要获取值的属性
     - returns: 属性的值
     */
    func getValueOfProperty(property:String)->AnyObject?{
        let allPropertys = self.getAllPropertys()
        if(allPropertys.contains(property)){
            return self.value(forKey: property) as AnyObject
            
        }else{
            return nil
        }
    }
    
    /**
     设置对象属性的值
     - parameter property: 属性
     - parameter value:    值
     - returns: 是否设置成功
     */
    func setValueOfProperty(property:String,value:AnyObject)->Bool{
        let allPropertys = self.getAllPropertys()
        if(allPropertys.contains(property)){
            self.setValue(value, forKey: property)
            return true
            
        }else{
            return false
            
        }
    }
    
    /**
     获取对象的所有属性名称
     - returns: 属性名称数组
     */
    func getAllPropertys()->[String]{
        var result = [String]()
        let count = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
        let buff = class_copyPropertyList(object_getClass(self), count)
        let countInt = Int(count[0])
        
        print(count)
        print(Int(count[0]))
        
        for i in 0 ..< countInt
        {
            let temp = buff?[i]
            let tempPro = property_getName(temp!)
            let proper = String.init(utf8String: tempPro)
            result.append(proper!)
        }

        return result
    }
}

//动画拓展
/*
 transform.scale	比例转化	@(0.8)
 transform.scale.x	宽的比例	@(0.8)
 transform.scale.y	高的比例	@(0.8)
 transform.rotation.x	围绕x轴旋转	@(M_PI)
 transform.rotation.y	围绕y轴旋转	@(M_PI)
 transform.rotation.z	围绕z轴旋转	@(M_PI)
 cornerRadius	圆角的设置	@(50)
 backgroundColor	背景颜色的变化	(id)[UIColor purpleColor].CGColor
 bounds	大小，中心不变	[NSValue valueWithCGRect:CGRectMake(0, 0, 200, 200)];
 position	位置(中心点的改变)	[NSValue valueWithCGPoint:CGPointMake(300, 300)];
 contents	内容，比如UIImageView的图片	imageAnima.toValue = (id)[UIImage imageNamed:@"to"].CGImage;
 opacity	透明度	@(0.7)
 contentsRect.size.width	横向拉伸缩放	@(0.4)最好是0~1之间的
 
 // - 函数
 kCAMediaTimingFunctionLinear（线性）：匀速，给你一个相对静态的感觉
 kCAMediaTimingFunctionEaseIn（渐进）：动画缓慢进入，然后加速离开
 kCAMediaTimingFunctionEaseOut（渐出）：动画全速进入，然后减速的到达目的地
 kCAMediaTimingFunctionEaseInEaseOut（渐进渐出）：动画缓慢的进入，中间加
 kCAMediaTimingFunctionDefault (默认)
 */
extension CALayer
{
    public func animate(type: String, form: Any? = nil, to: Any?, duration: CGFloat, repeatCount: Float = 0, delegate: Any? = nil, timing: String = kCAMediaTimingFunctionEaseInEaseOut, autoreverses:Bool = false, begin:CFTimeInterval = 0)
    {
        let pulse = CABasicAnimation(keyPath: type)
        
        if delegate != nil
        {
            pulse.delegate = delegate as? CAAnimationDelegate
        }
        
        pulse.timingFunction = CAMediaTimingFunction(name:timing)
        pulse.duration = CFTimeInterval(duration)
        
        if form != nil
        {
            pulse.fromValue = form
        }
        pulse.toValue = to
        pulse.repeatCount = repeatCount
        pulse.isRemovedOnCompletion = false
        pulse.fillMode = kCAFillModeForwards
        pulse.autoreverses = autoreverses
        pulse.beginTime = begin
        self.add(pulse, forKey: nil)
    }
}

//动画
public class AnimateUIView: UIView, CAAnimationDelegate
{
    
    // - 设置回调组
    public var callback:[String: Any?]!
    public var queue: [[Any?]]!
    
    // - 设置回收函数
    deinit {
        //        print("对象收回")
    }
    
    @objc public func run(_ recognizer: UITapGestureRecognizer? = nil)
    {
        
        let target = recognizer?.view
        
        if target != nil
        {
            target?.isUserInteractionEnabled = false
        }
        if self.queue != nil && self.queue.count > 0
        {
            let q = self.queue.removeFirst()
            if let end = q[0] as? () -> ()
            {
                (end)()
                if target != nil
                {
                    target?.isUserInteractionEnabled = true
                }
            }else
            {
                self.layer.animate(type: q[0] as! String, form: q[1], to: q[2], duration: "\(q[3]!)".toCGFloat(), delegate: self, timing: kCAMediaTimingFunctionLinear)
            }
        }
    }
    
    @objc public func onclick(_ recognizer: UITapGestureRecognizer)
    {
        //                print(recognizer.view?.tagName)
        if let view = recognizer.view
        {
            view.isUserInteractionEnabled = false
            let name = view.tagName
            if name != nil
            {
                if let f = self.callback[name!] as? () -> Void
                {
                    f()
                }
                
                // - 是不是有一种可能再f函数里已经将view销毁？
                view.isUserInteractionEnabled = true
            }
        }
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if self.queue.count > 0
        {
            run()
        }
    }
    
}


//延时执行喵神封装
public typealias Task = (_ cancel : Bool) -> Void

public func delay(_ time: TimeInterval, task: @escaping ()->()) ->  Task? {
    
    func dispatch_later(block: @escaping ()->()) {
        let t = DispatchTime.now() + time
        DispatchQueue.main.asyncAfter(deadline: t, execute: block)
    }
    var closure: (()->Void)? = task
    var result: Task?
    
    let delayedClosure: Task = {
        cancel in
        if let internalClosure = closure {
            if (cancel == false) {
                DispatchQueue.main.async(execute: internalClosure)
            }
        }
        closure = nil
        result = nil
    }
    
    result = delayedClosure
    
    dispatch_later {
        if let delayedClosure = result {
            delayedClosure(false)
        }
    }
    return result
}

public func cancel(_ task: Task?) {
    task?(true)
}


// - 网络来源调试函数
public func MLog<T>(_ message:T, file:String = #file, function:String = #function,
                 line:Int = #line) {
    if DEBUG
    {
        //获取文件名
        let fileName = (file as NSString).lastPathComponent
        //打印日志内容
        print("====================================")
        print("\(fileName):\(line) \(function)")
        print("\(message)")
        print("------------------------------------\n\r")
    }
}


public func setInterval(delayTime:TimeInterval, repeatCount: Float = 1, function:@escaping () -> Void)
{
    if repeatCount <= 0
    {
        return
    }
    
    _ = delay(delayTime, task: {
        function()
        setInterval(delayTime: delayTime, repeatCount: repeatCount - 1, function: function)
    })
}
