//
//  SwiftJSONModel.swift
//  
//
//  Created by 刘凡 on 15/2/28.
//
//

import Foundation

///  字典转模型协议
@objc protocol JSONModelProtocol {
    ///  自定义类映射字典
    ///
    ///  :returns: 映射字典
    static func customClassMapping() -> [String: String]
}

class JSONModelManager {
    
    /// 单例实例变量
    private static let sharedInstance = JSONModelManager()
    /// 全局访问变量
    class var sharedManager: JSONModelManager {
        return sharedInstance
    }
    /// 模型类的命名空间名称
    var classNamespaceName: String?

    ///  字典转模型
    ///
    ///  :param: dict 数据字典
    ///  :param: cls  模型类
    ///
    ///  :returns: 模型类对象
    func objectWithDictionary(dict: NSDictionary, cls: AnyClass) -> AnyObject {
        
        // 1. 取出模型信息
        let info = fullModelInfo(cls)
            
        // 2. 实例化对象
        let obj: AnyObject = cls.alloc()

        // 3. 遍历模型信息字典
        for (k, v) in info {
            if let value: AnyObject = dict[k] {
                if v.isEmpty {
                    if !(value === NSNull()) {
                        obj.setValue(value, forKey: k)
                    }
                } else {
                    let type = NSStringFromClass(value.classForCoder)
                    if type == "NSDictionary"  {
                        let subObj: AnyObject = objectWithDictionary(value as! NSDictionary, cls: NSClassFromString("\(classNamespaceName!).\(v)"))
                        obj.setValue(subObj, forKey: k)
                    } else if type == "NSArray" {
                        let subObj: AnyObject = objectsWithArray(value as! NSArray, cls: NSClassFromString("\(classNamespaceName!).\(v)"))
                        obj.setValue(subObj, forKey: k)
                    }
                }
            }
        }

        return obj
    }
    
    ///  使用数组实例化模型对象数组
    ///
    ///  :param: array 数组
    ///  :param: cls   模型类
    ///
    ///  :returns: 实例化的模型数组
    func objectsWithArray(array: NSArray, cls: AnyClass!) -> NSArray {
        var list = [AnyObject]()
        
        // TODO: - 目前默认数组中存储的就是字典
        for dict in array {
            if "\(dict.classForCoder)" == "NSDictionary" {
                list.append(objectWithDictionary(dict as! NSDictionary, cls: cls))
            }
        }
        
        return list
    }
    
    ///  模型转字典
    ///
    ///  :param: obj 模型对象
    ///
    ///  :returns: 字典信息
    func objectDictionary(obj: AnyObject) -> [String: AnyObject] {
        // 1. 取出模型字典
        let info = fullModelInfo(obj.classForCoder)
        
        var dict = [String: AnyObject]()
        for (k, v) in info {
            let value: AnyObject? = obj.valueForKey(k)
            
            if v.isEmpty && value != nil {
                dict[k] = obj.valueForKey(k)
            } else if value != nil {
                let type = NSStringFromClass(value?.classForCoder)
                if type == "NSArray" || type == "NSMutableArray" {
                    dict[k] = objectArray(value! as! [AnyObject])
                } else {
                    dict[k] = objectDictionary(value!)
                }
            }
        }
        
        return dict
    }
    
    ///  返回对象数组的字典信息
    ///
    ///  :param: objs 对象数组
    ///
    ///  :returns: 对象数组的字典信息
    func objectArray(objs: [AnyObject]) -> [AnyObject] {
        
        var array = [AnyObject]()
        
        // TODO: 目前默认数组中存储的就是字典
        for obj in objs {
            array.append(objectDictionary(obj))
        }
        
        return array
    }
    
    ///  提取完整模型信息
    ///
    ///  :param: cls 模型类
    ///
    ///  :returns: 模型类信息字典
    func fullModelInfo(cls: AnyClass) -> [String: String] {
        // 如果缓冲池中已经存在直接返回
        if let cache = modelCache["\(cls)"] {
            return cache
        }
        
        var currentCls: AnyClass = cls
        var infoDict = [String: String]()
        while let parent: AnyClass = currentCls.superclass() {
            // 追加模型信息
            infoDict.merge(modelInfo(currentCls))
            
            currentCls = parent
        }
        
        // 将模型信息添加到缓冲池
        modelCache["\(cls)"] = infoDict
        
        return infoDict
    }
    
    ///  提取模型类信息字典
    ///
    ///  :param: cls 模型类
    ///
    ///  :returns: 模型类信息字典
    func modelInfo(cls: AnyClass) -> [String: String] {
        // 如果缓冲池中已经存在直接返回
        if let cache = modelCache["\(cls)"] {
            return cache
        }
        
        // 提取类自定义属性字典
        var mappingDict: [NSString: NSString]?
        if cls.respondsToSelector("customClassMapping") {
            mappingDict = cls.customClassMapping()
        }
        
        var count:UInt32 = 0
        let properties = class_copyPropertyList(cls, &count)
        
        var infoDict = [String: String]()
        for i in 0..<count {
            let pty = properties[Int(i)]

            let cname = property_getName(pty)
            var name = String.fromCString(cname)!
            
            let type = mappingDict?[name] ?? ""
            infoDict[name] = type as String
        }
        free(properties)
        
        // 将模型信息添加到缓冲池
        modelCache["\(cls)"] = infoDict
        
        return infoDict
    }
    
    ///  将二进制数据反序列化为 NSDictionary 或者 NSArray
    ///
    ///  :param: data json 数据
    ///
    ///  :returns: 如果数据格式正确，返回 NSDictionary 或者 NSArray，否则返回 nil
    class func json(data: NSData) -> AnyObject? {
        return NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: nil)
    }
    
    /// 模型信息缓冲池
    var modelCache = [String: [String: String]]()
}

extension Dictionary {
    mutating func merge<K, V>(dict: [K: V]) {
        for (k, v) in dict {
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}
