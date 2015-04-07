//
//  simpleNetwork.swift
//  simpleNetWork
//
//  Created by iyouwp on 15/4/7.
//  Copyright (c) 2015年 iyouwp. All rights reserved.
//

import Foundation

// 网络访问方法枚举
public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
}


public class WPNetwork_swift {
    
    public init(){}
    
    public typealias Completion = (result: AnyObject?, error: NSError?) -> ()
    static let errorDomain = "simpleNetwork"
    
    // 全局网络会话
    lazy var session = {
        return NSURLSession.sharedSession()
    }()
    
    
    
    public func requestJSON(method: HTTPMethod, _ urlString: String, _ parameter: [String: String]?,completion: Completion) {
        
        if let request = requestInfo(method, urlString, parameter) {
            session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                if (error != nil && data == nil) {
                    completion(result: nil, error: error)
                }
                
                let json: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil)
                
                if json == nil {
                    let error = NSError(domain: WPNetwork_swift.errorDomain, code: -1, userInfo: ["error":"JSON序列化失败"])
                    completion(result: nil, error: error)
                    return
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(result: json, error: nil)
                })
                
            }).resume()
            
        
        }
        
        let error = NSError(domain: WPNetwork_swift.errorDomain, code: -1 , userInfo: ["error":"未能创建网络请求"])
        completion(result: nil, error: error)
    }
    
    
    
    
    ///  返回网络请求
    ///
    ///  :param: method    请求方式
    ///  :param: urlString URL 字符串
    ///  :param: parameter 参数字典
    ///
    ///  :returns: 网络请求
    func requestInfo(method: HTTPMethod, _ urlString: String, _ parameter: [String: String]?) -> NSURLRequest? {
        if urlString.isEmpty {
            return nil
        }
    
        var request: NSMutableURLRequest?
        var urlStr = urlString
        if method == .GET {
            if let para = queryString(parameter) {
                urlStr = urlString + "?" + para
            }
            let url = NSURL(string: urlStr)
            request = NSMutableURLRequest(URL: url!)
        } else if method == .POST {
        if let para = queryString(parameter) {
                request = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
                request!.HTTPMethod = method.rawValue
                request!.HTTPBody = para.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            }
        }
        return request
    }
    
    
    
    ///  通过请求的参数字典，返回请求参数的字符串
    ///
    ///  :param: queryStr 请求的参数字典
    ///
    ///  :returns: 返回请求参数的字符串
    func queryString(queryStr: [String: String]?) -> String? {
        if queryStr == nil {
            return nil
        }
        
        var array = [String]()
        for (k, v) in queryStr! {
            let str = k + "=" + v.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            array.append(str)
        }
        return join("&", array)
    }
    
}
