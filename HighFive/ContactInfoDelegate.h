//
//  ContactInfoDelegate.h
//  HighFive
//
//  Created by Trevor Grayson on 9/10/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactInfoDelegate : UIAlertView <UIAlertViewDelegate>

+(ContactInfoDelegate*) checkForContactInfo;
@end
