//
//  LJMeituanRefreshView.swift
//  自定义刷新控件
//
//  Created by 连俊杨 on 16/11/28.
//  Copyright © 2016年 yang_ljun. All rights reserved.
//

import UIKit

class LJMeituanRefreshView: LJRefreshView {

    @IBOutlet weak var buildingIconView: UIImageView!
    
    @IBOutlet weak var earthIconView: UIImageView!

    @IBOutlet weak var kangarooIconView: UIImageView!
    
    // 父视图高度
    override var parentViewHeight: CGFloat {
        didSet {
//            print("父视图高度\(parentViewHeight)")
            
            if parentViewHeight < 19 {// 如果向下拉取太小，袋鼠没有出现，所以不用做处理
                return
            }
            /*
                比例：高度差 / 最大高度差
                19  == 1 (想让在19的时候为最小，设置为0.3) -> 0.3
                126 == 0 (想让在126的时候为最大，即1) -> 1
             **/
            var scale: CGFloat
            if parentViewHeight > 120 {
                scale = 1
            }else{
                scale = 1 - (120 - parentViewHeight) / (120 - 19)
            }
            
            kangarooIconView.transform = CGAffineTransform(scaleX: scale, y: scale)
            
        }
    }
    
    override func awakeFromNib() {
        // 1,房子
        let bImage1 = #imageLiteral(resourceName: "icon_building_loading_1")
        let bImage2 = #imageLiteral(resourceName: "icon_building_loading_2")
        
        // 变换图片
        buildingIconView.image = UIImage.animatedImage(with: [bImage1, bImage2], duration: 0.5)
        
        // 2,地球转
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        
        anim.toValue = -2 * M_PI
        anim.repeatCount = MAXFLOAT
        anim.duration = 3
        anim.isRemovedOnCompletion = false
        
        earthIconView.layer.add(anim, forKey: nil)
        
        // 把视图层次放到最前面
        self.bringSubview(toFront: kangarooIconView)
        
        // 3,袋鼠
        let kImage1 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_1")
        let kImage2 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_2")
        
        // 变换图片
        kangarooIconView.image = UIImage.animatedImage(with: [kImage1, kImage2], duration: 0.5)

        // 想让袋鼠由小变大，底部位置不变（需要设置锚点）
        kangarooIconView.layer.anchorPoint = CGPoint(x: 0.5,
                                                     y: 1)
        // 必须设置frame或center
        let x = self.bounds.width * 0.5
        let y = self.bounds.height - 19
        kangarooIconView.center = CGPoint(x: x,
                                          y: y)
        
        // 这个时候就可以改变袋鼠的大小
//        kangarooIconView.transform = CGAffineTransform(scaleX: 1, y: 1)
        
    }
    
}
