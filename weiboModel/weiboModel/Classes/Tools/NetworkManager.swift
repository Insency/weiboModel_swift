//
//  NetworkManager.swift
//  weiboModel
//
//  Created by iyouwp on 15/4/8.
//  Copyright (c) 2015年 iyouwp. All rights reserved.
//

import Foundation

import WPNetwork


class NetworkManager  {
    
    
    private static let instance = WPNetwork_swift()
    
    /// 网络任务管理者 单例
    class var sharedNetworkManager: WPNetwork_swift {
        return instance
    }
    
    // TODO: 这个类型在 WPNetwork 中已经定义
    typealias Completion = (result: AnyObject?, error: NSError?) -> ()
    
    func requestJSON(method: HTTPMethod, _ urlString: String, _ parameter: [String: String]?,completion: Completion) -> Void {
        network.requestJSON(method, urlString, parameter, completion: completion)
    }
    private let network = WPNetwork_swift()
}
