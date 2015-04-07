//
//  weiboModelTests.swift
//  weiboModelTests
//
//  Created by iyouwp on 15/4/8.
//  Copyright (c) 2015年 iyouwp. All rights reserved.
//

import UIKit
import XCTest

class weiboModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // 懒加载测试用的 OAuthVC
    lazy var testOAuthVC: OAuthVC? = {
        let bundle = NSBundle(forClass: OAuthVC.self)
        println(bundle)
        let sb = UIStoryboard(name: "OAuth", bundle: bundle)
        return sb.instantiateInitialViewController() as? OAuthVC
        }()
}

// 测试 OAuth 单元
extension weiboModelTests {
    
    
    func testOAuth() {
        // 登陆界面，应该加载网页，返回值没有 code
        var url = NSURL(string: "https://api.weibo.com/oauth2/authorize?client_id=1476495812&redirect_uri=http://www.itheima.com")
        
        var result = testOAuthVC!.p_ifLoadWithCode(url!)
        XCTAssertTrue(result.load, "加载")
        XCTAssertNil(result.code, "没有code")
        
        // 点击注册按钮，不加载网页，没有 code
        url = NSURL(string: "http://weibo.cn/dpool/ttt/h5/reg.php?wm=4406&appsrc=2nrfRa&backURL=https%3A%2F%2Fapi.weibo.com%2F2%2Foauth2%2Fauthorize%3Fclient_id%3D1476495812%26response_type%3Dcode%26display%3Dmobile%26redirect_uri%3Dhttp%253A%252F%252Fwww.itheima.com%26from%3D%26with_cookie%3D")
        
        result = testOAuthVC!.p_ifLoadWithCode(url!)
        XCTAssertFalse(result.load, "没有加载")
        XCTAssertNil(result.code, "没有code")
        
        // 登录成功
        // 加载网页，没有 code
        url = NSURL(string: "https://api.weibo.com/oauth2/authorize")!
        result = testOAuthVC!.p_ifLoadWithCode(url!)
        XCTAssertTrue(result.load, "应该加载")
        XCTAssertNil(result.code, "不应该有code")
        
        // 取消授权
        // 不加载网页，没有 code
        url = NSURL(string: "http://www.itheima.com/?error_uri=%2Foauth2%2Fauthorize&error=access_denied&error_description=user%20denied%20your%20request.&error_code=21330")
        result = testOAuthVC!.p_ifLoadWithCode(url!)
        XCTAssertFalse(result.load, "不应该加载")
        XCTAssertNil(result.code, "不应该有code")
        
        // 换个账号
        // 不加载网页，没有 code
        url = NSURL(string: "http://login.sina.com.cn/sso/logout.php?entry=openapi&r=https%3A%2F%2Fapi.weibo.com%2Foauth2%2Fauthorize%3Fclient_id%3D1476495812%26redirect_uri%3Dhttp%3A%2F%2Fwww.itheima.com")
        result = testOAuthVC!.p_ifLoadWithCode(url!)
        XCTAssertFalse(result.load, "不应该加载")
        XCTAssertNil(result.code, "不应该有code")
        
        // 授权回调
        // 加载网页，有 code
        let demoCode = "644ed03793abf0085e112a5a58eb2f02"
        url = NSURL(string: "http://www.itheima.com/?code=\(demoCode)")
        result = testOAuthVC!.p_ifLoadWithCode(url!)
        XCTAssertFalse(result.load, "不应该加载")
        XCTAssert(result.code == demoCode, "code 不正确")
    }

    
}
