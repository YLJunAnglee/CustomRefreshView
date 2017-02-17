//
//  LJRefreshControl.swift
//  WeiBo
//
//  Created by 连俊杨 on 16/11/27.
//  Copyright © 2016年 yang_ljun. All rights reserved.
//

import UIKit

// 刷新状态切换的临界点
let refreshContentOffset: CGFloat = 120

/*
    - Normal:       普通状态，什么都不做
    - Pulling:      超过临界点，如果放手，开始刷新
    - WillRefresh:  超过临界点，并且放手
 **/
enum LJRefreshState {
    case Normal
    case Pulling
    case WillRefresh
}

// 刷新控件 - 负责刷新相关的逻辑处理
class LJRefreshControl: UIControl {
    
    // MARK - 添加属性
    // 刷新控件的父视图
    private weak var scrollView: UIScrollView?
    
    lazy var refreshView: LJRefreshView = LJRefreshView.refreshView()
    
    // 添加构造函数
    init() {
        super.init(frame: CGRect())
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    // willMove方法，父视图的addSubview 会调用
    // 当添加到父视图的时候，newSuperview是父视图
    // 当父视图被移除，newSuperview 是nil
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        // 判断父视图的类型
        guard let sv = newSuperview as? UIScrollView else {
            return
        }
        
        // 记录父视图
        scrollView = sv
        
        // KVO 监听父视图的 contentOffset
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [], context: nil)
        
    }
    // 移除观察者
    // 提示：所有的下拉刷新第三方框架都是监听父视图的contentOffset
    // 所有的框架的KVO监听思路 都是这个思路!
    override func removeFromSuperview() {
        // 调用父类方法之前，父类存在
        // 所以要在之前移除观察者
        superview?.removeObserver(self, forKeyPath: "contentOffset")
        
        super.removeFromSuperview()
        
        // 调用父类方法之后，父类不存在
    }
    
    // KVO的方法回调
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // contentOffset 的 y值 跟 contentInset的 top有关
        guard let sv = scrollView else {
            return
        }
        // 把初始高度设置为0，更好计算
        let height = -(sv.contentOffset.y + sv.contentInset.top)
        
        // 如果是向上推动就不做变化
        if height < 0 {
            return
        }
        
       
        // 可以根据高度设置刷新控件的frame
        self.frame = CGRect(x: 0,
                            y: -height,
                            width: sv.bounds.width,
                            height: height)
        
        // 传递父视图高度
        // 如果正在刷新，就不传递高度，其他状态传递
        if refreshView.refreshState != .WillRefresh {
            refreshView.parentViewHeight = height
        }
        
        
        // 判断临界点 - 只需要判断一次
        if sv.isDragging {  // 是拖拽状态
            
            if (height > refreshContentOffset) && (refreshView.refreshState == .Normal) {
                print("放手刷新")
                refreshView.refreshState = .Pulling
            }else if (height <= refreshContentOffset) && (refreshView.refreshState == .Pulling){
                print("在使点劲")
                refreshView.refreshState = .Normal
            }
            
        }else{
            // 放手 - 判断是否超过临界点
            if refreshView.refreshState == .Pulling {
                print("准备开始刷新")
/*************
                 // 这里面改变状态之后，要想继续上面的判断，就需要在刷新完成之后，把状态修改为Normal
                 refreshView.refreshState = .WillRefresh
                 
                 // 让整个刷新视图显示出来
                 // 解决方法：修改表格的contentInset
                 var inset = sv.contentInset
                 inset.top += refreshContentOffset
                 
                 sv.contentInset = inset
*******************/
                beginRefreshing()
                
                // 发送加载数据的消息
                sendActions(for: .valueChanged)
            }
        }
    }
    
    
    // 开始刷新
    func beginRefreshing() {
        print("开始刷新")
        
        // 守护父视图
        guard let sv = scrollView else {
            return
        }
        if refreshView.refreshState == .WillRefresh {
            return
        }
        
        // 设置刷新视图的状态
        refreshView.refreshState = .WillRefresh
        
        // 调整表格的间距
        var inset = sv.contentInset
        inset.top += refreshContentOffset
        
        sv.contentInset = inset
        
        // 设置刷新视图的父视图高度
        refreshView.parentViewHeight = refreshContentOffset
    }
    
    
    // 结束刷新
    func endRefreshing() {
        print("结束刷新")
        // 守护父视图
        guard let sv = scrollView else {
            return
        }
        
        // 这里要判断是否是刷新状态，如果不是，下面的操作就不需要
        if refreshView.refreshState != .WillRefresh {
            return
        }
        
        // 恢复刷新状态
        refreshView.refreshState = .Normal
        // 恢复表格位置
        var inset = sv.contentInset
        inset.top -= refreshContentOffset
        sv.contentInset = inset
    }
}

extension LJRefreshControl {
    
    func setupUI() {
        
        backgroundColor = superview?.backgroundColor
        
        // 添加刷新视图 - 从xib加载出来，默认是 xib 中指定的宽高
        addSubview(refreshView)
        
        // 自动布局 - 设置 xib 控件的自动布局，需要指定宽高约束
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerX,
                                         multiplier: 1.0,
                                         constant: 0))
        
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .bottom,
                                         multiplier: 1.0,
                                         constant: 0))
        
        // 添加宽高
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: refreshView.bounds.width))
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .height,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: refreshView.bounds.height))
    }
}



