//
//  AccessToken.swift
//  Swift-微博
//
//  Created by iyouwp on 15/4/12.
//  Copyright (c) 2015年 iyouwp. All rights reserved.
//

import UIKit

class AccessToken: NSObject, NSCoding {
    
    var access_token : String?
    var remind_in : NSNumber?
    var expires_in: NSNumber?{
        didSet{
            expires_date = NSDate(timeIntervalSinceNow: expires_in!.doubleValue)
            println(expires_date)
            println(expires_in)
        }
    }
    var uid : NSNumber?
    var expires_date: NSDate?
 
    init(dict: NSDictionary) {
        super.init()
        self.setValuesForKeysWithDictionary(dict as [NSObject : AnyObject])
    }
    
    
    
    // MARK: 归档接档相关
    func saveAccessToken(){
        NSKeyedArchiver.archiveRootObject(self, toFile: AccessToken.accessTokenPath())
    }
    
    class func loadAccessToken() -> AccessToken?{
        return NSKeyedUnarchiver.unarchiveObjectWithFile(self.accessTokenPath()) as? AccessToken
    }
    
    class func accessTokenPath() -> String{
        var path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last as! String
        return path.stringByAppendingPathComponent("AccessToken.plist")
    }
    
    // 不指定 key 值，会默认使用属性名作为 key 值
    required init(coder aDecoder: NSCoder) {
        access_token =  aDecoder.decodeObject() as? String
//        remind_in = aDecoder.decodeObject() as? NSNumber
        expires_in = aDecoder.decodeObject() as? NSNumber
        expires_date = aDecoder.decodeObject() as? NSDate
        uid = aDecoder.decodeObject() as? NSNumber
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(access_token)
//        aCoder.encodeObject(remind_in)
        aCoder.encodeObject(expires_date)
        aCoder.encodeObject(expires_in)
        aCoder.encodeObject(uid)
    }
}
