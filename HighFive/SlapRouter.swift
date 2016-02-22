//
//  SlapRouter.swift
//  HighFive
//
//  Created by Trevor Grayson on 2/16/16.
//  Copyright © 2016 Ipsum LLC. All rights reserved.
//

import UIKit

public class SlapRouter: NSObject {
    
    @objc public static let domain = "ifive.club"
    //@objc public static let domain = "192.168.1.6:8080"
    
    @objc public class func slap(from: String, to: String, ferocity: Double) -> String {
        let fString = String(format:"%4.2f", ferocity)
        
        return url(
            [action("slap"), from, to, fString].joinWithSeparator("/")
        )
    }
    
    @objc public class func invite(idString: String) -> String {
        return url(
            [action("invite"), idString].joinWithSeparator("/")
        )
    }
    
    @objc public class func action(name: String) -> String {
        return arrayToUrl([name])
    }
    
    @objc public class func arrayToUrl(dirs: [String]) -> String {
        return url(
            (["http:/", domain] + dirs).joinWithSeparator("/")
        )
    }
    
    @objc public class func baseUrl() -> NSURL {
        return NSURL(string: "http://" + domain)!
    }
    
    class func url(path: String) -> String {
        return path
    }

}
