//
//  TabbarController.swift
//  xframe
//
//  Created by XiaoJiao Chen on 2017/3/15.
//  Copyright © 2017年 XiaoJiao Chen. All rights reserved.
//

import UIKit

public class TabbarController: UITabBarController {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //使用资源创建
    public func addChildViewController(controller: UIViewController, title:String, named:String, named_select:String? = nil, height:CGFloat? = 30){
        let img = UIImage(named: named)!
        let img_selected = named_select != nil ? UIImage(named: named_select!) : UIImage(named: "\(named)_selected")!
        self.addChildViewController(controller: controller, title: title, image: [img, img_selected!], height: height!)
    }
    
    //使用图片集创建
    public func addChildViewController(controller: UIViewController, title:String, image:[UIImage], height:CGFloat? = 30){
        
        var imgarr = image
        
        if (imgarr.count) > 0
        {
            imgarr[0] = (imgarr[0].scaleImage(scaleSize: height! / (imgarr[0].size.height)))
            controller.tabBarItem.image = imgarr[0].withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }
        
        if (imgarr.count) > 1
        {
            imgarr[1] = (imgarr[1].scaleImage(scaleSize: height! / (imgarr[1].size.height)))
            controller.tabBarItem.selectedImage = imgarr[1].withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        }
        
        controller.tabBarItem.title = title
        
        self.addChild(controller)
    }
    
    override public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //        print(item.title!)
        // 使用枚举遍历,判断选中的tabBarItem等于数组中的第几个
        for (k,v) in (tabBar.items?.enumerated())! {
            if v == item {
                self.animationWithIndex(index: k)
                return
            }
        }
    }
    
    //pushvc
    public func pushViewController(vc: UIViewController, animated: Bool)
    {
        self.navigationController?.pushViewController(vc, animated: animated)
    }
    
    //popvc
    public func popViewController()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //presentVC
    public func presentController(vc: UIViewController, animated: Bool)
    {
        self.present(vc, animated: animated, completion: nil)
    }
    
    //dismissVC
    public func dismissController()
    {
        self.dismiss(animated: true, completion: nil)

    }
    
    
    private func animationWithIndex(index:Int){
        // 不知为何,无法设置数组类型为UITabBarButton??????所以设置成了Any
        var tabbarbuttonArray:[Any] = [Any]()
        
        for tabBarBtn in self.tabBar.subviews {
            if tabBarBtn.isKind(of: NSClassFromString("UITabBarButton")!) {
                tabbarbuttonArray.append(tabBarBtn)
            }
        }
        
        // 给tabBarButton添加动画效果
        let tabBarLayer = (tabbarbuttonArray[index] as AnyObject).layer
        tabBarLayer?.animate(type: "transform.scale", form: 0, to: 1, duration: 0.08, delegate: nil, timing: CAMediaTimingFunctionName.easeInEaseOut)
    }
}
