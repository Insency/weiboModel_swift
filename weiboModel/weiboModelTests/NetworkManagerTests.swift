//
//  NetworkManagerTests.swift
//  weiboModel
//
//  Created by iyouwp on 15/4/8.
//  Copyright (c) 2015年 iyouwp. All rights reserved.
//

import UIKit
import XCTest

class NetworkManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSharedNetworkManager() {
        let manager1 = NetworkManager.sharedNetworkManager
        let manager2 = NetworkManager.sharedNetworkManager
        
        XCTAssert(manager1 === manager2, "单例对象不一致")
        
    }
    

}
