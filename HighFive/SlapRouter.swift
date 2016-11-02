//
//  SlapRouter.swift
//  HighFive
//
//  Created by Trevor Grayson on 2/16/16.
//  Copyright © 2016 Ipsum LLC. All rights reserved.
//

import UIKit

open class SlapRouter: NSObject {
    
    @objc public static let domain = "ifive.club"
    //@objc open static let domain = "127.0.0.1:8080"
    
    @objc open class func slap(_ from: String, to: String, ferocity: Double) -> String {
        let fString = String(format:"%4.2f", ferocity)
        
        return url(
            [action("slap"), from, to, fString].joined(separator: "/")
        )
    }
    
    @objc open class func invite(_ idString: String) -> String {
        return url(
            [action("invite"), idString].joined(separator: "/")
        )
    }
    
    @objc open class func action(_ name: String) -> String {
        return arrayToUrl([name])
    }
    
    @objc open class func arrayToUrl(_ dirs: [String]) -> String {
        return url(
            (["http:/", domain] + dirs).joined(separator: "/")
        )
    }
    
    @objc open class func baseUrl() -> URL {
        return URL(string: "http://" + domain)!
    }
    
    class func url(_ path: String) -> String {
        return path
    }

}
