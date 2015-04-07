//
//  ViewController.swift
//  43-OAuth
//
//  Created by iyouwp on 15/4/5.
//  Copyright (c) 2015年 iyouwp. All rights reserved.
//

import UIKit

//import simpleNetWork

class OAuthVC: UIViewController {

    let WB_API_URL_String = "https://api.weibo.com"
    let WB_Redirect_URL_String = "http://www.itheima.com"
    
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        p_requestOAuth()
    }


    func p_requestOAuth() {
        let urlString = "\(WB_API_URL_String)/oauth2/authorize?client_id=1476495812&redirect_uri=http://www.itheima.com"
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string: urlString)!))
        
    }
}


extension OAuthVC:UIWebViewDelegate {
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        println(__FUNCTION__ + "\(request.URL)")
        let result = p_ifLoadWithCode(request.URL!)
        
        if !result.load {
            println("不加载")
//           let r = simpleNetwork()
        }
        
        if let code = result.code {
            println("code:\(code)")
            
            p_sendRequestWithCode(code)
        }
        // TODO:ffd
        // MARK: - df
        
        return result.load
    }

    /// 根据 URL 判断是否继续加载页面
    /// 返回：是否加载，如果有 code，同时返回 code，否则返回 nil
    func p_ifLoadWithCode(url: NSURL) -> (load: Bool, code: String?) {
        
        // 1. 将url转换成字符串
        let urlString = url.absoluteString!
        
        // 2. 如果不是微博的 api 地址，都不加载
        if !urlString.hasPrefix(WB_API_URL_String) {
            // 3. 如果是回调地址，需要判断 code
            if urlString.hasPrefix(WB_Redirect_URL_String) {
                if let query = url.query {
                    let codestr: NSString = "code="
                    
                    if query.hasPrefix(codestr as String) {
                        var q = query as NSString!
                        return (false, q.substringFromIndex(codestr.length))
                    }
                }
            }
            
            return (false, nil)
        }
        
        return (true, nil)
    }

    
    func p_sendRequestWithCode(code: String) {
        let urlString = "https://api.weibo.com/oauth2/access_token"
        let url :NSURL? = NSURL(string: urlString)
        var req = NSMutableURLRequest(URL: url!)
        
        req.HTTPMethod = "POST"
        var bodyStr = "client_id=1476495812&client_secret=ccb851ded8dd142182c7820c014000ae&grant_type=authorization_code&code=\(code)&redirect_uri=http://www.itheima.com"
        
        req.HTTPBody = bodyStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        NSURLSession.sharedSession().dataTaskWithRequest(req as NSURLRequest, completionHandler: { (data, _, _) -> Void in
            
            let dict: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil)
            
//            println(dict)
//            SVProgressHUD.show()
            
//            Optional({
//                "access_token" = "2.00EnziDGaAOvbB1dc04be270kKIr_B";
//                "expires_in" = 157679999;
//                "remind_in" = 157679999;
//                uid = 5551849958;
//            })
            
        }).resume()
        
    
    }

}
