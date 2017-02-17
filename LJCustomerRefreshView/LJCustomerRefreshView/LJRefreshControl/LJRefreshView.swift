//
//  LJRefreshView.swift
//  自定义刷新控件
//
//  Created by 连俊杨 on 16/11/28.
//  Copyright © 2016年 yang_ljun. All rights reserved.
//

import UIKit

// 刷新视图 - 负责刷新相关的UI显示和动画
class LJRefreshView: UIView {
    
    // 刷新状态
    /*
        iOS 系统中 UIView 封装的旋转动画
      - 默认是顺时针旋转
      - 就近原则
      - 要想实现同方向旋转，需要调整一个非常小的数字（近）
      - 如果想实现 360度 旋转，需要核心动画 CABaseAnimation
     ***/
    var refreshState: LJRefreshState = .Normal {
        didSet {
            switch refreshState {
            case .Normal:
                // 恢复视图
                tipIcon?.isHidden = false
                indicator?.stopAnimating()
                
                tipLabel?.text = "继续使劲拉..."
                
                // 恢复旋转箭头  这种是 尾随闭包
                UIView.animate(withDuration: 0.25){
                    self.tipIcon?.transform = CGAffineTransform.identity
                }
            case .Pulling:
                tipLabel?.text = "放手就刷新..."
                
                // 旋转箭头视图
                UIView.animate(withDuration: 0.25, animations: {
                    self.tipIcon?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI-0.001))
                })
            case .WillRefresh:
                tipLabel?.text = "正在刷新中..."
                
                // 隐藏提示图标
                tipIcon?.isHidden = true
                
                // 显示菊花
                indicator?.startAnimating()
            }
        }
    }
    
    // 父视图的高度
    var parentViewHeight: CGFloat = 0
    
    // 提示器
    @IBOutlet weak var indicator: UIActivityIndicatorView?
    // 提示图像
    @IBOutlet weak var tipIcon: UIImageView?
    // 提示标签
    @IBOutlet weak var tipLabel: UILabel?
    
    // 类方法(class) 返回nib的本类
    class func refreshView() -> LJRefreshView {
    
        let nib = UINib(nibName: "LJMeituanRefreshView", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! LJRefreshView
    }
    
}
