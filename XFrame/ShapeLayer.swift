//
//  Layer.swift
//  xframe
//
//  Created by XiaoJiao Chen on 2017/4/10.
//  Copyright © 2017年 XiaoJiao Chen. All rights reserved.
//

import UIKit

public class ShapeLayer: CAShapeLayer {
    public func line(form: CGPoint, to: CGPoint, width: CGFloat, color: CGColor, dash: [NSNumber]?)
    {
        let linepath = UIBezierPath()
        linepath.move(to: form)
        linepath.addLine(to: to)
        if dash != nil
        {
            self.lineDashPattern = dash
        }
        self.lineWidth = width
        self.strokeColor = color
        self.path = linepath.cgPath
    }
    
    private func computeArc(x0:CGFloat, y0: CGFloat, rx:CGFloat, ry:CGFloat, angle: CGFloat, largeArcFlag: Bool, sweepFlag: Bool, x:CGFloat, y:CGFloat) -> [String:CGFloat]
    {
        let dx2 = (x0 - x) / 2
        let dy2 = (y0 - y) / 2
        
        let angle = Math.toRadians(angle: angle.truncatingRemainder(dividingBy: 360))
        
        let cosAngle = cos(angle)
        let sinAngle = sin(angle)
        
        let x1 = (cosAngle * dx2 + sinAngle * dy2)
        let y1 = (-sinAngle * dx2 + cosAngle * dy2)
        
        var rx = Math.abs(number: rx)
        var ry = Math.abs(number: ry)
        
        var prx = rx * rx
        var pry = ry * ry
        let px1 = x1 * x1
        let py1 = y1 * y1
        
        let radiicheck = px1/prx + py1/pry
        if radiicheck > 1
        {
            rx = sqrt(radiicheck) * rx
            ry = sqrt(radiicheck) * ry
            
            prx = rx * rx
            pry = ry * ry
        }
        
        
        var sign:CGFloat = (largeArcFlag == sweepFlag) ? -1 : 1
        var sq = ((prx * pry) - (prx * py1) - (pry * px1)) / ((prx * py1) + (pry * px1))
        
        sq = sq < 0 ? 0 : sq
        
        let coef = (sign * sqrt(sq))
        let cx1 = coef * ((rx * y1) / ry)
        let cy1 = coef * -((ry * x1) / rx)
        
        let sx2 = (x0 + x) / 2.0
        let sy2 = (y0 + y) / 2.0
        let cx = sx2 + (cosAngle * cx1 - sinAngle * cy1)
        let cy = sy2 + (sinAngle * cx1 + cosAngle * cy1)
        
        
        let ux = (x1 - cx1) / rx
        let uy = (y1 - cy1) / ry
        let vx = (-x1 - cx1) / rx
        let vy = (-y1 - cy1) / ry
        
        var n:CGFloat = sqrt((ux * ux) + (uy * uy))
        var p:CGFloat = ux
        
        sign = (uy < 0) ? -1.0 : 1.0
        var angleStart = Math.toDegrees(radians: sign * acos(p / n))
        
        n = sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy))
        p = ux * vx + uy * vy;
        sign = (ux * vy - uy * vx < 0) ? -1.0 : 1.0;
        var angleExtent = Math.toDegrees(radians: sign * acos(p / n))
        if(!sweepFlag && angleExtent > 0) {
            angleExtent -= 360
        } else if (sweepFlag && angleExtent < 0) {
            angleExtent += 360
        }
        
        angleExtent = angleExtent.truncatingRemainder(dividingBy: 360)
        angleStart = angleStart.truncatingRemainder(dividingBy: 360)
        
        return [
            "centerX": cx,
            "centerY": cy,
            "start": Math.toRadians(angle: angleStart),
            "extent": Math.toRadians(angle: angleExtent),
            "x1": x0,
            "y1": y0,
            "endx": x,
            "endy": y
        ]
    }
    
    //SVG A 函数单独处理
    private func svgPathA(linepath:UIBezierPath, i: [String], result: [CGFloat], type: String = "A") -> [CGFloat]
    {
        var x1 = result[0]
        var y1 = result[1]
        var endx = result[2]
        var endy = result[3]
        let scale = result[4]
        
        for j in 1...(i.count-1)/7
        {
            x1 = endx
            y1 = endy
            
            
            let RX = (i[j*7-6].toCGFloat()) * scale
            let RY = (i[j*7-5].toCGFloat()) * scale
            let X_ROTATION = (i[j*7-4].toCGFloat())
            let FLAG1 = i[j*7-3].toCGFloat() != 0
            let FLAG2 = i[j*7-2].toCGFloat() != 0
            
            endx = (type == "A" ? 0 : endx) + i[j*7-1].toCGFloat() * scale
            endy = (type == "A" ? 0 : endy) + i[j*7].toCGFloat() * scale
            
            let X = endx
            let Y = endy
            
            var result = self.computeArc(x0: x1, y0: y1, rx: RX, ry: RY, angle: X_ROTATION, largeArcFlag: FLAG1, sweepFlag: FLAG2, x: X, y: Y)
            
            let start = result["start"]!
            
            if start < 0
            {
                result["start"] = 2 * CGFloat.pi + start
            }
            
            result["end"] = result["start"]! + result["extent"]!
            
            if result["end"]! < 0
            {
                result["end"] = 2 * CGFloat.pi + result["end"]!
            }else if result["end"]! - 2 * CGFloat.pi >= 0.0
            {
                result["end"] = result["end"]! - 2 * CGFloat.pi
            }
            
            if Int(RX * 100) == Int(RY * 100)
            {
                
                let r = sqrtf(powf(Float(result["endx"]! - result["centerX"]!), 2) + powf(Float(result["endy"]! - result["centerY"]!), 2))
                
                linepath.addArc(withCenter: CGPoint.init(x: result["centerX"]!, y: result["centerY"]!), radius: CGFloat(r), startAngle: result["start"]!, endAngle: result["end"]!, clockwise: FLAG2)
            }else
            {
                let r = RX > RY ? RX : RY
                linepath.addArc(withCenter: CGPoint.init(x: result["centerX"]!, y: result["centerY"]!) , radius: r, startAngle: result["start"]!, endAngle: result["end"]!, clockwise: FLAG2)
            }
            
        }
        
        return [x1, y1, endx, endy]
    }
    
    public func SvgPaths(datas: [[String]], width: CGFloat, color: CGColor, scale: CGFloat = 1.0, border:String = "")
    {
        let linepath = UIBezierPath()
        self.lineWidth = width
        if border != ""
        {
            self.strokeColor = UIColor.colorWithHexString(border).cgColor
        }
        
        self.fillColor = color
        
        var endx: CGFloat = 0.0
        var endy: CGFloat = 0.0
        var x1: CGFloat = 0.0
        var x2: CGFloat? = nil
        var y1: CGFloat = 0.0
        var y2: CGFloat? = nil
        
        var count = 0
        
        for i in datas
        {
            //                        if count > 9
            //                        {
            //                            self.path = linepath.cgPath
            //                            return
            //                        }
            //                        print("-------------------------【\(count)】")
            //                        print(i)
            
            switch i[0] {
            case "M":
                for j in 1...(i.count-1)/2
                {
                    endx = i[j*2-1].toCGFloat() * scale
                    endy = i[j*2].toCGFloat() * scale
                    linepath.move(to: CGPoint(x: endx, y: endy))
                }
                x2 = nil
                y2 = nil
                break
            case "m":
                for j in 1...(i.count-1)/2
                {
                    endx += i[j*2-1].toCGFloat() * scale
                    endy += i[j*2].toCGFloat() * scale
                    linepath.move(to: CGPoint(x: endx, y: endy))
                }
                x2 = nil
                y2 = nil
                break
            case "L":
                for j in 1...(i.count-1)/2
                {
                    endx = i[j*2-1].toCGFloat() * scale
                    endy = i[j*2].toCGFloat() * scale
                    linepath.addLine(to: CGPoint(x: endx, y: endy))
                }
                x2 = nil
                y2 = nil
                break
            case "l":
                for j in 1...(i.count-1)/2
                {
                    endx = endx + i[j*2-1].toCGFloat() * scale
                    endy = endy + i[j*2].toCGFloat() * scale
                    linepath.addLine(to: CGPoint(x: endx, y: endy))
                }
                x2 = nil
                y2 = nil
                break
            case "H":
                for j in 1...(i.count-1)
                {
                    endx = i[j].toCGFloat() * scale
                    linepath.addLine(to: CGPoint(x: endx, y: endy))
                }
                x2 = nil
                y2 = nil
                break
            case "h":
                for j in 1...(i.count-1)
                {
                    endx += i[j].toCGFloat() * scale
                    linepath.addLine(to: CGPoint(x: endx, y: endy))
                }
                x2 = nil
                y2 = nil
                break
            case "V":
                for j in 1...(i.count-1)
                {
                    endy = i[j].toCGFloat() * scale
                    linepath.addLine(to: CGPoint(x: endx, y: endy))
                }
                x2 = nil
                y2 = nil
                break
            case "v":
                for j in 1...(i.count-1)
                {
                    endy += i[j].toCGFloat() * scale
                    linepath.addLine(to: CGPoint(x: endx, y: endy))
                }
                x2 = nil
                y2 = nil
                break
            case "C":
                for j in 1...(i.count-1)/6
                {
                    x1 = i[j*6-5].toCGFloat() * scale
                    y1 = i[j*6-4].toCGFloat() * scale
                    x2 = i[j*6-3].toCGFloat() * scale
                    y2 = i[j*6-2].toCGFloat() * scale
                    endx = i[j*6-1].toCGFloat() * scale
                    endy = i[j*6].toCGFloat() * scale
                    linepath.addCurve(to: CGPoint(x: endx, y: endy), controlPoint1: CGPoint(x: x1, y: y1), controlPoint2: CGPoint(x: x2!, y: y2!))
                }
                break
            case "c":
                for j in 1...(i.count-1)/6
                {
                    x1 = endx + i[j*6-5].toCGFloat() * scale
                    y1 = endy + i[j*6-4].toCGFloat() * scale
                    x2 = endx + i[j*6-3].toCGFloat() * scale
                    y2 = endy + i[j*6-2].toCGFloat() * scale
                    endx += i[j*6-1].toCGFloat() * scale
                    endy += i[j*6].toCGFloat() * scale
                    linepath.addCurve(to: CGPoint(x: endx, y: endy), controlPoint1: CGPoint(x: x1, y: y1), controlPoint2: CGPoint(x: x2!, y: y2!))
                }
                break
            case "S":
                for j in 1...(i.count-1)/4
                {
                    let tx2 = i[j*4-3].toCGFloat() * scale
                    let ty2 = i[j*4-2].toCGFloat() * scale
                    x1 = endx * 2 - (x2 != nil ? x2! : tx2)
                    y1 = endy * 2 - (y2 != nil ? y2! : ty2)
                    x2 = tx2
                    y2 = ty2
                    endx = i[j*4-1].toCGFloat() * scale
                    endy = i[j*4].toCGFloat() * scale
                    linepath.addCurve(to: CGPoint(x: endx, y: endy), controlPoint1: CGPoint(x: x1, y: y1), controlPoint2: CGPoint(x: x2!, y: y2!))
                }
                break
            case "s":
                for j in 1...(i.count-1)/4
                {
                    let tx2 = endx + i[j*4-3].toCGFloat() * scale
                    let ty2 = endy + i[j*4-2].toCGFloat() * scale
                    x1 = endx * 2 - (x2 != nil ? x2! : tx2)
                    y1 = endy * 2 - (y2 != nil ? y2! : ty2)
                    x2 = tx2
                    y2 = ty2
                    endx += i[j*4-1].toCGFloat() * scale
                    endy += i[j*4].toCGFloat() * scale
                    linepath.addCurve(to: CGPoint(x: endx, y: endy), controlPoint1: CGPoint(x: x1, y: y1), controlPoint2: CGPoint(x: x2!, y: y2!))
                }
                break
            case "Q":
                for j in 1...(i.count-1)/4
                {
                    x1 = i[j*4-3].toCGFloat() * scale
                    y1 = i[j*4-2].toCGFloat() * scale
                    endx = i[j*4-1].toCGFloat() * scale
                    endy = i[j*4].toCGFloat() * scale
                    linepath.addQuadCurve(to: CGPoint(x: endx, y: endy), controlPoint: CGPoint(x: x1, y: y1))
                }
                x2 = nil
                y2 = nil
                break
            case "q":
                for j in 1...(i.count-1)/4
                {
                    x1 = endx + i[j*4-3].toCGFloat() * scale
                    y1 = endy + i[j*4-2].toCGFloat() * scale
                    endx += i[j*4-1].toCGFloat() * scale
                    endy += i[j*4].toCGFloat() * scale
                    linepath.addQuadCurve(to: CGPoint(x: endx, y: endy), controlPoint: CGPoint(x: x1, y: y1))
                }
                x2 = nil
                y2 = nil
                break
            case "T":
                for j in 1...(i.count-1)/4
                {
                    x1 = (i[j*4-3].toCGFloat() * scale + x1 - endx)
                    y1 = (i[j*4-2].toCGFloat() * scale + y1 - endy)
                    endx = i[j*4-1].toCGFloat() * scale
                    endy = i[j*4].toCGFloat() * scale
                    linepath.addQuadCurve(to: CGPoint(x: endx, y: endy), controlPoint: CGPoint(x: x1, y: y1))
                }
                x2 = nil
                y2 = nil
                break
            case "t":
                for j in 1...(i.count-1)/4
                {
                    x1 = (i[j*4-3].toCGFloat() * scale + x1 - endx)
                    y1 = (i[j*4-2].toCGFloat() * scale + y1 - endy)
                    endx += i[j*4-1].toCGFloat() * scale
                    endy += i[j*4].toCGFloat() * scale
                    linepath.addQuadCurve(to: CGPoint(x: endx, y: endy), controlPoint: CGPoint(x: x1, y: y1))
                }
                x2 = nil
                y2 = nil
                break
            case "A":
                let result = self.svgPathA(linepath: linepath, i: i, result: [x1, y1, endx, endy, scale])
                x1 = result[0]
                y1 = result[1]
                endx = result[2]
                endy = result[3]
                x2 = nil
                y2 = nil
                break
            case "a":
                let result = self.svgPathA(linepath: linepath, i: i, result: [x1, y1, endx, endy, scale], type: "a")
                x1 = result[0]
                y1 = result[1]
                endx = result[2]
                endy = result[3]
                x2 = nil
                y2 = nil
                break
            case "Z":
                //                self.path = linepath.cgPath
                break
            case "z":
                break
            default:
                endx = 0.0
                endy = 0.0
                break
            }
            
            //                        if x2 != nil && y2 != nil
            //                        {
            //                            print("x1:\(x1), y1:\(y1), x2:\(x2!), y2:\(y2!), x:\(endx / scale) y:\(endy / scale)")
            //                        }else
            //                        {
            //                            print("x1:\(x1), y1:\(y1), x:\(endx / scale) y:\(endy / scale)")
            //                        }
            
            count += 1
        }
        
        
        self.path = linepath.cgPath
    }
}
