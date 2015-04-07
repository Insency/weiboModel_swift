//
//  WPNetwork_swiftTests.swift
//  WPNetwork_swiftTests
//
//  Created by iyouwp on 15/4/7.
//  Copyright (c) 2015年 iyouwp. All rights reserved.
//

import UIKit
import XCTest

class simpleNetWorkTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    let network = WPNetwork_swift()
    let testHTTPHost = "http://httpbin.org"
    
    ///  测试 GET 请求
    func testGETRequestInfo(){
        var r = network.requestInfo(.GET, "", nil)
        println(r?.URL?.absoluteString)
        XCTAssert(r?.URL?.absoluteString == "", "传入空值返回错误")
        
        r = network.requestInfo(.GET, testHTTPHost, nil)
        println(r?.URL?.absoluteString)
        XCTAssert(r?.URL?.absoluteString == "http://httpbin.org", "没有参数列表错误")
        
        r = network.requestInfo(.GET, testHTTPHost, ["username":"1" ,"pwd":"2"])
        println(r?.URL?.absoluteString)
        XCTAssert(r?.URL?.absoluteString == "http://httpbin.org?pwd=2&username=1", "三个参数都传值有错误")
        
    }
    
    ///  测试 POST 请求
    func testPOSTRequestInfo(){
        var r = network.requestInfo(.POST, "", nil)
        println(r)
        XCTAssert(r?.URL?.absoluteString == nil, "传入空值返回错误")
        
        r = network.requestInfo(.POST, testHTTPHost, nil)
        println(r)
        XCTAssert(r?.URL?.absoluteString == nil, "没有参数列表错误")
        
        r = network.requestInfo(.POST, testHTTPHost, ["username":"1" ,"pwd":"2"])
        println(r)
        XCTAssert(r?.URL?.absoluteString == "http://httpbin.org", "三个参数都传值有错误")
        XCTAssert(r?.HTTPMethod == "POST", "请求类型错误")
        XCTAssert(r?.HTTPBody == "pwd=2&username=1".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), "请求体错误")
        
    }
    
    
    
    ///  测试参数字典的字符串拼接
    func testQueryString() {
        
        XCTAssertNil(network.queryString(nil), "传空值返回值错误")
        XCTAssert(network.queryString(["a":"1"]) == "a=1", "传入单个key值字典返回错误")
        XCTAssert(network.queryString(["a":"1", "b":"2"]) == "b=2&a=1", "传入多个key值字典返回值错误")
        println(network.queryString(["a":"1", "b":"我", "version":"ios 8.0"]))
        XCTAssert(network.queryString(["a":"1", "b":"我", "version":"ios 8.0"]) == "b=%E6%88%91&a=1&version=ios%208.0", "百分号转义错误")
    }
    
    // 测试坏请求访问
    func testBadRequest() {
        network.requestJSON(.GET, "", nil) { (result, error) -> () in
            println(error)
            XCTAssertNotNil(error, "坏网络请求失败")
        }
        
    }
    
    // 测试正常网络访问
    func testRequestJSON() {
        let expectation = expectationWithDescription(testHTTPHost)
        
        network.requestJSON(.GET, testHTTPHost, nil) { (result, error) -> () in
            println(result)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(15.0, handler: { (error) -> Void in
            
            XCTAssertNil(error)
        })
    }
    
    
}
