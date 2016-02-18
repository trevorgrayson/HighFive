//
//  SlapRouter.swift
//  HighFive
//
//  Created by Trevor Grayson on 2/16/16.
//  Copyright © 2016 Ipsum LLC. All rights reserved.
//

import UIKit

public class SlapRouter: NSObject {
    
    static let domain = "192.168.1.6:8080"
    
    @objc public class func slap(from: String, to: String, ferocity: Double) -> NSURL {
        let fString = String(format:"%4.2f", ferocity)
        
        return url(
            [action("slap").absoluteString, from, to, fString].joinWithSeparator("/")
        )
    }
    
    @objc public class func invite(idString: String) -> NSURL {
        return url(
            [action("invite").absoluteString, idString].joinWithSeparator("/")
        )
    }
    
    @objc public class func action(name: String) -> NSURL {
        return arrayToUrl([name])
    }
    
    @objc public class func arrayToUrl(dirs: [String]) -> NSURL {
        return url(
            (["http://", domain] + dirs).joinWithSeparator("/")
        )
    }
    
    class func url(path: String) -> NSURL {
        return NSURL( string: path )!
    }

}
