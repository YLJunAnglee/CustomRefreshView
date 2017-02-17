//
//  ViewController.swift
//  LJCustomerRefreshView
//
//  Created by 连俊杨 on 17/2/17.
//  Copyright © 2017年 yang_ljun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    lazy var refreshControl: LJRefreshControl = LJRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addSubview(refreshControl)
        
        tableView.contentInset = UIEdgeInsets(top: 0,
                                              left: 0,
                                              bottom: 0,
                                              right: 0)
        
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        
        loadData()
    }
    
    @objc func loadData() {
        print("开始刷新")
        
        refreshControl.beginRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            print("结束刷新")
            
            self.refreshControl.endRefreshing()
        }
    }
}

