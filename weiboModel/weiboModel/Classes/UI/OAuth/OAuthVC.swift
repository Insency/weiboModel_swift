//
//  ViewController.swift
//  43-OAuth
//
//  Created by iyouwp on 15/4/5.
//  Copyright (c) 2015年 iyouwp. All rights reserved.
//

import UIKit


class OAuthVC: UIViewController {

    let WB_API_URL_String       = "https://api.weibo.com"
    let WB_Redirect_URL_String  = "http://www.itheima.com"
    let WB_Access_Token_String  = "https://api.weibo.com/oauth2/access_token"
    let WB_Client_Id            = "1476495812"
    let WB_Client_Secret        = "ccb851ded8dd142182c7820c014000ae"
    let WB_Grant_Type           = "authorization_code"


    
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        p_requestOAuth()
    }


    func p_requestOAuth() {
        let urlString = "\(WB_API_URL_String)/oauth2/authorize?client_id=\(WB_Client_Id)&redirect_uri=\(WB_Redirect_URL_String)"
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string: urlString)!))
        
    }
}


extension OAuthVC:UIWebViewDelegate {
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        println(__FUNCTION__ + "\(request.URL)")
        let result = p_ifLoadWithCode(request.URL!)
        
        if !result.load {
            println("不加载")
            if result.ifReload {
                SVProgressHUD.showInfoWithStatus("你真的残忍的拒绝吗？", maskType: SVProgressHUDMaskType.Gradient)
                p_requestOAuth()
            }
        }
        
        if let code = result.code {
            println("code:\(code)")
            
            p_sendRequestWithCode(code)
        }
        
        return result.load
    }

    /// 根据 URL 判断是否继续加载页面
    /// 返回：是否加载，如果有 code，同时返回 code，否则返回 nil
    func p_ifLoadWithCode(url: NSURL) -> (load: Bool, code: String?, ifReload:Bool) {
        
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
                        return (false, q.substringFromIndex(codestr.length), false)
                    }else{
                        return(false, nil, true)
                    }
                }
            }
            
            return (false, nil, false)
        }
        
        return (true, nil, false)
    }

    
    func p_sendRequestWithCode(code: String) {
        let urlString = WB_Access_Token_String
        
        let para = ["client_id":"\(WB_Client_Id)",
        "client_secret":"\(WB_Client_Secret)",
        "grant_type":"\(WB_Grant_Type)",
        "code":code,
        "redirect_uri":"\(WB_Redirect_URL_String)"]
        
        NetworkManager.sharedNetworkManager.requestJSON(.POST, urlString, para) { (result, error) -> () in
            println(result)
            
        }
    }

}
